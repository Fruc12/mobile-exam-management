import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/controllers/auth_controller.dart';
import '../controllers/actor_controller.dart';
import '../controllers/admin_user_controller.dart';
import '../models/actor_model.dart';

class ActorFormScreen extends ConsumerStatefulWidget {
  final ActorModel? actor;
  final int? userId; 

  const ActorFormScreen({super.key, this.actor, this.userId});

  @override
  ConsumerState<ActorFormScreen> createState() => _ActorFormScreenState();
}

class _ActorFormScreenState extends ConsumerState<ActorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _npiController;
  late final TextEditingController _nRibController;
  late final TextEditingController _birthplaceController;
  late final TextEditingController _phoneController;

  String _selectedDiploma = 'BAC';
  String _selectedBank = 'NSIA';
  DateTime _selectedDate = DateTime.now();
  
  File? _idCardFile;
  File? _ribFile;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _npiController = TextEditingController(text: widget.actor?.npi);
    _nRibController = TextEditingController(text: widget.actor?.nRib);
    _birthplaceController = TextEditingController(text: widget.actor?.birthplace);
    _phoneController = TextEditingController(text: widget.actor?.phone);
    
    if (widget.actor != null) {
      _selectedDiploma = widget.actor!.diploma;
      _selectedBank = widget.actor!.bank;
      _selectedDate = widget.actor!.birthdate;
    }
  }

  @override
  void dispose() {
    _npiController.dispose();
    _nRibController.dispose();
    _birthplaceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isIdCard) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final size = await file.length();
      
      if (size > 2 * 1024 * 1024) { 
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Le fichier est trop lourd (max 2Mo)"), backgroundColor: Colors.orange),
          );
        }
        return;
      }

      setState(() {
        if (isIdCard) {
          _idCardFile = file;
        } else {
          _ribFile = file;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.actor == null && (_idCardFile == null || _ribFile == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner tous les documents"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(actorControllerProvider.notifier);
      final birthdateStr = _selectedDate.toIso8601String().split('T')[0];
      final currentUser = ref.read(authControllerProvider).user;
      final isAdmin = currentUser?.isAdmin ?? false;

      if (widget.actor == null) {
        final newActor = await notifier.createActor(
          npi: _npiController.text,
          nRib: _nRibController.text,
          idCard: _idCardFile!,
          rib: _ribFile!,
          birthdate: birthdateStr,
          birthplace: _birthplaceController.text,
          diploma: _selectedDiploma,
          bank: _selectedBank,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          userId: widget.userId,
        );

        if (isAdmin) {
          ref.read(adminUserControllerProvider.notifier).refresh();
        } else {
          await ref.read(authControllerProvider.notifier).tryAutoLogin();
        }

        if (mounted && newActor != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profil créé avec succès")),
          );
          context.go('/actors/${newActor.id}');
        }
      } else {
        await notifier.updateActor(
          widget.actor!.id,
          npi: _npiController.text,
          nRib: _nRibController.text,
          idCard: _idCardFile,
          rib: _ribFile,
          birthdate: birthdateStr,
          birthplace: _birthplaceController.text,
          diploma: _selectedDiploma,
          bank: _selectedBank,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        );
        ref.invalidate(actorDetailProvider(widget.actor!.id));
        
        if (isAdmin) {
          ref.read(adminUserControllerProvider.notifier).refresh();
        } else {
          await ref.read(authControllerProvider.notifier).tryAutoLogin();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profil mis à jour avec succès")),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.actor == null ? "Création Profil Acteur" : "Modifier mes informations"),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _npiController,
                    decoration: const InputDecoration(
                      labelText: "NPI (Identifiant National)",
                      hintText: "11 chiffres requis",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Le NPI est obligatoire";
                      if (!RegExp(r'^\d{11}$').hasMatch(v)) return "Doit contenir exactement 11 chiffres";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nRibController,
                    decoration: const InputDecoration(
                      labelText: "Numéro RIB",
                      hintText: "32 caractères alphanumériques",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Le RIB est obligatoire";
                      if (v.length != 32) return "Doit faire exactement 32 caractères";
                      if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(v)) return "Alphanumérique uniquement";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _birthplaceController,
                    decoration: const InputDecoration(
                      labelText: "Lieu de naissance", 
                      border: OutlineInputBorder()
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? "Champ obligatoire" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: "Téléphone (Optionnel)",
                      hintText: "10 chiffres",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v != null && v.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(v)) {
                        return "Doit contenir 10 chiffres";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDiploma,
                    decoration: const InputDecoration(
                      labelText: "Dernier diplôme obtenu", 
                      border: OutlineInputBorder()
                    ),
                    items: const [
                      DropdownMenuItem(value: 'BAC', child: Text('BAC')),
                      DropdownMenuItem(value: 'LICENCE', child: Text('LICENCE')),
                      DropdownMenuItem(value: 'MASTER', child: Text('MASTER')),
                      DropdownMenuItem(value: 'DOCTORAT', child: Text('DOCTORAT')),
                    ],
                    onChanged: (value) => setState(() => _selectedDiploma = value!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedBank,
                    decoration: const InputDecoration(
                      labelText: "Votre Banque", 
                      border: OutlineInputBorder()
                    ),
                    items: const [
                      DropdownMenuItem(value: 'NSIA', child: Text('NSIA')),
                      DropdownMenuItem(value: 'UBA', child: Text('UBA')),
                      DropdownMenuItem(value: 'ECOBANK', child: Text('ECOBANK')),
                      DropdownMenuItem(value: 'BOA', child: Text('BOA')),
                      DropdownMenuItem(value: 'LA POSTE', child: Text('LA POSTE')),
                      DropdownMenuItem(value: 'CORIS', child: Text('CORIS')),
                      DropdownMenuItem(value: 'ORABANK', child: Text('ORABANK')),
                    ],
                    onChanged: (value) => setState(() => _selectedBank = value!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text("Date de naissance"),
                    subtitle: Text("${_selectedDate.toLocal()}".split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.grey), 
                      borderRadius: BorderRadius.circular(4)
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Documents justificatifs (Max 2Mo)", 
                    style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 8),
                  _FilePickerTile(
                    label: "Carte d'identité (JPG, PNG)",
                    file: _idCardFile,
                    onTap: () => _pickFile(true),
                    isExisting: widget.actor?.idCard != null,
                  ),
                  const SizedBox(height: 8),
                  _FilePickerTile(
                    label: "RIB (JPG, PNG)",
                    file: _ribFile,
                    onTap: () => _pickFile(false),
                    isExisting: widget.actor?.rib != null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16)
                    ),
                    child: const Text("VALIDER"),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class _FilePickerTile extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onTap;
  final bool isExisting;

  const _FilePickerTile({
    required this.label, 
    required this.file, 
    required this.onTap, 
    required this.isExisting
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(
        file != null 
            ? file!.path.split('/').last 
            : (isExisting ? "Document déjà envoyé ✓" : "Aucun fichier sélectionné"),
        style: TextStyle(
          color: file != null 
              ? Colors.green 
              : (isExisting ? Colors.blue : Colors.red)
        ),
      ),
      trailing: const Icon(Icons.attach_file),
      tileColor: Colors.grey[100],
      onTap: onTap,
    );
  }
}
