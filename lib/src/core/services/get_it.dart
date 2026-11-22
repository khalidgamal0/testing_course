import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/cubit/send_message_cubit.dart';
import '../../features/models/repositories/gemini_repository_impl.dart';
import 'api_client.dart';
import 'gemini_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<Dio>(Dio.new, dispose: (dio) => dio.close());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(dio: getIt<Dio>()));
  getIt.registerLazySingleton<GeminiService>(
    () => GeminiService(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<SendMessageRepository>(
    () => GeminiRepositoryImpl(geminiService: getIt<GeminiService>()),
  );
  getIt.registerFactory<SendMessageCubit>(
    () => SendMessageCubit(repository: getIt<SendMessageRepository>()),
  );
}
