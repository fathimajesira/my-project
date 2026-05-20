import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:elixra_fashion/features/profile/providers/user_provider.dart';
import 'package:elixra_fashion/features/auth/providers/auth_provider.dart';
import 'package:elixra_fashion/core/models/address_model.dart';
import 'package:elixra_fashion/shared/widgets/custom_button.dart';
import 'package:elixra_fashion/shared/widgets/custom_text_field.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses'), centerTitle: true),
      body: userProvider.addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No addresses saved yet'),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'ADD NEW ADDRESS',
                    onPressed: () => _showAddAddressDialog(context, userId),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userProvider.addresses.length + 1,
              itemBuilder: (context, index) {
                if (index == userProvider.addresses.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: CustomButton(
                      text: 'ADD NEW ADDRESS',
                      onPressed: () => _showAddAddressDialog(context, userId),
                    ),
                  );
                }
                final address = userProvider.addresses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(address.label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(address.fullName, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
                        Text('${address.street}, ${address.city}, ${address.state} ${address.zip}'),
                        Text('Phone: ${address.phone}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => userProvider.deleteAddress(userId, address.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddAddressDialog(BuildContext context, String userId) {
    final labelController = TextEditingController();
    final nameController = TextEditingController();
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final zipController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add New Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              CustomTextField(label: 'Label (e.g. Home, Work)', controller: labelController),
              const SizedBox(height: 12),
              CustomTextField(label: 'Full Name', controller: nameController),
              const SizedBox(height: 12),
              CustomTextField(label: 'Street Address', controller: streetController),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: CustomTextField(label: 'City', controller: cityController)),
                  const SizedBox(width: 12),
                  Expanded(child: CustomTextField(label: 'State', controller: stateController)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: CustomTextField(label: 'Zip Code', controller: zipController)),
                  const SizedBox(width: 12),
                  Expanded(child: CustomTextField(label: 'Phone', controller: phoneController)),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'SAVE ADDRESS',
                onPressed: () {
                  final address = AddressModel(
                    id: const Uuid().v4(),
                    label: labelController.text,
                    fullName: nameController.text,
                    street: streetController.text,
                    city: cityController.text,
                    state: stateController.text,
                    zip: zipController.text,
                    phone: phoneController.text,
                  );
                  context.read<UserProvider>().addAddress(userId, address);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
