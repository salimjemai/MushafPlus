import 'package:flutter/foundation.dart';

/// Where support for Mushaf+ comes from, per platform.
///
/// Store rule of thumb (Apple 3.1.1, Google Play Payments policy): a tip to
/// the developer inside the iOS/Android app must go through the store's own
/// in-app purchase, with no links to other payment methods. The website is
/// free to point at Stripe, PayPal or a bank account. So:
///  * iOS/Android → [tipProducts] bought with `in_app_purchase`
///  * web/desktop → [donationLinks] and [bankDetails]

/// Consumable product ids. Create the same ids in App Store Connect
/// (In-App Purchases → Consumable) and in Play Console (Monetize → Products
/// → In-app products). Prices are set there, never here.
const tipProducts = <String>['mushafplus_tip_small', 'mushafplus_tip_medium', 'mushafplus_tip_large'];

class DonationLink {
  const DonationLink(this.label, this.url);
  final String label;
  final String url;
}

/// Web / desktop donation links. Empty entries are skipped, so fill in only
/// what exists, for example:
///   DonationLink('Stripe', 'https://donate.stripe.com/XXXX'),
///   DonationLink('PayPal', 'https://www.paypal.com/donate/?hosted_button_id=XXXX'),
///   DonationLink('Ko-fi', 'https://ko-fi.com/XXXX'),
const donationLinks = <DonationLink>[
  DonationLink('PayPal', 'https://paypal.me/salimjemai'),
];

/// Bank transfer details shown on the web donate page with a copy button
/// (leave empty to hide the card). One field per line, e.g.
/// "Account name: …\nIBAN: …\nBIC: …".
const bankDetails = '';

/// True where the store tip jar applies (installed iOS/Android app).
bool get tipJarPlatform => !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android);

bool get hasDonationLinks => donationLinks.any((l) => l.url.isNotEmpty) || bankDetails.isNotEmpty;
