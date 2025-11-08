import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/payment.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Generate PDF receipt
  Future<Uint8List> generateReceipt({
    required String studentName,
    required String studentEmail,
    required String roomNumber,
    required double amount,
    required DateTime paymentDate,
    required String receiptId,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.deepPurple50,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'NESTIFY PG',
                        style: pw.TextStyle(
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.deepPurple,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Payment Receipt',
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 40),

                // Receipt Details
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Receipt Details',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Divider(thickness: 2),
                      pw.SizedBox(height: 15),

                      _buildDetailRow('Receipt ID:', receiptId),
                      pw.SizedBox(height: 10),
                      _buildDetailRow('Issue Date:', DateFormat('MMM dd, yyyy').format(DateTime.now())),
                      pw.SizedBox(height: 10),
                      _buildDetailRow('Payment Date:', DateFormat('MMM dd, yyyy').format(paymentDate)),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // Student Information
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Student Information',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Divider(thickness: 2),
                      pw.SizedBox(height: 15),

                      _buildDetailRow('Name:', studentName),
                      pw.SizedBox(height: 10),
                      _buildDetailRow('Email:', studentEmail),
                      pw.SizedBox(height: 10),
                      _buildDetailRow('Room Number:', roomNumber),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // Payment Amount
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    border: pw.Border.all(color: PdfColors.green, width: 2),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Amount Paid:',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '₹${amount.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green900,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Footer
                pw.Divider(thickness: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'Thank you for your payment!',
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text(
                    'This is a computer-generated receipt and does not require a signature.',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 150,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 14,
              color: PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  // Upload receipt to Firebase Storage
  Future<String> uploadReceipt({
    required Uint8List pdfBytes,
    required String studentId,
    required String receiptId,
  }) async {
    try {
      final String storagePath = 'receipts/$studentId/$receiptId.pdf';
      final Reference ref = _storage.ref().child(storagePath);

      final metadata = SettableMetadata(
        contentType: 'application/pdf',
        customMetadata: {
          'studentId': studentId,
          'receiptId': receiptId,
        },
      );

      final UploadTask uploadTask = ref.putData(pdfBytes, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload receipt: $e');
    }
  }

  // Create payment record
  Future<void> createPayment({
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String roomNumber,
    required double amount,
    required DateTime paymentDate,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Generate unique receipt ID
      final receiptId = 'RCP-${DateTime.now().millisecondsSinceEpoch}';

      // Generate PDF receipt
      final pdfBytes = await generateReceipt(
        studentName: studentName,
        studentEmail: studentEmail,
        roomNumber: roomNumber,
        amount: amount,
        paymentDate: paymentDate,
        receiptId: receiptId,
      );

      // Upload receipt to storage
      final receiptUrl = await uploadReceipt(
        pdfBytes: pdfBytes,
        studentId: studentId,
        receiptId: receiptId,
      );

      // Create payment record in Firestore
      final payment = Payment(
        id: receiptId,
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        amount: amount,
        paymentDate: paymentDate,
        receiptUrl: receiptUrl,
        createdBy: user.uid,
        createdAt: DateTime.now(),
        roomNumber: roomNumber,
      );

      await _firestore.collection('payments').doc(receiptId).set(payment.toMap());
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  // Get all payments (for owner)
  Stream<List<Payment>> getAllPayments() {
    return _firestore
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList());
  }

  // Get payments for specific student
  Stream<List<Payment>> getStudentPayments(String studentId) {
    return _firestore
        .collection('payments')
        .where('studentId', isEqualTo: studentId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList());
  }

  // Get all students (for payment creation)
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .orderBy('fullName')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return data;
    }).toList();
  }

  // Delete payment
  Future<void> deletePayment(String paymentId, String receiptUrl) async {
    try {
      // Delete from Firestore
      await _firestore.collection('payments').doc(paymentId).delete();

      // Delete receipt from Storage
      try {
        final ref = _storage.refFromURL(receiptUrl);
        await ref.delete();
      } catch (e) {
        print('Error deleting receipt from storage: $e');
      }
    } catch (e) {
      throw Exception('Failed to delete payment: $e');
    }
  }
}
