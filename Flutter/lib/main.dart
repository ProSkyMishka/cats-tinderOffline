// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'di/locator.dart';
import 'services/cat_local_storage.dart';
import 'models/liked_cat.dart';
import 'controllers//main_screen.dart';
import 'domain/like_cubit.dart';

final getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupLocator();

  final localStorage = getIt<CatLocalStorage>();
  final savedCats = await localStorage.loadLikedCats();

  runApp(MyApp(savedCats: savedCats));
}

class MyApp extends StatelessWidget {
  final List<LikedCat> savedCats;

  const MyApp({Key? key, required this.savedCats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
          getIt<LikeCubit>()..initialize(savedCats),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MainScreen(),
      ),
    );
  }
}
