import 'package:flutter/material.dart';

class DiscoveryMapScreen extends StatelessWidget {
  const DiscoveryMapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Discover Materials')), 
                   body: const Center(child: Text('Discovery Map\n\nGoogle Maps Integration\nMaterial pins and locations\nComing Soon!', 
                                                 textAlign: TextAlign.center, style: TextStyle(fontSize: 18))));
  }
}

class MaterialsFeedScreen extends StatelessWidget {
  const MaterialsFeedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Materials Feed')), 
                   body: const Center(child: Text('Materials Feed\n\n"Near You" materials\nFilters and search\nComing Soon!', 
                                                 textAlign: TextAlign.center, style: TextStyle(fontSize: 18))));
  }
}

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Profile')), 
                   body: const Center(child: Text('Student Profile\n\nSkills, domains, preferences\nProject portfolio\nComing Soon!', 
                                                 textAlign: TextAlign.center, style: TextStyle(fontSize: 18))));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Settings')), 
                   body: const Center(child: Text('Settings\n\nProfile, privacy, notifications\nAccount management\nComing Soon!', 
                                                 textAlign: TextAlign.center, style: TextStyle(fontSize: 18))));
  }
}

class OpportunitiesDashboardScreen extends StatelessWidget {
  const OpportunitiesDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Opportunities')), 
                   body: const Center(child: Text('Opportunities Dashboard\n\nGenerated opportunity cards\nStudent matches\nConfirm/Reject actions\nComing Soon!', 
                                                 textAlign: TextAlign.center, style: TextStyle(fontSize: 18))));
  }
}

class RequestBoardScreen extends StatelessWidget {
  const RequestBoardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Material Requests')), 
                   body: const Center(child: Text('Request Board\n\nMy requests\nProgress tracking\nPost new requests\nComing Soon!', 
                                                 textAlign: TextAlign.center, style: TextStyle(fontSize: 18))));
  }
}

class RequestCreationScreen extends StatelessWidget {
  const RequestCreationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Create Request')), 
                   body: const Center(child: Text('Create Material Request\n\nMaterial type, quantity\nProject description\nDeadline\nComing Soon!', 
                                                 textAlign: TextAlign.center, style: TextStyle(fontSize: 18))));
  }
}

class BarterOpportunitiesScreen extends StatelessWidget {
  const BarterOpportunitiesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Skill Exchange')), 
                   body: const Center(child: Text('Barter Opportunities\n\nSkill-for-material exchange\nApply to opportunities\nTrack applications\nComing Soon!', 
                                                 textAlign: TextAlign.center, style: TextStyle(fontSize: 18))));
  }
}

class ImpactDashboardScreen extends StatelessWidget {
  const ImpactDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Impact')), 
                   body: const Center(child: Text('Impact Dashboard\n\nCO₂ saved, materials diverted\nPersonal & campus metrics\nLeaderboards\nComing Soon!', 
                                                 textAlign: TextAlign.center, style: TextStyle(fontSize: 18))));
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Notifications')), 
                   body: const Center(child: Text('Notifications\n\nMatches, approvals, reminders\nReal-time updates\nComing Soon!', 
                                                 textAlign: TextAlign.center, style: TextStyle(fontSize: 18))));
  }
}