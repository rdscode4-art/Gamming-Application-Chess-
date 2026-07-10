import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../routes/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/matchmaking_bloc.dart';
import '../blocs/matchmaking_event.dart';
import '../blocs/matchmaking_state.dart';

class PlayModeScreen extends StatefulWidget {
  const PlayModeScreen({super.key});

  @override
  State<PlayModeScreen> createState() => _PlayModeScreenState();
}

class _PlayModeScreenState extends State<PlayModeScreen> {
  final List<String> _tabs = ['Free', 'Paid'];

  @override
  void initState() {
    super.initState();
    context.read<MatchmakingBloc>().add(MatchmakingLoadModes());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MatchmakingBloc, MatchmakingState>(
      listenWhen: (previous, current) => 
          (previous.error != current.error && current.error != null) ||
          (previous.isSearching == false && current.isSearching == true),
      listener: (context, state) {
        if (state.error != null && state.error!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        } else if (state.isSearching) {
          context.push(AppRoutes.matchmaking);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.bgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildTabs(state),
                const SizedBox(height: 16),
                Expanded(
                  child: state.isLoading 
                    ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: state.currentModes.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildContestCard(state.currentModes[index]);
                        },
                      ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
              ),
              child: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).iconTheme.color, size: 16),
            ),
          ),
          Text(
            'Contests',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Icon(Icons.filter_alt_outlined, color: Theme.of(context).colorScheme.primary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(MatchmakingState state) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = state.selectedTab == index;
          return GestureDetector(
            onTap: () => context.read<MatchmakingBloc>().add(MatchmakingTabChanged(index)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08)),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(
                tab,
                style: TextStyle(
                  color: isSelected ? Theme.of(context).scaffoldBackgroundColor : context.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContestCard(dynamic mode) {
    Color tagColor = mode.isRated ? AppColors.purpleLight : (mode.isPaid ? AppColors.gold : AppColors.green);
    
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mode.label,
                style: TextStyle(color: context.textPrimary, fontSize: 16, fontWeight: FontWeight.w900),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  mode.tag,
                  style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Entry: ', style: TextStyle(color: context.textSecondary, fontSize: 13)),
                      Text(mode.entryFee == 0 ? 'Free' : '₹${mode.entryFee}', style: TextStyle(color: mode.entryFee == 0 ? AppColors.green : context.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('Prize: ', style: TextStyle(color: context.textSecondary, fontSize: 13)),
                      Text(mode.prize == 0 ? '-' : '₹${mode.prize}', style: const TextStyle(color: AppColors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Icon(Icons.schedule, color: context.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text(mode.timeControl.replaceAll('_', ' '), style: TextStyle(color: context.textSecondary, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  context.read<MatchmakingBloc>().add(MatchmakingModeSelected(mode));
                  context.read<MatchmakingBloc>().add(MatchmakingPlayRequested());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('Play', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 14, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
