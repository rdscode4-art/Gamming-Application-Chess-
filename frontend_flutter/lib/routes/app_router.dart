import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/views/splash_screen.dart';
import '../../features/auth/presentation/views/onboarding_screen.dart';
import '../../features/auth/presentation/views/phone_input_screen.dart';
import '../../features/auth/presentation/views/otp_verification_screen.dart';
import '../../features/auth/presentation/views/complete_profile_screen.dart';
import '../../features/home/presentation/views/app_shell.dart';
import '../../features/home/presentation/views/home_screen.dart';
import '../../features/matchmaking/presentation/views/play_mode_screen.dart';
import '../../features/matchmaking/presentation/views/matchmaking_screen.dart';
import '../../features/game/presentation/views/game_screen.dart';
import '../../features/wallet/presentation/views/wallet_screen.dart';
import '../../features/wallet/presentation/views/add_money_screen.dart';
import '../../features/wallet/presentation/views/withdraw_screen.dart';
import '../../features/wallet/presentation/views/transactions_screen.dart';
import '../../features/home/presentation/views/leaderboard_screen.dart';
import '../../features/profile/presentation/views/profile_screen.dart';
import '../../features/profile/presentation/views/settings_screen.dart';
import '../../features/profile/presentation/views/legal_screen.dart';
import '../../features/matchmaking/presentation/views/tournament_detail_screen.dart';
import '../../features/matchmaking/presentation/views/create_tournament_screen.dart';
import '../../features/game/presentation/views/victory_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/di/service_locator.dart';
import '../features/matchmaking/presentation/blocs/matchmaking_bloc.dart';
import '../features/game/presentation/blocs/game_bloc.dart';
import '../features/wallet/presentation/blocs/wallet_bloc.dart';
import '../features/profile/presentation/blocs/profile_bloc.dart';
import '../features/profile/presentation/blocs/profile_event.dart';
import '../features/home/presentation/blocs/leaderboard_bloc.dart';
import '../features/home/presentation/blocs/leaderboard_event.dart';
import '../features/tournament/presentation/blocs/tournament_bloc.dart';
import '../features/tournament/presentation/blocs/tournament_event.dart';
import '../features/home/presentation/blocs/home_bloc.dart';

class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const home = '/home';
  static const playMode = '/play-mode';
  static const matchmaking = '/matchmaking';
  static const game = '/game';
  static const wallet = '/wallet';
  static const addMoney = '/add-money';
  static const withdraw = '/withdraw';
  static const transactions = '/transactions';
  static const leaderboard = '/leaderboard';
  static const tournamentDetail = '/tournament-detail';
  static const createTournament = '/create-tournament';
  static const victory = '/victory';
  static const profile = '/profile';
  static const settings = '/settings';
  static const legal = '/legal';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const PhoneInputScreen(),
      routes: [
        GoRoute(
          path: 'otp',
          builder: (context, state) {
            final phoneNumber = state.extra as String? ?? '';
            return OtpVerificationScreen(phoneNumber: phoneNumber);
          },
        ),
        GoRoute(
          path: 'complete-profile',
          builder: (context, state) => const CompleteProfileScreen(),
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: getIt<MatchmakingBloc>()),
              BlocProvider.value(value: getIt<WalletBloc>()),
              BlocProvider(create: (_) => getIt<TournamentBloc>()..add(LoadTournaments())),
              BlocProvider(create: (_) => getIt<HomeBloc>()),
            ],
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.playMode,
          builder: (context, state) => BlocProvider.value(
            value: getIt<MatchmakingBloc>(),
            child: const PlayModeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.leaderboard,
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<LeaderboardBloc>()..add(LoadLeaderboard()),
            child: const LeaderboardScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<ProfileBloc>()..add(LoadProfile()),
            child: const ProfileScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.matchmaking,
      builder: (context, state) => BlocProvider.value(
        value: getIt<MatchmakingBloc>(),
        child: const MatchmakingScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.game,
      builder: (context, state) {
        final matchData = state.extra as Map<String, dynamic>?;
        return BlocProvider(
          create: (_) => getIt<GameBloc>(),
          child: GameScreen(matchData: matchData),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.wallet,
      builder: (context, state) => BlocProvider.value(
        value: getIt<WalletBloc>(),
        child: const WalletScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.tournamentDetail,
      builder: (context, state) {
        final id = state.extra as String?;
        return BlocProvider(
          create: (_) => getIt<TournamentBloc>()..add(LoadTournamentDetails(id ?? '')),
          child: const TournamentDetailScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.createTournament,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<TournamentBloc>(),
        child: const CreateTournamentScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.victory,
      builder: (context, state) {
        final result = state.extra as Map<String, dynamic>?;
        return VictoryScreen(gameResult: result);
      },
    ),
    GoRoute(
      path: AppRoutes.addMoney,
      builder: (context, state) => BlocProvider.value(
        value: getIt<WalletBloc>(),
        child: const AddMoneyScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.withdraw,
      builder: (context, state) => BlocProvider.value(
        value: getIt<WalletBloc>(),
        child: const WithdrawScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.transactions,
      builder: (context, state) => BlocProvider.value(
        value: getIt<WalletBloc>(),
        child: const TransactionsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.legal,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return LegalScreen(
          title: extra['title'] ?? 'Legal',
          content: extra['content'] ?? '',
        );
      },
    ),
  ],
);
