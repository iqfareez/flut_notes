import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'no_auth.dart';
import 'phone_auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        SvgPicture.asset(
          'assets/blob-scene-haikei.svg',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => const PhoneAuth()),
                      );
                    },
                    child: const Text('Continue with phone number')),
                const SizedBox(height: 10),
                const Text(
                  'or',
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (builder) => const NoAuth()),
                    );
                  },
                  child: const Text('Continue without account'),
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
