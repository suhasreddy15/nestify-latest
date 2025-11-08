# Complaint Management Feature - Nestify

## Overview
The Complaint Management feature allows students to raise complaints about their PG accommodation, and enables owners to view, filter, and resolve these complaints efficiently.

## Features Implemented

### For Students
- **Raise Complaints**: Simple form with title and description fields
- **View Complaint History**: See all submitted complaints with their status
- **Real-time Updates**: Automatically see when complaints are resolved
- **Input Validation**: Ensures proper complaint format before submission

### For Owners
- **View All Complaints**: See complaints from all students
- **Filter by Status**: Toggle between All, Pending, and Resolved complaints
- **Update Status**: Mark complaints as resolved or reopen them
- **Detailed View**: See full complaint details including student information
- **Real-time Updates**: Live updates as new complaints come in

## File Structure

```
lib/
├── models/
│   └── complaint.dart              # Complaint data model
├── services/
│   └── complaint_service.dart      # Firestore operations for complaints
├── screens/
│   ├── student_complaint_screen.dart    # Student complaint form & history
│   ├── owner_complaint_list_screen.dart # Owner complaint management
│   ├── student_dashboard.dart           # Updated with complaint access
│   └── owner_dashboard.dart             # Updated with complaint access
└── main.dart                            # Updated with routes
```

## Data Model

### Complaint Collection (Firestore)
```
complaints/
  ├── [complaintId]/
      ├── title: string
      ├── description: string
      ├── studentId: string
      ├── studentEmail: string
      ├── timestamp: timestamp
      └── status: string ('pending' or 'resolved')
```

## How to Use

### As a Student:
1. Login to your student account
2. Click on "Raise a Complaint" card on the dashboard
3. Fill in the complaint form:
   - Title (minimum 5 characters)
   - Description (minimum 20 characters)
4. Click "Submit Complaint"
5. View your complaint history below the form
6. Track the status of your complaints (pending/resolved)

### As an Owner:
1. Login to your owner account
2. Click on "Manage Complaints" card on the dashboard
3. View all complaints from students
4. Filter complaints by status using the filter chips at the top
5. Click on a complaint to see full details
6. Use the "Mark as Resolved" or "Reopen" buttons to update status
7. Complaints update in real-time for all users

## Key Features

### Student Complaint Screen
- **Form Validation**: 
  - Title must be at least 5 characters
  - Description must be at least 20 characters
- **Real-time History**: Shows all complaints with live updates
- **Status Indicators**: Color-coded chips for pending (orange) and resolved (green)
- **Timestamp Display**: Shows how long ago each complaint was submitted

### Owner Complaint List Screen
- **Status Filters**: Quick toggle between All, Pending, and Resolved
- **Complaint Cards**: Rich information display with student email and timestamp
- **Detail Modal**: Bottom sheet with full complaint information
- **Quick Actions**: Resolve or reopen directly from the list
- **Empty States**: Helpful messages when no complaints exist

## Firebase Setup Required

Make sure your Firestore rules allow:
1. Students can create and read their own complaints
2. Owners can read all complaints and update status

### Recommended Firestore Security Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /complaints/{complaintId} {
      // Students can create complaints and read their own
      allow create: if request.auth != null && 
                      request.auth.uid == request.resource.data.studentId;
      allow read: if request.auth != null && 
                     (request.auth.uid == resource.data.studentId ||
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner');
      
      // Only owners can update complaint status
      allow update: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner' &&
                      request.resource.data.keys().hasOnly(['status']);
    }
  }
}
```

## Dependencies Added
- `intl: ^0.19.0` - For date formatting in the owner complaint list

## Testing

### Test the Feature:
1. **Run the app**: `flutter run -d chrome`
2. **Login as Student**:
   - Create a few test complaints
   - Verify they appear in your history
3. **Login as Owner** (different account):
   - Verify you see all student complaints
   - Test status filters
   - Mark complaints as resolved
4. **Switch back to Student**:
   - Verify status updates are reflected

## Future Enhancements
- Add complaint categories (maintenance, cleanliness, noise, etc.)
- Allow owners to add comments/replies
- Add image attachments to complaints
- Email notifications for status updates
- Complaint priority levels
- Search and sort functionality
- Analytics dashboard for owners

## Error Handling
- All operations include try-catch blocks
- User-friendly error messages via SnackBars
- Graceful handling of network issues
- Loading states during operations

## UI/UX Features
- Material Design 3 components
- Responsive layouts
- Color-coded status indicators
- Smooth animations and transitions
- Empty state illustrations
- Loading indicators
- Confirmation dialogs for critical actions

---

Built with ❤️ for Nestify PG Management System
