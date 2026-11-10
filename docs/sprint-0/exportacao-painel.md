# Exportação do painel UFMS 87+

Exportação completa feita em 10/11/2026, só por leitura: **524 documentos em 15 coleções**, mais uma cópia do código do painel (versão `1794325837-6917`). A conferência de integridade passou; há 2 avisos e 1 divergência com a auditoria, descritos abaixo.

## Onde está

O pacote `ufms87-export-2026-11-10.zip` (527 KB) **não está neste repositório**: o repositório é público e o pacote contém o seu histórico de estudo. Ele foi entregue na conversa; guarde-o no Drive ou no computador.

SHA-256 do pacote: `638a77012bbdf1a200f6ae57d98510ce703bd4f221e1523d9b01915f9f201e3e`

| Arquivo no pacote | Conteúdo |
| --- | --- |
| `ufms87-export.json` | Todas as coleções em um arquivo, com o `id` em cada documento |
| `manifesto.json` | Contagem, tamanho e SHA-256 por coleção; avisos |
| `colecoes/<coleção>/<id>.json` | Um arquivo por documento, como veio do painel |
| `painel-ufms87-v1794325837.html` | Código do painel na data da exportação |

Para conferir ou refazer o pacote a partir da pasta `colecoes`:

```bash
python3 tools/consolidar_exportacao.py colecoes saida
```

## Contagens

Estas são as contagens de referência para o Sprint 2 ("contagens iguais às do painel atual"). O painel segue em uso, então os dados do candidato vão crescer: a migração usará uma exportação nova, e esta fica como cópia de segurança.

| Coleção | Documentos | Tipo | Conteúdo |
| --- | --- | --- | --- |
| provas | 4 | Compartilhado | Provas FAPEC 2018 (duas), 2020 e 2022, com Raio-X |
| blocos | 10 | Compartilhado | 4 de diagnóstico, 2 de prova, 4 de pré e pós-teste |
| questoes | 149 | Compartilhado | 80 inéditas e 69 oficiais FAPEC |
| textos | 8 | Compartilhado | Textos-base das questões |
| assuntos | 57 | Compartilhado | Matriz do edital: 18 Português, 13 RL, 12 Específicos, 10 Legislação, 4 Inglês |
| licoes | 7 | Compartilhado | 161 seções em 16 tipos de bloco |
| cartoes | 206 | Misto | Frente, verso e referência (conteúdo) + caixa e histórico (candidato) |
| decks | 10 | Misto | Vínculo com a lição (conteúdo) + liberação (candidato) |
| plano | 15 | Candidato | Um documento por dia, 08 a 22/11 |
| tentativas | 3 | Candidato | Respostas, certeza e tempo por bloco |
| erros | 18 | Candidato | Caderno de erros |
| revisoes | 21 | Candidato | Fila de revisão com histórico |
| progresso | 2 | Candidato | Andamento e respostas nas lições |
| tempo | 2 | Candidato | Minutos por dia e disciplina |
| registros | 12 | Candidato | Diário de continuidade da mentoria |
| **Total** | **524** | | |

## Achados da conferência

- **Divergência com a auditoria.** O documento de auditoria cita "cerca de 250 questões". O banco tem 149 na coleção `questoes` e 7 dentro das lições: **156**. Vale a contagem da exportação.
- **Aviso.** Os baralhos `res430_p2` e `res430_p3` apontam para lições que ainda não foram escritas. É estado esperado (lições da semana 2), não perda de dado.
- **Status não é dado.** Os 57 assuntos estão gravados como "NÃO ESTUDADO": o status real é calculado no navegador a partir das tentativas. Essa regra precisa ir para o servidor (Sprint 3), e a comparação de paridade deve usar o status calculado, não o campo gravado.
- Todas as demais referências entre coleções existem (questão → bloco, texto e prova; erro e revisão → questão; lição → assunto; cartão → baralho).

## Campos por coleção

| Coleção | Campos |
| --- | --- |
| provas | ano, banca, cargo, cargoCurto, data, nivel, total, titulo, ordem, fonte, relevancia, estrutura, temas, inteligencia, impacto, pendente, blocoId |
| blocos | titulo, descricao, disciplina, fase, ordem, tempoAlvoMin, licaoId, momento (pre/pos), dataAlvo |
| questoes | enunciado, alternativas (A–E), gabarito, comentario, pegadinha, disciplina, assunto, assuntoId, origem (fapec/inedita), fonte, provaId, numero, blocoId, textoId, ordem, foraEdital |
| textos | titulo, corpo, fonte |
| assuntos | nome, disciplina, ordem, semana, complexidade, depende, fonte, status, etapas |
| licoes | titulo, disciplina, assuntoId, deck, fonte, ordem, tempoMin, secoes |
| cartoes | frente, verso, ref, deck, deckNome, disciplina, ordem · box, n, acertos, inicio, proxima, historico |
| decks | licao, motivo · ativo, liberadoEm |
| plano | semana, titulo, foco, tarefas (id, hora, dur, oque, metodo, disciplina, como, obs, link, linkNome, feito, feitoEm) |
| tentativas | blocoId, blocoTitulo, disciplina, dia, inicio, fim, duracaoSeg, total, acertos, itens (qid, resposta, gabarito, correta, certeza, assunto, disciplina) |
| erros | tentativaId, qid, dia, disciplina, assunto, resposta, gabarito, certeza, tipo (A–G), nota, medida |
| revisoes | qid, disciplina, assunto, motivo, criada, etapa, proxima, status, reincidencias, historico |
| progresso | idx, concluida, respostas (por seção) |
| tempo | min, por (disciplina) |
| registros | data, dia, titulo, texto |

Tipos de seção das lições: objetivo, guia, texto, quadro, lei, caso, checkpoint, armadilha, resumo, exemplo, passos, raiox, aposta, destaque, questao, mapa, questionario.

## Mapa para o modelo relacional (proposta para o Sprint 1)

| Hoje | Tabelas | Observação |
| --- | --- | --- |
| Constantes no código (prova, disciplinas, pesos, metas) | concurso, cargo, edital, disciplina | Hoje fixas no JavaScript; passam a ser dados |
| provas | prova | Raio-X fica em tabela própria ligada à prova |
| assuntos | assunto, assunto_dependencia | `status` e `etapas` saem: viram dados do candidato |
| questoes, textos | questao, alternativa, texto_base | Origem obrigatória; questão de lição entra no mesmo banco |
| blocos | bloco, bloco_questao | Uma questão poderá estar em mais de um bloco |
| licoes | licao, licao_secao | Seção com tipo e conteúdo estruturado |
| cartoes, decks | cartao, baralho + cartao_estado, baralho_liberacao | Separar conteúdo de estado do candidato |
| plano | plano_dia, tarefa | |
| tentativas | tentativa, tentativa_item | `assunto` em texto passa a ser chave para assunto |
| erros, revisoes | erro, revisao, revisao_evento | |
| progresso | licao_progresso, secao_resposta | |
| tempo | sessao_estudo | No servidor, medido por sessão |
| registros | registro_mentoria | |

Toda tabela de dado do candidato leva `usuario_id`; o isolamento por usuário é testado no Sprint 1.

Pontos de atenção para a migração:

- Erros, tentativas e revisões guardam o **nome** do assunto, não o `id`. A importação precisa casar por nome com a matriz e listar o que não casar.
- Identificadores atuais (`diag1_03`, `cf37_09`) serão preservados como código de origem, para comparar as duas versões lado a lado.
- Datas estão em texto (`AAAA-MM-DD`) no fuso local; horários de tentativa estão em UTC.
