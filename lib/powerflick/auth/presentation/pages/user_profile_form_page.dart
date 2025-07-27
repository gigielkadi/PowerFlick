import 'package:flutter/material.dart';
import '../../../../core/constants/k_colors.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/home_setup_page.dart';

class UserProfileFormPage extends StatefulWidget {
  const UserProfileFormPage({super.key});

  @override
  State<UserProfileFormPage> createState() => _UserProfileFormPageState();
}

class _UserProfileFormPageState extends State<UserProfileFormPage> {
  final TextEditingController _nameController = TextEditingController();
  DateTime _selectedDate = DateTime(2021, 2, 9);
  final List<String> _homeTypes = ['Apartment', 'House', 'Villa', 'Duplex', 'Studio'];
  String? _selectedHomeType;
  int _peopleCount = 5;
  final Map<String, bool> _priorities = {
    'Reduce electricity bill': true,
    'Lower carbon footprint': false,
    'Improve system performance': false,
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: KColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: KColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showHomeTypeBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Select Home Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _homeTypes.length,
                itemBuilder: (context, index) {
                  final type = _homeTypes[index];
                  return ListTile(
                    title: Text(type),
                    trailing: _selectedHomeType == type
                        ? const Icon(Icons.check, color: KColors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedHomeType = type;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate available screen height
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final availableHeight = screenHeight - statusBarHeight;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'We want to know you better!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Main form content in a scrollable container
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Name/Nickname field
                          _buildFieldLabel('Name/ Nickname'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Enter your name',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: KColors.primary, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Birthdate field
                          _buildFieldLabel('Birthdate'),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Colors.grey),
                                  const SizedBox(width: 16),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(_selectedDate),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Home type dropdown
                          _buildFieldLabel('What type of home do you live in'),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _showHomeTypeBottomSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedHomeType ?? 'Eg. Villa, duplex, apartment...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _selectedHomeType != null ? Colors.black87 : Colors.grey.shade400,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Household size counter
                          _buildFieldLabel('How many people live in your household?'),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildCounterButton(
                                icon: Icons.remove,
                                onPressed: () {
                                  if (_peopleCount > 1) {
                                    setState(() {
                                      _peopleCount--;
                                    });
                                  }
                                },
                              ),
                              Container(
                                width: 80,
                                alignment: Alignment.center,
                                child: Text(
                                  '$_peopleCount',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              _buildCounterButton(
                                icon: Icons.add,
                                onPressed: () {
                                  setState(() {
                                    _peopleCount++;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Priorities checkboxes
                          _buildFieldLabel('What\'s your priority?'),
                          const SizedBox(height: 8),
                          ..._priorities.entries.map((entry) => _buildCheckbox(entry.key, entry.value)),
                        ],
                      ),
                    ),
                  ),
                  
                  // Next button
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Save the user data and navigate to dashboard
                        _saveUserData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
  
  Widget _buildCounterButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.grey.shade600, size: 18),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
  
  Widget _buildCheckbox(String title, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _priorities[title] = !(_priorities[title] ?? false);
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _priorities[title] ?? false ? KColors.primary : Colors.grey.shade400,
                  width: 1.5,
                ),
                color: _priorities[title] ?? false ? KColors.primary : Colors.transparent,
              ),
              child: _priorities[title] ?? false
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _saveUserData() async {
    // Here you would save the user data to your database
    final userData = {
      'name': _nameController.text,
      'birthdate': _selectedDate.toIso8601String(),
      'home_type': _selectedHomeType,
      'household_size': _peopleCount,
      'priorities': _priorities.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList(),
    };
    
    // Print for debugging
    print('User profile data: $userData');
    
    try {
      // Save data to Supabase
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user != null) {
        await supabase.from('users').upsert({
          'id': user.id,
          'email': user.email,
          'first_name': _nameController.text,
          'birthdate': _selectedDate.toIso8601String(),
          'home_type': _selectedHomeType,
          'household_size': _peopleCount,
          'priorities': _priorities.entries
              .where((entry) => entry.value)
              .map((entry) => entry.key)
              .toList(),
        });
        
        // Navigate to HomeSetupPage instead of dashboard
        if (mounted) {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => HomeSetupPage(userName: _nameController.text),
            ),
          );
        }
      } else {
        // For demo purposes, still navigate even if user is null
        if (mounted) {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => HomeSetupPage(userName: _nameController.text),
            ),
          );
        }
      }
    } catch (e) {
      print('Error saving user data: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
      
      // For demo, still navigate even if there's an error
      if (mounted) {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => HomeSetupPage(userName: _nameController.text),
          ),
        );
      }
    }
  }
} 