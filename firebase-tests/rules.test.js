/**
 * Firestore security-rules emulator tests — TASK-Phase-7.md Block D.7.
 *
 * These were written as part of the Phase 7 audit because D.7 lists rules
 * unit tests as a GATE for the phase, not a follow-up, and none existed.
 * They are NOT run as part of this pass — running them needs the Firebase
 * emulator suite, which this environment cannot start. A human must run:
 *
 *   cd hostel_finder_app/firebase-tests
 *   npm install
 *   firebase emulators:exec --project demo-hostel-finder --only firestore "npm test"
 *
 * (run from firebase-tests/, with a firebase.json alongside it — or from
 * the app root by pointing --config/firestore rules paths at
 * ../firestore.rules — either works, this file only assumes a Firestore
 * emulator is reachable on the default port via the test environment's
 * connectFirestoreEmulator-equivalent inside initializeTestEnvironment).
 *
 * Covers, at minimum, every case D.7 names explicitly:
 *  1. a student cannot create a hostels doc
 *  2. an owner cannot update another owner's hostels doc
 *  3. an owner cannot set their own verificationStatus to verified
 *  4. a signed-out read of an unpublished hostel fails
 *  5. a signed-out read of a published hostel succeeds
 *  6. the viewCount-only increment succeeds for a non-owner, and a
 *     full-document owner update still works
 *  7. role cannot be changed on an existing users/{uid} doc via update
 */

const fs = require('fs');
const path = require('path');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');

let testEnv;

const OWNER_A = 'owner_a_uid';
const OWNER_B = 'owner_b_uid';
const STUDENT = 'student_uid';

const publishedHostel = {
  ownerId: OWNER_A,
  ownerName: 'Owner A',
  name: 'Sunrise Hostel',
  fullAddress: '123 Main St',
  city: 'Hyderabad',
  pricePerMonth: 8000,
  totalRooms: 10,
  photos: [],
  amenities: [],
  availability: 'available',
  status: 'published',
  contactPhone: '03001234567',
  contactWhatsapp: '03001234567',
  rating: 4.2,
  reviewCount: 3,
  viewCount: 10,
  isFeatured: false,
};

const draftHostel = { ...publishedHostel, status: 'draft' };

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-hostel-finder-rules-test',
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, '..', 'firestore.rules'), 'utf8'),
    },
  });
});

after(async () => {
  if (testEnv) await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

describe('users/{uid}', () => {
  it('role cannot be changed on an existing doc via update', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(STUDENT).set({
        role: 'student',
        displayName: 'Ali',
        email: 'ali@example.com',
        verificationStatus: 'unverified',
      });
    });

    const asStudent = testEnv.authenticatedContext(STUDENT).firestore();
    await assertFails(
      asStudent.collection('users').doc(STUDENT).update({ role: 'owner' })
    );
  });

  it('an owner cannot set their own verificationStatus to verified', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({
        role: 'owner',
        displayName: 'Owner A',
        email: 'owner@example.com',
        verificationStatus: 'unverified',
      });
    });

    const asOwner = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertFails(
      asOwner
        .collection('users')
        .doc(OWNER_A)
        .update({ verificationStatus: 'verified' })
    );
  });

  it('a legitimate self-update that leaves role/verificationStatus unchanged succeeds', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(STUDENT).set({
        role: 'student',
        displayName: 'Ali',
        email: 'ali@example.com',
        verificationStatus: 'unverified',
      });
    });

    const asStudent = testEnv.authenticatedContext(STUDENT).firestore();
    await assertSucceeds(
      asStudent.collection('users').doc(STUDENT).update({
        displayName: 'Ali Khan',
        role: 'student',
        verificationStatus: 'unverified',
      })
    );
  });
});

