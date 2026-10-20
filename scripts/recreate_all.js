const fs = require('fs');
const path = require('path');
const https = require('https');

const PROJECT_ID = 'aptech-network-hub';
const API_KEY = 'AIzaSyDbl8zlNcmMIONle-SoeHocBIoiaXggFW4';

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
      reqOptions.headers['Content-Length'] = Buffer.byteLength(body);
    }

    const req = https.request(reqOptions, res => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        let parsed = null;
        try { parsed = JSON.parse(data); } catch (e) { parsed = data; }
        resolve({ status: res.statusCode, data: parsed });
      });
    });

    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

const ACCOUNTS = [
  {
    name: 'Shabbir Ahmed',
    email: 'cah-sf@aptech-education.com.pk',
    password: 'SuperShabbir123!',
    role: 'Super Admin',
    isSuperAdmin: true,
    isApproved: true,
    associatedLabs: []
  },
  {
    name: 'Wahaj Aamir',
    email: 'wahajaamir2@gmail.com',
    password: 'X2!5sxv=',
    role: 'Super Admin',
    isSuperAdmin: true,
    isApproved: true,
    associatedLabs: []
  },
  {
    name: 'Shabbir Ahmed',
    email: 'academicsfc@gmail.com',
    password: 'Shabbir@321',
    role: 'Super Admin',
    isSuperAdmin: true,
    isApproved: true,
    associatedLabs: []
  },
  {
    name: 'Miss Zeenat Umer',
    email: 'academicsfc2@gmail.com',
    password: 'AdminZeenat123!',
    role: 'Admin',
    isSuperAdmin: false,
    isApproved: true,
    associatedLabs: []
  },
  {
    name: 'Waseem Iqbal',
    email: 'cm-sf@aptech-education.com.pk',
    password: 'AdminWaseem123!',
    role: 'Admin',
    isSuperAdmin: false,
    isApproved: true,
    associatedLabs: []
  },
  {
    name: 'System Admin',
    email: 'admin@gmail.com',
    password: 'AdminPassword123!',
    role: 'Admin',
    isSuperAdmin: false,
    isApproved: true,
    associatedLabs: []
  },
  {
    name: 'Ali Raza',
    email: 'aliraza.jkp@gmail.com',
    password: 'FacultyAli123!',
    role: 'Faculty',
    isSuperAdmin: false,
    isApproved: true,
    associatedLabs: []
  },
  {
    name: 'Ali Khan',
    email: 'tech.ali@aptech.edu',
    password: 'TechPassword123!',
    role: 'IT Technician',
    isSuperAdmin: false,
    isApproved: true,
    associatedLabs: ['Lab 101', 'Lab 102', 'JBR Lab']
  },
  {
    name: 'Sara Ahmed',
    email: 'tech.sara@aptech.edu',
    password: 'TechPassword123!',
    role: 'IT Technician',
    isSuperAdmin: false,
    isApproved: true,
    associatedLabs: ['Lab 201', 'Lab 210', 'IBR Lab']
  },
  {
    name: 'General Technician',
    email: 'technician@gmail.com',
    password: 'TechPassword123!',
    role: 'IT Technician',
    isSuperAdmin: false,
    isApproved: true,
    associatedLabs: ['Lab 101', 'Lab 102', 'Lab 201', 'Lab 210']
  }
];

