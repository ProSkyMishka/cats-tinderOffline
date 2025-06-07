import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/liked_cat.dart';
import '../services/cat_local_storage.dart';

class LikeState {
  final List<LikedCat> likedCats;
  final String? selectedBreed;

  LikeState({required this.likedCats, this.selectedBreed});

  List<LikedCat> get filtered {
    if (selectedBreed == null || selectedBreed!.isEmpty || selectedBreed == 'Все породы') {
      return likedCats;
    }
    return likedCats.where((c) => c.cat.breedName == selectedBreed).toList();
  }
}

class LikeCubit extends Cubit<LikeState> {
  final CatLocalStorage localStorage;

  LikeCubit({required this.localStorage}) : super(LikeState(likedCats: []));

  Future<void> initialize(List<LikedCat> cats) async {
    emit(LikeState(likedCats: cats));
  }

  void add(LikedCat cat) async {
    final updated = [...state.likedCats, cat];
    await localStorage.saveLikedCats(updated);
    emit(LikeState(likedCats: updated, selectedBreed: state.selectedBreed));
  }

  void remove(LikedCat cat) async {
    final updated = state.likedCats.where((c) => c != cat).toList();
    await localStorage.saveLikedCats(updated);
    emit(LikeState(likedCats: updated, selectedBreed: state.selectedBreed));
  }

  void filterByBreed(String? breed) {
    emit(LikeState(
      likedCats: state.likedCats,
      selectedBreed: breed == 'Все породы' ? null : breed,
    ));
  }

  void clearFilter() {
    emit(LikeState(likedCats: state.likedCats));
  }
}
