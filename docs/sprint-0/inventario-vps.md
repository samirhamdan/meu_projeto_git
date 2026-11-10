# Inventário da VPS

Situação: **pendente**. Ainda não tenho acesso à VPS; a arquitetura do roadmap (seção 5) continua sendo hipótese até este documento ser preenchido.

## Como gerar

O script só lê: não instala, não altera e não reinicia nada, e não imprime senhas nem variáveis de ambiente.

Copie `scripts/inventario-vps.sh` para a VPS e rode:

```bash
bash inventario-vps.sh > inventario-vps.txt
```

Com `sudo` o resultado traz mais detalhes (processo por porta, Docker), mas não é obrigatório. Revise o arquivo e envie o conteúdo na conversa. O `.gitignore` impede que `inventario-vps.txt` seja versionado: ele lista domínios e serviços dos seus outros sistemas.

## O que o script levanta

| Bloco | Pergunta que responde |
| --- | --- |
| Sistema | Qual distribuição, versão e arquitetura |
| Recursos | Quanta memória, swap e disco estão livres; o que mais consome memória |
| Contêineres | Há Docker e Compose; o que roda; quanto cada contêiner usa |
| Proxy e portas | Nginx, Caddy ou Traefik; no sistema ou em contêiner; domínios e portas em uso |
| Bancos | PostgreSQL, MySQL, Redis ou outro já instalado, e onde |
| Linguagens | Node, Python, PHP e outras, para seguir a pilha dos seus outros sistemas |
| Serviços e backup | O que roda como serviço; se já existe ferramenta de backup |

## Resultado

A preencher com a saída do script.

| Item | Valor |
| --- | --- |
| Sistema operacional | |
| Memória total / disponível | |
| Disco total / livre | |
| Docker e Compose | |
| Proxy reverso | |
| Banco já instalado | |
| Pilha dos outros sistemas | |
| Ferramenta de backup | |

## Critérios que vou aplicar

- Memória disponível abaixo de 2 GB ou disco livre abaixo de 10 GB: limites por contêiner e avaliação do plano B do roadmap (segunda VPS).
- Proxy existente: a plataforma entra como mais um destino nele; não instalo um segundo proxy.
- PostgreSQL já existente: decidir entre um banco novo na mesma instância ou um contêiner próprio, conforme a versão e quem mais usa.
