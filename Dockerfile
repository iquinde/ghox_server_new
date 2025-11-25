# Dockerfile para producción en DigitalOcean
FROM node:18-alpine

# Instalar PM2 globalmente
RUN npm install -g pm2

# Crear directorio de aplicación
WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias
RUN npm ci --only=production

# Copiar código fuente
COPY . .

# Crear usuario no-root
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Cambiar propietario de archivos
RUN chown -R nodejs:nodejs /app
USER nodejs

# Exponer puerto
EXPOSE 8080

# Usar PM2 para gestión de procesos
CMD ["pm2-runtime", "start", "ecosystem.config.js"]