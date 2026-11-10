#!/usr/bin/env python3
"""Consolida a exportação do painel UFMS 87+ (um JSON por documento) em um único
pacote e confere a integridade.

Entrada: pasta com uma subpasta por coleção e um arquivo <id>.json por documento.
Saída:   <saida>/ufms87-export.json  (todas as coleções, id incluído em cada documento)
         <saida>/manifesto.json      (contagens, tamanho e SHA-256 por coleção)

Uso: python3 tools/consolidar_exportacao.py <pasta_exportacao> <pasta_saida>

Só lê a pasta de entrada. Retorna código 1 se alguma verificação falhar.
Os dados exportados são pessoais: não devem ser versionados em repositório público.
"""
import hashlib
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

COLECOES = [
    "provas", "blocos", "questoes", "textos", "tentativas", "erros", "revisoes",
    "assuntos", "registros", "cartoes", "decks", "plano", "licoes", "progresso", "tempo",
]

# Baralhos podem apontar para lições ainda não escritas: vira aviso, não erro.
AVISOS = [("decks", "licao", "licoes")]

# (coleção, campo, coleção de destino): toda referência preenchida deve existir.
REFERENCIAS = [
    ("questoes", "blocoId", "blocos"),
    ("questoes", "textoId", "textos"),
    ("questoes", "provaId", "provas"),
    ("blocos", "licaoId", "licoes"),
    ("tentativas", "blocoId", "blocos"),
    ("erros", "qid", "questoes"),
    ("erros", "tentativaId", "tentativas"),
    ("revisoes", "qid", "questoes"),
    ("cartoes", "deck", "decks"),
    ("licoes", "assuntoId", "assuntos"),
    ("progresso", "__id__", "licoes"),
]


def carregar(pasta: Path) -> dict:
    dados = {}
    for col in COLECOES:
        docs = []
        for arq in sorted((pasta / col).glob("*.json")):
            doc = json.loads(arq.read_text(encoding="utf-8"))
            docs.append({"id": arq.stem, **doc})
        dados[col] = docs
    return dados


def verificar(dados: dict) -> tuple:
    problemas, avisos = [], []
    ids = {col: {d["id"] for d in docs} for col, docs in dados.items()}
    for col, campo, destino in AVISOS:
        for d in dados[col]:
            if d.get(campo) and d[campo] not in ids[destino]:
                avisos.append(f"{col}/{d['id']}: {campo}={d[campo]!r} ainda não existe em {destino}")
    for col in COLECOES:
        if not dados[col]:
            problemas.append(f"coleção vazia ou ausente: {col}")
    for col, campo, destino in REFERENCIAS:
        for d in dados[col]:
            valor = d["id"] if campo == "__id__" else d.get(campo)
            if valor and valor not in ids[destino]:
                problemas.append(f"{col}/{d['id']}: {campo}={valor!r} não existe em {destino}")
    for t in dados["tentativas"]:
        for item in t.get("itens", []):
            if item.get("qid") not in ids["questoes"]:
                problemas.append(f"tentativas/{t['id']}: item {item.get('qid')!r} não existe em questoes")
    for a in dados["assuntos"]:
        for dep in a.get("depende", []):
            if dep not in ids["assuntos"]:
                problemas.append(f"assuntos/{a['id']}: depende de {dep!r}, que não existe")
    return problemas, avisos


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__)
        return 2
    entrada, saida = Path(sys.argv[1]), Path(sys.argv[2])
    saida.mkdir(parents=True, exist_ok=True)
    dados = carregar(entrada)

    manifesto = {"geradoEm": datetime.now(timezone.utc).isoformat(timespec="seconds"), "colecoes": {}}
    for col, docs in dados.items():
        bruto = json.dumps(docs, ensure_ascii=False, sort_keys=True).encode("utf-8")
        manifesto["colecoes"][col] = {
            "documentos": len(docs),
            "bytes": len(bruto),
            "sha256": hashlib.sha256(bruto).hexdigest(),
        }
    manifesto["total"] = sum(c["documentos"] for c in manifesto["colecoes"].values())
    manifesto["questoesEmLicoes"] = sum(
        1 for l in dados["licoes"] for s in l.get("secoes", []) if s.get("tipo") == "questao"
    )
    problemas, avisos = verificar(dados)
    manifesto["problemas"] = problemas
    manifesto["avisos"] = avisos

    (saida / "ufms87-export.json").write_text(
        json.dumps(dados, ensure_ascii=False, indent=1, sort_keys=True), encoding="utf-8"
    )
    (saida / "manifesto.json").write_text(
        json.dumps(manifesto, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    for col, info in manifesto["colecoes"].items():
        print(f"{col:<11} {info['documentos']:>4}")
    print(f"{'total':<11} {manifesto['total']:>4}")
    print(f"questões dentro de lições: {manifesto['questoesEmLicoes']}")
    for a in avisos:
        print("AVISO:", a)
    for p in problemas:
        print("PROBLEMA:", p)
    print("integridade:", "falhou" if problemas else "ok")
    return 1 if problemas else 0


if __name__ == "__main__":
    sys.exit(main())
