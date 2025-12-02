import mongoose from 'mongoose';
import dotenv from 'dotenv';
import { User } from './models/User.js';
dotenv.config();

export async function connectDB(uri = process.env.MONGO_URI) {
  if (!uri) throw new Error('MONGO_URI no definido');

  try {
    // Log detallado de la URI de conexión (ocultando credenciales)
    const maskedUri = uri.replace(/\/\/([^:]+):([^@]+)@/, '//***:***@');
    console.log('🔗 Intentando conectar a MongoDB...');
    console.log('📍 URI:', maskedUri);
    
    // Extraer el nombre de la base de datos de la URI
    const dbNameMatch = uri.match(/\.net\/([^?]+)/);
    const dbName = dbNameMatch ? dbNameMatch[1] : 'default';
    console.log('🗄️ Base de datos objetivo:', dbName);

    await mongoose.connect(uri); // remove deprecated options
    
    // Verificar la conexión real y mostrar información detallada
    const connection = mongoose.connection;
    const actualDbName = connection.db.databaseName;
    const host = connection.host;
    
    console.log('✅ MongoDB conectado exitosamente');
    console.log('🏠 Host:', host);
    console.log('🗄️ Base de datos conectada:', actualDbName);
    console.log('📊 Estado de conexión:', connection.readyState === 1 ? 'Conectado' : 'Desconectado');
    
    if (dbName !== actualDbName) {
      console.warn('⚠️ ADVERTENCIA: Base de datos objetivo difiere de la conectada!');
      console.warn('   Objetivo:', dbName);
      console.warn('   Actual:', actualDbName);
    }
  } catch (error) {
    console.error('❌ Error al conectar a MongoDB:');
    console.error('🔍 URI utilizada:', maskedUri);
    console.error('📝 Error:', error.message);
    throw error;
  }

  // Seed admin idempotente después de la conexión exitosa
  try {
    const adminUsername = process.env.ADMIN_USERNAME || 'admin';
    const adminUserId = process.env.ADMIN_USERID || '000000001';
    const adminDisplayName = process.env.ADMIN_DISPLAYNAME || 'Administrador';

    const admin = await User.findOne({ username: adminUsername });
    if (!admin) {
      await User.create({
        userId: adminUserId,
        username: adminUsername,
        displayName: adminDisplayName,
        role: 'admin'
      });
      console.log('🛡️ Usuario admin creado automáticamente');
    } else {
      console.log('🛡️ Usuario admin ya existe');
    }

    // Seed roles collection
    const roles = [
      { name: 'ORGANIZATION_MANAGER', description: 'ORGANIZATION_MANAGER', is_default: true },
      { name: 'ORGANIZATION_ADMIN',   description: 'ORGANIZATION_ADMIN',   is_default: true },
      { name: 'ORGANIZATION_USER',    description: 'ORGANIZATION_USER',    is_default: true }
    ];
    const rolesColl = mongoose.connection.db.collection('roles');
    for (const r of roles) {
      await rolesColl.updateOne(
        { name: r.name },
        { $setOnInsert: { ...r, createdAt: new Date(), updatedAt: new Date() } },
        { upsert: true }
      );
    }
    console.log('✅ Roles sembrados (si no existían)');
  } catch (err) {
    console.error('Error conectando/sembrando DB:', err);
    throw err; // deja que el proceso falle y Render muestre el error en logs
  }
}