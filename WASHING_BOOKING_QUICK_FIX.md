# Quick Fix: Washing Booking Not Working

## The Problem
The washing booking feature wasn't storing data because:
1. Firestore security rules were blocking writes
2. Complex queries needed composite indexes

## The Solution - 2 Simple Steps

### Step 1: Update Firestore Security Rules

1. Go to **Firebase Console** → **Firestore Database** → **Rules**
2. Copy the entire content from the file `firestore.rules` in your project
3. Paste it into the Firebase Console Rules editor
4. Click **Publish**

**OR manually add this rule for washing_bookings:**

```javascript
match /washing_bookings/{bookingId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && 
                   request.resource.data.studentId == request.auth.uid;
  allow delete: if request.auth != null && 
                   resource.data.studentId == request.auth.uid;
}
```

### Step 2: Create Firestore Index

1. Go to **Firebase Console** → **Firestore Database** → **Indexes**
2. Click **"Add Index"**
3. Create an index with:
   - **Collection ID:** `washing_bookings`
   - **Fields to index:**
     - `timestamp` → Ascending
   - **Query scope:** Collection
4. Click **Create**

**OR** just try to create a booking and Firebase will show an error with a direct link to create the index automatically.

## What I Fixed in the Code

I simplified the `washing_booking_service.dart` to:
- ✅ Use simpler Firestore queries that don't need complex indexes
- ✅ Filter data in Dart instead of in Firestore
- ✅ Require only one simple index on `timestamp`

## Test It Now

1. **Login as a student**
2. Go to **Washing Machine Booking** screen
3. Select a **date** (today or future)
4. Select a **time** from the list
5. Click **"Confirm Booking"**
6. You should see: ✅ **"Booking created successfully!"**

## Verify in Firebase

1. Go to **Firebase Console** → **Firestore Database**
2. Look for the `washing_bookings` collection
3. You should see a new document with:
   ```
   {
     studentId: "abc123...",
     studentName: "John Doe",
     date: Timestamp,
     time: "08:00 AM",
     timestamp: Timestamp
   }
   ```

## Common Issues

### "Missing or insufficient permissions"
→ You need to update Firestore rules (Step 1 above)

### "The query requires an index"
→ Create the index on `timestamp` field (Step 2 above)

### "This time slot is already booked"
→ This is normal! Someone else already booked that time. Choose another slot.

### Still not working?
1. Make sure you're logged in as a student (not owner)
2. Check the Flutter console for detailed error messages
3. Verify your internet connection
4. Make sure Firebase is initialized properly in your app

## That's It!
After these 2 steps, the washing booking feature should work perfectly! 🎉
