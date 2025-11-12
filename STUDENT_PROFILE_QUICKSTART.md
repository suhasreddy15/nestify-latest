# Student Profile Feature - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1. Install Dependencies
```bash
flutter pub get
```

**New packages added:**
- `firebase_storage: ^11.7.0` - File uploads
- `file_picker: ^6.1.1` - Select files
- `url_launcher: ^6.2.5` - Open documents

### 2. Configure Firebase Storage Rules

Go to Firebase Console → Storage → Rules and add:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /aadhaar_documents/{userId}/{document} {
      allow write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null;
    }
  }
}
```

### 3. Update Firestore Rules

Go to Firebase Console → Firestore → Rules and update:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Students can read and update their own profile
      allow read, update: if request.auth != null && request.auth.uid == userId;
      
      // Owners can read all students
      allow read: if request.auth != null && 
                  get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner';
    }
  }
}
```

### 4. Run the App
```bash
flutter run
```

---

## 📱 For Students

### Update Your Profile:
1. Open Nestify app
2. Login as Student
3. Click **"My Profile"** card (green with person icon)
4. Fill in your details:
   - Full Name
   - Phone Number (10 digits)
   - Room Number
5. Click **"Save Changes"**

### Upload Aadhaar Document:
1. In Profile screen, scroll to "Aadhaar Document" section
2. Click **"Upload Document"**
3. Select PDF or image file (max 5MB)
4. Wait for upload to complete
5. Green checkmark appears when successful

### Replace or Delete Document:
- To replace: Click **"Replace Document"** and select new file
- To delete: Click trash icon → Confirm deletion

---

## 👔 For Owners

### View All Students:
1. Open Nestify app
2. Login as Owner
3. Click **"Student Details"** card (green with people icon)
4. See list of all registered students
5. Green "Verified" badge shows who uploaded documents

### View Student Profile:
1. Tap on any student card
2. Bottom sheet opens with complete details:
   - Full name and email
   - Phone number
   - Room number
   - Aadhaar document status
3. If document uploaded, click **"View Document"**
4. Document opens in browser/viewer

---

## 🎯 Key Features at a Glance

### Students Can:
✅ Edit name, phone, room number  
✅ Upload Aadhaar (PDF/JPG/PNG)  
✅ Replace or delete documents  
✅ See upload status instantly  

### Owners Can:
✅ View all student profiles  
✅ See who has verified documents  
✅ Download/view Aadhaar files  
✅ Access contact information  

---

## 🔒 Security & Privacy

- **Students** can only edit their own profile
- **Owners** can view but not edit student profiles
- Documents stored securely in Firebase Storage
- Files accessible only to authenticated users
- Role-based access control enforced

---

## 📋 Validation Rules

| Field | Rules |
|-------|-------|
| **Name** | Required, min 2 characters |
| **Phone** | Required, exactly 10 digits |
| **Room Number** | Required |
| **Aadhaar File** | Max 5MB, PDF/JPG/PNG only |

---

## ⚡ Quick Troubleshooting

### Problem: Can't upload file
**Solution**: Check file size (must be under 5MB) and format (PDF/JPG/PNG only)

### Problem: Document won't open
**Solution**: Make sure your device has a PDF viewer or image viewer app installed

### Problem: Profile not loading
**Solution**: Check internet connection and ensure you're logged in

### Problem: Changes not saving
**Solution**: Verify all required fields are filled and valid

---

## 🎨 UI Overview

### Student Profile Screen:
```
┌─────────────────────────────┐
│    👤 Profile Icon          │
│                             │
│  Personal Information       │
│  ┌─────────────────────┐   │
│  │ Full Name           │   │
│  │ Phone Number        │   │
│  │ Room Number         │   │
│  │ [Save Changes]      │   │
│  └─────────────────────┘   │
│                             │
│  Aadhaar Document           │
│  ┌─────────────────────┐   │
│  │ ✅ Document Uploaded│   │
│  │ aadhaar.pdf         │   │
│  │ [🗑️ Delete]         │   │
│  │ [Upload/Replace]    │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
```

