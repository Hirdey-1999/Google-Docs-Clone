import 'package:docs_clone/Screens/document_screen.dart';
import 'package:docs_clone/Screens/home_screen.dart';
import 'package:docs_clone/Screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

final loggedOut = RouteMap(routes: {
  '/': (route) => const MaterialPage(
        child: LoginButton(),
      ),
});

final loggedIn = RouteMap(routes: {
  '/': (route) => MaterialPage(
        child: homeScreen(),
      ),
  '/document/:id': (route) => MaterialPage(
        child: documentScreen(
          id: route.pathParameters['id'] ?? '',
        ),
      ),
});
