#!/usr/bin/env python3
"""Generates the legal documents from ONE source so the in-app screens
(lib/core/constants/legal_content.dart) and the hosted pages (legal/*.html)
can never drift apart.

Run from hostel_finder_app/:   python tool/generate_legal.py
Edit the text here, then re-run. Placeholders in {BRACES} are filled from
the CONFIG block below. Set SUPPORT_EMAIL before you publish.
"""
import html
import pathlib

CONFIG = {
    "APP": "HostelPin",
    "SUPPORT_EMAIL": "usaidkhanchandio@gmail.com",
    "UPDATED": "13 November 2026",
    "COUNTRY": "Pakistan",
}

PRIVACY = [
    ("Who we are", [
        "{APP} is a mobile app that helps students find hostels and lets hostel owners list them. This policy explains what personal data {APP} collects, why, who we share it with, and the choices you have.",
        "Questions or requests: {SUPPORT_EMAIL}.",
    ]),
    ("Information we collect", [
        "Account information: your name, email address, phone number, the role you choose (student or owner), and an optional profile photo. If you sign in with Google, we receive your name, email address and profile photo from Google.",
        "Student activity: the hostels you save. Recent searches are kept only in memory on your device for the current session.",
        "Owner listings: the hostel details you publish, including name, address, price, description, facilities, contact phone and WhatsApp number, photos, and the map location you pin. This information is shown publicly to students once your listing is approved.",
        "Owner identity verification: to protect students from fake listings, owners who want to list a hostel submit their full name, guardian name, CNIC number, date of birth, phone, email and city, photographs of both sides of their CNIC, a live selfie, and a document proving ownership of the property. These are sensitive documents. They are visible only to you and to {APP} administrators reviewing your application.",
        "Location: if you allow it, we use your device's precise location to show hostels near you on the map and, for owners, to pin a listing's location. We do not track your location in the background and we do not store a history of where you have been.",
        "Camera and photos: the app accesses your camera or photo library only when you choose to take or attach a photo (profile picture, listing photos, verification documents).",
        "Technical data: standard diagnostic information handled by our service providers (for example IP address and device type) when the app connects to their servers.",
    ]),
    ("How we use your information", [
        "To create and secure your account and sign you in.",
        "To show hostels, save your favourites and show hostels near you.",
        "To let owners publish listings, and to let administrators verify owners and approve listings before they appear to students.",
        "To let students contact owners by phone or WhatsApp. When you tap Call or WhatsApp, your phone or WhatsApp opens; we do not see the conversation.",
        "To prevent fraud and abuse, enforce our Terms of Service, and keep the service running.",
        "We do not sell your personal data and we do not use it for advertising.",
    ]),
    ("Who we share it with", [
        "We use the following service providers, who process data on our behalf: Google Firebase (authentication and our database), Google Sign-In, Google Maps, Cloudinary (storage and delivery of photos and verification documents), and Cloudflare (a secure service that authorises uploads of verification documents).",
        "Public information: owner listings (including the owner's name and contact numbers) are visible to other users of the app.",
        "Legal: we may disclose information if required by law or to protect the rights, safety and property of our users or the public.",
    ]),
    ("Verification documents", [
        "Your CNIC images, selfie and ownership document are stored privately with our media provider, are never shown to other users, and are viewable only by administrators for the purpose of reviewing your application. We keep them for as long as your account exists so we can respond to disputes, and delete them after you delete your account (see below).",
    ]),
    ("How long we keep data", [
        "We keep your data while your account is active. When you delete your account we delete your profile, saved hostels, and, for owners, your listings, activity history and verification record from our database immediately. Photos and documents held by our media provider are removed within 30 days of the deletion. Backups and logs may persist for a short additional period before being overwritten.",
    ]),
    ("Deleting your account and your rights", [
        "You can delete your account at any time inside the app: Profile > Account Settings > Delete Account. You can also request deletion at the web address or email shown on our deletion page. You may also ask us to access or correct your data by contacting {SUPPORT_EMAIL}.",
        "You can withdraw location or camera access at any time in your device settings; some features will then be unavailable.",
    ]),
    ("Security", [
        "Data is transmitted over encrypted connections (HTTPS/TLS). Access to the database is restricted by security rules so that, for example, only you and administrators can read your verification record. No method of storage or transmission is completely secure, so we cannot guarantee absolute security.",
    ]),
    ("Children", [
        "{APP} is not directed at children under 13 and we do not knowingly collect their data. Owners must be at least 18 years old. If you believe a child has given us personal data, contact us and we will delete it.",
    ]),
    ("Changes to this policy", [
        "We may update this policy from time to time. The 'Last updated' date above shows the latest version. If changes are significant we will notify you in the app.",
    ]),
    ("Contact", ["{SUPPORT_EMAIL}"]),
]

