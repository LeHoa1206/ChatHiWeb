import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Upload image
  Future<String> uploadImage(File file, String conversationId) async {
    try {
      String fileName = '${_uuid.v4()}${path.extension(file.path)}';
      String filePath = 'messages/$conversationId/images/$fileName';
      
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(file);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Lỗi tải lên hình ảnh: ${e.toString()}');
    }
  }

  // Upload file
  Future<String> uploadFile(File file, String conversationId) async {
    try {
      String fileName = '${_uuid.v4()}_${path.basename(file.path)}';
      String filePath = 'messages/$conversationId/files/$fileName';
      
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(file);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Lỗi tải lên tệp: ${e.toString()}');
    }
  }

  // Upload audio
  Future<String> uploadAudio(File file, String conversationId) async {
    try {
      String fileName = '${_uuid.v4()}.m4a';
      String filePath = 'messages/$conversationId/audio/$fileName';
      
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(file);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Lỗi tải lên âm thanh: ${e.toString()}');
    }
  }

  // Upload video
  Future<String> uploadVideo(File file, String conversationId) async {
    try {
      String fileName = '${_uuid.v4()}${path.extension(file.path)}';
      String filePath = 'messages/$conversationId/videos/$fileName';
      
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(file);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Lỗi tải lên video: ${e.toString()}');
    }
  }

  // Upload avatar
  Future<String> uploadAvatar(File file, String userId) async {
    try {
      String fileName = '${_uuid.v4()}${path.extension(file.path)}';
      String filePath = 'avatars/$userId/$fileName';
      
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(file);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Lỗi tải lên avatar: ${e.toString()}');
    }
  }

  // Delete file
  Future<void> deleteFile(String fileUrl) async {
    try {
      Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      print('Lỗi xóa tệp: $e');
    }
  }

  // Get file metadata
  Future<Map<String, dynamic>?> getFileMetadata(File file) async {
    try {
      String extension = path.extension(file.path).toLowerCase();
      int fileSize = await file.length();
      
      Map<String, dynamic> metadata = {
        'size': fileSize,
        'extension': extension,
      };

      // For images, get dimensions
      if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(extension)) {
        // You can use image package to get dimensions
        metadata['type'] = 'image';
      } else if (['.mp4', '.mov', '.avi', '.mkv'].contains(extension)) {
        metadata['type'] = 'video';
      } else if (['.mp3', '.wav', '.m4a', '.aac'].contains(extension)) {
        metadata['type'] = 'audio';
      } else {
        metadata['type'] = 'file';
      }

      return metadata;
    } catch (e) {
      print('Lỗi lấy metadata: $e');
      return null;
    }
  }
}