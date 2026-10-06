import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:printing/printing.dart';
import '../models/cv_model.dart';
import '../services/firestore_service.dart';
import '../services/pdf_service.dart';
import '../controllers/cv_controller.dart';

class CVPreviewDialog extends StatefulWidget {
  final CVModel cv;
  final CVController controller;

  const CVPreviewDialog({super.key, required this.cv, required this.controller});

  @override
  State<CVPreviewDialog> createState() => _CVPreviewDialogState();
}

class _CVPreviewDialogState extends State<CVPreviewDialog> {
  Future<void> _saveToCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      final loggedIn = await showDialog<bool>(
        context: context,
        builder: (context) => const LoginDialog(),
      );
      if (loggedIn != true) {
        return; // User cancelled or failed login
      }
    }

    try {
      final firestoreService = FirestoreService();
      await firestoreService.saveCV(widget.cv);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CV successfully saved to Cloud!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdfService = PdfService();
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 1000,
        height: MediaQuery.of(context).size.height * 0.95,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Full PDF Preview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _saveToCloud,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Save to Cloud'),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: PdfPreview(
                build: (format) => pdfService.generateCVPdf(widget.cv, widget.controller.currentTemplate),
                allowSharing: true,
                allowPrinting: true,
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginOrRegister() async {
    setState(() => _isLoading = true);
    try {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        } else {
          rethrow;
        }
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auth Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Login required to Save CV'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Please login or register to save your CV to Firebase.'),
          const SizedBox(height: 16),
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
          TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isLoading ? null : _loginOrRegister,
          child: _isLoading ? const CircularProgressIndicator() : const Text('Login / Register'),
        ),
      ],
    );
  }
}