async function run() {
  console.log('========================================================');
  console.log('🔄 RECREATING ALL USERS AND DATABASE FOR APTECH-NETWORK-HUB');
  console.log('========================================================\n');

  // 1. Purge any remaining auth users
  console.log('1️⃣ Checking and purging existing auth users...');
  const authUsersRes = await request(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:batchGet`, {
    headers: { 'Authorization': `Bearer ${adminToken}` }
  });
  const existingUsers = authUsersRes.data.users || [];
  if (existingUsers.length > 0) {
    const ids = existingUsers.map(u => u.localId);
    console.log(`   Found ${ids.length} existing users. Deleting...`);
    for (let i = 0; i < ids.length; i += 50) {
      await request(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:batchDelete`, {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${adminToken}` }
      }, { localIds: ids.slice(i, i + 50) });
    }
    console.log('   ✅ Auth users wiped.');
  } else {
    console.log('   ✅ Auth pool is already completely clean.');
  }

  // 2. Wipe Firestore Collections: users, complaints, labs, notifications, workstations
  console.log('\n2️⃣ Purging Firestore collections...');
  const collections = ['users', 'complaints', 'labs', 'notifications', 'workstations'];
  for (const col of collections) {
    const res = await request(`https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${col}?pageSize=300`, {
      headers: { 'Authorization': `Bearer ${adminToken}` }
    });
    const docs = res.data.documents || [];
    if (docs.length > 0) {
      console.log(`   Deleting ${docs.length} documents from '${col}'...`);
      for (const d of docs) {
        await request(`https://firestore.googleapis.com/v1/${d.name}`, {
          method: 'DELETE',
          headers: { 'Authorization': `Bearer ${adminToken}` }
        });
      }
      console.log(`   ✅ Collection '${col}' cleared.`);
    } else {
      console.log(`   Collection '${col}' already empty.`);
    }
  }

  // 3. Create all 10 users in Auth and Firestore
  console.log('\n3️⃣ Provisioning all 10 users in Firebase Auth & Firestore...');
  const userMap = {}; // email -> { uid, ... }

  for (const acc of ACCOUNTS) {
    console.log(`   Creating Auth user: ${acc.email} (${acc.role})...`);
    const signupRes = await request(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`, {
      method: 'POST'
    }, {
      email: acc.email,
      password: acc.password,
      returnSecureToken: true
    });

    if (signupRes.status !== 200) {
      throw new Error(`Failed to create ${acc.email}: ` + JSON.stringify(signupRes.data));
    }

    const uid = signupRes.data.localId;
    userMap[acc.email] = { ...acc, uid };
    console.log(`   -> Created UID: ${uid}`);

    // Create Firestore document with identical UID as doc ID
    const fields = {
      uid: { stringValue: uid },
      name: { stringValue: acc.name },
      email: { stringValue: acc.email },
      role: { stringValue: acc.role },
      isApproved: { booleanValue: true },
      isSuperAdmin: { booleanValue: acc.isSuperAdmin },
      tempPassword: { stringValue: acc.password },
      createdAt: { integerValue: String(Date.now()) }
    };

    if (acc.associatedLabs && acc.associatedLabs.length > 0) {
      fields.associatedLabs = {
        arrayValue: {
          values: acc.associatedLabs.map(l => ({ stringValue: l }))
        }
      };
    }

    const docRes = await request(`https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/users/${uid}`, {
      method: 'PATCH',
      headers: { 'Authorization': `Bearer ${adminToken}` }
    }, { fields });

    if (docRes.status !== 200) {
      throw new Error(`Failed to write /users/${uid}: ` + JSON.stringify(docRes.data));
    }
    console.log(`   ✅ User doc saved: /users/${uid}`);
  }

  // 4. Load backup data
  console.log('\n4️⃣ Restoring Labs and Complaints with updated UIDs...');
  const backup = JSON.parse(fs.readFileSync(path.join(__dirname, 'legacy_backup.json'), 'utf8'));

  // Re-create Labs
  for (const lab of backup.labs) {
    const labId = lab.name.split('/').pop();
    const labFields = JSON.parse(JSON.stringify(lab.fields));
    
    // Assign technician based on lab name if appropriate
    const labName = labFields.name?.stringValue || '';
    if (['Lab 101', 'Lab 102', 'JBR Lab'].includes(labName)) {
      labFields.assignedTo = { stringValue: 'Ali Khan' };
    } else if (['Lab 201', 'Lab 210', 'IBR Lab'].includes(labName)) {
      labFields.assignedTo = { stringValue: 'Sara Ahmed' };
    }

    const labRes = await request(`https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/labs/${labId}`, {
      method: 'PATCH',
      headers: { 'Authorization': `Bearer ${adminToken}` }
    }, { fields: labFields });

    if (labRes.status === 200) {
      console.log(`   ✅ Created Lab: ${labName} (${labId})`);
    } else {
      console.warn(`   Warning creating lab ${labId}:`, labRes.data);
    }
  }

  // Re-create Complaints linked to new UIDs
  const aliRazaUid = userMap['aliraza.jkp@gmail.com'].uid;
  const wahajUid = userMap['wahajaamir2@gmail.com'].uid;
  const aliKhanUid = userMap['tech.ali@aptech.edu'].uid;
  const saraAhmedUid = userMap['tech.sara@aptech.edu'].uid;
  const genTechUid = userMap['technician@gmail.com'].uid;

  let compCreated = 0;
  for (const comp of backup.complaints) {
    const compId = comp.name.split('/').pop();
    const f = JSON.parse(JSON.stringify(comp.fields));

    // Faculty linking
    const fName = f.facultyName?.stringValue || '';
    if (fName.toLowerCase().includes('wahaj')) {
      f.facultyId = { stringValue: wahajUid };
      f.facultyEmail = { stringValue: 'wahajaamir2@gmail.com' };
    } else {
      f.facultyId = { stringValue: aliRazaUid };
      f.facultyEmail = { stringValue: 'aliraza.jkp@gmail.com' };
      f.facultyName = { stringValue: 'Ali Raza' };
    }

    // Technician linking based on assignedTo or lab
    const labName = f.lab?.stringValue || '';
    const assignedName = f.assignedToName?.stringValue || f.assignedTo?.stringValue || '';
    
    let targetTechUid = genTechUid;
    let targetTechName = 'Ali Khan';

    if (assignedName.includes('Sara') || ['Lab 201', 'Lab 210', 'IBR Lab'].includes(labName)) {
      targetTechUid = saraAhmedUid;
      targetTechName = 'Sara Ahmed';
    } else {
      targetTechUid = aliKhanUid;
      targetTechName = 'Ali Khan';
    }

    f.assignedTo = { stringValue: targetTechName };
    f.assignedToName = { stringValue: targetTechName };
    f.assignedToId = { stringValue: targetTechUid };

    if (f.resolvedByName || f.status?.stringValue === 'Resolved') {
      f.resolvedByName = { stringValue: targetTechName };
      f.resolvedById = { stringValue: targetTechUid };
      f.statusUpdatedByName = { stringValue: targetTechName };
      f.statusUpdatedById = { stringValue: targetTechUid };
    }

    const compRes = await request(`https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/complaints/${compId}`, {
      method: 'PATCH',
      headers: { 'Authorization': `Bearer ${adminToken}` }
    }, { fields: f });

    if (compRes.status === 200) {
      compCreated++;
    } else {
      console.warn(`   Warning creating complaint ${compId}:`, compRes.data);
    }
  }
  console.log(`   ✅ Restored & linked ${compCreated} complaints.`);

  // 5. Verification Test: Sign in with EVERY account
  console.log('\n5️⃣ VERIFYING SIGN-IN FOR ALL 10 ACCOUNTS:');
  let allOk = true;
  for (const acc of ACCOUNTS) {
    const signin = await request(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`, {
      method: 'POST'
    }, {
      email: acc.email,
      password: acc.password,
      returnSecureToken: true
    });

    if (signin.status === 200 && signin.data.localId === userMap[acc.email].uid) {
      console.log(`   ✅ [OK] ${acc.email} -> UID matches: ${signin.data.localId}`);
    } else {
      allOk = false;
      console.error(`   ❌ [FAIL] ${acc.email}:`, signin.data);
    }
  }

  if (allOk) {
    console.log('\n🎉 ALL 10 ACCOUNTS CREATED, VERIFIED, AND LINKED SUCCESSFULLY!');
  } else {
    throw new Error('Some accounts failed authentication verification!');
  }
}

run().catch(err => {
  console.error('\n❌ Fatal error:', err);
  process.exit(1);
});
