# Plataforma de mentoria para concursos

Reconstrução, em VPS própria, do método validado no painel **UFMS 87+** (mentoria para um candidato, hoje publicada como artifact no claude.ai). O UFMS 87+ entra como o primeiro concurso cadastrado, não como caso especial no código.

O painel atual **continua em uso e não é alterado** por este repositório. O estudo só migra para a nova versão quando houver paridade (regra do roadmap).

## Situação

| Sprint | Período | Situação |
| --- | --- | --- |
| 0. Inventário e decisões | 11 a 15/11/2026 | Em andamento: ver [docs/sprint-0](docs/sprint-0/README.md) |
| 1. Fundação | 16 a 29/11/2026 | Aguardando o Sprint 0 |

## Conteúdo

| Caminho | O que é |
| --- | --- |
| `docs/sprint-0/` | Entregáveis do Sprint 0: inventário da VPS, exportação do painel, decisões |
| `scripts/inventario-vps.sh` | Levantamento somente leitura da VPS |
| `tools/consolidar_exportacao.py` | Consolida e confere a exportação do painel |

## Regra sobre dados

Histórico de estudo, exportações do painel e segredos **não entram no repositório** (ver `.gitignore`).
