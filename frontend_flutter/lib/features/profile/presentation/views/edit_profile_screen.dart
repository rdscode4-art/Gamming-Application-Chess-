import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bg_blobs.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/network/api_client.dart';
import '../blocs/profile_bloc.dart';
import '../blocs/profile_state.dart';
import '../blocs/profile_event.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _fullNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileBloc>().state;
    final user = state.userProfile ?? {};
    
    _usernameController = TextEditingController(text: user['username'] ?? '');
    _emailController = TextEditingController(text: user['email'] ?? '');
    _fullNameController = TextEditingController(text: user['fullName'] ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username cannot be empty')));
      return;
    }

    setState(() {
      _isLoading = true;
    });
    
    try {
      await ApiClient.instance.put('/users/me', data: {
        'username': username,
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      if (mounted) {
        setState(() => _isLoading = false);
        // Dispatch event to refresh profile
        context.read<ProfileBloc>().add(LoadProfile());
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: BlocListener<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) => previous.isLoading != current.isLoading || previous.error != current.error,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Upload Error: ${state.error}'), backgroundColor: AppColors.red),
            );
          } else if (!state.isLoading && state.userProfile != null) {
            // Check if it was an upload success by checking if we just finished loading
            final bool wasLoading = context.read<ProfileBloc>().state.isLoading;
            // Actually it's better to just show success if error is null and loading finished
          }
        },
        child: Stack(
          children: [
            Container(decoration: BoxDecoration(gradient: context.isDark ? AppColors.navyGrad : null)),
            const BgBlobs(),
            SafeArea(
              child: Column(
              children: [
                BackHeader(title: 'Edit Profile', onBack: () => context.pop()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAvatarSection(context),
                        const SizedBox(height: 32),
                        _buildInputForm(context),
                        const SizedBox(height: 32),
                        _buildSaveButton(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final user = state.userProfile ?? {};
        final avatarUrl = user['avatarUrl'] as String?;

        return Center(
          child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.purpleLight,
              shape: BoxShape.circle,
              image: avatarUrl != null && avatarUrl.isNotEmpty
                  ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: (avatarUrl == null || avatarUrl.isEmpty)
                ? Center(
                    child: Text(
                      _usernameController.text.isNotEmpty ? _usernameController.text[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
          ),
          if (state.isLoading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                try {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  
                  if (image != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Starting upload...')),
                    );
                    context.read<ProfileBloc>().add(UploadAvatar(image.path));
                  } else if (image == null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No image selected')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Picker Error: $e')),
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.bgColor, width: 3),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
    });
  }

  Widget _buildInputForm(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        children: [
          _buildTextField(
            label: 'Username',
            controller: _usernameController,
            icon: Icons.person_outline,
            context: context,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Full Name',
            controller: _fullNameController,
            icon: Icons.badge_outlined,
            context: context,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Email Address',
            controller: _emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required BuildContext context,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: context.textPrimary.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: 
            FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: context.isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(color: context.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.purpleLight, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: context.textSecondary),
            ),
            onChanged: (val) {
              if (label == 'Username' && val.isNotEmpty) {
                setState(() {}); // to update avatar text
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _saveProfile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.purpleGrad,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.purpleLight.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
