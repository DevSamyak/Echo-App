import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/auth/view/pages/otp_page.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:client/features/home/view/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      authViewmodelProvider.select((value) => value?.isLoading == true),
    );

    ref.listen(authViewmodelProvider, (_, next) {
      next?.when(
        data: (user) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        },
        error: (error, st) {
          showSnackBar(context, error.toString());
        },
        loading: () {},
      );
    });

    return Scaffold(
      body: isLoading
          ? const Loader()
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Echo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in to continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Pallete.subtitleText,
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'Enter phone number',
                            prefixIcon: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Text(
                                '+91',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Pallete.whiteColor,
                                ),
                              ),
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your phone number';
                            }
                            final cleaned = value.replaceAll(RegExp(r'\s+'), '');
                            if (cleaned.length < 10) {
                              return 'Enter a valid 10-digit phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        AuthGradientButton(
                          buttontext: 'Send OTP',
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              final phone = phoneController.text.trim();
                              final formattedPhone =
                                  phone.startsWith('+91')
                                      ? phone
                                      : '+91$phone';
                              final success = await ref
                                  .read(authViewmodelProvider.notifier)
                                  .sendOtp(formattedPhone);
                              if (success && context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OtpPage(
                                      phoneNumber: formattedPhone,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 28),
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Pallete.borderColor)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  color: Pallete.subtitleText,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Pallete.borderColor)),
                          ],
                        ),
                        const SizedBox(height: 28),
                        InkWell(
                          onTap: () async {
                            await ref
                                .read(authViewmodelProvider.notifier)
                                .signInWithGoogle();
                          },
                          borderRadius: BorderRadius.circular(7),
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: Pallete.whiteColor,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.g_mobiledata,
                                  color: Colors.black,
                                  size: 36,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