describe('hostels/{id}', () => {
  it('a student cannot create a hostels doc', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(STUDENT).set({ role: 'student' });
    });

    const asStudent = testEnv.authenticatedContext(STUDENT).firestore();
    await assertFails(
      asStudent
        .collection('hostels')
        .doc('h1')
        .set({ ...publishedHostel, ownerId: STUDENT })
    );
  });

  it("an owner cannot update another owner's hostels doc", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('users').doc(OWNER_B).set({ role: 'owner' });
      await ctx.firestore().collection('hostels').doc('h1').set(publishedHostel);
    });

    const asOwnerB = testEnv.authenticatedContext(OWNER_B).firestore();
    await assertFails(
      asOwnerB.collection('hostels').doc('h1').set({ ...publishedHostel, name: 'Hijacked' })
    );
  });

  it('an owner cannot inflate rating/viewCount via a normal update', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('hostels').doc('h1').set(publishedHostel);
    });

    const asOwnerA = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertFails(
      asOwnerA
        .collection('hostels')
        .doc('h1')
        .set({ ...publishedHostel, rating: 5.0 })
    );
  });

  it('a full-document owner update that leaves rating/viewCount unchanged succeeds', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('hostels').doc('h1').set(publishedHostel);
    });

    const asOwnerA = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertSucceeds(
      asOwnerA
        .collection('hostels')
        .doc('h1')
        .set({ ...publishedHostel, pricePerMonth: 9000 })
    );
  });

  it('the viewCount-only increment succeeds for a non-owner (student)', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(STUDENT).set({ role: 'student' });
      await ctx.firestore().collection('hostels').doc('h1').set(publishedHostel);
    });

    const asStudent = testEnv.authenticatedContext(STUDENT).firestore();
    await assertSucceeds(
      asStudent
        .collection('hostels')
        .doc('h1')
        .update({ viewCount: publishedHostel.viewCount + 1 })
    );
  });

  it('a signed-out read of a published hostel succeeds', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('hostels').doc('h1').set(publishedHostel);
    });

    const asGuest = testEnv.unauthenticatedContext().firestore();
    await assertSucceeds(asGuest.collection('hostels').doc('h1').get());
  });

  it('a signed-out read of an unpublished (draft) hostel fails', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('hostels').doc('h1').set(draftHostel);
    });

    const asGuest = testEnv.unauthenticatedContext().firestore();
    await assertFails(asGuest.collection('hostels').doc('h1').get());
  });

  it('the owner can still read their own unpublished (draft) hostel', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('hostels').doc('h1').set(draftHostel);
    });

    const asOwnerA = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertSucceeds(asOwnerA.collection('hostels').doc('h1').get());
  });

  // 2.A — every brand-new listing requires admin approval before going
  // live. These two tests are the server-side enforcement of that: without
  // them, a client could bypass AddListingController.publishListing()'s
  // pending gate entirely by writing status: 'published' straight to
  // Firestore.
  it('an owner cannot create a hostel doc with status published directly', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
    });

    const asOwnerA = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertFails(
      asOwnerA.collection('hostels').doc('h1').set(publishedHostel)
    );
  });

  it('an owner can create a hostel doc with status pending', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
    });

    const asOwnerA = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertSucceeds(
      asOwnerA.collection('hostels').doc('h1').set({ ...publishedHostel, status: 'pending' })
    );
  });

  it('an owner cannot self-approve a pending hostel by updating status to published', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx
        .firestore()
        .collection('hostels')
        .doc('h1')
        .set({ ...publishedHostel, status: 'pending' });
    });

    const asOwnerA = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertFails(
      asOwnerA
        .collection('hostels')
        .doc('h1')
        .set({ ...publishedHostel, status: 'published' })
    );
  });

  it('an owner can still edit an already-published hostel and it stays published', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('hostels').doc('h1').set(publishedHostel);
    });

    const asOwnerA = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertSucceeds(
      asOwnerA
        .collection('hostels')
        .doc('h1')
        .set({ ...publishedHostel, name: 'Sunrise Hostel (Updated)', status: 'published' })
    );
  });
});

