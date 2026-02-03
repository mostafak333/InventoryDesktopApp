import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import 'auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _projectController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    String t(String key) => AppLocalizations.of(context)?.translate(key) ?? key;

    return Scaffold(
      appBar: AppBar(title: Text(t('register'))),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _projectController,
              decoration: InputDecoration(labelText: t('project_name')),
            ),
            TextField(
              controller: _userController,
              decoration: InputDecoration(labelText: t('username')),
            ),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: InputDecoration(labelText: t('password')),
            ),
            const SizedBox(height: 30),
            authState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref
                            .read(authControllerProvider.notifier)
                            .registerProject(
                              projectName: _projectController.text,
                              username: _userController.text,
                              password: _passController.text,
                            );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t('registration_success'))),
                          );
                          Navigator.pop(context); // Go back to Login
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t('registration_error'))),
                          );
                        }
                      }
                    },
                    child: Text(t('register_button')),
                  ),
          ],
        ),
      ),
    );
  }
}
