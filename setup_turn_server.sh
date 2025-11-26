#!/bin/bash

# Script para configurar servidor STUN/TURN en DigitalOcean
echo "🚀 Configurando servidor STUN/TURN en DigitalOcean..."

# Actualizar sistema
apt update && apt upgrade -y

# Instalar Coturn (servidor STUN/TURN)
apt install -y coturn

# Habilitar coturn
systemctl enable coturn

# Crear configuración personalizada
cat > /etc/turnserver.conf << 'EOF'
# Configuración STUN/TURN para Ghox Server

# Puertos de escucha
listening-port=3478
tls-listening-port=5349

# IP externa (será reemplazada automáticamente)
external-ip=EXTERNAL_IP_PLACEHOLDER

# Realm (dominio)
realm=ghox-voice.com

# Base de datos SQLite para usuarios
userdb=/var/lib/turn/turndb

# Logs
log-file=/var/log/turnserver.log
verbose

# Seguridad
fingerprint
use-auth-secret
static-auth-secret=GHOX_TURN_SECRET_2025

# Optimizaciones
no-cli
no-tls
no-dtls

# Restricciones de red (permitir solo lo necesario)
denied-peer-ip=10.0.0.0-10.255.255.255
denied-peer-ip=192.168.0.0-192.168.255.255
denied-peer-ip=172.16.0.0-172.31.255.255
allowed-peer-ip=EXTERNAL_IP_PLACEHOLDER

# Límites
max-allocate-lifetime=3600
max-allocate-timeout=60

# Puertos para relay
min-port=50000
max-port=60000

EOF

# Obtener IP externa automáticamente
EXTERNAL_IP=$(curl -s http://checkip.amazonaws.com/)
echo "📡 IP externa detectada: $EXTERNAL_IP"

# Reemplazar placeholder con IP real
sed -i "s/EXTERNAL_IP_PLACEHOLDER/$EXTERNAL_IP/g" /etc/turnserver.conf

# Crear usuario para TURN
turnadmin -a -u ghoxuser -p GhoxTurn2025 -r ghox-voice.com

# Configurar firewall
ufw allow 3478/tcp
ufw allow 3478/udp
ufw allow 5349/tcp
ufw allow 5349/udp
ufw allow 50000:60000/udp

# Iniciar servicio
systemctl start coturn
systemctl status coturn

echo "✅ Servidor STUN/TURN configurado exitosamente!"
echo "📋 Detalles de configuración:"
echo "   STUN: stun:$EXTERNAL_IP:3478"
echo "   TURN: turn:$EXTERNAL_IP:3478"
echo "   Usuario: ghoxuser"
echo "   Contraseña: GhoxTurn2025"
echo "   Realm: ghox-voice.com"
echo ""
echo "🔥 Ahora actualiza tu código para usar este servidor!"