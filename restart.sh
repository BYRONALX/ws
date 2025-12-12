#!/bin/bash

# ============================================
# WhaTicket SaaS - Script de Restart Local
# ============================================

set -e

echo "🚀 WhaTicket SaaS - Deploy Local"
echo "================================="
echo ""

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Função para printar mensagens coloridas
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "ℹ $1"
}

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    print_error "Docker não está instalado!"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose não está instalado!"
    exit 1
fi

print_success "Docker e Docker Compose encontrados"

# Verificar se arquivo .env existe
if [ ! -f .env ]; then
    print_warning "Arquivo .env não encontrado. Criando a partir do .env.example..."
    cp .env.example .env
    print_info "IMPORTANTE: Edite o arquivo .env com suas configurações antes de continuar"
    print_info "Pressione Enter para continuar ou Ctrl+C para sair e editar..."
    read
fi

# Menu de opções
echo ""
echo "Escolha uma opção:"
echo "1) Build completo e iniciar (recomendado na primeira vez)"
echo "2) Apenas iniciar containers existentes"
echo "3) Parar todos os containers"
echo "4) Parar e remover tudo (incluindo volumes - CUIDADO!)"
echo "5) Ver logs dos containers"
echo "6) Rebuild sem cache"
echo ""
read -p "Opção [1-6]: " option

case $option in
    1)
        print_info "Iniciando build completo..."
        echo ""
        
        # Parar containers se estiverem rodando
        print_info "Parando containers existentes..."
        docker-compose down 2>/dev/null || true
        
        # Build das imagens
        print_info "Building imagens Docker (isso pode demorar alguns minutos)..."
        docker-compose build
        
        # Iniciar containers
        print_info "Iniciando containers..."
        docker-compose up -d
        
        # Aguardar um pouco
        sleep 5
        
        # Verificar status
        print_info "Verificando status dos containers..."
        docker-compose ps
        
        echo ""
        print_success "Deploy completo!"
        echo ""
        print_info "Aguarde aproximadamente 1-2 minutos para as migrações serem executadas"
        print_info ""
        print_info "Frontend: http://localhost:3000"
        print_info "Backend API: http://localhost:8080"
        print_info ""
        print_info "Para ver os logs em tempo real, execute:"
        echo "  docker-compose logs -f"
        echo ""
        print_info "Para acessar apenas logs do backend:"
        echo "  docker-compose logs -f backend"
        ;;
        
    2)
        print_info "Iniciando containers..."
        docker-compose up -d
        
        sleep 3
        docker-compose ps
        
        print_success "Containers iniciados!"
        print_info "Frontend: http://localhost:3000"
        print_info "Backend: http://localhost:8080"
        ;;
        
    3)
        print_info "Parando containers..."
        docker-compose down
        print_success "Containers parados!"
        ;;
        
    4)
        print_warning "ATENÇÃO: Isso irá remover TODOS os dados (banco de dados, uploads, etc)!"
        read -p "Tem certeza? (digite 'sim' para confirmar): " confirm
        
        if [ "$confirm" = "sim" ]; then
            print_info "Removendo tudo..."
            docker-compose down -v
            print_success "Tudo removido!"
        else
            print_info "Operação cancelada"
        fi
        ;;
        
    5)
        print_info "Exibindo logs (Ctrl+C para sair)..."
        docker-compose logs -f
        ;;
        
    6)
        print_info "Rebuild sem cache..."
        docker-compose down
        docker-compose build --no-cache
        docker-compose up -d
        
        sleep 5
        docker-compose ps
        
        print_success "Rebuild completo!"
        ;;
        
    *)
        print_error "Opção inválida!"
        exit 1
        ;;
esac

echo ""
print_info "Comandos úteis:"
echo "  docker-compose ps              # Ver status"
echo "  docker-compose logs -f         # Ver todos os logs"
echo "  docker-compose logs -f backend # Logs do backend"
echo "  docker-compose restart         # Reiniciar"
echo "  docker-compose down            # Parar"
echo ""