describe('users/{uid}/saved/{hostelId}', () => {
  it("a student cannot read another student's saved subcollection", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx
        .firestore()
        .collection('users')
        .doc(STUDENT)
        .collection('saved')
        .doc('h1')
        .set({ hostelId: 'h1', name: 'Sunrise Hostel' });
    });

    const otherStudent = testEnv.authenticatedContext('other_student').firestore();
    await assertFails(
      otherStudent.collection('users').doc(STUDENT).collection('saved').doc('h1').get()
    );
  });
});

describe('activities/{id}', () => {
  it("an owner cannot read another owner's activities", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('users').doc(OWNER_B).set({ role: 'owner' });
      await ctx
        .firestore()
        .collection('activities')
        .doc('a1')
        .set({ ownerId: OWNER_A, type: 'listing_created', title: 't', message: 'm', createdAt: new Date() });
    });

    const asOwnerB = testEnv.authenticatedContext(OWNER_B).firestore();
    await assertFails(asOwnerB.collection('activities').doc('a1').get());
  });
});

describe('verifications/{uid}', () => {
  it('an owner can read and write their own verification doc', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
    });

    const asOwnerA = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertSucceeds(
      asOwnerA.collection('verifications').doc(OWNER_A).set({ status: 'draft' })
    );
    await assertSucceeds(asOwnerA.collection('verifications').doc(OWNER_A).get());
  });

  it('an owner cannot read or write another owner verification doc', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('users').doc(OWNER_B).set({ role: 'owner' });
      await ctx.firestore().collection('verifications').doc(OWNER_A).set({ status: 'pending' });
    });

    const asOwnerB = testEnv.authenticatedContext(OWNER_B).firestore();
    await assertFails(asOwnerB.collection('verifications').doc(OWNER_A).get());
    await assertFails(
      asOwnerB.collection('verifications').doc(OWNER_A).set({ status: 'draft' })
    );
  });
  
  it('an owner cannot create a doc with status approved/rejected/changesRequested', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
    });

    const asOwnerA = testEnv.authenticatedContext(OWNER_A).firestore();
    for (const status of ['approved', 'rejected', 'changesRequested']) {
      await assertFails(
        asOwnerA.collection('verifications').doc(OWNER_A).set({ status })
      );
    }
  });

  it('an owner cannot move their own doc to approved/rejected/changesRequested via update', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('verifications').doc(OWNER_A).set({ status: 'pending' });
    });

    const asOwnerA = testEnv.authenticatedContext(OWNER_A).firestore();
    for (const status of ['approved', 'rejected', 'changesRequested']) {
      await assertFails(
        asOwnerA.collection('verifications').doc(OWNER_A).update({ status })
      );
    }
  });

  it('an owner cannot set reviewedBy/reviewedAt/rejectionReason on their own doc', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('verifications').doc(OWNER_A).set({ status: 'draft' });
    });

    const asOwnerA = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertFails(
      asOwnerA
        .collection('verifications')
        .doc(OWNER_A)
        .update({ status: 'pending', reviewedBy: 'admin_uid' })
    );
    await assertFails(
      asOwnerA
        .collection('verifications')
        .doc(OWNER_A)
        .update({ status: 'pending', reviewedAt: new Date() })
    );
    await assertFails(
      asOwnerA
        .collection('verifications')
        .doc(OWNER_A)
        .update({ status: 'pending', rejectionReason: 'self-approved, nice try' })
    );
  });

  it('a draft -> pending submit that leaves reviewedBy/reviewedAt untouched succeeds', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('verifications').doc(OWNER_A).set({ status: 'draft' });
    });

    const asOwnerA = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertSucceeds(
      asOwnerA
        .collection('verifications')
        .doc(OWNER_A)
        .update({ status: 'pending', submittedAt: new Date() })
    );
  });

  it('a signed-out read of a verification doc fails', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('verifications').doc(OWNER_A).set({ status: 'pending' });
    });

    const asGuest = testEnv.unauthenticatedContext().firestore();
    await assertFails(asGuest.collection('verifications').doc(OWNER_A).get());
  });
});
