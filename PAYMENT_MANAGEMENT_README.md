# Payment Management Feature

## Overview
The Payment Management feature enables PG owners to record student payments and automatically generate digital receipts. Students can view their payment history and download their receipts.

## Features

### For Owners
- **Record Payments**: Mark student payments as paid with amount and date
- **Auto-Receipt Generation**: Automatically generate professional PDF receipts
- **Payment History**: View all payment records in a chronological list
- **Student Selection**: Choose from dropdown list of all registered students
- **Payment Details**: View detailed information for each payment
- **Delete Payments**: Remove payment records when needed

### For Students
- **Payment History**: View all payments with dates and amounts
- **Total Paid Summary**: See total amount paid with payment count
- **Download Receipts**: Download PDF receipts for each payment
- **Payment Details**: View detailed payment information

## Files Created

### Models
- `lib/models/payment.dart` - Payment data model with Firestore integration

### Services
- `lib/services/payment_service.dart` - Business logic for:
  - PDF receipt generation
  - Firebase Storage upload/download
  - Firestore CRUD operations
  - Student data retrieval

### Screens
- `lib/screens/owner_payment_management_screen.dart` - Owner interface for:
  - Viewing all payments
  - Adding new payments
  - Viewing payment details
  - Deleting payments

- `lib/screens/student_payment_history_screen.dart` - Student interface for:
  - Viewing payment history
  - Total paid summary card
  - Downloading receipts

## Dependencies Added
```yaml
pdf: ^3.10.8              # PDF generation
printing: ^5.12.0         # PDF preview and printing utilities
path_provider: ^2.1.2     # File system path access
```

## Database Structure

### Firestore Collection: `payments`
```javascript
{
  id: string,                    // Auto-generated receipt ID (RCP-timestamp)
  studentId: string,             // Reference to student user
  studentName: string,           // Student's full name
  studentEmail: string,          // Student's email
  amount: number,                // Payment amount in rupees
  paymentDate: timestamp,        // Date of payment
  receiptUrl: string,            // Firebase Storage URL to PDF
  createdBy: string,             // Owner's user ID
  createdAt: timestamp,          // Record creation time
  roomNumber: string             // Student's room number
}
```

### Firebase Storage Path
```
receipts/
  {studentId}/
    {receiptId}.pdf
```

## Receipt Format
Professional PDF receipt includes:
- **Header**: "NESTIFY PG" branding with purple theme
- **Receipt Details**: Receipt ID, issue date, payment date
- **Student Information**: Name, email, room number
- **Payment Amount**: Large highlighted amount in green
- **Footer**: Thank you message and disclaimer

## Navigation Routes

### Owner Routes
- `/owner/payments` - Payment Management screen
  - Add payment button (FAB)
  - Payment list with cards
  - Payment details modal
  - Delete confirmation dialog

### Student Routes
- `/student/payments` - Payment History screen
  - Total paid summary card
  - Payment history list
  - Download receipt buttons
  - Payment details bottom sheet

## Dashboard Integration

### Owner Dashboard
New card added:
- **Icon**: Payment (teal)
- **Title**: Payment Management
- **Description**: Record payments & generate receipts
- **Route**: `/owner/payments`

### Student Dashboard
New grid item added:
- **Icon**: Payment (teal)
- **Label**: Payment History
- **Route**: `/student/payments`

## Usage Flow

### Owner Adding Payment
1. Click "Add Payment" FAB
2. Select student from dropdown
3. Enter amount
4. Select payment date
5. Click "Create Payment"
6. System generates PDF receipt
7. Uploads to Firebase Storage
8. Creates Firestore record
9. Shows success message

### Student Viewing Payments
1. Navigate to Payment History
2. View total paid summary
3. Scroll through payment list
4. Click payment card for details
5. Click "Download Receipt" to open PDF

## Error Handling
- Invalid amount validation
- Student selection required
- PDF generation error handling
- Storage upload error handling
- Network error messages
- Receipt download failure handling

## Security Rules
Recommended Firestore security rules:
```javascript
match /payments/{paymentId} {
  // Owners can read/write all payments
  allow read, write: if request.auth != null && 
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner';
  
  // Students can only read their own payments
  allow read: if request.auth != null && 
    resource.data.studentId == request.auth.uid;
}
```

## Future Enhancements
- [ ] Payment notifications
- [ ] Monthly payment reminders
- [ ] Payment analytics dashboard
- [ ] Export payment reports
- [ ] Multi-month payments
- [ ] Payment due tracking
- [ ] Recurring payment setup
- [ ] Payment filtering by date range
- [ ] Receipt email delivery
- [ ] Payment verification badges
