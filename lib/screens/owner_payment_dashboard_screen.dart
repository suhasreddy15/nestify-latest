import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/payment_service.dart';

class OwnerPaymentDashboardScreen extends StatefulWidget {
  const OwnerPaymentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<OwnerPaymentDashboardScreen> createState() => _OwnerPaymentDashboardScreenState();
}

class _OwnerPaymentDashboardScreenState extends State<OwnerPaymentDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PaymentService _paymentService = PaymentService();
  
  // For filtering by month
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Dashboard'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.people_outline),
              text: 'Unpaid',
            ),
            Tab(
              icon: Icon(Icons.check_circle_outline),
              text: 'Paid',
            ),
          ],
        ),
        actions: [
          // Month selector
          PopupMenuButton<int>(
            icon: Row(
              children: [
                const Icon(Icons.calendar_month),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM yyyy').format(_selectedMonth),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            itemBuilder: (context) {
              final months = List.generate(12, (index) {
                final month = DateTime.now().subtract(Duration(days: 30 * index));
                return PopupMenuItem(
                  value: index,
                  child: Text(DateFormat('MMMM yyyy').format(month)),
                );
              });
              return months;
            },
            onSelected: (index) {
              setState(() {
                _selectedMonth = DateTime.now().subtract(Duration(days: 30 * index));
              });
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUnpaidTab(),
          _buildPaidTab(),
        ],
      ),
    );
  }

  // Unpaid Tab - Shows students who haven't paid this month
  Widget _buildUnpaidTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('No students found', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }

        final allStudents = snapshot.data!.docs;

        return StreamBuilder<QuerySnapshot>(
          stream: _paymentService.getMonthlyPayments(_selectedMonth),
          builder: (context, paymentSnapshot) {
            final paidStudentIds = <String>{};
            
            if (paymentSnapshot.hasData) {
              for (var doc in paymentSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                paidStudentIds.add(data['studentId'] ?? '');
              }
            }

            // Filter unpaid students
            final unpaidStudents = allStudents.where((doc) {
              return !paidStudentIds.contains(doc.id);
            }).toList();

            // Sort by name
            unpaidStudents.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aName = (aData['fullName'] ?? aData['email'] ?? '').toString().toLowerCase();
              final bName = (bData['fullName'] ?? bData['email'] ?? '').toString().toLowerCase();
              return aName.compareTo(bName);
            });

            if (unpaidStudents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.celebration, size: 80, color: Colors.green[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'All students have paid!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: unpaidStudents.length,
              itemBuilder: (context, index) {
                final studentDoc = unpaidStudents[index];
                final studentData = studentDoc.data() as Map<String, dynamic>;
                return _buildUnpaidStudentCard(studentDoc.id, studentData);
              },
            );
          },
        );
      },
    );
  }

  // Paid Tab - Shows students who paid this month
  Widget _buildPaidTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _paymentService.getMonthlyPayments(_selectedMonth),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No payments recorded yet',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedMonth),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final payments = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final paymentDoc = payments[index];
            final paymentData = paymentDoc.data() as Map<String, dynamic>;
            return _buildPaidStudentCard(paymentDoc.id, paymentData);
          },
        );
      },
    );
  }

  Widget _buildUnpaidStudentCard(String studentId, Map<String, dynamic> studentData) {
    final name = studentData['fullName'] ?? studentData['email'] ?? 'Unknown';
    final email = studentData['email'] ?? 'No email';
    final room = studentData['roomNumber']?.toString() ?? 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.red[100],
          child: Icon(Icons.person, size: 28, color: Colors.red[700]),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(email, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.meeting_room, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Room: $room', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton.icon(
          onPressed: () => _showMarkAsPaidDialog(studentId, studentData),
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Mark Paid'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  Widget _buildPaidStudentCard(String paymentId, Map<String, dynamic> paymentData) {
    final name = paymentData['studentName'] ?? 'Unknown';
    final email = paymentData['studentEmail'] ?? 'No email';
    final room = paymentData['roomNumber']?.toString() ?? 'N/A';
    final amount = (paymentData['amount'] ?? 0).toDouble();
    final paymentDate = (paymentData['paymentDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    final paymentMethod = paymentData['paymentMethod'] ?? 'Cash';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.green[100],
                  child: Icon(Icons.check_circle, size: 28, color: Colors.green[700]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.meeting_room, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('Room: $room', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM').format(paymentDate),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.payment, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      paymentMethod,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _viewReceipt(paymentData),
                      icon: const Icon(Icons.receipt, size: 18),
                      label: const Text('Receipt'),
                    ),
                    TextButton.icon(
                      onPressed: () => _confirmDeletePayment(paymentId, paymentData),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMarkAsPaidDialog(String studentId, Map<String, dynamic> studentData) {
    final amountController = TextEditingController(text: '5000');
    DateTime selectedDate = DateTime.now();
    String selectedPaymentMethod = 'Cash';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Mark as Paid'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentData['fullName'] ?? 'Student',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(studentData['email'] ?? '', style: const TextStyle(color: Colors.grey)),
                const Divider(height: 24),
                const Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixText: '₹ ',
                    hintText: 'Enter amount',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text('Payment Date', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 12),
                        Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedPaymentMethod,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'Online Transfer', child: Text('Online Transfer')),
                    DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                    DropdownMenuItem(value: 'Card', child: Text('Card')),
                    DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedPaymentMethod = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount')),
                  );
                  return;
                }

                Navigator.pop(context);

                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Generating receipt...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                try {
                  print('UI: Starting payment creation...');
                  
                  // Add timeout to prevent infinite loading
                  await _paymentService.createPayment(
                    studentId: studentId,
                    studentName: studentData['fullName'] ?? 'Unknown',
                    studentEmail: studentData['email'] ?? 'No email',
                    roomNumber: studentData['roomNumber']?.toString() ?? 'N/A',
                    amount: amount,
                    paymentDate: selectedDate,
                    paymentMethod: selectedPaymentMethod,
                  ).timeout(
                    const Duration(seconds: 15),
                    onTimeout: () {
                      print('UI: Payment creation timed out after 15 seconds');
                      throw TimeoutException('Payment creation took too long. Please check your internet connection.');
                    },
                  );

                  print('UI: Payment creation completed successfully');
                  
                  if (mounted) {
                    Navigator.pop(context); // Close loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment recorded successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  print('UI: Error during payment creation: $e');
                  if (mounted) {
                    Navigator.pop(context); // Close loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Mark Paid & Send Receipt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewReceipt(Map<String, dynamic> paymentData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Receipt'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReceiptRow('Student:', paymentData['studentName'] ?? 'Unknown'),
              _buildReceiptRow('Email:', paymentData['studentEmail'] ?? 'N/A'),
              _buildReceiptRow('Room:', paymentData['roomNumber']?.toString() ?? 'N/A'),
              const Divider(),
              _buildReceiptRow(
                'Amount:',
                '₹${(paymentData['amount'] ?? 0).toStringAsFixed(2)}',
              ),
              _buildReceiptRow(
                'Date:',
                DateFormat('dd MMM yyyy').format(
                  (paymentData['paymentDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
                ),
              ),
              _buildReceiptRow('Method:', paymentData['paymentMethod'] ?? 'Cash'),
              const Divider(),
              if (paymentData['receiptUrl'] != null) ...[
                const SizedBox(height: 8),
                const Text('Receipt Image:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Image.network(
                  paymentData['receiptUrl'],
                  errorBuilder: (context, error, stackTrace) =>
                      const Text('Unable to load receipt image'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (paymentData['receiptUrl'] != null && paymentData['receiptUrl'].toString().isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                final receiptUrl = paymentData['receiptUrl'] as String;
                final uri = Uri.parse(receiptUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to open receipt'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('Download PDF'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmDeletePayment(String paymentId, Map<String, dynamic> paymentData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text(
          'Are you sure you want to delete this payment record for ${paymentData['studentName']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await _paymentService.deletePayment(
                  paymentId,
                  paymentData['receiptUrl'] ?? '',
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
