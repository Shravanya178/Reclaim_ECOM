import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final List<String> _selectedSkills = ['Electronics', 'Arduino', '3D Printing'];
  final List<String> _selectedDomains = ['IoT', 'Robotics'];
  String _availability = 'Part-time';
  bool get _isDesktop => MediaQuery.of(context).size.width > 768;
  
  final List<String> _allSkills = ['Electronics', 'Arduino', '3D Printing', 'Welding', 'Woodworking', 'Programming', 'CAD Design', 'Laser Cutting', 'Soldering', 'Mechanical'];
  final List<String> _allDomains = ['IoT', 'Robotics', 'Sustainability', 'Healthcare', 'Agriculture', 'Education', 'Smart Home', 'Wearables'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDesktop ? Colors.grey.shade100 : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        actions: [IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.white), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: _isDesktop ? EdgeInsets.all(24) : EdgeInsets.zero,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: _isDesktop ? BorderRadius.circular(16) : BorderRadius.zero,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text('SA', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                      ),
                      SizedBox(height: 16),
                      Text('Shravanya A', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                      SizedBox(height: 4),
                      Text('Information Technology • 3rd Year', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 24,
                        runSpacing: 12,
                        children: [
                          _buildProfileStat('Projects', '8'),
                          _buildProfileStat('Materials Used', '23'),
                          _buildProfileStat('CO₂ Saved', '12.5kg'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Skills Section
                _buildSection(
                  'Skills & Expertise',
                  Icons.build_outlined,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._selectedSkills.map((skill) => Chip(
                        label: Text(skill),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
                        deleteIcon: Icon(Icons.close, size: 16),
                        onDeleted: () => setState(() => _selectedSkills.remove(skill)),
                      )),
                      ActionChip(
                        label: const Text('+ Add'),
                        onPressed: () => _showSkillPicker(),
                      ),
                    ],
                  ),
                ),
                
                // Domains Section
                _buildSection(
                  'Project Interests',
                  Icons.interests_outlined,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._selectedDomains.map((domain) => Chip(
                        label: Text(domain),
                        backgroundColor: Colors.green.shade50,
                        labelStyle: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w500),
                        deleteIcon: Icon(Icons.close, size: 16),
                        onDeleted: () => setState(() => _selectedDomains.remove(domain)),
                      )),
                      ActionChip(label: const Text('+ Add'), onPressed: () => _showDomainPicker()),
                    ],
                  ),
                ),
                
                // Availability Section
                _buildSection(
                  'Availability',
                  Icons.schedule_outlined,
                  Column(
                    children: ['Full-time', 'Part-time', 'Weekends only', 'Project-based'].map((option) => RadioListTile<String>(
                      title: Text(option, style: TextStyle(color: Colors.grey.shade800)),
                      value: option,
                      groupValue: _availability,
                      onChanged: (value) => setState(() => _availability = value!),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    )).toList(),
                  ),
                ),
                
                // Past Projects
                _buildSection(
                  'Past Projects',
                  Icons.work_history_outlined,
                  Column(
                    children: [
                      _buildProjectCard('Smart Waste Bin', 'IoT-based waste sorting', 'Completed', 3),
                      SizedBox(height: 8),
                      _buildProjectCard('Solar Phone Charger', 'Recycled solar cells', 'Completed', 2),
                      SizedBox(height: 8),
                      _buildProjectCard('Water Quality Monitor', 'Arduino-based sensors', 'In Progress', 1),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: _isDesktop ? 0 : 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
              SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            ],
          ),
          SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildProjectCard(String title, String description, String status, int materialsUsed) {
    final isCompleted = status == 'Completed';
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: isCompleted ? Colors.green.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
            child: Icon(isCompleted ? Icons.check_circle : Icons.pending, color: isCompleted ? Colors.green : Colors.orange, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: isCompleted ? Colors.green.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(4)),
                child: Text(status, style: TextStyle(fontSize: 10, color: isCompleted ? Colors.green.shade700 : Colors.orange.shade700, fontWeight: FontWeight.w600)),
              ),
              SizedBox(height: 4),
              Text('$materialsUsed materials', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }

  void _showSkillPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Skills', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allSkills.where((s) => !_selectedSkills.contains(s)).map((skill) => ActionChip(
                label: Text(skill),
                onPressed: () { setState(() => _selectedSkills.add(skill)); Navigator.pop(context); },
              )).toList(),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDomainPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Project Interest', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allDomains.where((d) => !_selectedDomains.contains(d)).map((domain) => ActionChip(
                label: Text(domain),
                onPressed: () { setState(() => _selectedDomains.add(domain)); Navigator.pop(context); },
              )).toList(),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}