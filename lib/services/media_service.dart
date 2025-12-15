import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MediaService {
  static final ImagePicker _imagePicker = ImagePicker();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Pick image from gallery or camera
  static Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Pick file
  static Future<PlatformFile?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  // Send image message to Firestore
  static Future<void> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required Uint8List imageBytes,
    required String fileName,
    String? replyTo,
  }) async {
    try {
      // Convert image to base64 for storage in Firestore
      // Note: In production, you should use Firebase Storage
      final String base64Image = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
      
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'senderName': senderName,
        'content': fileName,
        'type': 'image',
        'imageData': base64Image, // Store as base64 for demo
        'fileName': fileName,
        'fileSize': imageBytes.length,
        'replyTo': replyTo,
        'isPinned': false,
        'isDeleted': false,
        'reactions': {},
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update conversation last message
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'lastMessage': '📷 Đã gửi ảnh',
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error sending image message: $e');
      rethrow;
    }
  }

  // Send file message to Firestore
  static Future<void> sendFileMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required Uint8List fileBytes,
    required String fileName,
    required String fileType,
    String? replyTo,
  }) async {
    try {
      // Convert file to base64 for storage in Firestore
      // Note: In production, you should use Firebase Storage
      final String base64File = 'data:$fileType;base64,${base64Encode(fileBytes)}';
      
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'senderName': senderName,
        'content': fileName,
        'type': 'file',
        'fileData': base64File, // Store as base64 for demo
        'fileName': fileName,
        'fileType': fileType,
        'fileSize': fileBytes.length,
        'replyTo': replyTo,
        'isPinned': false,
        'isDeleted': false,
        'reactions': {},
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update conversation last message
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'lastMessage': '📎 Đã gửi file: $fileName',
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error sending file message: $e');
      rethrow;
    }
  }

  // Get file size in readable format
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Get file icon based on file type
  static IconData getFileIcon(String fileType) {
    if (fileType.contains('image')) {
      return Icons.image;
    } else if (fileType.contains('video')) {
      return Icons.video_file;
    } else if (fileType.contains('audio')) {
      return Icons.audio_file;
    } else if (fileType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (fileType.contains('word') || fileType.contains('document')) {
      return Icons.description;
    } else if (fileType.contains('excel') || fileType.contains('spreadsheet')) {
      return Icons.table_chart;
    } else if (fileType.contains('powerpoint') || fileType.contains('presentation')) {
      return Icons.slideshow;
    } else if (fileType.contains('zip') || fileType.contains('rar')) {
      return Icons.archive;
    } else {
      return Icons.insert_drive_file;
    }
  }
}

