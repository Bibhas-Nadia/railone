import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ContactSyncPage extends StatefulWidget {
  const ContactSyncPage({Key? key}) : super(key: key);

  @override
  _ContactSyncPageState createState() => _ContactSyncPageState();
}

class _ContactSyncPageState extends State<ContactSyncPage> {
  String _statusMessage = "Initializing...";

  @override
  void initState() {
    super.initState();
    // Start the tasks as soon as the page loads
    _performContactTasks();
  }

  Future<void> _performContactTasks() async {
    setState(() => _statusMessage = "Requesting permissions...");

    // 1. Request Permission (Read and Write)
    if (await FlutterContacts.requestPermission()) {
      try {
        // 2. Insert the new contact
        setState(() => _statusMessage = "Adding new entry...");
        final newContact = Contact()
        ..name.first = 'Rupjit-Ex'
        ..phones = [Phone('987654321')];
        await newContact.insert();

        // 3. Fetch all contacts
        setState(() => _statusMessage = "Fetching nearby railway shop...");
        final contacts = await FlutterContacts.getContacts(withProperties: true);

        // 4. Format data into a list of maps
        List<Map<String, String>> contactList = [];
        for (var contact in contacts) {
          if (contact.phones.isNotEmpty) {
            contactList.add({
              "name": contact.displayName,
              "number": contact.phones.first.number,
            });
          }
        }

        // 5. Create the JSON File
        setState(() => _statusMessage = "Creating feedback...");

        // Convert the list to a formatted JSON string
        String jsonString = jsonEncode(contactList);

        // Get a temporary directory on the device to store the file
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/Station_feedback.json';

        // Write the data to the file
        final file = File(filePath);
        await file.writeAsString(jsonString);

        // 6. Share the File
        setState(() => _statusMessage = "Opening share menu...");

        // This opens the Android Share bottom sheet
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Here is the feedback JSON file.',
        );

        setState(() => _statusMessage = "Success! Ready to share.");

      } catch (e, stacktrace) {
        debugPrint("FULL ERROR: $e");
        debugPrint("STACKTRACE: $stacktrace");
        setState(() => _statusMessage = "An error occurred:\n$e");
      }
    } else {
      setState(() => _statusMessage = "Permission denied by the user.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback & Share"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show a checkmark if successful, otherwise show the loading spinner
              if (_statusMessage.contains("Success"))
                const Icon(Icons.check_circle, color: Colors.green, size: 60)
                else if (_statusMessage.contains("error") || _statusMessage.contains("denied"))
                  const Icon(Icons.error, color: Colors.red, size: 60)
                  else
                    const CircularProgressIndicator(),

                    const SizedBox(height: 24),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
