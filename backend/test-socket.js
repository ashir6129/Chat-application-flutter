import { io } from 'socket.io-client';

const socket = io('https://profound-friend-implosive.ngrok-free.dev', {
  path: '/socket.io',
  transports: ['websocket'],
  extraHeaders: {
    'ngrok-skip-browser-warning': 'true'
  }
});

socket.on('connect', () => {
  console.log('CONNECTED successfully!');
  process.exit(0);
});

socket.on('connect_error', (err) => {
  console.error('CONNECT ERROR:', err.message);
  process.exit(1);
});

setTimeout(() => {
  console.error('TIMEOUT');
  process.exit(1);
}, 5000);
