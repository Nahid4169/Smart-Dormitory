import 'package:flutter/material.dart';
import '../theme.dart';

class PaymentsPage extends StatelessWidget {
  final List<Map<String, dynamic>> payments;
  final ValueChanged<Map<String, dynamic>> onTogglePayment;

  const PaymentsPage({
    super.key,
    required this.payments,
    required this.onTogglePayment,
  });

  @override
  Widget build(BuildContext context) {
    final total = payments.fold<int>(
      0,
          (sum, p) => sum + (p['amount'] as int),
    );

    final paid = payments.where((p) => p['paid'] == true).length;

    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        header('Payment Management', 'Track dormitory fees for registered students.'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            statCard('Total Records', '${payments.length}', Icons.receipt_long, purple),
            statCard('Paid', '$paid', Icons.check_circle, green),
            statCard('Pending', '${payments.length - paid}', Icons.pending_actions, orange),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: cardDecoration(),
          child: Text(
            'Total listed fees: ₩${total.toString()}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 15),
        ...payments.map((p) {
          final isPaid = p['paid'] == true;
          return Container(
            margin: const EdgeInsets.only(bottom: 9),
            decoration: cardDecoration(),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: green.withOpacity(0.13),
                child: const Icon(Icons.account_balance_wallet, color: green),
              ),
              title: Text(p['name']),
              subtitle: Text('${p['studentId']} • ₩${p['amount']}'),
              trailing: TextButton(
                onPressed: () => onTogglePayment(p),
                child: Text(
                  isPaid ? 'PAID' : 'PENDING',
                  style: TextStyle(
                    color: isPaid ? green : orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
