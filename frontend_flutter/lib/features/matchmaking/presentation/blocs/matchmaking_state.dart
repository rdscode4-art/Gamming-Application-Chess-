import 'package:equatable/equatable.dart';
import '../../domain/models/game_mode.dart';

class MatchmakingState extends Equatable {
  final int selectedTab;
  final bool isLoading;
  final bool isSearching;
  final int searchElapsed;
  final List<GameMode> freeModes;
  final List<GameMode> paidModes;
  final List<GameMode> ratedModes;
  final GameMode? selectedMode;
  final int myBalance;
  final int myRating;
  final String myUsername;
  final Map<String, dynamic>? matchFoundData;
  final String? error;

  const MatchmakingState({
    this.selectedTab = 0,
    this.isLoading = true,
    this.isSearching = false,
    this.searchElapsed = 0,
    this.freeModes = const [],
    this.paidModes = const [],
    this.ratedModes = const [],
    this.selectedMode,
    this.myBalance = 0,
    this.myRating = 1200,
    this.myUsername = '',
    this.matchFoundData,
    this.error,
  });

  MatchmakingState copyWith({
    int? selectedTab,
    bool? isLoading,
    bool? isSearching,
    int? searchElapsed,
    List<GameMode>? freeModes,
    List<GameMode>? paidModes,
    List<GameMode>? ratedModes,
    GameMode? selectedMode,
    int? myBalance,
    int? myRating,
    String? myUsername,
    Map<String, dynamic>? matchFoundData,
    bool clearMatchData = false,
    String? error,
  }) {
    return MatchmakingState(
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      searchElapsed: searchElapsed ?? this.searchElapsed,
      freeModes: freeModes ?? this.freeModes,
      paidModes: paidModes ?? this.paidModes,
      ratedModes: ratedModes ?? this.ratedModes,
      selectedMode: selectedMode ?? this.selectedMode,
      myBalance: myBalance ?? this.myBalance,
      myRating: myRating ?? this.myRating,
      myUsername: myUsername ?? this.myUsername,
      matchFoundData: clearMatchData ? null : (matchFoundData ?? this.matchFoundData),
      error: error,
    );
  }

  List<GameMode> get currentModes {
    switch (selectedTab) {
      case 0: return freeModes;
      case 1: return paidModes;
      case 2: return ratedModes;
      default: return freeModes;
    }
  }

  @override
  List<Object?> get props => [
    selectedTab, isLoading, isSearching, searchElapsed,
    freeModes, paidModes, ratedModes, selectedMode,
    myBalance, myRating, myUsername, matchFoundData, error
  ];
}
