# 🚀 Guia Rápido - Deploy Local

## Início Rápido

### Windows

```cmd
restart.bat
```

Escolha a opção **1** (Build completo e iniciar) na primeira vez.

### Linux/Mac

```bash
chmod +x restart.sh
./restart.sh
```

Escolha a opção **1** (Build completo e iniciar) na primeira vez.

---

## ⏱️ Tempo Estimado

- **Primeiro build**: 5-10 minutos (download de imagens + build)
- **Builds subsequentes**: 2-3 minutos
- **Startup**: 1-2 minutos (migrações de banco)

---

## 🌐 URLs de Acesso

Após a inicialização:

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **Health Check Backend**: http://localhost:8080/api/health

---

## 📋 Opções do Script

1. **Build completo e iniciar** - Use na primeira vez ou após mudanças significativas
2. **Apenas iniciar** - Use quando os containers já existem
3. **Parar containers** - Para sem remover dados
4. **Limpar tudo** - ⚠️ Remove TUDO incluindo dados do banco
5. **Ver logs** - Monitora logs em tempo real
6. **Rebuild sem cache** - Build do zero (mais lento)
7. **Status** - Ver status e recursos (apenas Windows)

---

## 🔍 Verificar Status

```cmd
docker-compose ps
```

Você deve ver 4 containers rodando:

- ✅ whaticket_postgres
- ✅ whaticket_redis
- ✅ whaticket_backend
- ✅ whaticket_frontend

---

## 📊 Ver Logs

### Todos os serviços

```cmd
docker-compose logs -f
```

### Apenas Backend

```cmd
docker-compose logs -f backend
```

### Apenas Frontend

```cmd
docker-compose logs -f frontend
```

---

## 🏥 Health Checks

### Backend

```cmd
curl http://localhost:8080/api/health
```

Deve retornar JSON com `status: "healthy"`

### Frontend

```cmd
curl http://localhost:3000/health
```

Deve retornar `healthy`

---

## 👤 Primeiro Acesso

1. Acesse http://localhost:3000
2. Você verá a tela de login
3. Clique em **"Cadastrar"** ou **"Criar Conta"**
4. O primeiro usuário criado será o **administrador**

---

## ⚙️ Configurações

O arquivo `.env` foi criado automaticamente com valores padrão para desenvolvimento local:

- **Database**: `whaticket` / `whaticket123`
- **Redis**: senha `redis123`
- **URLs**: localhost

Para modificar, edite o arquivo `.env` e reinicie com `restart.bat` opção 1.

---

## 🔄 Reiniciar Após Mudanças

### Mudanças em código:

```cmd
restart.bat
Opção: 1 (Build completo)
```

### Mudanças em .env:

```cmd
restart.bat
Opção: 3 (Parar)
restart.bat
Opção: 2 (Iniciar)
```

---

## 🐛 Troubleshooting

### Containers não iniciam

```cmd
docker-compose down
docker-compose up -d
docker-compose logs -f
```

### Erro "port already in use"

Verifique se há outro serviço usando as portas 3000 ou 8080:

```cmd
netstat -ano | findstr :3000
netstat -ano | findstr :8080
```

### Banco de dados não responde

```cmd
docker-compose restart postgres
```

### Limpar e recomeçar

```cmd
docker-compose down -v
docker-compose up -d
```

**⚠️ Isso apaga todos os dados!**

---

## 📦 Volumes de Dados

Os dados são persistidos em volumes Docker:

- `whaticket_postgres_data` - Banco de dados
- `whaticket_redis_data` - Cache Redis
- `whaticket_backend_public` - Arquivos enviados
- `whaticket_backend_wwebjs` - Sessões WhatsApp

### Ver volumes

```cmd
docker volume ls | findstr whaticket
```

### Backup de volumes

Veja [COMMANDS.md](./COMMANDS.md) para comandos de backup.

---

## 🎯 Próximos Passos

1. ✅ Acesse http://localhost:3000
2. ✅ Crie sua conta de administrador
3. ✅ Configure sua empresa
4. ✅ Conecte um número via QR Code do WhatsApp
5. ✅ Teste enviar/receber mensagens

---

## 📞 Precisa de Ajuda?

- [EASYPANEL_DEPLOY.md](./EASYPANEL_DEPLOY.md) - Guia completo
- [COMMANDS.md](./COMMANDS.md) - Referência de comandos
- [CHANGELOG.md](./CHANGELOG.md) - Lista de mudanças

**Bom uso do WhaTicket SaaS! 🚀**
