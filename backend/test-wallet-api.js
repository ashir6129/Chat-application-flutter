import jwt from 'jsonwebtoken';
import env from './src/config/env.js';
import http from 'http';

// User 'ashir_khan' ID: 07964e60-146b-4588-ab7c-36a5c49df055
const token = jwt.sign(
  { sub: '07964e60-146b-4588-ab7c-36a5c49df055', username: 'ashir_khan' },
  env.jwt.secret
);

const options = {
  hostname: 'localhost',
  port: 4000,
  path: '/api/v1/boxes/wallet',
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
};

const req = http.request(options, (res) => {
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  res.on('end', () => {
    console.log("=== API RESPONSE ===");
    console.log(data);
  });
});

req.on('error', (e) => {
  console.error(`Problem with request: ${e.message}`);
});

req.end();
