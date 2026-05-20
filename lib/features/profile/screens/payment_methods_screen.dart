import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:elixra_fashion/features/profile/providers/user_provider.dart';
import 'package:elixra_fashion/features/auth/providers/auth_provider.dart';
import 'package:elixra_fashion/core/models/payment_card_model.dart';
import 'package:elixra_fashion/shared/widgets/custom_button.dart';
import 'package:elixra_fashion/shared/widgets/custom_text_field.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods'), centerTitle: true),
      body: userProvider.cards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.credit_card_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No cards saved yet'),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'ADD NEW CARD',
                    onPressed: () => _showAddCardDialog(context, userId),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userProvider.cards.length + 1,
              itemBuilder: (context, index) {
                if (index == userProvider.cards.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: CustomButton(
                      text: 'ADD NEW CARD',
                      onPressed: () => _showAddCardDialog(context, userId),
                    ),
                  );
                }
                final card = userProvider.cards[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.credit_card, size: 32),
                    title: Text('**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}'),
                    subtitle: Text('${card.cardHolderName} | Expires ${card.expiryDate}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => userProvider.deleteCard(userId, card.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddCardDialog(BuildContext context, String userId) {
    final numberController = TextEditingController();
    final nameController = TextEditingController();
    final expiryController = TextEditingController();
    final typeController = TextEditingController();

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
              const Text('Add New Card', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              CustomTextField(label: 'Card Number', controller: numberController),
              const SizedBox(height: 12),
              CustomTextField(label: 'Card Holder Name', controller: nameController),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: CustomTextField(label: 'Expiry Date (MM/YY)', controller: expiryController)),
                  const SizedBox(width: 12),
                  Expanded(child: CustomTextField(label: 'Card Type (Visa/MasterCard)', controller: typeController)),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'SAVE CARD',
                onPressed: () {
                  final card = PaymentCardModel(
                    id: const Uuid().v4(),
                    cardNumber: numberController.text,
                    cardHolderName: nameController.text,
                    expiryDate: expiryController.text,
                    cardType: typeController.text,
                  );
                  context.read<UserProvider>().addCard(userId, card);
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
