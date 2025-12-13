import 'dart:typed_data';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/payment.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Cloudinary configuration
  static const String _cloudName = 'difixpzlr';
  static const String _uploadPreset = 'nestify_receipts';
  final CloudinaryPublic _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset);

  // Generate PDF receipt (simplified and fast)
  Future<Uint8List> generateReceipt({
    required String studentName,
    required String studentEmail,
    required String roomNumber,
    required double amount,
    required DateTime paymentDate,
    required String receiptId,
  }) async {
    print('PaymentService: Generating receipt...');
    
    // Use simple defaults - no database calls for speed
    const pgName = 'NESTIFY PG';
    // Note: pgAddress and pgContact can be fetched from owner details if needed
    // Currently using minimal information for faster PDF generation

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
                        pgName,
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

  // Upload receipt to Cloudinary
  Future<String> uploadReceipt({
    required Uint8List pdfBytes,
    required String studentId,
    required String receiptId,
  }) async {
    try {
      print('PaymentService: Starting Cloudinary upload - PDF size: ${pdfBytes.length} bytes');
      
      // Upload PDF to Cloudinary using Auto resource type
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          pdfBytes,
          identifier: '$receiptId.pdf',
          folder: 'nestify/receipts/$studentId',
          resourceType: CloudinaryResourceType.Auto, // Try Auto instead of Raw
        ),
      );
      
      print('PaymentService: ✅ Cloudinary upload successful!');
      print('PaymentService: URL: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      print('PaymentService: ❌ Cloudinary upload FAILED - $e');
      throw Exception('Failed to upload receipt to Cloudinary: $e');
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
    String? paymentMethod,
  }) async {
    try {
      print('PaymentService: Starting payment creation...');
      final startTime = DateTime.now();
      
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Generate unique receipt ID
      final receiptId = 'RCP-${DateTime.now().millisecondsSinceEpoch}';
      print('PaymentService: Receipt ID generated: $receiptId');

      // Generate PDF receipt
      print('PaymentService: Generating PDF receipt...');
      final pdfStartTime = DateTime.now();
      final pdfBytes = await generateReceipt(
        studentName: studentName,
        studentEmail: studentEmail,
        roomNumber: roomNumber,
        amount: amount,
        paymentDate: paymentDate,
        receiptId: receiptId,
      );
      final pdfDuration = DateTime.now().difference(pdfStartTime);
      print('PaymentService: PDF generated in ${pdfDuration.inMilliseconds}ms');

      // Upload receipt to Cloudinary
      print('PaymentService: Uploading PDF to Cloudinary...');
      final uploadStartTime = DateTime.now();
      final receiptUrl = await uploadReceipt(
        pdfBytes: pdfBytes,
        studentId: studentId,
        receiptId: receiptId,
      );
      final uploadDuration = DateTime.now().difference(uploadStartTime);
      print('PaymentService: Upload completed in ${uploadDuration.inMilliseconds}ms');

      // Create payment record in Firestore
      print('PaymentService: Saving to Firestore...');
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
        status: 'paid',
        paymentMethod: paymentMethod,
      );

      await _firestore.collection('payments').doc(receiptId).set(payment.toMap());
      
      final totalDuration = DateTime.now().difference(startTime);
      print('PaymentService: ✅ Payment created successfully! Total time: ${totalDuration.inMilliseconds}ms');
      print('PaymentService: Receipt URL: $receiptUrl');
    } catch (e) {
      print('PaymentService: ❌ ERROR - $e');
      print('PaymentService: Stack trace: ${StackTrace.current}');
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

  // Get payments for a specific month
  Stream<QuerySnapshot> getMonthlyPayments(DateTime month) {
    // Get start of month
    final startOfMonth = DateTime(month.year, month.month, 1);
    
    // Get start of next month
    final endOfMonth = DateTime(month.year, month.month + 1, 1);
    
    return _firestore
        .collection('payments')
        .where('paymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('paymentDate', isLessThan: Timestamp.fromDate(endOfMonth))
        .snapshots();
  }

  // Get all students (for payment creation)
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      print('PaymentService: Fetching all students...');
      
      // Fetch all students without orderBy to avoid composite index requirement
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      print('PaymentService: Found ${snapshot.docs.length} students');

      // Convert to list with null handling
      final students = snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        
        // Add null handling for optional fields
        data['fullName'] = data['fullName'] ?? data['name'] ?? data['email'] ?? 'Unknown';
        data['roomNumber'] = data['roomNumber']?.toString() ?? data['room']?.toString() ?? 'N/A';
        data['email'] = data['email'] ?? 'No email';
        
        return data;
      }).toList();

      // Sort by name in memory (no Firestore index needed)
      students.sort((a, b) {
        final aName = (a['fullName'] as String? ?? '').toLowerCase();
        final bName = (b['fullName'] as String? ?? '').toLowerCase();
        return aName.compareTo(bName);
      });

      print('PaymentService: Students sorted by name');
      return students;
    } catch (e) {
      print('PaymentService: Error fetching students: $e');
      rethrow;
    }
  }

  // Delete payment
  Future<void> deletePayment(String paymentId, String receiptUrl) async {
    try {
      // Delete from Firestore
      await _firestore.collection('payments').doc(paymentId).delete();

      // Note: Cloudinary file deletion requires server-side Admin API
      // The receipt URL will become orphaned in Cloudinary
      // For production, implement a Cloud Function to delete Cloudinary files
      print('PaymentService: Payment deleted. Cloudinary file cleanup requires server-side implementation.');
    } catch (e) {
      throw Exception('Failed to delete payment: $e');
    }
  }

  // Regenerate and resend receipt to student
  Future<String> regenerateReceipt(String paymentId) async {
    try {
      print('PaymentService: Regenerating receipt for payment: $paymentId');
      
      // Get existing payment
      final paymentDoc = await _firestore.collection('payments').doc(paymentId).get();
      if (!paymentDoc.exists) {
        throw Exception('Payment not found');
      }
      
      final data = paymentDoc.data() as Map<String, dynamic>;
      
      // Generate new receipt ID
      final newReceiptId = 'RCP-${DateTime.now().millisecondsSinceEpoch}';
      print('PaymentService: New receipt ID: $newReceiptId');
      
      // Generate PDF
      final pdfBytes = await generateReceipt(
        studentName: data['studentName'] ?? 'Unknown',
        studentEmail: data['studentEmail'] ?? 'No email',
        roomNumber: data['roomNumber']?.toString() ?? 'N/A',
        amount: (data['amount'] ?? 0).toDouble(),
        paymentDate: (data['paymentDate'] as Timestamp).toDate(),
        receiptId: newReceiptId,
      );
      
      // Upload to storage
      final receiptUrl = await uploadReceipt(
        pdfBytes: pdfBytes,
        studentId: data['studentId'],
        receiptId: newReceiptId,
      );
      
      // Update payment record with new receipt URL
      await _firestore.collection('payments').doc(paymentId).update({
        'receiptUrl': receiptUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('PaymentService: Receipt regenerated successfully!');
      return receiptUrl;
    } catch (e) {
      print('PaymentService: Failed to regenerate receipt - $e');
      throw Exception('Failed to regenerate receipt: $e');
    }
  }

  // Get student's payment receipts
  Future<List<Payment>> getStudentReceipts(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('studentId', isEqualTo: studentId)
          .orderBy('paymentDate', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList();
    } catch (e) {
      print('PaymentService: Error fetching student receipts: $e');
      throw Exception('Failed to fetch receipts: $e');
    }
  }
}

