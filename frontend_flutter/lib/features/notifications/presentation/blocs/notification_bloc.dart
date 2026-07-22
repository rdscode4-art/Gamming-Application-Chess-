import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart';
import 'notification_state.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/notification_model.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc(this._repository) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
  }

  Future<void> _onLoadNotifications(
      LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final notifications = await _repository.fetchNotifications();
      emit(NotificationLoaded(notifications: notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
      MarkNotificationAsRead event, Emitter<NotificationState> emit) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      
      // Optimistic update
      final updatedNotifications = currentState.notifications.map((notif) {
        if (notif.id == event.notificationId) {
          return NotificationModel(
            id: notif.id,
            type: notif.type,
            title: notif.title,
            body: notif.body,
            data: notif.data,
            isRead: true, // Mark as read
            createdAt: notif.createdAt,
          );
        }
        return notif;
      }).toList();

      emit(NotificationLoaded(notifications: updatedNotifications));

      try {
        await _repository.markAsRead(event.notificationId);
      } catch (e) {
        // Silently fail or revert optimistic update if needed
      }
    }
  }
}
