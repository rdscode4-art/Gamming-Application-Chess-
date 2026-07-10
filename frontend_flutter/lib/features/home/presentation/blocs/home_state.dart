import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final List<Map<String, dynamic>> banners;
  final List<Map<String, dynamic>> liveMatches;
  final String? error;

  const HomeState({
    this.isLoading = true,
    this.banners = const [],
    this.liveMatches = const [],
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? banners,
    List<Map<String, dynamic>>? liveMatches,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      banners: banners ?? this.banners,
      liveMatches: liveMatches ?? this.liveMatches,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, banners, liveMatches, error];
}
