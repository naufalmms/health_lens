import 'package:flutter/material.dart';
import 'package:health_lens/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _emergencyEmail = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Registration')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => value!.isEmpty ? 'Please enter name' : null,
              onSaved: (value) => _name = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Emergency Email'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter emergency email' : null,
              onSaved: (value) => _emergencyEmail = value!,
            ),
            ElevatedButton(
              child: const Text('Complete Registration'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  context.read<AuthProvider>().completeRegistration(
                        name: _name,
                        emergencyEmail: _emergencyEmail,
                      );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
