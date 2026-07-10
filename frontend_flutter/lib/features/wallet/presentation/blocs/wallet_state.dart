import 'package:equatable/equatable.dart';

class WalletState extends Equatable {
  final bool isLoading;
  final bool isTransactionsLoading;
  final bool isActionLoading;
  final int depositBalance;
  final int winningsBalance;
  final int bonusBalance;
  final int totalBalance;
  final List<dynamic> transactions;
  final String? errorMessage;
  final String? successMessage;
  final String? lastOrderId;

  const WalletState({
    this.isLoading = false,
    this.isTransactionsLoading = false,
    this.isActionLoading = false,
    this.depositBalance = 0,
    this.winningsBalance = 0,
    this.bonusBalance = 0,
    this.totalBalance = 0,
    this.transactions = const [],
    this.errorMessage,
    this.successMessage,
    this.lastOrderId,
  });

  WalletState copyWith({
    bool? isLoading,
    bool? isTransactionsLoading,
    bool? isActionLoading,
    int? depositBalance,
    int? winningsBalance,
    int? bonusBalance,
    int? totalBalance,
    List<dynamic>? transactions,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
    String? lastOrderId,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      isTransactionsLoading: isTransactionsLoading ?? this.isTransactionsLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      depositBalance: depositBalance ?? this.depositBalance,
      winningsBalance: winningsBalance ?? this.winningsBalance,
      bonusBalance: bonusBalance ?? this.bonusBalance,
      totalBalance: totalBalance ?? this.totalBalance,
      transactions: transactions ?? this.transactions,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      lastOrderId: lastOrderId ?? this.lastOrderId,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isActionLoading,
        isTransactionsLoading,
        depositBalance,
        winningsBalance,
        bonusBalance,
        totalBalance,
        transactions,
        errorMessage,
        successMessage,
        lastOrderId,
      ];
}
