@echo off
REM ============================================
REM WhaTicket SaaS - Script de Restart Local (Windows)
REM ============================================

echo ========================================
echo   WhaTicket SaaS - Deploy Local
echo ========================================
echo.

REM Verificar se Docker está instalado
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERRO] Docker nao esta instalado!
    pause
    exit /b 1
)

where docker-compose >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERRO] Docker Compose nao esta instalado!
    pause
    exit /b 1
)

echo [OK] Docker e Docker Compose encontrados
echo.

REM Verificar se arquivo .env existe
if not exist .env (
    echo [AVISO] Arquivo .env nao encontrado. Criando a partir do .env.example...
    copy .env.example .env
    echo.
    echo [INFO] Arquivo .env criado com valores padrao para desenvolvimento local
    echo.
)

REM Menu de opções
echo Escolha uma opcao:
echo.
echo 1) Build completo e iniciar (recomendado na primeira vez)
echo 2) Apenas iniciar containers existentes
echo 3) Parar todos os containers
echo 4) Parar e remover tudo (incluindo volumes - CUIDADO!)
echo 5) Ver logs dos containers
echo 6) Rebuild sem cache
echo 7) Ver status dos containers
echo.
set /p option="Opcao [1-7]: "

if "%option%"=="1" goto build_start
if "%option%"=="2" goto start
if "%option%"=="3" goto stop
if "%option%"=="4" goto clean
if "%option%"=="5" goto logs
if "%option%"=="6" goto rebuild
if "%option%"=="7" goto status

echo [ERRO] Opcao invalida!
pause
exit /b 1

:build_start
echo.
echo [INFO] Iniciando build completo...
echo.
echo [INFO] Parando containers existentes...
docker-compose down 2>nul

echo.
echo [INFO] Building imagens Docker (isso pode demorar alguns minutos)...
docker-compose build

echo.
echo [INFO] Iniciando containers...
docker-compose up -d

timeout /t 5 /nobreak >nul

echo.
echo [INFO] Verificando status dos containers...
docker-compose ps

echo.
echo [OK] Deploy completo!
echo.
echo [INFO] Aguarde aproximadamente 1-2 minutos para as migracoes serem executadas
echo.
echo Frontend: http://localhost:3000
echo Backend API: http://localhost:8080
echo.
echo Para ver os logs em tempo real, execute:
echo   docker-compose logs -f
echo.
goto end

:start
echo.
echo [INFO] Iniciando containers...
docker-compose up -d

timeout /t 3 /nobreak >nul
docker-compose ps

echo.
echo [OK] Containers iniciados!
echo Frontend: http://localhost:3000
echo Backend: http://localhost:8080
goto end

:stop
echo.
echo [INFO] Parando containers...
docker-compose down
echo [OK] Containers parados!
goto end

:clean
echo.
echo [AVISO] Isso ira remover TODOS os dados (banco de dados, uploads, etc)!
set /p confirm="Tem certeza? (digite 'sim' para confirmar): "

if "%confirm%"=="sim" (
    echo.
    echo [INFO] Removendo tudo...
    docker-compose down -v
    echo [OK] Tudo removido!
) else (
    echo [INFO] Operacao cancelada
)
goto end

:logs
echo.
echo [INFO] Exibindo logs (Ctrl+C para sair)...
docker-compose logs -f
goto end

:rebuild
echo.
echo [INFO] Rebuild sem cache...
docker-compose down
docker-compose build --no-cache
docker-compose up -d

timeout /t 5 /nobreak >nul
docker-compose ps

echo.
echo [OK] Rebuild completo!
goto end

:status
echo.
echo [INFO] Status dos containers:
docker-compose ps
echo.
echo [INFO] Recursos utilizados:
docker stats --no-stream
goto end

:end
echo.
echo Comandos uteis:
echo   docker-compose ps              # Ver status
echo   docker-compose logs -f         # Ver todos os logs
echo   docker-compose logs -f backend # Logs do backend
echo   docker-compose restart         # Reiniciar
echo   docker-compose down            # Parar
echo.
pause
