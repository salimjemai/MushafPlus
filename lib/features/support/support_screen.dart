import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n.dart';
import '../../data/donations.dart';

/// "Support Mushaf+": a store tip jar in the installed iOS/Android app,
/// donation links and bank details everywhere else. The app never unlocks
/// anything for a tip, so the purchases are plain consumables.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  List<ProductDetails> _products = const [];
  bool _loading = true;
  bool _available = false;
  bool _buying = false;
  bool _thanked = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (tipJarPlatform) {
      _sub = _iap.purchaseStream.listen(_onPurchases, onError: (Object e) {
        if (mounted) setState(() => _error = '$e');
      });
      _loadProducts();
    } else {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final available = await _iap.isAvailable();
      if (!available) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final res = await _iap.queryProductDetails(tipProducts.toSet());
      final list = [...res.productDetails]..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      if (mounted) {
        setState(() {
          _available = list.isNotEmpty;
          _products = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '$e';
        });
      }
    }
  }

  Future<void> _buy(ProductDetails p) async {
    setState(() {
      _buying = true;
      _error = null;
    });
    try {
      await _iap.buyConsumable(purchaseParam: PurchaseParam(productDetails: p));
    } catch (e) {
      if (mounted) {
        setState(() {
          _buying = false;
          _error = '$e';
        });
      }
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (mounted) {
            setState(() {
              _thanked = true;
              _buying = false;
            });
          }
        case PurchaseStatus.error:
          if (mounted) {
            setState(() {
              _buying = false;
              _error = p.error?.message;
            });
          }
        case PurchaseStatus.canceled:
          if (mounted) setState(() => _buying = false);
        case PurchaseStatus.pending:
          break;
      }
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/settings'),
        ),
        title: Text(l.supportTitle),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                    child: Icon(Icons.favorite, color: scheme.primary, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(l.supportIntro, style: const TextStyle(height: 1.45))),
                ],
              ),
              const SizedBox(height: 20),
              if (_thanked) ...[
                Card(
                  color: scheme.primaryContainer.withValues(alpha: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Icon(Icons.volunteer_activism, color: scheme.primary),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l.tipThanks, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4))),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (tipJarPlatform) ..._tipJar(l, scheme) else ..._webDonate(l, scheme),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: scheme.error, fontSize: 12.5)),
              ],
              const SizedBox(height: 20),
              Text(l.supportFootnote, style: TextStyle(fontSize: 12, color: scheme.outline, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _tipJar(AppLocalizations l, ColorScheme scheme) {
    if (_loading) return const [Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))];
    if (!_available) {
      return [Text(l.tipUnavailable, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4))];
    }
    final icons = [Icons.coffee_outlined, Icons.local_florist_outlined, Icons.auto_awesome];
    return [
      Text(l.tipJarIntro, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4)),
      const SizedBox(height: 10),
      for (var i = 0; i < _products.length; i++) ...[
        Card(
          child: ListTile(
            leading: Icon(icons[i % icons.length], color: scheme.primary),
            title: Text(_products[i].title.isEmpty ? l.supportTitle : _products[i].title.replaceAll(RegExp(r'\s*\(.*\)$'), '')),
            subtitle: _products[i].description.isEmpty ? null : Text(_products[i].description),
            trailing: FilledButton.tonal(
              onPressed: _buying ? null : () => _buy(_products[i]),
              child: Text(_products[i].price),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
      if (_buying) const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator()),
    ];
  }

  List<Widget> _webDonate(AppLocalizations l, ColorScheme scheme) {
    final links = donationLinks.where((d) => d.url.isNotEmpty).toList();
    if (links.isEmpty && bankDetails.isEmpty) {
      return [Text(l.donateComingSoon, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4))];
    }
    return [
      Text(l.donateIntro, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4)),
      const SizedBox(height: 10),
      for (final d in links) ...[
        Card(
          child: ListTile(
            leading: Icon(Icons.open_in_new, color: scheme.primary),
            title: Text(d.label),
            subtitle: Text(Uri.parse(d.url).host, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => launchUrl(Uri.parse(d.url), mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank'),
          ),
        ),
        const SizedBox(height: 8),
      ],
      if (bankDetails.isNotEmpty)
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.account_balance_outlined, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.bankTransfer, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      SelectableText(bankDetails, style: const TextStyle(height: 1.5, fontFeatures: [FontFeature.tabularFigures()])),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l.copy,
                  icon: const Icon(Icons.copy_outlined),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await Clipboard.setData(const ClipboardData(text: bankDetails));
                    messenger.showSnackBar(SnackBar(content: Text(l.copied)));
                  },
                ),
              ],
            ),
          ),
        ),
    ];
  }
}
