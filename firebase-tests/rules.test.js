/**
 * Firestore security-rules emulator tests — TASK-Phase-7.md Block D.7,
 * extended by TASK-Phase-9.md Block A.7 (the `describe('isAdmin() — Phase 9
 * admin-broad rules', ...)` block near the bottom of this file).
 *
 * These were written as part of the Phase 7 audit because D.7 lists rules
 * unit tests as a GATE for the phase, not a follow-up, and none existed.
 * The Phase 9 admin-rules block was added for the same reason — Block A.7
 * treats this suite passing as a completion gate for Block A itself, and
 * this pass found a genuine bug hiding behind that gap: isAdmin() only ever
 * granted READ access on users/*, hostels/*, verifications/* — there was no
 * admin WRITE rule anywhere, so Block G.5's Approve batch (which updates
 * all three collections) would have failed with permission-denied on every
 * field against real deployed rules, despite the Dart code compiling fine.
 * The admin-only, narrowly-scoped update/delete rules these new tests cover
 * were added in the same pass as the tests themselves.
 *
 * Confirmed NOT run as part of this pass — this sandboxed environment has
 * no Java runtime (`java -version` → command not found), and the Firestore
 * emulator requires one to start at all; this isn't a "didn't get to it"
 * gap, it's a hard environment limitation. A human (or CI, which likely has
 * Java) must run:
 *
 *   cd hostel_finder_app/firebase-tests
 *   npm install
 *   firebase emulators:exec --project demo-hostel-finder-rules-test --only firestore "npm test"
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
const ADMIN = 'admin_uid';

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
      asOwnerA
        .collection('hostels')
        .doc('h1')
        .set({ ...publishedHostel, status: 'pending', rating: 0, reviewCount: 0, viewCount: 0 })
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

/**
 * Phase 9 Block A.7/G.5 — isAdmin()'s admin-broad rules. This project's own
 * highest-blast-radius rule change so far (every prior rule was "a user can
 * read/write their own doc only"); TASK-Phase-9.md's own exit criteria treat
 * this suite passing as a completion GATE for Block A, not a follow-up.
 *
 * Also covers the admin-write rules added alongside isAdmin() itself
 * (users/{uid}, hostels/{id}, verifications/{uid}) — without these, Block
 * G.5's 3-document batched Approve write fails with permission-denied on
 * every field, since the pre-existing owner-scoped update rules never
 * granted an admin session write access at all (a real bug this pass found
 * and fixed, not a hypothetical).
 */
