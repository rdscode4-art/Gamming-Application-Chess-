import 'package:get_it/get_it.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/guest_login_usecase.dart';
import '../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../features/matchmaking/presentation/blocs/matchmaking_bloc.dart';
import '../../features/game/presentation/blocs/game_bloc.dart';
import '../../features/wallet/presentation/blocs/wallet_bloc.dart';
import '../../features/matchmaking/data/repositories/matchmaking_repository.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/home/data/repositories/leaderboard_repository.dart';
import '../../features/home/data/repositories/home_repository.dart';
import '../../features/home/presentation/blocs/home_bloc.dart';
import '../../features/profile/presentation/blocs/profile_bloc.dart';
import '../../features/home/presentation/blocs/leaderboard_bloc.dart';
import '../../features/tournament/data/repositories/tournament_repository.dart';
import '../../features/tournament/presentation/blocs/tournament_bloc.dart';
import '../../features/notifications/data/repositories/notification_repository.dart';
import '../../features/notifications/presentation/blocs/notification_bloc.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  // --- Repositories ---
  getIt.registerLazySingleton<AuthRepositoryImpl>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<MatchmakingRepository>(() => MatchmakingRepository());
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepository());
  getIt.registerLazySingleton<LeaderboardRepository>(() => LeaderboardRepository());
  getIt.registerLazySingleton<TournamentRepository>(() => TournamentRepository());
  getIt.registerLazySingleton<HomeRepository>(() => HomeRepository());
  getIt.registerLazySingleton<NotificationRepository>(() => NotificationRepository());

  // --- UseCases ---
  getIt.registerLazySingleton<GuestLoginUseCase>(() => GuestLoginUseCase(getIt<AuthRepositoryImpl>()));

  // --- Blocs ---
  // We register Blocs as factories so that a new instance is created if needed, 
  // or lazy singletons if they maintain global state across the app.
  getIt.registerFactory(() => AuthBloc());
  
  getIt.registerLazySingleton<MatchmakingBloc>(() => MatchmakingBloc(repository: getIt<MatchmakingRepository>()));
  getIt.registerFactory<GameBloc>(() => GameBloc());
  getIt.registerLazySingleton<WalletBloc>(() => WalletBloc());
  getIt.registerLazySingleton<ProfileBloc>(() => ProfileBloc(getIt<ProfileRepository>()));
  getIt.registerFactory<LeaderboardBloc>(() => LeaderboardBloc(getIt<LeaderboardRepository>()));
  getIt.registerFactory<TournamentBloc>(() => TournamentBloc(getIt<TournamentRepository>()));
  getIt.registerFactory<HomeBloc>(() => HomeBloc(repository: getIt<HomeRepository>()));
  getIt.registerFactory<NotificationBloc>(() => NotificationBloc(getIt<NotificationRepository>()));
}
