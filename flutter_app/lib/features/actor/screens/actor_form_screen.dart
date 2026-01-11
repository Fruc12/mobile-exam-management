import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/actor_controller.dart';
import '../models/actor_model.dart';

class ActorFormScreen extends ConsumerStatefulWidget {
  final ActorModel? actor;
  const ActorFormScreen({super.key, this.actor});

  @override
  ConsumerState<ActorFormScreen> createState() => _ActorFormScreenState();
}

class _ActorFormScreenState extends ConsumerState<ActorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _npiController;
  late TextEditingController _nRibController;
  late TextEditingController _birthplaceController;
  late TextEditingController _phoneController;

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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        if (isIdCard) {
          _idCardFile = File(result.files.single.path!);
        } else {
          _ribFile = File(result.files.single.path!);
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(actorControllerProvider.notifier);
      final birthdateStr = _selectedDate.toIso8601String().split('T')[0];

      if (widget.actor == null) {
        // Mode Création
        if (_idCardFile == null || _ribFile == null) {
          throw Exception("Veuillez sélectionner la carte d'identité et le RIB");
        }

        await notifier.createActor(
          npi: _npiController.text,
          nRib: _nRibController.text,
          idCard: _idCardFile!,
          rib: _ribFile!,
          birthdate: birthdateStr,
          birthplace: _birthplaceController.text,
          diploma: _selectedDiploma,
          bank: _selectedBank,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        );
      } else {
        // Mode Edition
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
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Opération réussie")),
        );
        context.pop();
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
        title: Text(widget.actor == null ? "Renseigner mes informations" : "Modifier mes informations"),
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
                      labelText: "NPI",
                      hintText: "Identifiant National Unique (11 chiffres)",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.length != 11) ? "Le NPI doit faire 11 chiffres" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nRibController,
                    decoration: const InputDecoration(
                      labelText: "Numéro RIB",
                      hintText: "32 caractères alphanumériques",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.length != 32) ? "Le RIB doit faire 32 caractères" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _birthplaceController,
                    decoration: const InputDecoration(
                      labelText: "Lieu de naissance",
                      border: OutlineInputBorder(),
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
                    validator: (v) => (v != null && v.isNotEmpty && v.length != 10) ? "10 chiffres requis" : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDiploma,
                    decoration: const InputDecoration(labelText: "Plus haut diplôme", border: OutlineInputBorder()),
                    items: ['BAC', 'LICENCE', 'MASTER', 'DOCTORAT']
                        .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedDiploma = value!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedBank,
                    decoration: const InputDecoration(labelText: "Banque", border: OutlineInputBorder()),
                    items: ['NSIA', 'UBA', 'ECOBANK', 'BOA', 'LA POSTE', 'CORIS', 'ORABANK']
                        .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedBank = value!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text("Date de naissance"),
                    subtitle: Text("${_selectedDate.toLocal()}".split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
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
                  const Text("Documents justificatifs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  
                  _FilePickerTile(
                    label: "Carte d'identité (PDF, Image)",
                    file: _idCardFile,
                    onTap: () => _pickFile(true),
                    isExisting: widget.actor?.idCard != null,
                  ),
                  const SizedBox(height: 8),
                  _FilePickerTile(
                    label: "Relevé d'Identité Bancaire (RIB)",
                    file: _ribFile,
                    onTap: () => _pickFile(false),
                    isExisting: widget.actor?.rib != null,
                  ),
                  
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    child: Text(widget.actor == null ? "CRÉER MON PROFIL ACTEUR" : "METTRE À JOUR"),
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
    required this.isExisting,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(
        file != null 
          ? file!.path.split('/').last 
          : (isExisting ? "Document déjà envoyé (cliquez pour modifier)" : "Aucun fichier sélectionné"),
        style: TextStyle(color: file != null ? Colors.green : (isExisting ? Colors.orange : Colors.red)),
      ),
      trailing: const Icon(Icons.attach_file),
      tileColor: Colors.grey[100],
      onTap: onTap,
    );
  }
}
