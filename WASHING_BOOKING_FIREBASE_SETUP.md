# Washing Booking Firebase Setup Guide

## Issue
The washing booking feature is not storing data in Firebase because:
1. **Firestore Security Rules** may be blocking writes
2. **Composite Indexes** are missing for the queries used

## Solution

### 1. Firestore Security Rules

Add these rules to your Firebase Console (Firestore Database > Rules):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Washing Bookings Collection
    match /washing_bookings/{bookingId} {
      // Allow students to read their own bookings
      allow read: if request.auth != null && 
                     (resource.data.studentId == request.auth.uid || 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner');
      
      // Allow students to create bookings
      allow create: if request.auth != null && 
                       request.resource.data.studentId == request.auth.uid &&
                       request.resource.data.keys().hasAll(['studentId', 'studentName', 'date', 'time', 'timestamp']);
      
      // Allow students to delete their own bookings
      allow delete: if request.auth != null && 
                       resource.data.studentId == request.auth.uid;
      
      // Allow owners to delete any booking
      allow delete: if request.auth != null && 
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner';
    }
  }
}
```

### 2. Firestore Composite Indexes

The queries in `WashingBookingService` require composite indexes. You have two options:

#### Option A: Create Indexes via Firebase Console (Recommended)

1. Go to Firebase Console > Firestore Database > Indexes
2. Click "Add Index"
3. Create these indexes:

**Index 1: Student Bookings Query**
- Collection: `washing_bookings`
- Fields to index:
  - `studentId` - Ascending
  - `date` - Ascending
  - `time` - Ascending

**Index 2: All Bookings Query (for Owner)**
- Collection: `washing_bookings`
- Fields to index:
  - `date` - Ascending
  - `time` - Ascending

**Index 3: Date-based Bookings Query**
- Collection: `washing_bookings`
- Fields to index:
  - `date` - Ascending
  - `time` - Ascending

Note: Index 2 and 3 are the same, so you only need to create it once.

#### Option B: Let Firebase Create Indexes Automatically

1. Try to create a booking in the app
2. Check the Flutter console/logs for an error message
3. The error will contain a direct link to create the required index
4. Click the link and Firebase will auto-generate the index
5. Wait 1-2 minutes for the index to build

### 3. Test the Setup

After setting up rules and indexes:

1. **Test Creating a Booking:**
   - Login as a student
   - Go to Washing Booking screen
   - Select a date and time
   - Click "Confirm Booking"
   - Should show "Booking created successfully!"

2. **Verify in Firebase Console:**
   - Go to Firestore Database
   - Check `washing_bookings` collection
   - You should see the new booking document

3. **Check Data Structure:**
   ```
   washing_bookings/
     └── {auto-generated-id}
           ├── studentId: "user-uid-here"
           ├── studentName: "Student Name"
           ├── date: Timestamp
           ├── time: "08:00 AM"
           └── timestamp: Timestamp
   ```

## Common Errors and Solutions

### Error: "Missing or insufficient permissions"
**Solution:** Update Firestore Security Rules as shown above

### Error: "The query requires an index"
**Solution:** Create the composite indexes as shown above, or click the link in the error message

### Error: "User not authenticated"
**Solution:** Make sure the student is logged in before accessing the booking screen

### Error: "This time slot is already booked"
**This is expected behavior** - The slot is taken by another student. Choose a different time.

## Debugging Tips

1. **Check Console Logs:**
   - Open Chrome DevTools or Flutter console
   - Look for detailed error messages

2. **Verify User Authentication:**
   ```dart
   print('Current User: ${FirebaseAuth.instance.currentUser?.uid}');
   ```

3. **Test Rules in Firebase Console:**
   - Go to Firestore Database > Rules
   - Click "Rules Playground"
   - Test your queries

4. **Check Index Status:**
   - Go to Firestore Database > Indexes
   - Make sure all indexes show "Enabled" status (not "Building")

## Quick Fix Alternative

If you want to get it working immediately without complex queries, you can simplify the service. Update `washing_booking_service.dart`:

```dart
// Simplified version - Get student bookings without complex query
Stream<List<WashingBooking>> getStudentBookings() {
  final user = _auth.currentUser;
  if (user == null) return Stream.value([]);

  return _firestore
      .collection('washing_bookings')
      .where('studentId', isEqualTo: user.uid)
      .orderBy('timestamp', descending: true) // Changed from date
      .snapshots()
      .map((snapshot) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        return snapshot.docs
            .map((doc) => WashingBooking.fromFirestore(doc))
            .where((booking) => 
              booking.date.isAfter(today) || 
              booking.date.isAtSameMomentAs(today))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
      });
}
```

This uses filtering in Dart instead of Firestore, requiring fewer indexes.
