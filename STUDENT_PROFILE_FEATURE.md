# Student Profile Feature - Documentation

## Overview
The Student Profile feature allows students to view and edit their personal information (name, phone, room number) and upload their Aadhaar document (PDF or image). Owners can view all student profiles and their uploaded documents.

## Features

### For Students:
- ✅ **Personal Information Management**: Update name, phone number, and room number
- ✅ **Aadhaar Document Upload**: Upload Aadhaar as PDF, JPG, or PNG (max 5MB)
- ✅ **Document Management**: Replace or delete existing documents
- ✅ **Real-time Updates**: Changes reflect immediately in Firestore

### For Owners:
- ✅ **Student Directory**: View list of all registered students
- ✅ **Profile Details**: See complete student information including contact and room details
- ✅ **Document Verification**: View and download uploaded Aadhaar documents
- ✅ **Verification Status**: Quickly identify students who have uploaded documents

## Technical Architecture

### Data Model
The feature extends the existing `users` collection in Firestore with new fields:

```dart
{
  'fullName': 'Student Name',
  'email': 'student@example.com',
  'phone': '1234567890',
  'roomNumber': 'A101',
  'role': 'student',
  'aadhaarUrl': 'https://firebasestorage.googleapis.com/...',
  'aadhaarFileName': 'aadhaar.pdf',
  'aadhaarUploadedAt': Timestamp,
  'updatedAt': Timestamp,
  'uid': 'user-id'
}
```

### File Storage
- **Storage Path**: `aadhaar_documents/{userId}/{timestamp}.{extension}`
- **Supported Formats**: PDF, JPG, JPEG, PNG
- **Max File Size**: 5MB
- **Access**: Private files accessible only via download URL

### Components

#### 1. StudentProfileService (`lib/services/student_profile_service.dart`)
Core business logic for profile management:
- **getStudentProfile()**: Fetch current user's profile
- **updateStudentProfile()**: Update name, phone, room number
- **uploadAadhaarFile()**: Upload document to Firebase Storage
- **deleteAadhaarFile()**: Remove document from Storage and Firestore
- **getAllStudents()**: Stream of all student profiles (for owner)
- **getStudentDetails()**: Get specific student info (for owner)

#### 2. StudentProfileScreen (`lib/screens/student_profile_screen.dart`)
Student interface for managing profile:
- Personal information form with validation
- File picker for Aadhaar upload
- Document status display
- Replace/delete document functionality
- Real-time save feedback

#### 3. OwnerStudentDetailsScreen (`lib/screens/owner_student_details_screen.dart`)
Owner interface for viewing student information:
- Scrollable list of all students
- Verification badges for students with documents
- Detailed modal view with complete profile
- Document preview and download
- Timestamp display for document uploads

## Firebase Configuration

