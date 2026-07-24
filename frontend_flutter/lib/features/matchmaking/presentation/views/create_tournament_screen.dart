import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../tournament/presentation/blocs/tournament_bloc.dart';
import '../../../tournament/presentation/blocs/tournament_event.dart';
import '../../../tournament/presentation/blocs/tournament_state.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  String _selectedFormat = 'rapid_10';
  bool _isPublic = true;
  
  final _nameCtrl = TextEditingController();
  int _selectedPlayers = 8;
  final _entryFeeCtrl = TextEditingController(text: '100');
  final _startDateCtrl = TextEditingController();
  final _startTimeCtrl = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _entryFeeCtrl.dispose();
    _startDateCtrl.dispose();
    _startTimeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(icon: Icons.emoji_events_outlined, hint: 'Tournament Name', controller: _nameCtrl),
                    const SizedBox(height: 24),
                    Text('FORMAT', style: TextStyle(color: context.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    _buildFormatSelector(),
                    const SizedBox(height: 24),
                    Text('PLAYER COUNT', style: TextStyle(color: context.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    _buildPlayerSelector(),
                    const SizedBox(height: 24),
                    Text('ENTRY FEE (₹)', style: TextStyle(color: context.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    _buildInputField(icon: Icons.attach_money, hint: 'e.g. 100', controller: _entryFeeCtrl, isNumber: true),
                    const SizedBox(height: 8),
                    Text('Prize pool will be automatically calculated (90% of total entry fees)', style: TextStyle(color: context.textSecondary, fontSize: 11, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('START DATE', style: TextStyle(color: context.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              const SizedBox(height: 12),
                              _buildInputField(
                                icon: Icons.schedule, 
                                hint: 'DD/MM/YYYY', 
                                controller: _startDateCtrl,
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().add(const Duration(days: 1)),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (date != null) {
                                    _selectedDate = date;
                                    _startDateCtrl.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('START TIME', style: TextStyle(color: context.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              const SizedBox(height: 12),
                              _buildInputField(
                                icon: Icons.schedule, 
                                hint: 'HH:MM', 
                                controller: _startTimeCtrl,
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (time != null && context.mounted) {
                                    _selectedTime = time;
                                    _startTimeCtrl.text = time.format(context);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Public Tournament', style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Anyone can join', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                          ],
                        ),
                        Switch(
                          value: _isPublic,
                          activeColor: Theme.of(context).scaffoldBackgroundColor,
                          activeTrackColor: Theme.of(context).colorScheme.primary,
                          inactiveTrackColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                          onChanged: (val) => setState(() => _isPublic = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BlocConsumer<TournamentBloc, TournamentState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            Fluttertoast.showToast(msg: state.successMessage!, backgroundColor: AppColors.green);
            context.read<TournamentBloc>().add(ClearTournamentMessages());
            context.pop();
          }
          if (state.error != null) {
            Fluttertoast.showToast(msg: state.error!, backgroundColor: AppColors.red);
            context.read<TournamentBloc>().add(ClearTournamentMessages());
          }
        },
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.bgColor,
              border: Border(top: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))),
            ),
            child: SafeArea(
              child: GestureDetector(
                onTap: state.isActionLoading ? null : () {
                  if (_nameCtrl.text.isEmpty) {
                    Fluttertoast.showToast(msg: 'Name is required');
                    return;
                  }
                  if (_selectedDate == null || _selectedTime == null) {
                    Fluttertoast.showToast(msg: 'Please select a start date and time');
                    return;
                  }
                  final startDateTime = DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                    _selectedTime!.hour,
                    _selectedTime!.minute,
                  );

                  context.read<TournamentBloc>().add(CreateTournament({
                    'name': _nameCtrl.text,
                    'timeControl': _selectedFormat,
                    'maxPlayers': _selectedPlayers,
                    'entryFee': int.tryParse(_entryFeeCtrl.text) ?? 0,
                    'isPrivate': !_isPublic,
                    'startTime': startDateTime.toUtc().toIso8601String(),
                  }));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: state.isActionLoading ? Colors.grey : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Create Tournament',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
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
          Expanded(
            child: Text(
              'Create Tournament',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildInputField({required IconData icon, required String hint, TextEditingController? controller, bool isNumber = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                style: TextStyle(color: context.textPrimary, fontSize: 14),
                readOnly: onTap != null,
                onTap: onTap,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: context.textSecondary, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelector() {
    final formats = [
      {'label': 'Classic', 'val': 'classic_15'}, 
      {'label': 'Rapid', 'val': 'rapid_10'}, 
      {'label': 'Blitz', 'val': 'rapid_3'}
    ];
    return Row(
      children: formats.map((fmt) {
        final isSelected = _selectedFormat == fmt['val'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedFormat = fmt['val']!),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  fmt['label']!,
                  style: TextStyle(
                    color: isSelected ? Theme.of(context).scaffoldBackgroundColor : context.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayerSelector() {
    final counts = [2, 4, 8, 16, 32, 64, 128, 256];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: counts.map((count) {
          final isSelected = _selectedPlayers == count;
          return GestureDetector(
            onTap: () => setState(() => _selectedPlayers = count),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Theme.of(context).scaffoldBackgroundColor : context.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
