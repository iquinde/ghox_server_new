#!/bin/bash

# Setup completo para DigitalOcean Ubuntu 22.04
echo "🔧 GHOX SERVER - Setup Automático para DigitalOcean"
echo "=================================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para logs
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que somos root
if [[ $EUID -ne 0 ]]; then
   log_error "Este script debe ejecutarse como root"
   exit 1
fi

log_info "Actualizando sistema..."
apt-get update -y
apt-get upgrade -y

log_info "Instalando dependencias básicas..."
apt-get install -y curl wget git unzip software-properties-common

log_info "Instalando Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Verificar instalación
node_version=$(node --version)
npm_version=$(npm --version)
log_info "Node.js instalado: $node_version"
log_info "NPM instalado: $npm_version"

log_info "Instalando PM2 globalmente..."
npm install -g pm2

log_info "Configurando PM2 para auto-start..."
pm2 startup systemd
env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u root --hp /root

log_info "Configurando firewall..."
ufw --force enable
ufw allow 22    # SSH
ufw allow 80    # HTTP  
ufw allow 443   # HTTPS
ufw allow 8080  # API

log_info "Creando estructura de directorios..."
mkdir -p /opt/ghox_server
mkdir -p /var/log/ghox

log_info "Configurando Git (si es necesario)..."
if ! command -v git &> /dev/null; then
    apt-get install -y git
fi

# Crear usuario para la aplicación
log_info "Creando usuario para la aplicación..."
if ! id "ghox" &>/dev/null; then
    useradd -r -s /bin/false ghox
fi

log_info "Configurando permisos..."
chown -R ghox:ghox /opt/ghox_server
chown -R ghox:ghox /var/log/ghox

log_info "Instalando nginx (opcional para proxy reverso)..."
read -p "¿Deseas instalar nginx para proxy reverso? (y/n): " install_nginx
if [[ $install_nginx =~ ^[Yy]$ ]]; then
    apt-get install -y nginx
    
    # Crear configuración básica de nginx
    cat > /etc/nginx/sites-available/ghox << 'EOL'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOL

    # Activar configuración
    ln -sf /etc/nginx/sites-available/ghox /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    systemctl reload nginx
    systemctl enable nginx
    
    log_info "Nginx configurado para proxy reverso en puerto 80"
fi

log_info "Instalando herramientas de monitoreo..."
apt-get install -y htop neofetch

log_info "============================================="
log_info "🎉 SETUP COMPLETADO!"
log_info "============================================="
log_info ""
log_info "Próximos pasos:"
log_info "1. Clona tu repositorio en /opt/ghox_server"
log_info "2. Configura variables de entorno en .env"
log_info "3. Ejecuta el script deploy.sh"
log_info ""
log_info "Comandos útiles:"
log_info "- pm2 status         # Ver estado de aplicaciones"
log_info "- pm2 logs           # Ver logs"
log_info "- pm2 monit          # Monitor en tiempo real"
log_info "- systemctl status nginx  # Estado de nginx (si instalado)"
log_info ""
log_info "Tu servidor está listo para recibir la aplicación Ghox!"

# Mostrar información del sistema
log_info "Información del sistema:"
echo "CPU: $(nproc) cores"
echo "RAM: $(free -h | awk '/^Mem:/ {print $2}')"
echo "Disco: $(df -h / | awk '/^\/dev/ {print $4}') disponible"
echo "IP Pública: $(curl -s ifconfig.me)"