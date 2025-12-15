import 'package:cloud_firestore/cloud_firestore.dart';

class MigrationHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fix missing members in userConversations
  static Future<void> fixUserConversationsMembers(String userId) async {
    try {
      print('Starting migration for user: $userId');
      
      // Get all user conversations
      final userConversationsSnapshot = await _firestore
          .collection('userConversations')
          .doc(userId)
          .collection('conversations')
          .get();

      int updatedCount = 0;
      
      for (var doc in userConversationsSnapshot.docs) {
        final data = doc.data();
        
        // If members field is missing or empty, get it from main conversation
        if (data['members'] == null || (data['members'] as List).isEmpty) {
          final conversationId = data['conversationId'];
          
          if (conversationId != null && conversationId.toString().isNotEmpty) {
            try {
              final conversationDoc = await _firestore
                  .collection('conversations')
                  .doc(conversationId)
                  .get();
              
              if (conversationDoc.exists) {
                final conversationData = conversationDoc.data() as Map<String, dynamic>;
                
                // Update userConversation with members and other missing fields
                final updateData = <String, dynamic>{
                  'members': conversationData['members'] ?? [],
                };
                
                // Also update other fields if they're missing
                if (data['name'] == null && conversationData['name'] != null) {
                  updateData['name'] = conversationData['name'];
                }
                
                await doc.reference.update(updateData);
                updatedCount++;
                
                print('Updated conversation $conversationId with missing data');
              }
            } catch (e) {
              print('Error updating conversation $conversationId: $e');
            }
          }
        }
      }
      
      print('Migration completed for user $userId - Updated $updatedCount conversations');
    } catch (e) {
      print('Migration error for user $userId: $e');
    }
  }
}