TERMS = [
    ("Acceptance", [
        "By creating an account or using {APP} you agree to these Terms of Service and to our Privacy Policy. If you do not agree, do not use the app.",
    ]),
    ("The service", [
        "{APP} connects students looking for accommodation with hostel owners. We are a listing and discovery platform. We are not a party to any rental agreement between a student and an owner, we do not collect rent, and we do not guarantee the accuracy, quality, safety or availability of any listing.",
    ]),
    ("Accounts", [
        "You must provide accurate information and keep your password confidential. You are responsible for activity on your account. Owners must be at least 18 and must be the owner of, or authorised to list, the property they submit.",
    ]),
    ("Owner verification and listings", [
        "Owners must complete identity verification before listing. Every new listing is reviewed by an administrator and may be rejected or removed at our discretion, for example if the information is false, the documents are not valid, or the listing breaches these Terms.",
        "You are responsible for the content you submit, including photos, prices and contact details, and you confirm you have the right to publish it. Submitting forged documents or false information may result in permanent removal and referral to the authorities.",
    ]),
    ("Acceptable use", [
        "You agree not to: post false, misleading or fraudulent listings; impersonate another person; harass other users; scrape or misuse the service; attempt to access other users' data; upload unlawful or infringing content; or interfere with the security or operation of the app.",
    ]),
    ("Suspension and termination", [
        "We may suspend or terminate accounts that breach these Terms or put other users at risk. You may stop using the app and delete your account at any time from Account Settings.",
    ]),
    ("Disclaimers and liability", [
        "The service is provided 'as is' without warranties of any kind. To the maximum extent permitted by law, {APP} is not liable for any loss arising from dealings between users, from inaccurate listings, or from interruptions of the service. Students should visit a hostel and verify its details before paying any money.",
    ]),
    ("Changes", [
        "We may update these Terms. Continued use of the app after an update means you accept the new Terms.",
    ]),
    ("Governing law", ["These Terms are governed by the laws of {COUNTRY}."]),
    ("Contact", ["{SUPPORT_EMAIL}"]),
]

DELETE_PAGE = [
    ("How to delete your account in the app", [
        "1. Open {APP} and log in.",
        "2. Go to Profile, then Account Settings.",
        "3. Tap Delete Account and confirm. You may be asked to enter your password, or to sign in with Google again, to confirm it is you.",
    ]),
    ("What is deleted", [
        "Your profile, saved hostels and, for owners, your hostel listings, activity history and identity verification record are deleted from our database immediately. Photos and verification documents stored with our media provider are removed within 30 days. Deletion cannot be undone.",
    ]),
    ("Can't access the app?", [
        "Email {SUPPORT_EMAIL} from the address registered on your account with the subject 'Delete my {APP} account'. We will verify the request and delete your data within 30 days.",
    ]),
]


def fill(text):
    for key, value in CONFIG.items():
        text = text.replace("{" + key + "}", value)
    return text


def dart_str(text):
    escaped = fill(text).replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$")
    return "'" + escaped + "'"


def dart_doc(name, sections):
    out = ["  static const List<LegalSection> %s = [" % name]
    for title, paras in sections:
        out.append("    LegalSection(")
        out.append("      title: %s," % dart_str(title))
        out.append("      paragraphs: [")
        for p in paras:
            out.append("        %s," % dart_str(p))
        out.append("      ],")
        out.append("    ),")
    out.append("  ];")
    return "\n".join(out)


root = pathlib.Path(__file__).resolve().parent.parent
(root / "legal").mkdir(exist_ok=True)

dart = """// GENERATED by tool/generate_legal.py - edit the script, not this file.
// Source of truth for the in-app Privacy Policy and Terms of Service screens
// (legal/*.html are generated from the same text).

class LegalSection {
  final String title;
  final List<String> paragraphs;
  const LegalSection({required this.title, required this.paragraphs});
}

class LegalContent {
  LegalContent._();

  static const String lastUpdated = 'Last updated: %s';
  static const String supportEmail = %s;

%s

%s
}
""" % (CONFIG["UPDATED"], dart_str("{SUPPORT_EMAIL}"),
       dart_doc("privacyPolicy", PRIVACY), dart_doc("termsOfService", TERMS))
(root / "lib/core/constants/legal_content.dart").write_text(dart, encoding="utf-8")

CSS = ("body{font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;max-width:760px;margin:0 auto;"
       "padding:24px 16px 64px;line-height:1.6;color:#1f2430}h1{color:#4b3bb8;margin-bottom:4px}"
       "h2{margin-top:32px;font-size:1.15rem}.meta{color:#667085;margin-top:0}"
       "nav a{margin-right:16px;color:#4b3bb8}p{margin:10px 0}footer{margin-top:48px;color:#667085;font-size:.9rem}")
NAV = ('<nav><a href="index.html">Home</a><a href="privacy.html">Privacy Policy</a>'
       '<a href="terms.html">Terms of Service</a><a href="delete-account.html">Delete account</a></nav>')


def page(title, sections, fname):
    body = "".join(
        "<h2>%s</h2>" % html.escape(fill(t)) + "".join("<p>%s</p>" % html.escape(fill(p)) for p in ps)
        for t, ps in sections)
    doc = ('<!doctype html><html lang="en"><head><meta charset="utf-8">'
           '<meta name="viewport" content="width=device-width,initial-scale=1">'
           "<title>%s - %s</title><style>%s</style></head><body>%s<h1>%s</h1>"
           '<p class="meta">Last updated: %s</p>%s<footer>&copy; %s</footer></body></html>'
           % (title, CONFIG["APP"], CSS, NAV, title, CONFIG["UPDATED"], body, CONFIG["APP"]))
    (root / "legal" / fname).write_text(doc, encoding="utf-8")


page("Privacy Policy", PRIVACY, "privacy.html")
page("Terms of Service", TERMS, "terms.html")
page("Delete your account", DELETE_PAGE, "delete-account.html")
index = ('<!doctype html><html lang="en"><head><meta charset="utf-8">'
         '<meta name="viewport" content="width=device-width,initial-scale=1"><title>%s - Legal</title>'
         "<style>%s</style></head><body><h1>%s</h1><p class=\"meta\">Legal information</p><ul>"
         '<li><a href="privacy.html">Privacy Policy</a></li><li><a href="terms.html">Terms of Service</a></li>'
         '<li><a href="delete-account.html">Delete your account and data</a></li></ul></body></html>'
         % (CONFIG["APP"], CSS, CONFIG["APP"]))
(root / "legal" / "index.html").write_text(index, encoding="utf-8")
print("generated")