### Owner Student Details Screen:
```
┌─────────────────────────────┐
│  Student Details            │
├─────────────────────────────┤
│  ┌─────────────────────┐   │
│  │ 👤 John Doe         │   │
│  │ john@email.com      │   │
│  │ 📞 1234567890  🚪 A101│ │
│  │ ✅ Verified         │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 👤 Jane Smith       │   │
│  │ jane@email.com      │   │
│  │ 📞 0987654321  🚪 B202│ │
│  │ ⚠️ Not Verified    │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
```

---

## 📞 Support

### Common Questions:

**Q: What file formats are supported?**  
A: PDF, JPG, JPEG, and PNG files up to 5MB

**Q: Can I upload multiple documents?**  
A: Currently one Aadhaar document per student. Replace to update.

**Q: Can owners edit student profiles?**  
A: No, owners can only view. Students manage their own profiles.

**Q: Is my Aadhaar secure?**  
A: Yes, files are stored in Firebase Storage with security rules. Only authenticated users can access.

**Q: What happens to old document when I replace it?**  
A: The old file remains in storage (for backup). We'll add cleanup in future updates.

---

## 🚦 Testing Checklist

Before deployment, verify:

- [ ] Student can register and login
- [ ] Student dashboard shows "My Profile" card
- [ ] Profile loads existing data
- [ ] Can update name, phone, room
- [ ] Phone validation works (10 digits)
- [ ] Can upload PDF Aadhaar
- [ ] Can upload image Aadhaar
- [ ] File size limit enforced (5MB)
- [ ] Success messages appear
- [ ] Owner dashboard shows "Student Details"
- [ ] Owner sees all students
- [ ] Verification badges display correctly
- [ ] Can view student details
- [ ] Can open/download documents

---

## 📂 File Structure

```
lib/
├── services/
│   └── student_profile_service.dart    # Business logic
├── screens/
│   ├── student_profile_screen.dart     # Student UI
│   └── owner_student_details_screen.dart # Owner UI
└── main.dart                           # Routes

pubspec.yaml                            # Dependencies
```

---

## 🔄 Integration with Existing Features

### Updated Files:
- ✅ `lib/main.dart` - Added routes
- ✅ `lib/screens/student_dashboard.dart` - Added profile card
- ✅ `lib/screens/owner_dashboard.dart` - Added student details card
- ✅ `pubspec.yaml` - Added new dependencies

### New Routes:
- `/student/profile` → StudentProfileScreen
- `/owner/student-details` → OwnerStudentDetailsScreen

---

## 🎓 Next Steps

After setting up:

1. **Test as Student**: Create account, fill profile, upload document
2. **Test as Owner**: View the student you just created
3. **Verify Firebase**: Check Storage console to see uploaded file
4. **Check Firestore**: Verify user document has new fields
5. **Review Logs**: Look for any errors in Firebase Console

---

## 🛠️ Advanced Configuration

### Increase File Size Limit:
In `student_profile_service.dart`, line 53:
```dart
if (bytes.length > 5 * 1024 * 1024) {  // Change 5 to desired MB
```

### Add More File Types:
In `student_profile_screen.dart`, line 117:
```dart
allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
```

### Customize Storage Path:
In `student_profile_service.dart`, line 48:
```dart
final String storagePath = 'documents/${user.uid}/$timestamp.$fileExtension';
```

---

## 📊 Firebase Console Quick Links

After deployment, monitor:

1. **Firestore**: `users` collection → Check new fields (phone, roomNumber, aadhaarUrl)
2. **Storage**: `aadhaar_documents` folder → See uploaded files
3. **Authentication**: Users list → Verify student registrations
4. **Usage**: Project overview → Monitor storage quota

---

**Ready to use! 🎉**

Need more details? Check `STUDENT_PROFILE_FEATURE.md` for complete documentation.
