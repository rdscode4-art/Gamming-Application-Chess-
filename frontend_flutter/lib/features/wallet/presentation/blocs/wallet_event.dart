import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class WalletFetchData extends WalletEvent {}

class WalletAddMoney extends WalletEvent {
  final int amount;
  const WalletAddMoney(this.amount);
}

class WalletWithdrawMoney extends WalletEvent {
  final int amount;
  final String upiId;
  const WalletWithdrawMoney({required this.amount, required this.upiId});
}

class WalletPaymentSuccess extends WalletEvent {
  final String paymentId;
  final String orderId;
  final String signature;
  const WalletPaymentSuccess({required this.paymentId, required this.orderId, required this.signature});
}

class WalletPaymentError extends WalletEvent {
  final String message;
  const WalletPaymentError(this.message);
}

class WalletClearMessage extends WalletEvent {}
