import 'package:docs_clone/Screens/home_screen.dart';
import 'package:docs_clone/color.dart';
import 'package:docs_clone/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class LoginButton extends ConsumerWidget {
  const LoginButton({Key? key}) : super(key: key);
  void signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final sMessenger = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);
    final errorModel = await ref.read(AuthRepositoryProvider).signWithGoogle();
    if (errorModel.error == null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      navigator.replace('/');
    } else {
      sMessenger.showSnackBar(
        SnackBar(
          content: Text(errorModel.error!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => signInWithGoogle(ref, context),
          icon: Image.asset(
            'assets/images/glogo.jpg',
            height: 40,
          ),
          label: Text('Sign In With Google',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              )),
          style: ElevatedButton.styleFrom(
            primary: kwhitecolor,
            minimumSize: const Size(150, 50),
          ),
        ),
      ),
    );
  }
}