describe('isAdmin() — Phase 9 admin-broad rules', () => {
  it('an admin can reject a hostel with a reason; an owner cannot set the reason', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(ADMIN).set({ role: 'admin' });
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('hostels').doc('rej1').set({
        ownerId: OWNER_A, name: 'H', fullAddress: 'a', city: 'c', pricePerMonth: 5,
        rating: 0, viewCount: 0, status: 'pending',
      });
    });

    const asAdmin = testEnv.authenticatedContext(ADMIN).firestore();
    await assertSucceeds(
      asAdmin.collection('hostels').doc('rej1').update({ status: 'rejected', rejectionReason: 'Blurry photos' })
    );
    await assertFails(
      asAdmin.collection('hostels').doc('rej1').update({ rejectionReason: 'x'.repeat(501) })
    );

    const asOwner = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertFails(
      asOwner.collection('hostels').doc('rej1').update({ rejectionReason: 'tampered' })
    );
  });

  it('an admin can read any user doc', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(ADMIN).set({ role: 'admin' });
      await ctx.firestore().collection('users').doc(STUDENT).set({ role: 'student' });
    });

    const asAdmin = testEnv.authenticatedContext(ADMIN).firestore();
    await assertSucceeds(asAdmin.collection('users').doc(STUDENT).get());
  });

  it('a non-admin (owner) cannot read another user doc', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('users').doc(STUDENT).set({ role: 'student' });
    });

    const asOwnerA = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertFails(asOwnerA.collection('users').doc(STUDENT).get());
  });

  it('an admin can block a user (users/{uid}.status) without touching role', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(ADMIN).set({ role: 'admin' });
      await ctx.firestore().collection('users').doc(STUDENT).set({
        role: 'student',
        status: 'active',
        verificationStatus: 'unverified',
      });
    });

    const asAdmin = testEnv.authenticatedContext(ADMIN).firestore();
    await assertSucceeds(
      asAdmin.collection('users').doc(STUDENT).update({ status: 'blocked' })
    );
  });

  it("an admin cannot change a user's role or displayName via the admin update rule", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(ADMIN).set({ role: 'admin' });
      await ctx.firestore().collection('users').doc(STUDENT).set({
        role: 'student',
        displayName: 'Ali',
        status: 'active',
      });
    });

    const asAdmin = testEnv.authenticatedContext(ADMIN).firestore();
    await assertFails(
      asAdmin.collection('users').doc(STUDENT).update({ role: 'owner' })
    );
    await assertFails(
      asAdmin.collection('users').doc(STUDENT).update({ displayName: 'Hijacked' })
    );
  });

  it('an admin can delete a user doc; another user cannot', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(ADMIN).set({ role: 'admin' });
      await ctx.firestore().collection('users').doc(STUDENT).set({ role: 'student' });
    });

    // A plain user can no longer delete SOMEONE ELSE's profile (they may
    // delete their own — covered in the release-hardening block below).
    const asOwnerOther = testEnv.authenticatedContext(OWNER_B).firestore();
    await assertFails(asOwnerOther.collection('users').doc(STUDENT).delete());

    const asAdmin = testEnv.authenticatedContext(ADMIN).firestore();
    await assertSucceeds(asAdmin.collection('users').doc(STUDENT).delete());
  });

  it('an admin can read any hostel regardless of status', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(ADMIN).set({ role: 'admin' });
      await ctx.firestore().collection('hostels').doc('h1').set(draftHostel);
    });

    const asAdmin = testEnv.authenticatedContext(ADMIN).firestore();
    await assertSucceeds(asAdmin.collection('hostels').doc('h1').get());
  });

  it('an admin can flip a pending hostel to published (Approve); an owner cannot', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(ADMIN).set({ role: 'admin' });
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx
        .firestore()
        .collection('hostels')
        .doc('h1')
        .set({ ...publishedHostel, status: 'pending' });
    });

    const asAdmin = testEnv.authenticatedContext(ADMIN).firestore();
    await assertSucceeds(
      asAdmin.collection('hostels').doc('h1').update({ status: 'published' })
    );
  });

  it('an admin cannot touch other hostel fields via the admin-only status rule', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(ADMIN).set({ role: 'admin' });
      await ctx.firestore().collection('hostels').doc('h1').set(publishedHostel);
    });

    const asAdmin = testEnv.authenticatedContext(ADMIN).firestore();
    await assertFails(
      asAdmin.collection('hostels').doc('h1').update({ status: 'published', pricePerMonth: 1 })
    );
  });

  it('an admin can delete any hostel', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(ADMIN).set({ role: 'admin' });
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('hostels').doc('h1').set(publishedHostel);
    });

    const asAdmin = testEnv.authenticatedContext(ADMIN).firestore();
    await assertSucceeds(asAdmin.collection('hostels').doc('h1').delete());
  });

  it('an admin can read and approve another owner verification doc', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(ADMIN).set({ role: 'admin' });
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('verifications').doc(OWNER_A).set({ status: 'pending' });
    });

    const asAdmin = testEnv.authenticatedContext(ADMIN).firestore();
    await assertSucceeds(asAdmin.collection('verifications').doc(OWNER_A).get());
    await assertSucceeds(
      asAdmin.collection('verifications').doc(OWNER_A).update({
        status: 'approved',
        reviewedBy: ADMIN,
      })
    );
  });

  it('a non-admin owner still cannot approve their own verification doc', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('verifications').doc(OWNER_A).set({ status: 'pending' });
    });

    const asOwnerA = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertFails(
      asOwnerA.collection('verifications').doc(OWNER_A).update({ status: 'approved' })
    );
  });

  it('an admin can read and resolve reports; a non-admin cannot', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(ADMIN).set({ role: 'admin' });
      await ctx.firestore().collection('users').doc(STUDENT).set({ role: 'student' });
      await ctx.firestore().collection('reports').doc('r1').set({
        hostelId: 'h1',
        reportedBy: STUDENT,
        reason: 'spam',
        status: 'open',
      });
    });

    const asStudent = testEnv.authenticatedContext(STUDENT).firestore();
    await assertFails(asStudent.collection('reports').doc('r1').get());

    const asAdmin = testEnv.authenticatedContext(ADMIN).firestore();
    await assertSucceeds(asAdmin.collection('reports').doc('r1').get());
    await assertSucceeds(
      asAdmin.collection('reports').doc('r1').update({ status: 'resolved' })
    );
  });

  it('anyone can read config/appSettings; only an admin can write it', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(ADMIN).set({ role: 'admin' });
    });

    const asGuest = testEnv.unauthenticatedContext().firestore();
    await assertSucceeds(asGuest.collection('config').doc('appSettings').get());
    await assertFails(
      asGuest.collection('config').doc('appSettings').set({ maintenanceMode: true })
    );

    const asAdmin = testEnv.authenticatedContext(ADMIN).firestore();
    await assertSucceeds(
      asAdmin.collection('config').doc('appSettings').set({ maintenanceMode: true }, { merge: true })
    );
  });
});


