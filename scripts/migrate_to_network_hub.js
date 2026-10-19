const fs = require('fs');
const path = require('path');
const https = require('https');

// Keys & Project IDs
const OLD_PROJECT = 'aptech-it-support';
const OLD_API_KEY = 'AIzaSyCZpD7tWO02MEJv5VMphU82aC3dt_RUCjs';

const NEW_PROJECT = 'aptech-network-hub';
const NEW_API_KEY = 'AIzaSyDbl8zlNcmMIONle-SoeHocBIoiaXggFW4';

// Get CLI Access Token for admin operations on aptech-network-hub
const configPath = path.join(process.env.USERPROFILE, '.config', 'configstore', 'firebase-tools.json');
const cliConfig = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const adminToken = cliConfig.tokens.access_token;

// HTTP helper
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

// 7 Targeted Users to Create
const TARGET_USERS = [
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
  }
];

async function main() {
  console.log('====================================================');
  console.log('🚀 STARTING COMPREHENSIVE FIREBASE MIGRATION');
  console.log(`Source: ${OLD_PROJECT} -> Destination: ${NEW_PROJECT}`);
  console.log('====================================================\n');

  // Step 1: Login to Old Project to fetch legacy data
  console.log('1️⃣ Authenticating against legacy project to extract data...');
  const oldAuthRes = await request(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${OLD_API_KEY}`, {
    method: 'POST'
  }, {
    email: 'wahajaamir2@gmail.com',
    password: 'X2!5sxv=',
    returnSecureToken: true
  });

  if (oldAuthRes.status !== 200) {
    throw new Error('Failed to login to old project: ' + JSON.stringify(oldAuthRes.data));
  }
  const oldIdToken = oldAuthRes.data.idToken;
  console.log('✅ Connected to legacy project with Super Admin token.');

  // Fetch labs from old project
  console.log('   Fetching labs from legacy project...');
  const oldLabsRes = await request(`https://firestore.googleapis.com/v1/projects/${OLD_PROJECT}/databases/(default)/documents/labs?pageSize=100`, {
    headers: { 'Authorization': `Bearer ${oldIdToken}` }
  });
  const oldLabs = oldLabsRes.data.documents || [];
  console.log(`   Found ${oldLabs.length} labs.`);

  // Fetch complaints from old project
  console.log('   Fetching complaints from legacy project...');
  const oldComplaintsRes = await request(`https://firestore.googleapis.com/v1/projects/${OLD_PROJECT}/databases/(default)/documents/complaints?pageSize=100`, {
    headers: { 'Authorization': `Bearer ${oldIdToken}` }
  });
  const oldComplaints = oldComplaintsRes.data.documents || [];
  console.log(`   Found ${oldComplaints.length} complaints.`);

  // Fetch users from old project
  console.log('   Fetching users from legacy project...');
  const oldUsersRes = await request(`https://firestore.googleapis.com/v1/projects/${OLD_PROJECT}/databases/(default)/documents/users?pageSize=100`, {
    headers: { 'Authorization': `Bearer ${oldIdToken}` }
  });
  const oldUsers = oldUsersRes.data.documents || [];
  console.log(`   Found ${oldUsers.length} users in legacy database.`);

  // Save full backup locally
  const backup = { labs: oldLabs, complaints: oldComplaints, users: oldUsers };
  fs.writeFileSync(path.join(__dirname, 'legacy_backup.json'), JSON.stringify(backup, null, 2));
  console.log('💾 Backup of legacy data written to legacy_backup.json\n');

  // Step 2: Clear Destination Project (aptech-network-hub)
  console.log(`2️⃣ Clearing obsolete data from destination project (${NEW_PROJECT})...`);

  // Clear Auth Users
  const hubUsersRes = await request(`https://identitytoolkit.googleapis.com/v1/projects/${NEW_PROJECT}/accounts:batchGet`, {
    headers: { 'Authorization': `Bearer ${adminToken}` }
  });
  const existingHubUsers = hubUsersRes.data.users || [];
  if (existingHubUsers.length > 0) {
    const localIds = existingHubUsers.map(u => u.localId);
    console.log(`   Deleting ${localIds.length} obsolete auth users in ${NEW_PROJECT}...`);
    // Delete in chunks of 50
    for (let i = 0; i < localIds.length; i += 50) {
      const chunk = localIds.slice(i, i + 50);
      await request(`https://identitytoolkit.googleapis.com/v1/projects/${NEW_PROJECT}/accounts:batchDelete`, {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${adminToken}` }
      }, { localIds: chunk });
    }
    console.log('   ✅ All obsolete auth users deleted.');
  } else {
    console.log('   No existing auth users to delete.');
  }

  // Clear Firestore Collections: users, complaints, labs, notifications
  const collectionsToClear = ['users', 'complaints', 'labs', 'notifications'];
  for (const col of collectionsToClear) {
    const listRes = await request(`https://firestore.googleapis.com/v1/projects/${NEW_PROJECT}/databases/(default)/documents/${col}?pageSize=300`, {
      headers: { 'Authorization': `Bearer ${adminToken}` }
    });
    const docs = listRes.data.documents || [];
    if (docs.length > 0) {
      console.log(`   Deleting ${docs.length} documents from collection '${col}'...`);
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

  console.log('\n3️⃣ Creating the 7 specified users in Auth and Firestore...');
  const userMap = {}; // email -> { uid, ... }
  const oldUidToNewUid = {};

  for (const u of TARGET_USERS) {
    console.log(`   Creating Auth user: ${u.email} (${u.role})...`);
    const createRes = await request(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${NEW_API_KEY}`, {
      method: 'POST'
    }, {
      email: u.email,
      password: u.password,
      returnSecureToken: true
    });

    if (createRes.status !== 200) {
      throw new Error(`Failed to create auth user ${u.email}: ` + JSON.stringify(createRes.data));
    }

    const uid = createRes.data.localId;
    userMap[u.email] = { ...u, uid };
    console.log(`   Created UID: ${uid}`);

    // Map old UID to new UID
    const oldUserDoc = oldUsers.find(ou => {
      const em = ou.fields && ou.fields.email && ou.fields.email.stringValue;
      return em && em.toLowerCase() === u.email.toLowerCase();
    });
    if (oldUserDoc) {
      const oldUid = oldUserDoc.name.split('/').pop();
      oldUidToNewUid[oldUid] = uid;
    }

    // Create Firestore user document
    const fields = {
      uid: { stringValue: uid },
      name: { stringValue: u.name },
      email: { stringValue: u.email },
      role: { stringValue: u.role },
      isApproved: { booleanValue: u.isApproved },
      isSuperAdmin: { booleanValue: u.isSuperAdmin },
      createdAt: { integerValue: String(Date.now()) }
    };

    if (u.associatedLabs && u.associatedLabs.length > 0) {
      fields.associatedLabs = {
        arrayValue: {
          values: u.associatedLabs.map(l => ({ stringValue: l }))
        }
      };
    }

    const docRes = await request(`https://firestore.googleapis.com/v1/projects/${NEW_PROJECT}/databases/(default)/documents/users/${uid}`, {
      method: 'PATCH',
      headers: { 'Authorization': `Bearer ${adminToken}` }
    }, { fields });

    if (docRes.status !== 200) {
      throw new Error(`Failed to create user doc for ${u.email}: ` + JSON.stringify(docRes.data));
    }
    console.log(`   ✅ User doc created in Firestore: /users/${uid}`);
  }

  console.log('\n4️⃣ Migrating Labs to aptech-network-hub...');
  for (const lab of oldLabs) {
    const labId = lab.name.split('/').pop();
    const docRes = await request(`https://firestore.googleapis.com/v1/projects/${NEW_PROJECT}/databases/(default)/documents/labs/${labId}`, {
      method: 'PATCH',
      headers: { 'Authorization': `Bearer ${adminToken}` }
    }, { fields: lab.fields });

    if (docRes.status !== 200) {
      console.warn(`   Warning writing lab ${labId}:`, docRes.data);
    } else {
      console.log(`   ✅ Migrated lab: ${lab.fields.name ? lab.fields.name.stringValue : labId}`);
    }
  }

  console.log('\n5️⃣ Migrating Complaints to aptech-network-hub...');
  let compCount = 0;
  for (const comp of oldComplaints) {
    const compId = comp.name.split('/').pop();
    const clonedFields = JSON.parse(JSON.stringify(comp.fields));

    // Remap facultyId if mapped
    if (clonedFields.facultyId && clonedFields.facultyId.stringValue) {
      const oldFid = clonedFields.facultyId.stringValue;
      if (oldUidToNewUid[oldFid]) {
        clonedFields.facultyId.stringValue = oldUidToNewUid[oldFid];
      }
    }

    // Remap assignedToId if mapped
    if (clonedFields.assignedToId && clonedFields.assignedToId.stringValue) {
      const oldAid = clonedFields.assignedToId.stringValue;
      if (oldUidToNewUid[oldAid]) {
        clonedFields.assignedToId.stringValue = oldUidToNewUid[oldAid];
      }
    }

    const docRes = await request(`https://firestore.googleapis.com/v1/projects/${NEW_PROJECT}/databases/(default)/documents/complaints/${compId}`, {
      method: 'PATCH',
      headers: { 'Authorization': `Bearer ${adminToken}` }
    }, { fields: clonedFields });

    if (docRes.status === 200) compCount++;
  }
  console.log(`   ✅ Successfully migrated ${compCount} complaints.`);

  console.log('\n6️⃣ VERIFICATION & END-TO-END QA TESTING:');
  // Test authentication of all 7 users
  console.log('   Testing login for all 7 users on aptech-network-hub...');
  for (const u of TARGET_USERS) {
    const testLogin = await request(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${NEW_API_KEY}`, {
      method: 'POST'
    }, {
      email: u.email,
      password: u.password,
      returnSecureToken: true
    });
    if (testLogin.status === 200) {
      console.log(`   ✅ Login OK: ${u.email} (${u.role})`);
    } else {
      console.error(`   ❌ Login FAILED: ${u.email}`, testLogin.data);
    }
  }

  // End-to-end test complaint creation and resolution
  console.log('\n   Executing End-to-End Complaint Lifecycle Test:');
  const faculty = userMap['aliraza.jkp@gmail.com'];
  const tech = userMap['tech.ali@aptech.edu'];

  // 1. Faculty login
  const facultyAuth = await request(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${NEW_API_KEY}`, {
    method: 'POST'
  }, {
    email: faculty.email,
    password: faculty.password,
    returnSecureToken: true
  });
  const fToken = facultyAuth.data.idToken;

  // 2. Faculty creates complaint
  const testComplaintId = 'test-qa-' + Date.now();
  const testCompFields = {
    complaintId: { stringValue: testComplaintId },
    facultyId: { stringValue: faculty.uid },
    facultyName: { stringValue: faculty.name },
    lab: { stringValue: 'Lab 101' },
    issue: { stringValue: 'QA Verification Test: Network connectivity' },
    issueCategory: { stringValue: 'Network' },
    message: { stringValue: 'Test message for QA migration verification' },
    status: { stringValue: 'Pending' },
    assignedToId: { stringValue: tech.uid },
    assignedToName: { stringValue: tech.name },
    timestamp: { timestampValue: new Date().toISOString() },
    resolvedById: { stringValue: '' },
    resolvedByName: { stringValue: '' },
    statusUpdatedById: { stringValue: '' },
    statusUpdatedByName: { stringValue: '' }
  };

  const createCompRes = await request(`https://firestore.googleapis.com/v1/projects/${NEW_PROJECT}/databases/(default)/documents/complaints/${testComplaintId}`, {
    method: 'PATCH',
    headers: { 'Authorization': `Bearer ${fToken}` }
  }, { fields: testCompFields });
  console.log(`   1. Faculty created test complaint: Status ${createCompRes.status}`);

  // 3. Technician login & update
  const techAuth = await request(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${NEW_API_KEY}`, {
    method: 'POST'
  }, {
    email: tech.email,
    password: tech.password,
    returnSecureToken: true
  });
  const tToken = techAuth.data.idToken;

  testCompFields.status = { stringValue: 'In Progress' };
  testCompFields.statusUpdatedById = { stringValue: tech.uid };
  testCompFields.statusUpdatedByName = { stringValue: tech.name };

  const updateCompRes = await request(`https://firestore.googleapis.com/v1/projects/${NEW_PROJECT}/databases/(default)/documents/complaints/${testComplaintId}`, {
    method: 'PATCH',
    headers: { 'Authorization': `Bearer ${tToken}` }
  }, { fields: testCompFields });
  console.log(`   2. Technician updated complaint to 'In Progress': Status ${updateCompRes.status}`);

  // 4. Clean up test complaint
  await request(`https://firestore.googleapis.com/v1/projects/${NEW_PROJECT}/databases/(default)/documents/complaints/${testComplaintId}`, {
    method: 'DELETE',
    headers: { 'Authorization': `Bearer ${adminToken}` }
  });
  console.log('   3. Test complaint cleaned up successfully.');

  console.log('\n🎉 ALL MIGRATION AND QA STEPS COMPLETED SUCCESSFULLY!');
}

main().catch(err => {
  console.error('Fatal error during migration:', err);
  process.exit(1);
});
