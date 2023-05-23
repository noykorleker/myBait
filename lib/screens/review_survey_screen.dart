import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:mybait/Services/firebase_helper.dart';
import 'package:mybait/models/survey.dart';
import 'package:mybait/widgets/custom_Button.dart';
import 'package:mybait/widgets/custom_toast.dart';

class ReviewSurveyScreen extends StatelessWidget {
  static const routeName = '/reviewSurvey';
  String buildingID;
  String surveyID;
  CustomToast customToast = CustomToast();
  ReviewSurveyScreen(this.buildingID, this.surveyID, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Review'),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: FutureBuilder(
          future: FirebaseHelper.fetchSurveyDoc(buildingID, surveyID),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.none) {
              return Center(
                child: Column(
                  children: const [
                    Text('No Data...'),
                    CircularProgressIndicator(),
                  ],
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      snapshot.data!['title'],
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const Text(
                      'Description: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '${snapshot.data!['description']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                      maxLines: 20,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.done),
                          label: const Text('Yes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () async {
                            await addUserChoiceToResult('Yes');
                            customToast.showCustomToast(
                              'Thank you for voting 😇',
                              Colors.white,
                              Colors.green,
                            );
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: 50,
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.close),
                          label: const Text('No'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            await addUserChoiceToResult('No');
                            customToast.showCustomToast(
                              'Thank you for voting 😇',
                              Colors.white,
                              Colors.green,
                            );
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    )
                  ],
                ),
              );
            }
            return Center(
              child: const CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Future<void> addUserChoiceToResult(String choice) async {
    final collectionRef = FirebaseFirestore.instance
        .collection('Buildings')
        .doc(buildingID)
        .collection('Surveys');
    final documentRef = collectionRef.doc(surveyID);
    final documentSnapshot = await documentRef.get();
    final currentMap =
        documentSnapshot.data()!['result'] as Map<String, dynamic>;
    final currentList = documentSnapshot.data()!['result'][choice] as List<dynamic>;
    currentList.add(FirebaseAuth.instance.currentUser!.uid);
    currentMap[choice] = currentList;
    await documentRef.update({'result': currentMap});
  }
}