describe('release hardening (self-verification, block bypass, self-featuring, account deletion, reports)', () => {
  it('a new profile cannot be created already verified or non-active', async () => {
    const asNew = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertFails(
      asNew.collection('users').doc(OWNER_A).set({ role: 'owner', verificationStatus: 'verified', status: 'active' })
    );
    await assertFails(
      asNew.collection('users').doc(OWNER_A).set({ role: 'owner', verificationStatus: 'unverified', status: 'blocked' })
    );
    await assertSucceeds(
      asNew.collection('users').doc(OWNER_A).set({ role: 'owner', verificationStatus: 'unverified', status: 'active' })
    );
  });

  it('a blocked user cannot set their own status back to active', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(STUDENT).set({
        role: 'student', verificationStatus: 'unverified', status: 'blocked',
      });
    });
    const asStudent = testEnv.authenticatedContext(STUDENT).firestore();
    await assertFails(asStudent.collection('users').doc(STUDENT).update({ status: 'active' }));
  });

  it('a profile that predates verificationStatus/status can still update its name', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(STUDENT).set({ role: 'student', displayName: 'Old' });
    });
    const asStudent = testEnv.authenticatedContext(STUDENT).firestore();
    await assertSucceeds(
      asStudent.collection('users').doc(STUDENT).update({
        displayName: 'New', verificationStatus: 'unverified', status: 'active',
      })
    );
  });

  it('an owner cannot create a pre-rated / pre-viewed / featured listing', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
    });
    const asOwner = testEnv.authenticatedContext(OWNER_A).firestore();
    const base = { ...publishedHostel, status: 'pending', rating: 0, reviewCount: 0, viewCount: 0 };
    await assertFails(asOwner.collection('hostels').doc('h1').set({ ...base, rating: 5 }));
    await assertFails(asOwner.collection('hostels').doc('h2').set({ ...base, viewCount: 999 }));
    await assertFails(asOwner.collection('hostels').doc('h3').set({ ...base, isFeatured: true }));
    await assertSucceeds(asOwner.collection('hostels').doc('h4').set(base));
  });

  it('an owner cannot self-feature an existing listing', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('hostels').doc('h1').set(publishedHostel);
    });
    const asOwner = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertFails(
      asOwner.collection('hostels').doc('h1').set({ ...publishedHostel, isFeatured: true })
    );
  });

  it('a user can delete their own profile; an owner can delete own verification and activities', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
      await ctx.firestore().collection('verifications').doc(OWNER_A).set({ status: 'pending' });
      await ctx.firestore().collection('activities').doc('a1').set({ ownerId: OWNER_A, type: 'x' });
    });
    const asOwner = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertSucceeds(asOwner.collection('verifications').doc(OWNER_A).delete());
    await assertSucceeds(asOwner.collection('activities').doc('a1').delete());
    await assertSucceeds(asOwner.collection('users').doc(OWNER_A).delete());
  });

  it("an owner cannot delete another owner's verification doc or activities", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_B).set({ role: 'owner' });
      await ctx.firestore().collection('verifications').doc(OWNER_A).set({ status: 'pending' });
      await ctx.firestore().collection('activities').doc('a1').set({ ownerId: OWNER_A, type: 'x' });
    });
    const asOtherOwner = testEnv.authenticatedContext(OWNER_B).firestore();
    await assertFails(asOtherOwner.collection('verifications').doc(OWNER_A).delete());
    await assertFails(asOtherOwner.collection('activities').doc('a1').delete());
  });

  it('reports: must be filed as yourself, status open, bounded text', async () => {
    const asStudent = testEnv.authenticatedContext(STUDENT).firestore();
    const ok = { hostelId: 'h1', reportedBy: STUDENT, reason: 'spam', details: 'x', status: 'open' };
    await assertSucceeds(asStudent.collection('reports').doc('r1').set(ok));
    await assertFails(asStudent.collection('reports').doc('r2').set({ ...ok, reportedBy: 'someone_else' }));
    await assertFails(asStudent.collection('reports').doc('r3').set({ ...ok, status: 'resolved' }));
    await assertFails(asStudent.collection('reports').doc('r4').set({ ...ok, details: 'x'.repeat(2001) }));
  });
});


describe('hostel gender (boys/girls)', () => {
  const base = { ...publishedHostel, status: 'pending', rating: 0, reviewCount: 0, viewCount: 0 };

  it('an owner can create a listing with gender boys or girls, or without one (legacy)', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
    });
    const asOwner = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertSucceeds(asOwner.collection('hostels').doc('g1').set({ ...base, gender: 'boys' }));
    await assertSucceeds(asOwner.collection('hostels').doc('g2').set({ ...base, gender: 'girls' }));
    await assertSucceeds(asOwner.collection('hostels').doc('g3').set(base));
  });

  it('an owner cannot create a listing with any other gender value', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().collection('users').doc(OWNER_A).set({ role: 'owner' });
    });
    const asOwner = testEnv.authenticatedContext(OWNER_A).firestore();
    await assertFails(asOwner.collection('hostels').doc('g4').set({ ...base, gender: 'co-ed' }));
    await assertFails(asOwner.collection('hostels').doc('g5').set({ ...base, gender: '' }));
  });
});
