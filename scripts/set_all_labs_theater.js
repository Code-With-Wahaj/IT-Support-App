const https = require('https');

const PROJECT_ID = 'aptech-network-hub';
const API_KEY = 'AIzaSyDbl8zlNcmMIONle-SoeHocBIoiaXggFW4';

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
      reqOptions.headers['Content-Length'] = Buffer.byteLength(body);
    }

    const req = https.request(reqOptions, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: data ? JSON.parse(data) : null });
        } catch (e) {
          resolve({ status: res.statusCode, data });
        }
      });
    });

    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

async function updateLabsToTheater() {
  console.log("Authenticating as admin...");
  const authRes = await request(
    `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`,
    { method: 'POST' },
    {
      email: 'wahajaamir2@gmail.com',
      password: 'X2!5sxv=',
      returnSecureToken: true
    }
  );

  if (!authRes.data || !authRes.data.idToken) {
    console.error("Auth failed:", authRes);
    return;
  }

  const idToken = authRes.data.idToken;
  console.log("Authenticated successfully!");

  const getUrl = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/labs`;
  const res = await request(getUrl, {
    method: 'GET',
    headers: { 'Authorization': `Bearer ${idToken}` }
  });

  if (!res.data || !res.data.documents) {
    console.log("No lab documents found or error:", res);
    return;
  }

  console.log(`Found ${res.data.documents.length} labs. Updating layoutType to 'theater'...`);

  for (const doc of res.data.documents) {
    const labName = doc.fields?.name?.stringValue || doc.name.split('/').pop();
    const patchUrl = `https://firestore.googleapis.com/v1/${doc.name}?updateMask.fieldPaths=layoutType`;
    const patchRes = await request(
      patchUrl,
      {
        method: 'PATCH',
        headers: { 'Authorization': `Bearer ${idToken}` }
      },
      {
        fields: {
          layoutType: { stringValue: 'theater' }
        }
      }
    );

    console.log(`Updated ${labName} (${doc.name.split('/').pop()}) status: ${patchRes.status}`);
  }

  console.log("All labs updated to 'theater' in Firebase!");
}

updateLabsToTheater().catch(console.error);
