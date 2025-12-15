# Firebase Security Rules & Indexes

## Firestore Security Rules

The `firestore.rules` file contains security rules that:

1. **Users Collection**: Users can only read/write their own user documents
2. **Conversations Collection**: Users can only access conversations they are members of
3. **Messages Subcollection**: Users can only access messages in conversations they belong to
4. **Pinned Messages Subcollection**: Same access control as messages
5. **User Conversations Collection**: Users can only access their own conversation lists

## Firestore Indexes

The `firestore.indexes.json` file defines composite indexes for:

1. **Messages by Creation Time**: For ordering messages in conversations
2. **Conversations by Last Message Time**: For ordering conversation lists
3. **Messages by Seen Status**: For marking messages as read/unread
4. **Conversations by Type and Members**: For finding existing private conversations

## Deployment

To deploy these rules and indexes:

```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project (if not done)
firebase init firestore

# Deploy rules and indexes
firebase deploy --only firestore:rules,firestore:indexes
```

## Common Index Errors

If you see index errors like:
```
[cloud_firestore/failed-precondition] The query requires an index
```

1. Click the provided link in the error to create the index automatically
2. Or add the required index to `firestore.indexes.json` and deploy
3. Wait 5-10 minutes for the index to build

## Security Best Practices

1. Always authenticate users before allowing access
2. Use `request.auth.uid` to verify user identity
3. Check membership in conversations before allowing access
4. Validate data structure in write operations
5. Use `get()` function to check related documents when needed