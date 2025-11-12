# Washing Machine Booking - Quick Start Guide

## ✅ Implementation Complete

### Files Created
1. **Model**
   - `lib/models/washing_booking.dart` - WashingBooking data model

2. **Service**
   - `lib/services/washing_booking_service.dart` - All booking logic with duplicate prevention

3. **Screens**
   - `lib/screens/washing_booking_screen.dart` - Student booking interface
   - `lib/screens/owner_bookings_screen.dart` - Owner bookings management

4. **Documentation**
   - `WASHING_BOOKING_FEATURE.md` - Comprehensive implementation guide

### Files Updated
- ✅ `lib/main.dart` - Added routes for booking screens
- ✅ `lib/screens/student_dashboard.dart` - Added "Washing Machine" card
- ✅ `lib/screens/owner_dashboard.dart` - Added "Washing Bookings" card

## 🚀 Quick Test Guide

### Student Workflow
```
1. Login as student
2. Tap "Washing Machine" card (purple with laundry icon)
3. Tap "Select Date" → Choose a date
4. Tap "Select Time" → Choose from 8 time slots
5. Tap "Confirm Booking"
6. See your booking in "My Upcoming Bookings"
7. Try to book same slot again (should fail with error)
```

### Owner Workflow
```
1. Login as owner
2. Tap "Washing Bookings" card
3. See all student bookings grouped by date
4. Tap filter icon → Select specific date
5. View booking count for that date
6. Tap X to clear filter
```

## 📋 Available Time Slots

Students can book these times:
- 06:00 AM
- 08:00 AM
- 10:00 AM
- 12:00 PM
- 02:00 PM
- 04:00 PM
- 06:00 PM
- 08:00 PM

**One student per time slot per day** - duplicate prevention built-in!

## 🔥 Firestore Structure

```
washing_bookings/
  {bookingId}/
    ├─ studentId: "user123"
    ├─ studentName: "John Doe"
    ├─ date: 2025-11-08T00:00:00
    ├─ time: "06:00 AM"
    └─ timestamp: 2025-11-08T15:30:00
```

## 🎯 Key Features

### For Students
✅ DatePicker for date selection (up to 30 days ahead)
✅ Custom time slot dialog (8 predefined slots)
✅ Duplicate slot prevention with error message
✅ View upcoming bookings list
✅ Cancel bookings with confirmation dialog
✅ Real-time updates via StreamBuilder

### For Owners
✅ View all student bookings
✅ Filter by specific date
✅ Booking count statistics
✅ Bookings grouped by date
✅ Clear date filtering
✅ "Confirmed" status display

## 🛡️ Duplicate Prevention Logic

### How It Works
1. Student selects date + time
2. Before creating booking:
   - Query Firestore for same date AND time
   - If exists → Show error: "This time slot is already booked"
   - If not exists → Create booking successfully

### Query Implementation
```dart
// Check if date+time combination exists
final snapshot = await _firestore
    .collection('washing_bookings')
    .where('date', isGreaterThanOrEqualTo: startOfDay)
    .where('date', isLessThan: endOfDay)
    .where('time', isEqualTo: selectedTime)
    .limit(1)
    .get();

if (snapshot.docs.isNotEmpty) {
  throw Exception('Slot already booked!');
}
```

## 📱 Running the App

```bash
# Already installed, just run
flutter run -d chrome
```

## 🧪 Testing Scenarios

### Basic Tests
- [ ] Student books a slot successfully
- [ ] Second student tries same slot (should fail)
- [ ] Student cancels booking
- [ ] Owner views all bookings
- [ ] Owner filters by date
- [ ] Bookings persist after logout

### Edge Cases
- [ ] Booking 30 days in advance
- [ ] Multiple bookings for same student on different days
- [ ] Cancellation removes from both student and owner views
- [ ] Network error handling

## 🔧 Firestore Indexes

When you first run queries, Firestore will prompt to create indexes. Click the links to auto-create these composite indexes:

1. **Collection**: `washing_bookings`
   - Fields: `studentId` (Asc), `date` (Asc), `time` (Asc)

2. **Collection**: `washing_bookings`
   - Fields: `date` (Asc), `time` (Asc)

## 🎨 UI Design

### Student Screen
- **Purple theme** for washing machine feature
- **DatePicker**: Material calendar dialog
- **TimePicker**: Custom slot selection dialog
- **Booking cards**: Date, time, cancel button
- **Empty state**: "No upcoming bookings" message

### Owner Screen
- **Filter bar**: Active date filter display
- **Statistics**: Booking count per date
- **Grouped list**: Bookings organized by date
- **Confirmed badges**: Green "Confirmed" status

## ⚠️ Important Notes

### Date/Time Handling
- All dates stored without time component (00:00:00)
- Times stored as strings ("06:00 AM")
- Only future bookings displayed (from today onwards)
- Past bookings automatically hidden

### Cancellation
- Students can only cancel their own bookings
- Requires confirmation dialog
- Immediately removes from all views
- No restrictions on cancellation timing

## 🔐 Security Rules (Recommended)

Add to Firestore rules:
```javascript
match /washing_bookings/{bookingId} {
  // Students can create
  allow create: if request.auth != null && 
                getUserRole(request.auth.uid) == 'student';
  
  // All authenticated users can read
  allow read: if request.auth != null;
  
  // Students can delete only their bookings
  allow delete: if request.auth.uid == resource.data.studentId;
}
```

## 📊 Example Usage

### Scenario 1: Student Books
1. Student A opens booking screen
2. Selects Nov 10, 2025 @ 06:00 AM
3. Taps "Confirm Booking"
4. ✅ Booking created successfully

### Scenario 2: Duplicate Prevention
1. Student B tries to book Nov 10, 2025 @ 06:00 AM
2. System checks: Already booked by Student A
3. ❌ Error: "This time slot is already booked. Please choose another time."

### Scenario 3: Owner Views
1. Owner opens bookings screen
2. Sees bookings grouped:
   - **Nov 10, 2025** (2 bookings)
     - Student A - 06:00 AM
     - Student C - 08:00 AM
3. Filters to Nov 10
4. Statistics show: "Total Bookings: 2"

## 🐛 Troubleshooting

**Issue**: Can't create booking
- Check user is logged in as student
- Verify Firestore permissions
- Check network connection

**Issue**: "Slot already booked" error unexpected
- Verify date/time comparison logic
- Check Firestore data format
- Look at existing bookings in Firestore console

**Issue**: Bookings not showing
- Ensure booking date is in future
- Check studentId matches current user
- Verify Firestore indexes created

## 📈 Next Steps

1. ✅ Run the app: `flutter run -d chrome`
2. ✅ Test student booking flow
3. ✅ Test duplicate prevention
4. ✅ Test owner viewing bookings
5. ✅ Add Firestore security rules (optional but recommended)

## 📚 Full Documentation

See `WASHING_BOOKING_FEATURE.md` for:
- Detailed technical implementation
- Complete API reference
- Security considerations
- Future enhancement ideas
- Performance optimization tips

---

**Status**: ✅ Ready to Use
**No new dependencies required** - Uses existing Firebase packages
**Estimated setup time**: 2 minutes (just run the app!)

Happy booking! 🧺
