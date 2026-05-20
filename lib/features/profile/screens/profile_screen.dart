import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elixra_fashion/features/profile/screens/settings_screen.dart';
import 'package:elixra_fashion/features/profile/screens/edit_profile_screen.dart';
import 'package:elixra_fashion/features/profile/screens/order_history_screen.dart';
import 'package:elixra_fashion/features/wishlist/screens/wishlist_screen.dart';
import 'package:elixra_fashion/features/auth/providers/auth_provider.dart';
import 'package:elixra_fashion/features/profile/providers/orders_provider.dart';
import 'package:elixra_fashion/features/auth/screens/login_screen.dart';
import 'package:elixra_fashion/features/profile/screens/addresses_screen.dart';
import 'package:elixra_fashion/features/profile/screens/payment_methods_screen.dart';
import 'package:elixra_fashion/features/profile/providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    final ordersProvider = context.read<OrdersProvider>();
    if (authProvider.currentUser != null) {
      ordersProvider.loadUserOrders(authProvider.currentUser!.id);
      context.read<UserProvider>().loadUserProfile(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), centerTitle: true),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.currentUser == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Please login to view your profile'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }

          final user = authProvider.currentUser!;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person_outline, size: 50, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  user.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  ),
                  child: const Text('EDIT PROFILE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(height: 40),
                _buildProfileOption(
                  icon: Icons.shopping_bag_outlined,
                  title: 'ORDER HISTORY',
                  onTap: () {
                    final ordersProvider = context.read<OrdersProvider>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OrderHistoryScreen(),
                      ),
                    );
                  },
                ),
                _buildProfileOption(
                  icon: Icons.favorite_border,
                  title: 'WISHLIST',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen())),
                ),
                _buildProfileOption(
                  icon: Icons.location_on_outlined,
                  title: 'SHIPPING ADDRESSES',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesScreen())),
                ),
                _buildProfileOption(
                  icon: Icons.payment_outlined,
                  title: 'PAYMENT METHODS',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
                ),
                _buildProfileOption(
                  icon: Icons.settings_outlined,
                  title: 'SETTINGS',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
                const Divider(height: 40),
                _buildProfileOption(
                  icon: Icons.logout_outlined,
                  title: 'LOGOUT',
                  isDestructive: true,
                  onTap: () => _showLogoutDialog(context, authProvider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isDestructive ? Colors.red : Colors.black, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDestructive ? Colors.red : Colors.black,
          letterSpacing: 1,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: isDestructive ? Colors.red : Colors.grey[400], size: 16),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              authProvider.signOut().then((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              });
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
