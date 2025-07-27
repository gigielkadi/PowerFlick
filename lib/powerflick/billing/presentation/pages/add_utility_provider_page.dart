import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_colors.dart';
import '../../domain/models/electricity_bill.dart';

class AddUtilityProviderPage extends ConsumerStatefulWidget {
  const AddUtilityProviderPage({super.key});

  @override
  ConsumerState<AddUtilityProviderPage> createState() => _AddUtilityProviderPageState();
}

class _AddUtilityProviderPageState extends ConsumerState<AddUtilityProviderPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _customerNameController = TextEditingController();

  UtilityProvider? selectedProvider;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Add Utility Account'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Your Utility Provider',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              DropdownButtonFormField<UtilityProvider>(
                value: selectedProvider,
                decoration: const InputDecoration(
                  hintText: 'Choose your utility provider',
                  border: OutlineInputBorder(),
                ),
                items: UtilityProvider.values.map((provider) {
                  return DropdownMenuItem(
                    value: provider,
                    child: Text(provider.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProvider = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a provider' : null,
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _accountController,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _addAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Account', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Utility account added successfully!'),
          backgroundColor: KColors.success,
        ),
      );
      Navigator.pop(context);
    }

    setState(() {
      isLoading = false;
    });
  }
} 