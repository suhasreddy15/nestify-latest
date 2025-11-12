# Community Chat Feature - Nestify

## Overview
The Community Chat feature provides a real-time messaging platform where students can connect, communicate, and share information with fellow students in their PG community.

## Features Implemented

### Core Functionality
- **Real-time Messaging**: Live chat updates using Firestore streams
- **Auto-scroll**: Automatically scrolls to latest messages
- **Message History**: Shows recent 100 messages
- **Timestamp Display**: Smart timestamp formatting (time, yesterday, date)
- **User Identification**: Shows sender name with each message
- **Message Bubbles**: Different styling for own vs others' messages
- **Send Button**: Disabled during message sending to prevent duplicates

### User Experience
- **Empty State**: Friendly message when no chats exist
- **Loading State**: Shows progress indicator while loading
- **Error Handling**: Graceful error messages for failures
- **Input Validation**: Prevents sending empty messages
- **Keyboard Support**: Press Enter to send message
- **Responsive Design**: Works on all screen sizes

## File Structure

```
lib/
├── models/
│   └── chat_message.dart           # ChatMessage data model
├── services/
│   └── chat_service.dart           # Chat operations & Firestore streams
├── screens/
│   ├── community_chat_screen.dart  # Main chat UI
│   └── student_dashboard.dart      # Updated with chat access
└── main.dart                       # Updated with route
```

## Data Model

### Community Chat Collection (Firestore)
```
community_chat/
  ├── [messageId]/
      ├── message: string
      ├── senderName: string
      ├── senderId: string
      └── timestamp: timestamp
```

### ChatMessage Class
```dart
class ChatMessage {
  final String id;
  final String message;
  final String senderName;
  final String senderId;
  final DateTime timestamp;
}
```

## How to Use

### As a Student:
1. Login to your student account
2. Click on "Community Chat" card on the dashboard
3. View the conversation history
4. Type your message in the text field at the bottom
5. Click the send button or press Enter
6. Your message appears instantly
7. See messages from other students in real-time

### Message Display:
- **Your messages**: Appear on the right with primary container color
- **Others' messages**: Appear on the left with surface color
- **Sender name**: Shown above message (for others only)
- **Timestamp**: Shown below each message

### Timestamp Format:
- **Today**: Shows time (e.g., "14:30")
- **Yesterday**: Shows "Yesterday 14:30"
- **This week**: Shows day and time (e.g., "Mon 14:30")
- **Older**: Shows date and time (e.g., "Nov 05, 14:30")

## Key Features

### Real-time Updates
- Uses `StreamBuilder` to listen to Firestore changes
- New messages appear instantly for all users
- No need to refresh or reload

### Auto-scroll
- Automatically scrolls to bottom when new messages arrive
- Smooth animation for better UX
- Uses `ScrollController` for precise control

### Message Input
- Multi-line support for longer messages
- Auto-capitalizes first letter of sentences
- Send button shows loading indicator during send
- Input field disabled during sending

### User Identification
- Retrieves sender name from Firestore users collection
- Falls back to email username if no full name
- Shows "Student" as default if neither available

## Firebase Setup Required

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /community_chat/{messageId} {
      // Only authenticated students can read messages
      allow read: if request.auth != null;
      
      // Only authenticated students can create messages
      allow create: if request.auth != null && 
                      request.auth.uid == request.resource.data.senderId &&
                      request.resource.data.keys().hasAll(['message', 'senderName', 'senderId', 'timestamp']);
      
      // Users can only delete their own messages (optional)
      allow delete: if request.auth != null && 
                      request.auth.uid == resource.data.senderId;
    }
  }
}
```

### Firestore Index
For optimal performance, create a composite index:
- Collection: `community_chat`
- Fields: `timestamp` (Ascending)
- Query Scope: Collection

## Technical Implementation

### ChatService Methods
```dart
// Send a message
Future<void> sendMessage(String message)

// Get real-time stream of recent messages
Stream<List<ChatMessage>> getRecentMessages({int limit = 50})

// Get all messages (alternative)
Stream<List<ChatMessage>> getChatMessages()

// Delete own message (optional)
Future<void> deleteMessage(String messageId, String senderId)

