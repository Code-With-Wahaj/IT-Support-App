const fs = require('fs');
const path = require('path');
const https = require('https');

const PROJECT_ID = 'aptech-network-hub';

const configPath = path.join(process.env.USERPROFILE, '.config', 'configstore', 'firebase-tools.json');
const cliConfig = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const adminToken = cliConfig.tokens.access_token;

function request(url, options = {}, body = null) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const reqOptions = {
      hostname: u.hostname,
      port: 443,
      path: u.pathname + u.search,
      method: options.method || 'GET',
      headers: options.headers || {}
    };

    if (body) {
      if (typeof body === 'object') body = JSON.stringify(body);
      reqOptions.headers['Content-Type'] = 'application/json';
    }

    const req = https.request(reqOptions, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: data ? JSON.parse(data) : null });
        } catch(e) {
          resolve({ status: res.statusCode, data });
        }
      });
    });

    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

function pcFields(pcId, isFaulty = false) {
  return {
    pcId: { stringValue: pcId },
    keyboardOk: { booleanValue: !isFaulty },
    mouseOk: { booleanValue: true },
    ledOk: { booleanValue: true },
    vgaCableOk: { booleanValue: true },
    powerCableOk: { booleanValue: true },
    internetCableOk: { booleanValue: true },
    cpuWorking: { booleanValue: true },
    ram: { stringValue: '16 GB' },
    ssd: { stringValue: '512 GB' },
    os: { stringValue: 'Windows 11' },
    notes: { stringValue: isFaulty ? 'Keycap loose on keyboard' : '' }
  };
}

async function run() {
  console.log('Fetching all labs...');
  const res = await request(`https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/labs`, {
    headers: { 'Authorization': `Bearer ${adminToken}` }
  });

  const labs = res.data.documents || [];
  console.log(`Found ${labs.length} labs.`);

  for (const lab of labs) {
    const labId = lab.name.split('/').pop();
    const labName = lab.fields?.name?.stringValue || labId;
    const rows = parseInt(lab.fields?.rows?.integerValue || '3', 10);
    const cols = parseInt(lab.fields?.columns?.integerValue || '6', 10);
    console.log(`\nConfiguring PCs for ${labName} (${labId}) - ${rows}x${cols}...`);

    // Write IP (Instructor PC)
    await request(`https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/labs/${labId}/pcs/IP`, {
      method: 'PATCH',
      headers: { 'Authorization': `Bearer ${adminToken}` }
    }, { fields: pcFields('IP') });

    // Write all PCs
    for (let r = 1; r <= rows; r++) {
      for (let c = 1; c <= cols; c++) {
        const pcId = `PC-${r}-${c}`;
        // Mark PC-1-3 as slightly faulty in Lab 101 for realistic diagnostic telemetry
        const isFaulty = (labName.includes('101') && r === 1 && c === 3);
        await request(`https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/labs/${labId}/pcs/${pcId}`, {
          method: 'PATCH',
          headers: { 'Authorization': `Bearer ${adminToken}` }
        }, { fields: pcFields(pcId, isFaulty) });
      }
    }
    console.log(`  ✅ Populated ${rows * cols + 1} PCs in /labs/${labId}/pcs`);
  }
  console.log('\n🎉 Finished seeding all lab PCs!');
}

run().catch(console.error);
