import 'dart:developer';

import 'package:docs_clone/Screens/home_screen.dart';
import 'package:docs_clone/Screens/login_screen.dart';
import 'package:docs_clone/models/error_models.dart';
import 'package:docs_clone/repository/auth_repository.dart';
import 'package:docs_clone/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  errorModel? ModelError;
  
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    ModelError = await ref.read(AuthRepositoryProvider).getUserData();
    print(ModelError);
    if(ModelError!=null && ModelError?.data != null ){
      ref.read(userProvider.notifier).update((state) => ModelError!.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(DateTime.now());
    return MaterialApp.router(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: RoutemasterDelegate(routesBuilder: (context){
        final user = ref.watch(userProvider);
        if(user!=null && user.token.isNotEmpty){
          return loggedIn;
        }
        return loggedOut;
      }),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}

