# WhaTicket SaaS - Comandos Rápidos

## 🚀 Deploy Rápido

```bash
# 1. Clone o repositório
git clone <seu-repositorio>
cd whaticketsaas24-master

# 2. Configure variáveis de ambiente
cp .env.example .env
nano .env  # ou use seu editor preferido

# 3. Inicie os serviços
docker-compose up -d

# 4. Verifique os logs
docker-compose logs -f
```

## 📝 Comandos Úteis

### Gerenciamento de Containers

```bash
# Iniciar serviços
docker-compose up -d

# Parar serviços
docker-compose down

# Parar e remover volumes (CUIDADO: apaga dados!)
docker-compose down -v

# Reiniciar serviços
docker-compose restart

# Rebuild de imagens
docker-compose build --no-cache

# Ver status dos containers
docker-compose ps

# Ver logs de todos os serviços
docker-compose logs -f

# Ver logs de um serviço específico
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Database

```bash
# Executar migrations
docker-compose exec backend npm run db:migrate

# Verificar status das migrations
docker-compose exec backend npm run db:migrate -- --status

# Reverter última migration
docker-compose exec backend npm run db:migrate:undo

# Acessar PostgreSQL
docker-compose exec postgres psql -U whaticket -d whaticket

# Backup do banco
docker-compose exec postgres pg_dump -U whaticket whaticket > backup.sql

# Restaurar backup
cat backup.sql | docker-compose exec -T postgres psql -U whaticket whaticket
```

### Monitoramento

```bash
# Ver uso de recursos (CPU, RAM, etc)
docker stats

# Ver espaço em disco usado pelo Docker
docker system df

# Health check backend
curl http://localhost:8080/api/health

# Health check frontend
curl http://localhost:3000/health
```

### Limpeza

```bash
# Remover containers parados
docker container prune

# Remover imagens não utilizadas
docker image prune -a

# Remover volumes não utilizados
docker volume prune

# Limpeza completa (CUIDADO!)
docker system prune -a --volumes
```

### Debug

```bash
# Acessar shell do container backend
docker-compose exec backend sh

# Acessar shell do container frontend
docker-compose exec frontend sh

# Ver variáveis de ambiente do backend
docker-compose exec backend printenv

# Testar conexão Redis
docker-compose exec redis redis-cli -a SUA_SENHA ping

# Verificar Chrome no backend
docker-compose exec backend google-chrome --version
```

## 🔐 Gerar Secrets Seguros

```bash
# JWT Secret
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"

# Ou se não tiver Node instalado localmente
docker run --rm node:16-alpine node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

## 📦 Backup Completo

```bash
# Script de backup completo
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups/$DATE"

mkdir -p $BACKUP_DIR

# Backup banco de dados
docker-compose exec -T postgres pg_dump -U whaticket whaticket > $BACKUP_DIR/database.sql

# Backup arquivos públicos
docker run --rm -v whaticket_backend_public:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar czf /backup/public.tar.gz /data

# Backup sessões WhatsApp
docker run --rm -v whaticket_backend_wwebjs:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar czf /backup/wwebjs.tar.gz /data

echo "Backup concluído em: $BACKUP_DIR"
```

## 🔄 Atualização da Aplicação

```bash
# 1. Fazer backup
./backup.sh  # ou execute os comandos de backup acima

# 2. Baixar atualizações
git pull origin main

# 3. Rebuild e restart
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# 4. Verificar logs
docker-compose logs -f
```

## 🆘 Troubleshooting Rápido

### Backend não inicia

```bash
# Verificar logs
docker-compose logs backend

# Reiniciar apenas o backend
docker-compose restart backend

# Verificar conexão com banco
docker-compose exec postgres pg_isready -U whaticket
```

### Frontend não carrega

```bash
# Verificar logs do nginx
docker-compose logs frontend

# Testar se backend está respondendo
curl http://backend:8080/api/health

# Rebuild do frontend
docker-compose up -d --build frontend
```

### Erro de migração

```bash
# Ver status das migrations
docker-compose exec backend npm run db:migrate -- --status

# Tentar rodar migrations manualmente
docker-compose exec backend npm run db:migrate

# Se persistir, verificar logs detalhados
docker-compose logs backend | grep -i migration
```

### Redis não conecta

```bash
# Verificar se Redis está rodando
docker-compose ps redis

# Testar conexão
docker-compose exec redis redis-cli -a SUA_SENHA ping

# Reiniciar Redis
docker-compose restart redis
```

## 📊 Informações do Sistema

```bash
# Versão do Docker
docker --version

# Versão do Docker Compose
docker-compose --version

# Informações do sistema
docker info

# Ver versão Node.js no backend
docker-compose exec backend node --version

# Ver versão PostgreSQL
docker-compose exec postgres psql --version
```

---

Para mais detalhes, consulte:

- [EASYPANEL_DEPLOY.md](./EASYPANEL_DEPLOY.md) - Guia completo de deploy
- [.env.example](./.env.example) - Variáveis de ambiente
- [README.md](./README.md) - Documentação principal
