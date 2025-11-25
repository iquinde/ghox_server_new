# Ghox Server - Deployment en DigitalOcean

Servidor P2P WebRTC para videollamadas con soporte completo de signaling y presencia.

## 🚀 Deployment en DigitalOcean

### Opción 1: Deployment Manual

1. **Crear Droplet en DigitalOcean:**
   ```bash
   # Crear un droplet Ubuntu 22.04
   # Mínimo: 1GB RAM, 1 CPU
   # Recomendado: 2GB RAM, 1 CPU
   ```

2. **Conectar al servidor:**
   ```bash
   ssh root@your_server_ip
   ```

3. **Instalar Node.js y PM2:**
   ```bash
   # Instalar Node.js 18
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   apt-get install -y nodejs
   
   # Instalar PM2
   npm install -g pm2
   ```

4. **Clonar y configurar proyecto:**
   ```bash
   # Clonar repositorio
   git clone <tu_repositorio> /opt/ghox_server
   cd /opt/ghox_server
   
   # Instalar dependencias
   npm ci --only=production
   
   # Configurar variables de entorno
   nano .env
   ```

5. **Variables de entorno necesarias:**
   ```bash
   # .env
   JWT_SECRET=Ghox01
   MONGO_URI=mongodb+srv://Ghox_db:AdminGhox01@cluster0.1v2iivg.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0
   PORT=8080
   NODE_ENV=production
   ```

6. **Iniciar servidor:**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

### Opción 2: Docker Deployment

1. **Instalar Docker:**
   ```bash
   apt-get update
   apt-get install -y docker.io docker-compose
   systemctl enable docker
   systemctl start docker
   ```

2. **Build y run:**
   ```bash
   # Build imagen
   docker build -t ghox-server .
   
   # Run container
   docker run -d \
     --name ghox-server \
     --restart unless-stopped \
     -p 8080:8080 \
     -e JWT_SECRET=Ghox01 \
     -e MONGO_URI=mongodb+srv://Ghox_db:AdminGhox01@cluster0.1v2iivg.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0 \
     ghox-server
   ```

### Opción 3: Docker Compose

1. **Usar docker-compose.yml:**
   ```bash
   # Configurar variables en .env
   # Luego:
   docker-compose up -d
   ```

## 🔧 Configuración de Firewall

```bash
# Permitir tráfico HTTP/HTTPS y puerto personalizado
ufw allow 22    # SSH
ufw allow 80    # HTTP
ufw allow 443   # HTTPS
ufw allow 8080  # API
ufw enable
```

## 📊 Monitoreo

```bash
# Ver logs en vivo
pm2 logs ghox-server

# Ver status
pm2 status

# Reiniciar servidor
pm2 restart ghox-server

# Ver métricas
pm2 monit
```

## 🔄 Actualizaciones

```bash
# Pull últimos cambios
git pull origin main

# Reinstalar dependencias si es necesario
npm ci --only=production

# Restart servidor
pm2 restart ghox-server
```

## 🌐 URLs de acceso

Una vez deployado, tu servidor estará disponible en:

- **API Base**: `http://your_server_ip:8080`
- **Health Check**: `http://your_server_ip:8080/health`
- **API Docs**: `http://your_server_ip:8080/api-docs`
- **ICE Config**: `http://your_server_ip:8080/api/ice`

## 📱 Configurar Cliente Flutter

Actualiza el `.env` en tu app Flutter:

```bash
API_BASE_URL=http://your_server_ip:8080
```

## 🆘 Troubleshooting

### Si el servidor no inicia:
```bash
# Ver logs detallados
pm2 logs ghox-server --lines 100

# Verificar puerto
netstat -tlnp | grep 8080

# Verificar variables de entorno
pm2 env 0
```

### Si hay problemas de conectividad:
```bash
# Test desde el servidor
curl http://localhost:8080/health

# Test desde exterior
curl http://your_server_ip:8080/health
```

### Si MongoDB no conecta:
1. Verificar que la IP del servidor esté en la whitelist de MongoDB Atlas
2. Verificar que MONGO_URI sea correcta
3. Test de conectividad: `mongo "mongodb+srv://..."`