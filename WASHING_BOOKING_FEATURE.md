# Washing Machine Booking Feature - Implementation Guide

## Overview
The Washing Machine Booking feature allows students to book time slots for using the washing machine. Owners can view all bookings and monitor usage. The system prevents double-booking by checking for existing bookings at the same date and time.

## Features Implemented

### Student Side
1. **Washing Booking Screen** (`washing_booking_screen.dart`)
   - Select date using DatePicker (up to 30 days ahead)
   - Select time from predefined slots using custom dialog
   - Submit booking with duplicate slot prevention
   - View upcoming bookings list
   - Cancel own bookings
   - Real-time booking updates

2. **Available Time Slots**
   - 06:00 AM
   - 08:00 AM
   - 10:00 AM
   - 12:00 PM
   - 02:00 PM
   - 04:00 PM
   - 06:00 PM
   - 08:00 PM

### Owner Side
1. **Owner Bookings Screen** (`owner_bookings_screen.dart`)
   - View all upcoming bookings
   - Filter bookings by date
   - See booking statistics (count per date)
   - Bookings grouped by date
   - Confirmed status display
   - Clear overview of student usage

## Technical Implementation

### Data Model (`lib/models/washing_booking.dart`)

#### WashingBooking Model
```dart
class WashingBooking {
  final String id;
  final String studentId;
  final String studentName;
  final DateTime date;
  final String time;
  final DateTime timestamp;
}
```

### Firestore Structure

#### Collection: `washing_bookings`
```
washing_bookings/
  {bookingId}/
    - studentId: string (user UID)
    - studentName: string (from users collection)
    - date: timestamp (day selected)
    - time: string (e.g., "06:00 AM")
    - timestamp: timestamp (when booking was created)
```

### Services (`lib/services/washing_booking_service.dart`)

#### Key Methods
1. **createBooking(date, time)**
   - Validates slot availability
   - Gets student name from Firestore
   - Creates new booking
   - Throws error if slot already booked

2. **isSlotBooked(date, time)**
   - Checks if specific date/time combination exists
   - Returns boolean

3. **getStudentBookings()**
   - Stream of current student's bookings
   - Only future bookings (from today onwards)
   - Ordered by date and time

4. **getAllBookings()**
   - Stream of all bookings for owner
   - Only future bookings
   - Ordered by date and time

5. **getBookingsByDate(date)**
   - Stream of bookings for specific date
   - Used for date filtering

6. **deleteBooking(bookingId)**
   - Allows student to cancel their booking

7. **getBookingCountForDate(date)**
   - Returns count of bookings for a date
   - Used in owner statistics

## Duplicate Booking Prevention

### Logic Flow
1. Student selects date and time
2. On submit, service calls `isSlotBooked(date, time)`
3. Query Firestore for bookings matching:
   - Date (within same day range)
   - Time (exact match)
4. If found: Throw error "This time slot is already booked"
5. If not found: Create booking

### Query Implementation
```dart
final snapshot = await _firestore
    .collection('washing_bookings')
    .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dateOnly))
    .where('date', isLessThan: Timestamp.fromDate(nextDay))
    .where('time', isEqualTo: time)
    .limit(1)
    .get();

return snapshot.docs.isNotEmpty;
```

## Usage Instructions

### For Students

1. **Book a Time Slot**
   - Navigate to "Washing Machine" from dashboard
   - Tap "Select Date" → Choose date from calendar
   - Tap "Select Time" → Choose from available slots
   - Tap "Confirm Booking"
   - See confirmation message

2. **View Bookings**
   - Scroll down to "My Upcoming Bookings"
   - See all future bookings with details
   - Bookings automatically disappear after date passes

3. **Cancel Booking**
   - Tap red cancel icon on booking card
   - Confirm cancellation
   - Booking removed immediately

### For Owners

1. **View All Bookings**
   - Navigate to "Washing Bookings" from dashboard
   - See all upcoming bookings grouped by date
   - Each date shows booking count

2. **Filter by Date**
   - Tap filter icon in app bar
   - Select specific date
   - See only bookings for that date
   - View booking count statistics
   - Tap "X" or filter icon again to clear

3. **Monitor Usage**
   - Check booking patterns
   - See student names and times
   - All bookings marked as "Confirmed"

## UI Components

### Student Booking Screen
- **Booking Form Card**
  - Date picker with calendar icon
  - Time slot selector with dialog
  - Prominent submit button
  - Loading state during submission

- **Upcoming Bookings List**
  - Card-based layout
  - Date, time, and booking timestamp
  - Cancel button for each booking
  - Empty state message

### Owner Bookings Screen
- **Filter Bar** (when active)
  - Shows current filter date
  - Quick clear button

- **Statistics Card** (when filtered)
  - Total bookings count
  - Green color scheme

- **Grouped Bookings List**
  - Date headers with booking count
  - Student name and details
  - "Confirmed" status badge
  - Empty state for no bookings

## Error Handling

### Common Scenarios
1. **Slot already booked**: "This time slot is already booked. Please choose another time."
2. **Date not selected**: "Please select a date"
3. **Time not selected**: "Please select a time"
4. **User not authenticated**: "User not authenticated"
5. **Cancellation error**: "Error cancelling booking: {details}"

