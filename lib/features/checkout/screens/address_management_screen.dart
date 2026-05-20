import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:elixra_fashion/core/models/address_model.dart';
import 'package:elixra_fashion/shared/widgets/custom_button.dart';
import 'package:elixra_fashion/shared/widgets/custom_text_field.dart';

class AddressManagementScreen extends StatefulWidget {
  final List<AddressModel> addresses;
  final Function(AddressModel) onAddressSelected;

  const AddressManagementScreen({
    super.key,
    required this.addresses,
    required this.onAddressSelected,
  });

  @override
  State<AddressManagementScreen> createState() =>
      _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Address'), centerTitle: true),
      body: widget.addresses.isEmpty
          ? _buildAddNewAddress()
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentIndex = index),
                    itemCount: widget.addresses.length + 1,
                    itemBuilder: (context, index) {
                      if (index == widget.addresses.length) {
                        return _buildAddNewAddressCard();
                      }
                      return _buildAddressCard(widget.addresses[index], index);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: CustomButton(
                    text: 'CONTINUE',
                    onPressed: _currentIndex < widget.addresses.length
                        ? () {
                            widget.onAddressSelected(
                              widget.addresses[_currentIndex],
                            );
                            Navigator.pop(context);
                          }
                        : null,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAddressCard(AddressModel address, int index) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      address.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                address.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(address.street),
              Text('${address.city}, ${address.state} ${address.zip}'),
              const SizedBox(height: 8),
              Text('Phone: ${address.phone}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewAddressCard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_location, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Add New Address',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text('Swipe to add a new delivery address'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewAddress() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No addresses saved yet'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add Address'),
          ),
        ],
      ),
    );
  }
}
