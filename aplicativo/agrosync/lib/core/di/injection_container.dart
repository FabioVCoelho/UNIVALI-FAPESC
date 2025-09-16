import 'package:agrosync/features/plants/data/datasources/plant_local_data_source.dart';
import 'package:agrosync/features/plants/data/datasources/plant_local_data_source_impl.dart';
import 'package:agrosync/features/plants/data/datasources/plant_remote_data_source.dart';
import 'package:agrosync/features/plants/data/datasources/plant_remote_data_source_impl.dart';
import 'package:agrosync/features/plants/data/repositories/plant_repository_impl.dart';
import 'package:agrosync/features/plants/domain/repositories/plant_repository.dart';
import 'package:agrosync/features/plants/domain/usecases/delete_plant.dart';
import 'package:agrosync/features/plants/domain/usecases/get_all_plants.dart';
import 'package:agrosync/features/plants/domain/usecases/sync_with_firestore.dart';
import 'package:agrosync/features/plants/domain/usecases/update_plant.dart';
import 'package:agrosync/features/plants/presentation/bloc/plant_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../features/plants/domain/usecases/add_plant.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Register services
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<Box>(() => Hive.box('plant_box'));

  // Data sources
  sl.registerLazySingleton<PlantLocalDataSource>(
    () => PlantLocalDataSourceImpl(plantBox: sl<Box>()),
  );
  sl.registerLazySingleton<PlantRemoteDataSource>(
    () => PlantRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );

  // Repositories
  sl.registerLazySingleton<PlantRepository>(
    () => PlantRepositoryImpl(
      localDataSource: sl<PlantLocalDataSource>(),
      remoteDataSource: sl<PlantRemoteDataSource>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllPlants(sl<PlantRepository>()));
  sl.registerLazySingleton(() => UpdatePlant(sl<PlantRepository>()));
  sl.registerLazySingleton(() => DeletePlant(sl<PlantRepository>()));
  sl.registerLazySingleton(() => SyncWithFirestore(sl<PlantRepository>()));
  sl.registerLazySingleton(() => AddPlant(sl<PlantRepository>()));

  // BLoC
  sl.registerFactory(
    () => PlantBloc(
      getAllPlants: sl<GetAllPlants>(),
      updatePlant: sl<UpdatePlant>(),
      deletePlant: sl<DeletePlant>(),
      syncWithFirestore: sl<SyncWithFirestore>(),
      addPlant: sl<AddPlant>(),
    ),
  );
}