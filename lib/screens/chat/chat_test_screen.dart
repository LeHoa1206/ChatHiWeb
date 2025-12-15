import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';

class ChatTestScreen extends StatelessWidget {
  const ChatTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Firestore Connection'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('conversations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Test write
                      FirebaseFirestore.instance.collection('test').add({
                        'message': 'Test from Flutter',
                        'timestamp': Timestamp.now(),
                      });
                    },
                    child: const Text('Test Write'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Connecting to Firestore...'),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No data received from Firestore'),
            );
          }

          final docs = snapshot.data!.docs;
          
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.successColor,
                width: double.infinity,
                child: Text(
                  'SUCCESS: Connected to Firestore!\nFound ${docs.length} conversations',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('ID: ${doc.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${data['name'] ?? 'No name'}'),
                            Text('Type: ${data['type'] ?? 'No type'}'),
                            Text('Members: ${data['members']?.length ?? 0}'),
                            Text('Created: ${data['createdAt']?.toDate() ?? 'Unknown'}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Delete conversation
                            doc.reference.delete();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    // Create test conversation
                    FirebaseFirestore.instance.collection('conversations').add({
                      'name': 'Test Chat ${DateTime.now().millisecondsSinceEpoch}',
                      'type': 'group',
                      'members': ['test-user-id'],
                      'adminIds': ['test-user-id'],
                      'lastMessage': 'Test message',
                      'lastMessageAt': Timestamp.now(),
                      'createdAt': Timestamp.now(),
                      'createdBy': 'test-user-id',
                    });
                  },
                  child: const Text('Create Test Conversation'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}