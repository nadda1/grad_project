import 'package:flutter/material.dart';

class WalletPage extends StatelessWidget {
  final double balance;

  WalletPage({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Wallet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 5,
              child: ListTile(
                leading: Icon(Icons.account_balance_wallet, size: 40),
                title: Text('Balance'),
                subtitle: Text('\$${balance.toStringAsFixed(2)}'), // Display the balance
              ),
            ),
          ],
        ),
      ),
    );
  }
}
