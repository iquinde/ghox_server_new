module.exports = {
  apps: [{
    name: 'ghox-server',
    script: 'src/index.js',
    instances: 1, // Una instancia para WebSocket
    exec_mode: 'fork', // Fork mode para WebSocket
    env: {
      NODE_ENV: 'production',
      PORT: 8080
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true,
    max_restarts: 10,
    min_uptime: '10s',
    max_memory_restart: '1G'
  }]
};