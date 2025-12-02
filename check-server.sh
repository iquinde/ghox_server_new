#!/bin/bash

echo "🔍 Verificando estado actual del servidor..."

# Verificar servicios en ejecución
echo "=== PROCESOS NODE.JS ==="
ps aux | grep node

echo -e "\n=== PM2 STATUS ==="
pm2 list

echo -e "\n=== SERVICIOS NGINX ==="
systemctl status nginx

echo -e "\n=== PUERTOS EN USO ==="
netstat -tlnp | grep :3000
netstat -tlnp | grep :80
netstat -tlnp | grep :443

echo -e "\n=== DIRECTORIO ACTUAL ==="
ls -la /opt/
ls -la /var/www/

echo -e "\n=== CONFIGURACIÓN NGINX ==="
ls -la /etc/nginx/sites-enabled/

echo -e "\n=== VERSIÓN NODE ==="
node --version
npm --version

echo -e "\n=== REPOSITORIOS GIT ==="
find /opt -name ".git" -type d 2>/dev/null
find /var/www -name ".git" -type d 2>/dev/null