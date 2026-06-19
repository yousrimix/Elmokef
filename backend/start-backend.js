/**
 * Elmokef Backend Server Starter
 * - Starts the NestJS app
 * - Adds missing development routes (stats, etc.)
 */
const { fork } = require('child_process');
const http = require('http');

// Start NestJS backend
const backend = fork(require.resolve('./dist/main.js'), [], {
  stdio: 'pipe',
  env: Object.assign({}, process.env),
});

backend.stdout.on('data', d => process.stdout.write(d));
backend.stderr.on('data', d => process.stderr.write(d));

console.log('🚀 Elmokef Backend starting...');
