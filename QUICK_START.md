# Nestify - Quick Start Guide

## 🚀 First Time Setup

### Step 1: Install Dependencies
```powershell
flutter pub get
```

### Step 2: Run the App
```powershell
flutter run
```

### Step 3: Create Test Accounts

#### Create Owner Account
1. Click "Owner Login"
2. Click "Sign Up" or use test credentials:
   - Email: `owner@test.com`
   - Password: `password123`

#### Create Student Account  
1. Click "Student Login"
2. Register with email or use Google Sign-In
3. Test credentials:
   - Email: `student@test.com`
   - Password: `password123`

### Step 4: Configure Firebase (IMPORTANT!)

⚠️ **Most features won't work until you update Firebase rules!**

#### Update Firestore Rules:
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `nestifymega`
3. Go to **Firestore Database** → **Rules**
4. Replace with rules from `FEATURES_STATUS_AND_FIXES.md`
5. Click **Publish**

#### Update Storage Rules:
1. Go to **Storage** → **Rules**
2. Replace with rules from `FEATURES_STATUS_AND_FIXES.md`
3. Click **Publish**

## 📋 Testing Workflow

### As Owner (First Login):

1. **Complete Setup** (This is required!)
   - PG Name: "Sunrise PG"
   - Address: "123 Main St, Bangalore"
   - Contact: "9876543210"
   - Click "Complete Setup"

2. **Test Creating Dinner Vote:**
   - Open drawer → "Dinner Voting Setup"
   - Enter dish name: "Chicken Biryani"
   - Click "Create Vote"
   - ✅ Should show success message

3. **Test Viewing Complaints:**
   - Open drawer → "Complaints"
   - Should show "No complaints" initially
   - After student submits, you'll see them here

4. **Test Recording Payment:**
   - Open drawer → "Payments"
   - Click "+" button
   - Select a student
   - Enter amount: 5000
   - Select payment date
   - Choose payment method (optional)
   - Click "Create Payment"
   - ✅ PDF receipt generated automatically!

### As Student (First Login):

1. **Complete Profile:**
   - Go to "My Profile"
   - Enter room number
   - Upload ID document
   - Upload photo
   - Click "Save Profile"

2. **Test Submitting Complaint:**
   - Go to "Complaints"
   - Click "+" button
   - Title: "AC not working"
   - Description: "AC in room 101 stopped working"
   - Click "Submit"
   - ✅ Should appear in list

3. **Test Community Chat:**
   - Go to "Community Chat"
   - Type a message: "Hello everyone!"
   - Send
   - ✅ Message appears instantly

4. **Test Dinner Voting:**
   - Go to "Dinner Voting"
   - Should see today's vote (if owner created one)
   - Click "Yes" or "No"
   - ✅ Cannot vote twice
   - ✅ Cannot vote after 6 PM

5. **Test Washing Booking:**
   - Go to "Washing Machine"
   - Select date (today or future)
   - Select time slot (8 AM - 8 PM)
   - Click "Book Slot"
   - ✅ Booking confirmed

6. **Test Payment History:**
   - Go to "Payment History"
   - View payments (if owner recorded any)
   - Click "Download Receipt"
   - ✅ PDF opens in browser

## ⚠️ Common Issues & Quick Fixes

### Issue: "Permission denied" or "Missing permissions"
**Fix:** Update Firestore and Storage rules (see Step 4 above)

### Issue: "The query requires an index"
**Fix:** Click the error link to auto-create index, OR:
1. Firebase Console → Firestore → Indexes
2. Create composite index for the collection mentioned

### Issue: Empty screens / No data
**Fix:** This is normal for a new installation!
- Create test data using the workflows above
- Data will appear as you use the features

### Issue: Google Sign-In not working
**Fix:**
```powershell
# Get SHA-1 fingerprint
cd android
./gradlew signingReport

# Copy the SHA-1 from output
# Add it in Firebase Console → Project Settings → Your Android App
# Download new google-services.json
# Replace android/app/google-services.json
# Rebuild app
```

### Issue: PDF receipts show "NESTIFY PG" instead of my PG name
**Fix:** Complete Owner Setup Screen first! Your PG name will then appear on receipts.

### Issue: Can't upload documents
**Fix:** Update Storage rules (see Step 4 above)

### Issue: Notifications not appearing
**Fix:**
1. Grant notification permission when prompted
2. Ensure Firebase Cloud Messaging is enabled
3. Test by creating a dinner vote (sends notification to all students)

## 🔄 Reset Everything

If things are broken, try this:

```powershell
# Clean everything
flutter clean

# Get dependencies fresh
flutter pub get

# Clear app data on device
# Settings → Apps → Nestify → Clear Data

# Rebuild and run
flutter run
```

## 📱 Feature Availability by Time

| Feature | Available When |
|---------|----------------|
| Dinner Voting (Student) | Before 6:00 PM daily |
| Dinner Voting Setup (Owner) | Anytime |
| Washing Bookings | 8:00 AM - 8:00 PM slots |
| Complaints | 24/7 |
| Chat | 24/7 |
| Payments | Anytime |
| Profile | Anytime |

## ✅ Quick Verification

After setup, verify these work:

```
Owner:
☐ Login successful
☐ PG setup completed
☐ Can create dinner vote
☐ Can view complaints
☐ Can record payment
☐ PDF receipt downloads

Student:
☐ Login successful
☐ Profile setup completed
☐ Can submit complaint
☐ Can send chat messages
☐ Can vote on dinner
☐ Can book washing slot
☐ Can view payment history
```

## 🎯 Test Data Examples

Use these for testing:

**Complaints:**
- "WiFi not working in common area"
- "Water supply irregular in morning"
- "Need AC servicing in Room 205"

**Dinner Votes:**
- "Paneer Butter Masala"
- "Chicken Biryani"
- "Dal Tadka + Rice"

**Payment Amounts:**
- Monthly rent: 8000
- Deposit: 10000
- Maintenance: 1000

**Room Numbers:**
- 101, 102, 103, 201, 202, 203

## 📞 Still Having Issues?

1. Check `FEATURES_STATUS_AND_FIXES.md` for detailed solutions
2. Run `flutter doctor -v` to check your setup
3. Check Firebase Console logs
4. Enable verbose logging:
   ```powershell
   flutter run --verbose
   ```

## 🎓 Learning the Code

Key files to understand:

- `lib/main.dart` - App entry point and routing
- `lib/services/` - Firebase integration
- `lib/screens/` - All UI screens
- `lib/models/` - Data models
- `firebase.json` - Firebase configuration

## 🚀 Ready to Go!

After completing setup:
1. Firebase rules are updated ✅
2. Owner account created ✅
3. Student account created ✅
4. Owner setup completed ✅
5. Test data created ✅

**Your Nestify app is now fully functional! 🎉**

All features should work as expected. If you encounter any issues, refer to `FEATURES_STATUS_AND_FIXES.md` for detailed troubleshooting.