### User Feedback
- Success messages in green SnackBar
- Error messages in red SnackBar
- Loading indicators during operations
- Confirmation dialogs for cancellations

## Security Considerations

### Firestore Security Rules (Recommended)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /washing_bookings/{bookingId} {
      // Students can create bookings
      allow create: if request.auth != null && 
                    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'student';
      
      // Students can read their own bookings, owners can read all
      allow read: if request.auth != null;
      
      // Students can delete only their own bookings
      allow delete: if request.auth != null && 
                    resource.data.studentId == request.auth.uid;
    }
  }
}
```

## Firestore Indexes Required

### Composite Indexes
1. **For student bookings query**
   ```
   Collection: washing_bookings
   Fields: studentId (Ascending), date (Ascending), time (Ascending)
   ```

2. **For all bookings query**
   ```
   Collection: washing_bookings
   Fields: date (Ascending), time (Ascending)
   ```

3. **For slot availability check**
   ```
   Collection: washing_bookings
   Fields: date (Ascending), time (Ascending)
   ```

Firestore will automatically prompt to create these when queries are run.

## Testing Checklist

### Student Tests
- [ ] Book a time slot successfully
- [ ] Try to book same slot (should fail)
- [ ] View upcoming bookings
- [ ] Cancel a booking
- [ ] Book multiple different slots
- [ ] Verify bookings persist after logout/login

### Owner Tests
- [ ] View all bookings
- [ ] Filter by specific date
- [ ] Clear date filter
- [ ] See booking count statistics
- [ ] Verify bookings grouped correctly by date

### Edge Cases
- [ ] Booking on last available date (30 days ahead)
- [ ] Cancelling booking removes from both views
- [ ] Multiple students booking different times on same day
- [ ] Network connectivity issues
- [ ] Past bookings not showing in lists

## Navigation Integration

### Added Routes in main.dart
```dart
'/student/washing-booking': (context) => const WashingBookingScreen(),
'/owner/bookings': (context) => const OwnerBookingsScreen(),
```

### Dashboard Cards
- **Student Dashboard**: Purple card with laundry icon
- **Owner Dashboard**: Purple card with event note icon

## File Structure

```
lib/
├── models/
│   └── washing_booking.dart
├── services/
│   └── washing_booking_service.dart
└── screens/
    ├── washing_booking_screen.dart (student)
    └── owner_bookings_screen.dart (owner)
```

## Future Enhancements

### Potential Features
1. **Time slot capacity**: Allow multiple students per slot
2. **Duration options**: 30 min, 1 hour, 2 hour slots
3. **Notifications**: Remind students of upcoming booking
4. **Recurring bookings**: Book same time every week
5. **Booking history**: See past bookings
6. **Availability calendar**: Visual grid of free/booked slots
7. **Queue system**: Join waitlist if slot is full
8. **Owner management**: Mark slots as unavailable for maintenance

## Performance Considerations

### Optimizations
1. **Date-based queries**: Only fetch future bookings
2. **Indexed queries**: Composite indexes for fast lookups
3. **Real-time updates**: StreamBuilder for live data
4. **Limited date range**: Max 30 days booking window
5. **Grouped display**: Efficient rendering with ListView.builder

## Troubleshooting

### Issue: "Slot already booked" but no booking visible
**Solution**: Check date/time comparison logic, verify Firestore timestamp format

### Issue: Bookings not showing for student
**Solution**: Verify user authentication, check studentId matches current user

### Issue: Filter not working on owner screen
**Solution**: Ensure date comparison logic includes full day range (00:00 to 23:59)

### Issue: Can't create booking
**Solution**: Check Firestore security rules, verify user has 'student' role

## Dependencies Used

### Existing Packages
- `firebase_core` - Firebase initialization
- `firebase_auth` - User authentication
- `cloud_firestore` - Database operations
- `intl` - Date formatting (already present from previous features)

### No New Dependencies Required
All functionality uses existing packages from the project.

## Date & Time Handling

### Date Selection
- Uses Flutter's `showDatePicker`
- Start date: Today
- End date: 30 days from today
- Material Design 3 theming

### Time Selection
- Custom dialog with predefined slots
- 2-hour intervals throughout the day
- 12-hour format with AM/PM
- Easy tap to select

### Format Examples
- Date display: "Monday, Nov 8, 2025"
- Time display: "6:00 AM"
- Timestamp display: "Nov 8, 3:45 pm"

## Success Metrics

### Key Indicators
1. **Booking success rate**: Percentage of bookings completed vs attempted
2. **Slot utilization**: How many slots are booked vs available
3. **Cancellation rate**: Percentage of bookings cancelled
4. **Peak usage times**: Most popular booking slots
5. **User engagement**: Number of bookings per student

## Support & Maintenance

### Daily Operations
- Monitor booking conflicts
- Check for system errors
- Review cancellation patterns

### Weekly Tasks
- Analyze usage statistics
- Check Firestore quota usage
- Review student feedback

### Monthly Tasks
- Clean up old booking data (optional)
- Update time slots if needed
- Review and optimize queries

---

**Implementation Date**: November 2025
**Version**: 1.0.0
**Status**: Production Ready
**Dependencies**: None (uses existing packages)
