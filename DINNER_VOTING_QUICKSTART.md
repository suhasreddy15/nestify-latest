# Dinner Voting Feature - Quick Start Guide

## ✅ What's Been Implemented

### Files Created
1. **Models**
   - `lib/models/dinner_vote.dart` - Data models for votes and responses

2. **Services**
   - `lib/services/dinner_vote_service.dart` - Vote management logic
   - `lib/services/notification_service.dart` - FCM notification setup

3. **Screens**
   - `lib/screens/owner_dinner_voting_setup_screen.dart` - Owner creates voting
   - `lib/screens/student_dinner_voting_screen.dart` - Student votes

4. **Documentation**
   - `DINNER_VOTING_FEATURE.md` - Comprehensive implementation guide

### Updated Files
- `pubspec.yaml` - Added `firebase_messaging: ^14.7.0`
- `lib/main.dart` - Added routes for new screens
- `lib/screens/owner_dashboard.dart` - Added "Dinner Voting Setup" card
- `lib/screens/student_dashboard.dart` - Added "Dinner Voting" card

## 🚀 How to Test

### 1. Owner Workflow
```
1. Login as owner (owner@nestify.com / password123)
2. Tap "Dinner Voting Setup" on dashboard
3. Enter dish name (e.g., "Chicken Biryani")
4. Tap "Create Voting"
5. See confirmation and real-time vote counts
6. After 6 PM, view detailed responses
```

### 2. Student Workflow
```
1. Login as student
2. Tap "Dinner Voting" on dashboard
3. View today's dish and countdown timer
4. Tap "YES" or "NO" to vote
5. See confirmation and live results
6. After 6 PM, voting is locked
```

## ⏰ Time-Based Features

- **Voting Opens**: When owner creates vote (recommended 5 PM)
- **Voting Closes**: Automatically at 6:00 PM
- **Countdown Timer**: Shows time remaining for students
- **Auto-Lock**: System prevents votes after deadline

## 🔥 Firestore Structure

```
dinner_votes/
  {voteId}/
    ├─ dishName: "Chicken Biryani"
    ├─ date: 2025-11-08T00:00:00
    ├─ createdAt: 2025-11-08T17:00:00
    ├─ yesCount: 0
    ├─ noCount: 0
    ├─ isActive: true
    └─ responses/ (subcollection)
        └─ {studentId}/
            ├─ studentId: "abc123"
            ├─ studentName: "John Doe"
            ├─ vote: "yes"
            └─ timestamp: 2025-11-08T17:30:00
```

## 🔔 Push Notifications (Additional Setup Required)

### Current Status
✅ Package installed: `firebase_messaging: ^14.7.0`
✅ Service created with FCM integration
✅ Notification data stored in Firestore
⚠️ **Need to complete**: Firebase Console configuration

### To Enable Full Push Notifications

1. **Firebase Console Setup**
   ```
   - Go to Firebase Console → Project Settings
   - Navigate to Cloud Messaging tab
   - Enable Cloud Messaging API
   - Configure Android/iOS credentials
   ```

2. **Android Configuration**
   Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.firebase.messaging.default_notification_channel_id"
       android:value="dinner_voting_channel" />
   ```

3. **iOS Configuration**
   - Enable push notifications in Xcode capabilities
   - Upload APNs certificate to Firebase Console

4. **Backend Integration** (Production)
   - Use Firebase Cloud Functions to send FCM messages
   - Or implement custom backend service

### Current Notification Flow
1. Owner creates vote
2. System stores notification in each student's Firestore document
3. Students can see notifications in-app (requires UI implementation)
4. FCM push requires backend setup (documented above)

## 🎯 Key Features

### For Owners
✅ Create daily dinner voting with dish name
✅ Real-time vote count monitoring
✅ Voting history with past results
✅ Detailed response viewer after 6 PM
✅ Visual status indicators (open/closed)
✅ Percentage calculations and statistics

### For Students
✅ View today's dinner dish
✅ One-time Yes/No voting
✅ Countdown timer to deadline
✅ Real-time results with percentages
✅ Vote confirmation display
✅ Automatic time-based restrictions

## 🛡️ Security Features

### Implemented
- User authentication required
- One vote per student per day
- Time-based voting restrictions
- Vote count integrity through Firestore transactions

### Recommended Firestore Rules
```javascript
match /dinner_votes/{voteId} {
  allow create: if request.auth != null && 
                get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner';
  allow read: if request.auth != null;
  
  match /responses/{studentId} {
    allow create: if request.auth.uid == studentId;
    allow read: if request.auth != null;
  }
}
```

## 📱 Running the App

```bash
# Install dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Run on Android/iOS
flutter run
```

## 🧪 Testing Scenarios

### Test Cases to Verify
- [ ] Owner can create vote with dish name
- [ ] Duplicate vote prevention (same day)
- [ ] Student can vote before 6 PM
- [ ] Student cannot vote after 6 PM
- [ ] Student cannot vote twice
- [ ] Real-time vote counts update
- [ ] Countdown timer displays correctly
- [ ] Vote history shows past votes
- [ ] Response details accessible after 6 PM

### Edge Cases
- [ ] Voting exactly at 6:00 PM
- [ ] No voting created for today
- [ ] Network errors during vote submission
- [ ] Multiple students voting simultaneously

## 🐛 Troubleshooting

### Common Issues

**Issue**: "Voting is closed" shown before 6 PM
- **Cause**: Device time incorrect
- **Fix**: Ensure device time is accurate

**Issue**: Vote counts not updating
- **Cause**: Firestore permissions or network
- **Fix**: Check Firestore rules and internet connection

**Issue**: Notifications not received
- **Cause**: FCM not fully configured
- **Fix**: Complete FCM setup (see above)

**Issue**: "No voting created" after creation
- **Cause**: Date/timezone mismatch
- **Fix**: Verify Firestore timestamp format

## 📊 Database Indexes

### Required Firestore Indexes
```
Collection: dinner_votes
Composite Index:
  - date (Ascending)
  - createdAt (Descending)
```

Firestore will prompt to create these when first querying.

## 🎨 UI Features

- **Material Design 3** styling
- **Color-coded status**: Green (open), Orange (closed)
- **Progress bars** for vote visualization
- **Countdown timer** with hours/minutes
- **Responsive layout** for all screen sizes
- **Real-time updates** via StreamBuilder

## 📈 Future Enhancements

Potential additions:
- Custom voting deadline time
- Multiple meal voting (lunch/dinner)
- Vote analytics and reports
- Student comments on votes
- Email/SMS notifications
- Automatic scheduling (daily at 5 PM)
- Export results to CSV

## 📚 Documentation

- **Full Guide**: See `DINNER_VOTING_FEATURE.md`
- **API Reference**: Check inline code comments
- **Firestore Schema**: Documented in feature guide

## ✨ Summary

**Status**: ✅ Feature Complete & Ready to Use
**Dependencies**: ✅ All installed
**Routes**: ✅ Configured in main.dart
**Navigation**: ✅ Added to dashboards
**Documentation**: ✅ Comprehensive guides created

**Next Steps**:
1. Run `flutter pub get` (already done)
2. Test owner creating vote
3. Test student voting
4. Configure FCM for push notifications (optional)
5. Deploy to production

---

**Need Help?** Refer to `DINNER_VOTING_FEATURE.md` for detailed documentation.
