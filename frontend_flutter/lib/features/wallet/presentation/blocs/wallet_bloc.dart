import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_constants.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  late Razorpay _razorpay;

  WalletBloc() : super(const WalletState()) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    on<WalletFetchData>(_onFetchData);
    on<WalletAddMoney>(_onAddMoney);
    on<WalletWithdrawMoney>(_onWithdrawMoney);
    on<WalletPaymentSuccess>(_onPaymentSuccess);
    on<WalletPaymentError>(_onPaymentError);
    on<WalletClearMessage>(_onClearMessage);

    add(WalletFetchData());
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    add(WalletPaymentSuccess(
      paymentId: response.paymentId ?? '',
      orderId: response.orderId ?? '',
      signature: response.signature ?? '',
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    String msg = response.message ?? 'Transaction cancelled or failed.';
    if (msg == 'undefined' || msg == 'null' || msg.isEmpty) {
      msg = 'Payment cancelled by user.';
    }
    add(WalletPaymentError(msg));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    add(WalletPaymentError('Selected wallet: ${response.walletName}'));
  }

  Future<void> _onFetchData(WalletFetchData event, Emitter<WalletState> emit) async {
    emit(state.copyWith(isLoading: true, isTransactionsLoading: true));
    
    try {
      final res = await ApiService.get(AppConstants.walletUrl);
      if (res != null) {
        emit(state.copyWith(
          depositBalance: res['depositBalance'] ?? 0,
          winningsBalance: res['winningsBalance'] ?? 0,
          bonusBalance: res['bonusBalance'] ?? 0,
          totalBalance: res['totalBalance'] ?? 0,
        ));
      }
    } catch (e) {
      // Ignored
    }

    try {
      final resT = await ApiService.get(AppConstants.walletTransactionsUrl);
      if (resT != null && resT['transactions'] != null) {
        emit(state.copyWith(transactions: resT['transactions']));
      }
    } catch (e) {
      // Ignored
    }

    emit(state.copyWith(isLoading: false, isTransactionsLoading: false));
  }

  Future<void> _onAddMoney(WalletAddMoney event, Emitter<WalletState> emit) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      final res = await ApiService.post(AppConstants.walletDepositUrl, {
        'amount': event.amount,
      });

      emit(state.copyWith(isActionLoading: false));

      if (res != null && res['orderId'] != null) {
        emit(state.copyWith(lastOrderId: res['orderId']));
        var options = {
          'key': res['keyId'],
          'amount': res['amount'],
          'name': 'Chess Platform',
          'description': 'Wallet Deposit',
          'order_id': res['orderId'],
          'timeout': 120,
          'theme.color': '#FFB300',
        };
        _razorpay.open(options);
      }
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        errorMessage: 'Failed to initiate deposit. Please try again.',
      ));
    }
  }

  Future<void> _onWithdrawMoney(WalletWithdrawMoney event, Emitter<WalletState> emit) async {
    if (event.amount < 100) {
      emit(state.copyWith(errorMessage: 'Minimum withdrawal is ₹100', clearMessages: true));
      return;
    }
    if (event.amount > state.winningsBalance) {
      emit(state.copyWith(errorMessage: 'You can only withdraw from Winnings Balance (₹${state.winningsBalance})', clearMessages: true));
      return;
    }

    emit(state.copyWith(isActionLoading: true));
    try {
      final res = await ApiService.post(AppConstants.walletWithdrawUrl, {
        'amount': event.amount,
        'paymentDetails': event.upiId,
      });

      emit(state.copyWith(isActionLoading: false));
      if (res != null) {
        emit(state.copyWith(
          successMessage: 'Your request for ₹${event.amount} has been submitted.',
          clearMessages: true,
        ));
        add(WalletFetchData());
      }
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        errorMessage: 'Failed to request withdrawal.',
        clearMessages: true,
      ));
    }
  }

  Future<void> _onPaymentSuccess(WalletPaymentSuccess event, Emitter<WalletState> emit) async {
    try {
      final res = await ApiService.post(AppConstants.walletVerifyUrl, {
        'razorpay_order_id': event.orderId,
        'razorpay_payment_id': event.paymentId,
        'razorpay_signature': event.signature,
      });

      if (res != null) {
        emit(state.copyWith(
          successMessage: 'Payment successful. Balance updated.',
          clearMessages: true,
        ));
        add(WalletFetchData());
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Payment verification failed on our server. Please contact support.',
        clearMessages: true,
      ));
    }
  }

  Future<void> _onPaymentError(WalletPaymentError event, Emitter<WalletState> emit) async {
    // Attempt to mark as failed if there's an ongoing transaction
    // Razorpay error response doesn't always have order id, but if we saved it in state it would be better.
    // However, Razorpay creates order ID BEFORE payment, so we can store it in state when created.
    if (state.lastOrderId != null) {
      try {
        await ApiService.post(AppConstants.walletDepositFailUrl, {
          'razorpay_order_id': state.lastOrderId,
        });
      } catch (_) {}
    }
    
    emit(state.copyWith(errorMessage: event.message, clearMessages: true, lastOrderId: null));
    add(WalletFetchData());
  }

  void _onClearMessage(WalletClearMessage event, Emitter<WalletState> emit) {
    emit(state.copyWith(clearMessages: true));
  }

  @override
  Future<void> close() {
    _razorpay.clear();
    return super.close();
  }
}
