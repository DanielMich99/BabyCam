import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String babyName = 'Tom';
  int babyAgeMonths = 11;
  String healthCondition = 'None';
  final List<String> healthConditions = ['None', 'Allergy', 'Asthma', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Image.asset(
              'assets/images/babycam_logo.png',
              height: 48,
            ),
            const SizedBox(height: 4),
            const Text('BABY CAM',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        toolbarHeight: 90,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Account Settings
              ExpansionTile(
                leading: const Icon(Icons.person),
                title: const Text('account settings',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  // Add account settings widgets here
                ],
              ),
              // Baby Profiles
              ExpansionTile(
                leading: const Icon(Icons.child_care),
                title: const Text('baby profiles',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                initiallyExpanded: true,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.blue,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('assets/images/tom.jpg'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(babyName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: babyName,
                              decoration: const InputDecoration(
                                labelText: 'baby name',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide.none),
                              ),
                              onChanged: (value) =>
                                  setState(() => babyName = value),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: '$babyAgeMonths months',
                              decoration: const InputDecoration(
                                labelText: 'age',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide.none),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final age = int.tryParse(
                                    value.replaceAll(RegExp(r'[^0-9]'), ''));
                                if (age != null)
                                  setState(() => babyAgeMonths = age);
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: healthCondition,
                              items: healthConditions
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (value) => setState(
                                  () => healthCondition = value ?? 'None'),
                              decoration: const InputDecoration(
                                labelText: 'health condition',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListTile(
                              title: const Text('Manage Hazardous Objects'),
                              subtitle: const Text(
                                  'Manage the objects that the system will recognize as hazardous'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                // Navigate to hazardous objects management
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              tileColor: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Save logic
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Save',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // System Settings
              ExpansionTile(
                leading: const Icon(Icons.settings),
                title: const Text('system settings',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  // Add system settings widgets here
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: 'Camera'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}
