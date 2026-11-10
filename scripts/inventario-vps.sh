#!/usr/bin/env bash
# Inventário da VPS para o Sprint 0 da plataforma de mentoria.
#
# SOMENTE LEITURA: não instala, não altera e não reinicia nada.
# Não imprime senhas, chaves nem variáveis de ambiente de contêineres.
#
# Uso (na VPS):
#   bash inventario-vps.sh > inventario-vps.txt
# Rodar com sudo mostra mais detalhes (portas com o nome do processo, Docker),
# mas não é obrigatório. Revise o arquivo antes de enviar.

set -u
export LC_ALL=C

tem() { command -v "$1" >/dev/null 2>&1; }
secao() { printf '\n## %s\n\n' "$1"; }
rodar() {
  # rodar "rótulo" comando args...
  local rotulo="$1"; shift
  printf '### %s\n```\n' "$rotulo"
  if tem "$1"; then
    "$@" 2>&1 | head -n 200
  else
    echo "(comando $1 não encontrado)"
  fi
  printf '```\n\n'
}

echo "# Inventário da VPS"
echo
echo "Gerado em: $(date -u '+%Y-%m-%d %H:%M UTC')"
echo "Usuário que executou: $(id -un) (root: $([ "$(id -u)" -eq 0 ] && echo sim || echo não))"

secao "1. Sistema"
printf '### Distribuição\n```\n'
if [ -r /etc/os-release ]; then grep -E '^(PRETTY_NAME|VERSION_ID|ID)=' /etc/os-release; else echo "(sem /etc/os-release)"; fi
printf '```\n\n'
rodar "Kernel e arquitetura" uname -srm
rodar "Tempo ligado e carga" uptime
rodar "Fuso horário" date '+%Z %z'

secao "2. Recursos"
rodar "Processadores" nproc
rodar "Memória e swap" free -h
rodar "Disco" df -hT -x tmpfs -x devtmpfs -x overlay -x squashfs
printf '### Dez processos que mais usam memória\n```\n'
ps -eo comm,%mem,%cpu,rss --sort=-%mem 2>/dev/null | head -n 11
printf '```\n\n'

secao "3. Contêineres"
if tem docker; then
  rodar "Versão do Docker" docker --version
  printf '### Docker Compose\n```\n'
  docker compose version 2>&1 | head -n 1 || true
  tem docker-compose && docker-compose --version 2>&1 | head -n 1
  printf '```\n\n'
  rodar "Contêineres (nome, imagem, estado, portas)" docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
  rodar "Uso de memória e CPU por contêiner" docker stats --no-stream --format 'table {{.Name}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.CPUPerc}}'
  rodar "Redes" docker network ls --format 'table {{.Name}}\t{{.Driver}}'
  rodar "Volumes" docker volume ls --format 'table {{.Name}}\t{{.Driver}}'
  rodar "Espaço usado pelo Docker" docker system df
  rodar "Projetos Compose" docker compose ls -a
else
  echo "Docker não encontrado."
fi
tem podman && rodar "Podman" podman ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'

secao "4. Proxy reverso e portas"
printf '### Proxy instalado no sistema\n```\n'
for p in nginx caddy traefik apache2 httpd haproxy; do
  if tem "$p"; then echo "$p: instalado ($("$p" -v 2>&1 | head -n 1))"; fi
done
if tem systemctl; then
  for s in nginx caddy traefik apache2 httpd haproxy; do
    estado=$(systemctl is-active "$s" 2>/dev/null)
    [ "$estado" = "active" ] && echo "serviço $s: ativo"
  done
fi
printf '```\n\n'
printf '### Proxy rodando em contêiner\n```\n'
if tem docker; then
  docker ps --format '{{.Names}}\t{{.Image}}' 2>/dev/null | grep -Ei 'nginx|caddy|traefik|proxy|haproxy' || echo "(nenhum identificado pelo nome)"
fi
printf '```\n\n'
printf '### Domínios configurados no Nginx do sistema (só os nomes)\n```\n'
if [ -d /etc/nginx ]; then
  grep -rhoE '^\s*server_name\s+[^;]+' /etc/nginx/sites-enabled /etc/nginx/conf.d 2>/dev/null | sed -E 's/^\s*server_name\s+//' | tr ' ' '\n' | sort -u | head -n 100
else
  echo "(sem /etc/nginx)"
fi
printf '```\n\n'
printf '### Portas em escuta\n```\n'
if tem ss; then ss -tulpnH 2>/dev/null | awk '{print $1, $5, $7}' | sort -u | head -n 100
elif tem netstat; then netstat -tulpn 2>/dev/null | head -n 100
else echo "(sem ss nem netstat)"; fi
printf '```\n\n'
rodar "Firewall (ufw)" ufw status

secao "5. Bancos de dados"
printf '### Instalados no sistema\n```\n'
tem psql && psql --version
tem mysql && mysql --version
tem mariadb && mariadb --version
tem redis-server && redis-server --version
tem mongod && mongod --version | head -n 1
if tem systemctl; then
  for s in postgresql mysql mariadb redis redis-server mongod; do
    estado=$(systemctl is-active "$s" 2>/dev/null)
    [ "$estado" = "active" ] && echo "serviço $s: ativo"
  done
fi
printf '```\n\n'
printf '### Em contêiner\n```\n'
if tem docker; then
  docker ps --format '{{.Names}}\t{{.Image}}' 2>/dev/null | grep -Ei 'postgres|mysql|mariadb|redis|mongo|supabase' || echo "(nenhum identificado pela imagem)"
fi
printf '```\n\n'

secao "6. Linguagens e ferramentas"
printf '```\n'
for c in "node --version" "npm --version" "pnpm --version" "python3 --version" "php --version" "go version" "java -version" "ruby --version" "git --version" "pm2 --version" "certbot --version"; do
  bin=${c%% *}
  if tem "$bin"; then printf '%-10s %s\n' "$bin" "$($c 2>&1 | grep -v "^Picked up" | head -n 1)"; fi
done
printf '```\n\n'
if tem pm2; then rodar "Processos PM2" pm2 list --no-color; fi

secao "7. Serviços e agendamentos"
if tem systemctl; then
  printf '### Serviços em execução\n```\n'
  systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | awk '{print $1}' | head -n 80
  printf '```\n\n'
fi
printf '### Agendamentos do usuário (só a quantidade de linhas)\n```\n'
if tem crontab; then crontab -l 2>/dev/null | grep -vcE '^\s*(#|$)' || true; fi
printf '```\n\n'
printf '### Ferramentas de backup encontradas\n```\n'
for b in restic borg rclone duplicity pg_dump; do tem "$b" && echo "$b"; done
printf '```\n'

echo
echo "Fim do inventário."
