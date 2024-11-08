// screens/contacts_screen.dart
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = []; // Full list of contacts
  List<Contact> _filteredContacts = []; // Filtered list based on search query
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestPermissionAndFetchContacts();
    _searchController.addListener(_filterContacts); // Listen for search input
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Request permission and fetch contacts
  Future<void> _requestPermissionAndFetchContacts() async {
    final permissionStatus = await Permission.contacts.request();
    if (permissionStatus.isGranted) {
      _fetchContacts();
    } else {
      // Show a dialog if permission is denied
      _showPermissionDeniedDialog();
    }
  }

  // Fetch contacts from the device
  Future<void> _fetchContacts() async {
    final contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts.toList();
      _filteredContacts = _contacts;
    });
  }

  // Filter contacts based on search query
  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        final name = contact.displayName?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    });
  }

  // Show a dialog if permission is denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Denied'),
        content: Text('Contact permission is required to display contacts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Contacts',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredContacts.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      return ContactTile(contact: contact);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Custom widget for displaying each contact
class ContactTile extends StatelessWidget {
  final Contact contact;

  const ContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      leading: CircleAvatar(
        backgroundColor: Colors.blueAccent,
        child: Text(
          contact.initials(),
          style: TextStyle(color: Colors.white),
        ),
      ),
      title: Text(contact.displayName ?? 'No Name',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
      subtitle: Text(
        contact.phones!.isNotEmpty
            ? contact.phones!.first.value ?? ''
            : 'No phone number',
        style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
      ),
    );
  }
}
