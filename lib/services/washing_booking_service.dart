import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/washing_booking.dart';

class WashingBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new washing booking
  Future<void> createBooking(DateTime date, String time) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if slot is already booked
    final isBooked = await isSlotBooked(date, time);
    if (isBooked) {
      throw Exception('This time slot is already booked. Please choose another time.');
    }

    // Get student name from users collection
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final studentName = userDoc.data()?['fullName'] ?? 'Unknown Student';

    // Create booking
    final bookingData = WashingBooking(
      id: '',
      studentId: user.uid,
      studentName: studentName,
      date: date,
      time: time,
      timestamp: DateTime.now(),
    ).toMap();

    await _firestore.collection('washing_bookings').add(bookingData);
  }

  // Check if a specific slot is already booked
  Future<bool> isSlotBooked(DateTime date, String time) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final nextDay = dateOnly.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('washing_bookings')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dateOnly))
        .where('date', isLessThan: Timestamp.fromDate(nextDay))
        .where('time', isEqualTo: time)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Get current student's bookings
  Stream<List<WashingBooking>> getStudentBookings() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _firestore
        .collection('washing_bookings')
        .where('studentId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .orderBy('date', descending: false)
        .orderBy('time', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WashingBooking.fromFirestore(doc))
            .toList());
  }

  // Get all bookings (for owner)
  Stream<List<WashingBooking>> getAllBookings() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _firestore
        .collection('washing_bookings')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .orderBy('date', descending: false)
        .orderBy('time', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WashingBooking.fromFirestore(doc))
            .toList());
  }

  // Get bookings for a specific date
  Stream<List<WashingBooking>> getBookingsByDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final nextDay = dateOnly.add(const Duration(days: 1));

    return _firestore
        .collection('washing_bookings')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dateOnly))
        .where('date', isLessThan: Timestamp.fromDate(nextDay))
        .orderBy('date', descending: false)
        .orderBy('time', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WashingBooking.fromFirestore(doc))
            .toList());
  }

  // Delete a booking (student can cancel their own booking)
  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection('washing_bookings').doc(bookingId).delete();
  }

  // Get booking count for a specific date (for owner statistics)
  Future<int> getBookingCountForDate(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final nextDay = dateOnly.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('washing_bookings')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dateOnly))
        .where('date', isLessThan: Timestamp.fromDate(nextDay))
        .get();

    return snapshot.docs.length;
  }
}
