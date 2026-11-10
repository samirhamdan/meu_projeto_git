# Decisões do Sprint 0

São as seis decisões da seção 8 do roadmap. As recomendações são minhas e valem como proposta até você confirmar.

| # | Decisão | Situação | Resposta ou recomendação |
| --- | --- | --- | --- |
| 1 | O que roda na VPS | Pendente | Sai do inventário: [inventario-vps.md](inventario-vps.md) |
| 2 | Repositório e forma de trabalho | Parcial | Repositório definido: este. Faltam o nome, a visibilidade e a implantação (abaixo) |
| 3 | Pilha dos outros sistemas | Pendente | Sai do inventário. Se não houver pilha a seguir, proponho no Sprint 1 |
| 4 | Domínio ou subdomínio e nome do produto | Pendente | Preciso do domínio que você já tem |
| 5 | Chave da API do Claude e limite mensal | Pendente, sem pressa | Só é necessária no Sprint 4 (28/12). Nunca envie a chave pela conversa nem pelo repositório |
| 6 | Regra de migração do estudo | A confirmar | Paridade até 27/12/2026; senão, o estudo só muda depois da prova de 17/01/2027 |

## Decisão 2 em detalhe

**Nome.** Você pediu `ufms87+`. O GitHub não aceita `+` em nome de repositório (só letras, números, `-`, `_` e `.`) e trocaria o nome para `ufms87-`. Além disso, o roadmap trata o UFMS 87+ como o primeiro concurso da plataforma, não como a plataforma. Opções:

| Opção | Quando faz sentido |
| --- | --- |
| `ufms87-plus` | Manter a marca do painel atual |
| `ufms87` | Mais curto |
| Nome do produto (decisão 4) | Se o nome da plataforma já estiver escolhido |

Eu não consigo renomear daqui: não tenho essa permissão. Você renomeia em Settings → General → Repository name. O GitHub redireciona o endereço antigo, então nada quebra.

**Visibilidade.** O repositório está **público**. Recomendo torná-lo privado antes do Sprint 1 (Settings → General → Danger Zone → Change visibility): ele vai conter a configuração de implantação da sua VPS e o conteúdo autoral das lições. Enquanto for público, nenhum dado seu entra nele.

**Implantação.** Recomendo implantação automática pelo GitHub Actions com uma chave restrita a essa função, em vez de eu ter acesso direto à VPS. Confirmo depois do inventário.
