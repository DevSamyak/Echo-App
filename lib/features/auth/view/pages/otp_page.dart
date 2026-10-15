import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:client/features/home/view/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  const OtpPage({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
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

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Pallete.whiteColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Pallete.cardColor,
        border: Border.all(color: Pallete.borderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: Pallete.gradient2, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: Pallete.gradient1, width: 2),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pallete.transparentColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Loader()
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Verify OTP',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Code sent to ${widget.phoneNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Pallete.subtitleText,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Pinput(
                        length: 6,
                        controller: otpController,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        showCursor: true,
                        onCompleted: (pin) async {
                          await ref
                              .read(authViewmodelProvider.notifier)
                              .verifyOtp(pin);
                        },
                      ),
                      const SizedBox(height: 30),
                      AuthGradientButton(
                        buttontext: 'Verify',
                        onTap: () async {
                          final otp = otpController.text.trim();
                          if (otp.length != 6) {
                            showSnackBar(
                              context,
                              'Please enter a valid 6-digit OTP',
                            );
                            return;
                          }
                          await ref
                              .read(authViewmodelProvider.notifier)
                              .verifyOtp(otp);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () async {
                          final success = await ref
                              .read(authViewmodelProvider.notifier)
                              .sendOtp(widget.phoneNumber);
                          if (success && context.mounted) {
                            showSnackBar(context, 'OTP resent successfully');
                          }
                        },
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: Pallete.gradient2,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
