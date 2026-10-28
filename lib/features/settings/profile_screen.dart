import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../state/providers.dart';

/// Name and email of the person using the app. Setting up a masjid (and
/// publishing its widgets) requires one; it never leaves the device.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _masjidRole;

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileProvider);
    _name = TextEditingController(text: p?.name ?? '');
    _email = TextEditingController(text: p?.email ?? '');
    _masjidRole = TextEditingController(text: p?.role ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _masjidRole.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_form.currentState?.validate() ?? false)) return;
    ref.read(profileProvider.notifier).save(Profile(name: _name.text.trim(), email: _email.text.trim(), role: _masjidRole.text.trim()));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.profileSaved)));
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final existing = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.profile),
        actions: [TextButton.icon(onPressed: _save, icon: const Icon(Icons.check), label: Text(l.save))],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l.profileIntro, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l.name, prefixIcon: const Icon(Icons.person_outline)),
                  validator: (v) => (v == null || v.trim().length < 2) ? l.enterAName : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(labelText: l.email, prefixIcon: const Icon(Icons.alternate_email)),
                  validator: (v) => (v == null || !_emailRe.hasMatch(v.trim())) ? l.invalidEmail : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _masjidRole,
                  decoration: InputDecoration(labelText: l.masjidRole, hintText: l.masjidRoleHint, prefixIcon: const Icon(Icons.badge_outlined)),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: Text(l.save)),
                if (existing != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(profileProvider.notifier).clear();
                      if (context.canPop()) context.pop();
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l.removeProfile),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
