import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/cat.dart';
import '../../models/liked_cat.dart';
import '../../domain/like_cubit.dart';
import '../../views/like_dislike_button.dart';
import '../../views/swipeable_card.dart';
import 'detail_screen.dart';
import '../../views/liked_cats_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Cat? currentCat;
  bool isLoading = false;
  bool isOffline = false;

  static const _apiUrl = 'https://api.thecatapi.com/v1/images/search?has_breeds=true&api_key=live_50UpjVLhDSEH9DmBJIILNqR6F65EKQf7jhVSOQGCvRKtUlNIIPSby0rxQeZcZ55Z';

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    fetchRandomCat();
    Connectivity().onConnectivityChanged.listen((result) {
      final offline = result == ConnectivityResult.none;
      if (offline != isOffline) {
        setState(() {
          isOffline = offline;
        });
        final msg = offline ? 'Отключено от сети' : 'Сеть восстановлена';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    });
  }

  Future<void> _initConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      isOffline = result == ConnectivityResult.none;
    });
  }

  Future<void> fetchRandomCat() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newCat = Cat.fromJson(data[0] as Map<String, dynamic>);

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('last_cat', jsonEncode(newCat.toJson()));
        setState(() {
          currentCat = newCat;
          isLoading = false;
        });
      } else {
        throw Exception('Ошибка ${response.statusCode}');
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getString('last_cat');
      if (local != null) {
        try {
          final savedCat = Cat.fromLocalJson(jsonDecode(local) as Map<String, dynamic>);
          setState(() {
            currentCat = savedCat;
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Нет сети — показан последний загруженный кот")),
          );
        } catch (_) {
          setState(() {
            isLoading = false;
            currentCat = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Нет сети и нет локального кота")),
          );
        }
      } else {
        setState(() {
          isLoading = false;
          currentCat = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Нет сети и нет локального кота")),
        );
      }
    }
  }

  void likeCat() {
    if (currentCat == null) return;
    context.read<LikeCubit>().add(LikedCat(cat: currentCat!, likedAt: DateTime.now()));
    fetchRandomCat();
  }

  void dislikeCat() {
    fetchRandomCat();
  }

  void openDetailScreen() {
    if (currentCat != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailScreen(cat: currentCat!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Cat Browser'),
            if (isOffline) ...[
              SizedBox(width: 8),
              Icon(Icons.wifi_off, color: Colors.red, size: 20),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LikedCatsScreen()),
              );
            },
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : currentCat == null
          ? Center(child: Text('Нет данных'))
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: openDetailScreen,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SwipeableCard(
                cat: currentCat!,
                onLike: likeCat,
                onDislike: dislikeCat,
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              LikeDislikeButton(
                icon: Icons.thumb_down,
                onPressed: dislikeCat,
                color: Colors.red,
              ),
              LikeDislikeButton(
                icon: Icons.thumb_up,
                onPressed: likeCat,
                color: Colors.green,
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Лайков: ${context.watch<LikeCubit>().state.likedCats.length}',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