// Get total message count
Future<int> getMessageCount()
```

### UI Components

#### Message Bubble
- Container with rounded corners
- Different colors for sender/receiver
- Shows sender name, message text, and timestamp
- Responsive width (max 70% of screen)

#### Input Area
- Text field with rounded border
- Filled background for better visibility
- Send button with icon
- Shadow for depth
- Safe area padding for notched devices

#### Chat List
- ListView.builder for efficient rendering
- Padding for spacing
- Auto-scroll controller
- Pull-to-refresh capability (future enhancement)

## Testing

### Test the Feature:
1. **Run the app**: Already running in Chrome
2. **Login as Student 1**:
   - Click "Community Chat"
   - Send a test message
3. **Open in Incognito/Another Browser**:
   - Login as Student 2
   - Go to Community Chat
   - See Student 1's message
   - Reply to it
4. **Check Real-time**:
   - Watch Student 1's screen
   - See Student 2's message appear instantly
5. **Test Auto-scroll**:
   - Send multiple messages
   - Verify it scrolls to bottom automatically

## Performance Considerations

### Message Limit
- Default limit: 100 recent messages
- Prevents loading entire chat history
- Configurable via `getRecentMessages(limit: 100)`

### Stream Optimization
- Uses `.snapshots()` for real-time updates
- Firestore manages connection efficiently
- Automatic reconnection on network issues

### Error Handling
- Try-catch blocks for all operations
- Null checks for user data
- Graceful fallbacks for missing data

## Future Enhancements

### Planned Features
- [ ] Image/file sharing
- [ ] Message reactions (👍, ❤️, etc.)
- [ ] Reply to specific messages
- [ ] Delete own messages
- [ ] Edit sent messages (with time limit)
- [ ] User presence indicators (online/offline)
- [ ] Typing indicators
- [ ] Message search functionality
- [ ] Link previews
- [ ] Message notifications
- [ ] Group chats or channels
- [ ] Admin moderation tools
- [ ] Pinned messages
- [ ] Message formatting (bold, italic)

### Technical Improvements
- [ ] Pagination for older messages
- [ ] Message caching
- [ ] Offline support
- [ ] Image compression
- [ ] Voice messages
- [ ] Read receipts
- [ ] Message delivery status

## UI/UX Features

### Design Elements
- Material Design 3 components
- Smooth animations
- Color-coded message bubbles
- Empty state illustration
- Loading indicators
- Error states with retry options

### Accessibility
- Touch-friendly buttons
- Readable text sizes
- Color contrast compliance
- Screen reader support
- Keyboard navigation

### Responsive Layout
- Adapts to different screen sizes
- Mobile-first design
- Works on web, iOS, and Android
- Safe area handling for notched devices

## Troubleshooting

### Messages not appearing
- Check Firestore security rules
- Verify user authentication
- Check network connection
- Look for errors in console

### Auto-scroll not working
- Verify `ScrollController` is attached
- Check `addPostFrameCallback` execution
- Ensure messages list is not empty

### Send button disabled
- Check if `_isSending` state is stuck
- Verify message sending completes
- Check for exceptions in try-catch

## Best Practices

### For Development
- Always handle null cases
- Use try-catch for async operations
- Dispose controllers in `dispose()`
- Check `mounted` before `setState()`

### For Production
- Set appropriate Firestore limits
- Monitor Firestore usage/costs
- Implement rate limiting
- Add profanity filtering
- Set up content moderation

### For Users
- Be respectful in chat
- No spam or harassment
- Report inappropriate content
- Keep conversations relevant

## Security Considerations

### Privacy
- Only authenticated students can access
- User IDs are stored but not visible
- Email addresses not shown in chat
- Messages are not encrypted (consider encryption for sensitive data)

### Moderation
- Consider adding report message functionality
- Implement admin tools to delete inappropriate content
- Log message history for review
- Set up automated content filtering

### Data Retention
- Consider message retention policy
- Implement automatic deletion of old messages
- Provide export functionality
- Comply with data protection regulations

---

## Quick Reference

### Colors Used
- **Own messages**: Primary container color
- **Others' messages**: Surface container color
- **Send button**: Primary color (filled)
- **Input field**: Surface container background

### Important Files
- Model: `lib/models/chat_message.dart`
- Service: `lib/services/chat_service.dart`
- UI: `lib/screens/community_chat_screen.dart`

### Dependencies
- `firebase_auth` - User authentication
- `cloud_firestore` - Real-time database
- `intl` - Date formatting

---

Built with ❤️ for Nestify PG Management System
**Connecting students, building community!** 🏠💬
