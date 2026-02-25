import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;

  final List<RoleOption> _roleOptions = [
    RoleOption(
      role: UserRole.student,
      title: 'Student',
      subtitle: 'Find materials for your projects',
      description: 'Discover available materials on campus, request specific items, and contribute to sustainability.',
      icon: Icons.school_outlined,
      color: Colors.blue,
    ),
    RoleOption(
      role: UserRole.lab,
      title: 'Lab / Faculty',
      subtitle: 'Share materials and resources',
      description: 'Upload materials, generate opportunities for students, and track environmental impact.',
      icon: Icons.science_outlined,
      color: Colors.green,
    ),
    RoleOption(
      role: UserRole.admin,
      title: 'Administrator',
      subtitle: 'Manage campus sustainability',
      description: 'Oversee platform usage, manage users, and analyze campus-wide impact metrics.',
      icon: Icons.admin_panel_settings_outlined,
      color: Colors.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    final isMobile = screenWidth < 480;
    
    return Scaffold(
      backgroundColor: isDesktop ? const Color(0xFFF5F5F5) : Colors.white,
      appBar: AppBar(
        title: const Text('Select Your Role', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey.shade800,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: isDesktop ? 480 : 500),
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 16),
              padding: EdgeInsets.all(isDesktop ? 28 : 20),
              decoration: isDesktop ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))],
              ) : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How will you use ReClaim?',
                    style: TextStyle(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose your role to customize your experience',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  
                  ...List.generate(_roleOptions.length, (index) {
                    final option = _roleOptions[index];
                    final isSelected = _selectedRole == option.role;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => setState(() => _selectedRole = option.role),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected ? option.color.withOpacity(0.08) : Colors.grey.shade50,
                            border: Border.all(color: isSelected ? option.color : Colors.grey.shade200, width: isSelected ? 2 : 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected ? option.color : option.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(option.icon, size: 24, color: isSelected ? Colors.white : option.color),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(option.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isSelected ? option.color : Colors.grey.shade800)),
                                    const SizedBox(height: 2),
                                    Text(option.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, color: option.color, size: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _selectedRole != null ? _handleContinue : null,
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                      child: const Text('Continue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_selectedRole != null) {
      context.go('/campus-selection', extra: _selectedRole);
    }
  }
}

class RoleOption {
  final UserRole role;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  const RoleOption({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}