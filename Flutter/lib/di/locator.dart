import 'package:get_it/get_it.dart';
import '../services/cat_local_storage.dart';
import '../services/cat_local_storage_impl.dart';
import '../domain/like_cubit.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<CatLocalStorage>(() => CatLocalStorageImpl());

  locator.registerFactory<LikeCubit>(
        () => LikeCubit(localStorage: locator<CatLocalStorage>()),
  );
}
