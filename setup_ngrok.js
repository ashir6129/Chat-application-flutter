const { execSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

async function main() {
  console.log("Starting ngrok...");
  try { execSync('killall ngrok', { stdio: 'ignore' }); } catch(e) {}
  
  const ngrok = spawn('ngrok', ['http', '4000'], { stdio: 'ignore', detached: true });
  ngrok.unref();
  
  console.log("Waiting for ngrok to initialize...");
  await new Promise(r => setTimeout(r, 3000));
  
  let publicUrl = '';
  try {
    const response = execSync('curl -s http://localhost:4040/api/tunnels').toString();
    const tunnels = JSON.parse(response).tunnels;
    publicUrl = tunnels[0].public_url;
  } catch (error) {
    console.error("Failed to fetch ngrok URL. Make sure ngrok is installed and running.");
    process.exit(1);
  }
  
  console.log(`Ngrok Public URL: ${publicUrl}`);
  
  // Update backend/.env
  const envPath = path.join(__dirname, 'backend', '.env');
  if (fs.existsSync(envPath)) {
    let envContent = fs.readFileSync(envPath, 'utf8');
    envContent = envContent.replace(/BASE_URL=.*/g, `BASE_URL=${publicUrl}`);
    fs.writeFileSync(envPath, envContent);
    console.log("Updated backend/.env");
  } else {
    console.warn("backend/.env not found, skipping.");
  }
  
  // Update lib/core/api_config.dart
  const configPath = path.join(__dirname, 'lib', 'core', 'api_config.dart');
  if (fs.existsSync(configPath)) {
    let configContent = fs.readFileSync(configPath, 'utf8');
    configContent = configContent.replace(/static const String productionBaseUrl =\s*'[^']+';/g, `static const String productionBaseUrl =\n      '${publicUrl}/api/v1';`);
    fs.writeFileSync(configPath, configContent);
    console.log("Updated lib/core/api_config.dart");
  } else {
    console.warn("lib/core/api_config.dart not found, skipping.");
  }
  
  console.log("\nConfiguration updated successfully!");
  console.log("You can now run your backend and Flutter app. Ngrok is running in the background.");
  process.exit(0);
}
main();
