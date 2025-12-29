import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StationPickerSheet extends StatelessWidget {
  const StationPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      // Give it a rounded top look
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text("Select Drop-off Station", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // THE LIST
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('stations').where('is_active', isEqualTo: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No active stations found."),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true, // Important for bottom sheets
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue, 
                        child: Icon(Icons.location_on, color: Colors.white, size: 20)
                      ),
                      title: Text(data['name'] ?? "Unknown Station", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(data['address'] ?? "No address"),
                      onTap: () {
                        // RETURN THE SELECTED DATA AND ID BACK TO SELL PAGE
                        Navigator.pop(context, {
                          'id': doc.id,
                          'name': data['name'],
                          'address': data['address']
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}