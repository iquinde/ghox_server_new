#!/bin/bash

# Script de deployment para DigitalOcean
echo "🚀 Iniciando deployment de Ghox Server en DigitalOcean..."

# Verificar variables de entorno
if [ -z "$MONGO_URI" ]; then
    echo "❌ Error: MONGO_URI no está configurado"
    exit 1
fi

if [ -z "$JWT_SECRET" ]; then
    echo "❌ Error: JWT_SECRET no está configurado"
    exit 1
fi

# Crear directorio de logs
mkdir -p logs

# Instalar dependencias
echo "📦 Instalando dependencias..."
npm ci --only=production

# Verificar que todos los archivos estén en su lugar
echo "🔍 Verificando estructura..."
if [ ! -f "src/index.js" ]; then
    echo "❌ Error: src/index.js no encontrado"
    exit 1
fi

# Iniciar con PM2
echo "🎯 Iniciando servidor con PM2..."
pm2 start ecosystem.config.js

# Mostrar status
pm2 status

echo "✅ Deployment completado!"
echo "📊 Logs disponibles en: ./logs/"
echo "🌐 Servidor disponible en puerto 8080"