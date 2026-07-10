import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repository;

  HomeBloc({required HomeRepository repository})
      : _repository = repository,
        super(const HomeState()) {
    on<HomeLoadData>(_onLoadData);
    
    add(HomeLoadData());
  }

  Future<void> _onLoadData(HomeLoadData event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final results = await Future.wait([
        _repository.getBanners(),
        _repository.getLiveMatches(),
      ]);
      emit(state.copyWith(
        isLoading: false,
        banners: results[0],
        liveMatches: results[1],
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
