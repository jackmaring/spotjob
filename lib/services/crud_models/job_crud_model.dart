import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:spotjob/models/job.dart';
import 'package:spotjob/services/firestore_api.dart';

class JobCRUD {
  FirestoreApi _api = FirestoreApi('/jobs');

  Future<List<Job>> fetchJobs() async {
    var result = await _api.getDataCollection();
    List<Job> jobs =
        result.docs.map((doc) => Job.fromJson(doc.data())).toList();
    return jobs;
  }

  Stream<List<Job>> getJobs() {
    return _api.streamDataCollectionByDateCreated().map((snapshot) => snapshot
        .docs
        .map((document) => Job.fromJson(document.data()))
        .toList());
  }

  Stream<QuerySnapshot> fetchJobsStream() {
    return _api.streamDataCollection();
  }

  Future<Job> getJobById(String id) async {
    var doc = await _api.getDocumentById(id);
    return Job.fromJson(doc.data());
  }

  Future removeJob(String id) async {
    await _api.removeDocument(id);
    return;
  }

  Future updateJob(Job data) async {
    await _api.updateDocument(data.toJson(), data.id);
    return;
  }

  Future<Job> addJob(Job data) async {
    await _api
        .addDocument(data.toJson())
        .then((result) => {
              data.id = result.id,
              result.set({'id': data.id}, SetOptions(merge: true))
            })
        .catchError((e) => {print(e.message)});
    return data;
  }
}
