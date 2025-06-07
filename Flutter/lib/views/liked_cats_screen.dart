import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../domain/like_cubit.dart';
import '../models/liked_cat.dart';
import '../controllers/detail_screen.dart';

class LikedCatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LikeCubit>();

    final breeds = ['Все породы', ...{
      for (final cat in cubit.state.likedCats) cat.cat.breedName
    }];

    return Scaffold(
      appBar: AppBar(title: Text('Лайкнутые котики')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: const Text("Фильтр по породе"),
              value: cubit.state.selectedBreed ?? 'Все породы',
              isExpanded: true,
              items: breeds
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (value) => cubit.filterByBreed(
                value == 'Все породы' ? null : value,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<LikeCubit, LikeState>(
              builder: (context, state) {
                if (state.filtered.isEmpty) {
                  return Center(child: Text('Нет лайкнутых котов'));
                }
                return ListView.builder(
                  itemCount: state.filtered.length,
                  itemBuilder: (context, index) {
                    final likedCat = state.filtered[index];
                    final formattedDate =
                    DateFormat('dd.MM.yyyy HH:mm').format(likedCat.likedAt);
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: likedCat.cat.imageUrl,
                          width: 60,
                          placeholder: (context, url) =>
                              SizedBox(width: 60, child: Center(child: CircularProgressIndicator())),
                          errorWidget: (context, url, error) =>
                              Container(width: 60, color: Colors.grey[200], child: Icon(Icons.broken_image)),
                        ),
                        title: Text(likedCat.cat.breedName),
                        subtitle: Text('Дата лайка: $formattedDate'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(cat: likedCat.cat),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => cubit.remove(likedCat),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
