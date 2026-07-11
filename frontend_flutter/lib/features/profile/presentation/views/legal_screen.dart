import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_header.dart';

import '../../../../core/network/api_client.dart';

class LegalScreen extends StatefulWidget {
  final String title;
  final String settingKey;

  const LegalScreen({
    super.key,
    required this.title,
    required this.settingKey,
  });

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  String _content = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLegalContent();
  }

  Future<void> _fetchLegalContent() async {
    try {
      final response = await ApiClient.instance.get('/settings/public');
      if (response.data != null && response.data['settings'] != null) {
        if (mounted) {
          setState(() {
            _content = response.data['settings'][widget.settingKey] ?? 'Content not available.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _content = 'Failed to load content.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BackHeader(
                title: widget.title,
                onBack: () => context.pop(),
              ),
            ),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      _content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.textMuted
                                : Colors.black87,
                          ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