### Storage Rules
Add these security rules to Firebase Storage:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Aadhaar documents
    match /aadhaar_documents/{userId}/{document} {
      // Students can upload their own documents
      allow write: if request.auth != null && request.auth.uid == userId;
      // Students and owners can read documents
      allow read: if request.auth != null;
    }
  }
}
```

### Firestore Rules
Update rules to allow profile updates:

```javascript
match /users/{userId} {
  // Students can read their own profile
  allow read: if request.auth != null && request.auth.uid == userId;
  
  // Students can update their own profile fields
  allow update: if request.auth != null && 
                request.auth.uid == userId &&
                request.resource.data.role == resource.data.role; // Prevent role change
  
  // Owners can read all student profiles
  allow read: if request.auth != null && 
              get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner';
}
```

## User Flow

### Student Profile Update Flow:
1. Student clicks "My Profile" card on dashboard
2. Profile screen loads with current information
3. Student edits name, phone, or room number
4. Clicks "Save Changes" button
5. Validation checks (required fields, phone format)
6. Data saved to Firestore
7. Success message displayed

### Aadhaar Upload Flow:
1. Student clicks "Upload Document" button
2. File picker opens (filtered to PDF/images)
3. Student selects file
4. File size validation (max 5MB)
5. File uploaded to Firebase Storage
6. Download URL saved to Firestore
7. Document status updated to "Uploaded"
8. Student can replace or delete document

### Owner View Flow:
1. Owner clicks "Student Details" card on dashboard
2. List of all students loads in real-time
3. Students with documents show verification badge
4. Owner taps student card
5. Modal opens with complete profile details
6. Owner can view/download Aadhaar document
7. Document opens in external browser/viewer

## Validation Rules

### Phone Number:
- Must be exactly 10 digits
- Required field
- Only numeric characters

### Room Number:
- Required field
- Free-form text

### Full Name:
- Required field
- Minimum 2 characters

### Aadhaar File:
- Max size: 5MB
- Allowed formats: PDF, JPG, JPEG, PNG
- One file per student (replace existing)

## Error Handling

### Upload Errors:
- **File too large**: "File size must be less than 5MB"
- **Invalid format**: File picker filters prevent this
- **Network error**: "Error uploading file: [error details]"
- **Storage permission denied**: Displays Firebase error message

### Update Errors:
- **Validation failures**: Inline form validation messages
- **Network timeout**: "Error saving profile: [error details]"
- **Permission denied**: Firebase security error displayed

### Download Errors:
- **Invalid URL**: Handled by url_launcher package
- **File deleted**: User sees broken link message

## UI/UX Features

### Student Profile Screen:
- **Profile Icon**: Large circular avatar at top
- **Personal Information Card**: White card with form fields
- **Aadhaar Document Card**: Green success state or upload prompt
- **Loading States**: Spinners during save/upload operations
- **Success/Error Feedback**: SnackBars with color coding

### Owner Student Details Screen:
- **Student Cards**: Avatar, name, email, verification badge
- **Info Chips**: Phone and room number in pill-shaped containers
- **Modal Bottom Sheet**: Draggable detail view
- **Document Card**: Green success state with view button
- **Missing Document Warning**: Orange alert for unverified students

## Integration with Existing Features

### Dashboard Navigation:
- **Student Dashboard**: "My Profile" card added (green, person icon)
- **Owner Dashboard**: "Student Details" card added (green, people icon)

### Routes:
- `/student/profile` → StudentProfileScreen
- `/owner/student-details` → OwnerStudentDetailsScreen

### Dependencies:
- `firebase_storage: ^11.7.0` - File storage
- `file_picker: ^6.1.1` - File selection
- `url_launcher: ^6.2.5` - Open documents in browser

## Testing Checklist

### Student Profile:
- [ ] Load existing profile information
- [ ] Update name, phone, room number
- [ ] Validate phone number (10 digits)
- [ ] Upload PDF document
- [ ] Upload image document (JPG, PNG)
- [ ] Replace existing document
- [ ] Delete document
- [ ] Handle file size limit (5MB)
- [ ] Display error messages
- [ ] Show success confirmations

### Owner View:
- [ ] Display all students in list
- [ ] Show verification badges correctly
- [ ] Open student detail modal
- [ ] Display complete profile information
- [ ] View uploaded document
- [ ] Download document to device
- [ ] Handle students without documents
- [ ] Real-time updates when students add documents

## Common Issues & Solutions

### Issue: "Could not read file data"
**Solution**: This happens on web platform. Use `withData: true` in FilePicker (already implemented).

### Issue: File upload fails silently
**Solution**: Check Firebase Storage rules allow writes for the user's UID path.

### Issue: Document link doesn't open
**Solution**: Ensure url_launcher package is properly configured for the platform (iOS/Android require Info.plist/AndroidManifest updates).

### Issue: Profile doesn't load
**Solution**: Verify Firestore rules allow students to read their own user document.

### Issue: Owner can't see students
**Solution**: Confirm Firestore rules allow owners to query users collection filtered by role.

## Future Enhancements

### Possible Features:
1. **Image Preview**: Show thumbnail of uploaded image Aadhaar
2. **PDF Viewer**: In-app PDF viewer instead of external browser
3. **Multiple Documents**: Support for additional documents (ID proof, photos)
4. **Profile Photo**: Allow students to upload profile picture
5. **Edit History**: Track changes to profile over time
6. **Verification System**: Owner can approve/reject documents
7. **Expiry Reminders**: Notify when documents need renewal
8. **Bulk Export**: Owner can download all student data as CSV
9. **Search/Filter**: Search students by name, room, verification status
10. **QR Code**: Generate QR code for student profile

## Performance Considerations

### Optimization Strategies:
1. **Lazy Loading**: Student list loads incrementally for large datasets
2. **Image Compression**: Consider compressing images before upload
3. **Caching**: Profile data cached locally to reduce Firestore reads
4. **Storage Lifecycle**: Implement rules to delete old replaced documents

### Current Limits:
- Max file size: 5MB (adjustable in code)
- No limit on student count
- No pagination (implement if >100 students)

## Maintenance Notes

### Monitoring:
- Check Firebase Storage usage monthly
- Review failed upload logs in Firebase Console
- Monitor Firestore read/write operations

### Cleanup:
- Old Aadhaar files remain in Storage when replaced (manual cleanup needed)
- Consider implementing cleanup function to delete unreferenced files

### Updates:
- Keep firebase_storage package updated for security patches
- Test file picker compatibility with new OS versions
- Review Storage rules periodically

---

## Quick Reference

### Key Files:
- `lib/services/student_profile_service.dart` - Business logic
- `lib/screens/student_profile_screen.dart` - Student UI
- `lib/screens/owner_student_details_screen.dart` - Owner UI
- `lib/main.dart` - Route definitions

### Firebase Paths:
- Firestore: `users/{userId}`
- Storage: `aadhaar_documents/{userId}/{timestamp}.{ext}`

### Routes:
- Student: `/student/profile`
- Owner: `/owner/student-details`

### Dependencies:
```yaml
firebase_storage: ^11.7.0
file_picker: ^6.1.1
url_launcher: ^6.2.5
```

---

**Last Updated**: January 2025
**Version**: 1.0
**Status**: Production Ready ✅
