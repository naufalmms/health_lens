import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:health_lens/screens/assesment/model/assesment_result_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  // Generic method to save data to a specific collection
  Future<bool> saveData({
    required String collectionName,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    try {
      if (documentId != null) {
        await _firestore
            .collection(collectionName)
            .doc(documentId)
            .set(data, SetOptions(merge: true));
      } else {
        await _firestore.collection(collectionName).add(data);
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving data to $collectionName: $e');
      }
      return false;
    }
  }

  // Method to update an entire document in a collection
  Future<bool> updateDailyDocument({
    required String collectionName,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      // await _firestore
      //     .collection(collectionName)
      //     .doc(documentId)
      //     .set(data, SetOptions(merge: true));

      final matchingDoc = await _firestore
          .collection('detailed_depression_data')
          .where('userId', isEqualTo: documentId)
          .where('date', isEqualTo: data['date'])
          .get();

      if (matchingDoc.docs.isNotEmpty) {
        // Update the first matching document
        await matchingDoc.docs.first.reference
            .update({...data, 'timestamp': FieldValue.serverTimestamp()});

        if (kDebugMode) {
          print('Updated depression data for ${data['date']}');
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating document in $collectionName: $e');
      }
      return false;
    }
  }

  // Generic method to fetch data from a specific collection
  Future<Map<String, dynamic>?> fetchData({
    required String collectionName,
    required String documentId,
  }) async {
    try {
      final docSnapshot =
          await _firestore.collection(collectionName).doc(documentId).get();
      return docSnapshot.exists ? docSnapshot.data() : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data from $collectionName: $e');
      }
      return null;
    }
  }

  // Method to update specific fields in a document
  Future<bool> updateData({
    required String collectionName,
    required String documentId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(documentId)
          .update(updates);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating data in $collectionName: $e');
      }
      return false;
    }
  }

  // Method to delete a document
  Future<bool> deleteData({
    required String collectionName,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collectionName).doc(documentId).delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting data from $collectionName: $e');
      }
      return false;
    }
  }

  // Specific method for user profile
  Future<bool> saveUserProfile({
    required User user,
    String? name,
    String? emergencyEmail,
  }) async {
    final userData = {
      'email': user.email,
      if (name != null) 'name': name,
      if (emergencyEmail != null) 'emergencyEmail': emergencyEmail,
      'createdAt': FieldValue.serverTimestamp(),
    };

    return await saveData(
      collectionName: 'users',
      documentId: user.uid,
      data: userData,
    );
  }

  // Query method with optional filtering and ordering
  Future<List<Map<String, dynamic>>> queryCollection({
    required String collectionName,
    Map<String, dynamic>? whereConditions,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collectionName);

      // Apply where conditions
      if (whereConditions != null) {
        whereConditions.forEach((field, value) {
          query = query.where(field, isEqualTo: value);
        });
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error querying collection $collectionName: $e');
      }
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserEmergencyContacts(String userId) async {
    try {
      final userDoc =
          await fetchData(collectionName: 'users', documentId: userId);

      if (userDoc != null) {
        return {
          'userEmail': userDoc['email'],
          'emergencyEmail': userDoc['emergencyEmail']
        };
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user emergency contacts: $e');
      }
      return null;
    }
  }

  // Tambahkan metode baru dalam class FirestoreService
  Future<bool> saveDepressionAnalysis({
    required String userId,
    required double avgRestingHeartRate,
    required double avgHeartRate,
    required double avgDailySteps,
    required double avgDailySleepDuration,
    required double deepSleepPercentage,
    required double avgDailyActiveEnergyBurned,
    required double avgDailyWorkoutMinutes,
    required bool isDepressed,
    required bool needsAssessment,
  }) async {
    try {
      final userData = {
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'avgRestingHeartRate': avgRestingHeartRate,
        'avgHeartRate': avgHeartRate,
        'avgDailySteps': avgDailySteps,
        'avgDailySleepDuration': avgDailySleepDuration,
        'deepSleepPercentage': deepSleepPercentage,
        'avgDailyActiveEnergyBurned': avgDailyActiveEnergyBurned,
        'avgDailyWorkoutMinutes': avgDailyWorkoutMinutes,
        'isDepressed': isDepressed,
        'needsAssessment': needsAssessment,
      };

      await saveData(
        collectionName: 'depression_analysis',
        documentId: userId,
        data: userData,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving depression analysis: $e');
      }
      return false;
    }
  }

  Future<bool> saveAssessmentResults({
    required String userId,
    required int totalScore,
    required bool isDepressed,
    required List<int> selectedAnswers,
  }) async {
    try {
      final userData = {
        'userId': userId,
        'totalScore': totalScore,
        'isDepressed': isDepressed,
        'submittedAt': FieldValue.serverTimestamp(),
        'answers': selectedAnswers,
      };

      await saveData(
        collectionName: 'assessment_results',
        documentId: userId,
        data: userData,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving assessment results: $e');
      }
      return false;
    }
  }

  Future<List<AssessmentResult>> getAssessmentHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('assessment_results')
          .where('userId', isEqualTo: userId)
          .orderBy('submittedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AssessmentResult.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching assessment history: $e');
      }
      throw Exception('Failed to fetch assessment history');
    }
  }
}
