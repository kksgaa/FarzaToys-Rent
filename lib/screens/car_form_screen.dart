import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../app_store.dart';
import '../models/car.dart';
import '../services/supabase_service.dart';
import '../widgets/custom_app_bar.dart';
import '../main.dart'; 

class CarFormScreen extends StatefulWidget {
  final Car? car;
  const CarFormScreen({super.key, this.car});

  @override
  State<CarFormScreen> createState() => _CarFormScreenState();
}

class _CarFormScreenState extends State<CarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _colorCtrl;
  late TextEditingController _noteCtrl;
  late TextEditingController _priceCtrl;
  
  bool _isSaving = false;
  File? _selectedImage;

  bool get isEditing => widget.car != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.car?.name ?? '');
    _colorCtrl = TextEditingController(text: widget.car?.color ?? '');
    _noteCtrl = TextEditingController(text: widget.car?.note ?? '');
    _priceCtrl = TextEditingController(text: widget.car?.pricePer15Mins.toString() ?? '20000');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _colorCtrl.dispose();
    _noteCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    
    final store = context.read<AppStore>();
    final navigator = Navigator.of(context);
    
    try {
      String? uploadedImageUrl = widget.car?.imageUrl;
      if (_selectedImage != null) {
        uploadedImageUrl = await SupabaseService.uploadCarImage(_selectedImage!);
      }

      int finalPrice = int.tryParse(_priceCtrl.text.trim()) ?? 20000;

      if (isEditing) {
        final updated = widget.car!.copyWith(
          name: _nameCtrl.text.trim(),
          color: _colorCtrl.text.trim(),
          note: _noteCtrl.text.trim(),
          imageUrl: uploadedImageUrl,
          pricePer15Mins: finalPrice,
        );
        await store.updateCar(updated);
        navigator.pop();
        showSnackBarWithOK('Mobil berhasil diperbarui!');
      } else {
        final car = Car(
          id: '',
          name: _nameCtrl.text.trim(),
          color: _colorCtrl.text.trim(),
          note: _noteCtrl.text.trim(),
          imageUrl: uploadedImageUrl,
          pricePer15Mins: finalPrice,
        );
        await store.addCar(car);
        navigator.pop();
        showSnackBarWithOK('Mobil berhasil ditambahkan!');
      }
    } catch (e) {
      debugPrint(e.toString()); 
      showSnackBarWithOK('Gagal: $e', backgroundColor: const Color(0xFFFF8A80)); 
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _neoInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black38),
      prefixIcon: Icon(icon, color: Colors.black),
      prefixText: hint == 'Misal: 20000' ? 'Rp ' : null,
      prefixStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 3)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: isEditing ? 'EDIT MOBIL' : 'TAMBAH MOBIL'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage, 
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 130, height: 130,
                        decoration: BoxDecoration(
                          color: const Color(0xFF80DEEA), borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6), blurRadius: 0)],
                          image: _selectedImage != null
                              ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                              : (widget.car?.imageUrl != null && widget.car!.imageUrl!.isNotEmpty)
                                  ? DecorationImage(image: NetworkImage(widget.car!.imageUrl!), fit: BoxFit.cover)
                                  : null,
                        ),
                        child: (_selectedImage == null && (widget.car?.imageUrl == null || widget.car!.imageUrl!.isEmpty))
                            ? const Icon(Icons.add_a_photo, color: Colors.black, size: 50) : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFEA80FC), shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
                        child: const Icon(Icons.edit, color: Colors.black, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              _label('NAMA MOBIL'),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                decoration: _neoInputDecoration('Contoh: Ferrari SF90', Icons.label),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              
              _label('WARNA'),
              TextFormField(
                controller: _colorCtrl,
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                decoration: _neoInputDecoration('Contoh: Merah', Icons.palette),
                validator: (v) => v == null || v.trim().isEmpty ? 'Warna tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              
              _label('HARGA SEWA (PER 15 MENIT)'),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _neoInputDecoration('Misal: 20000', Icons.attach_money),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Harga tidak boleh kosong';
                  final intPrice = int.tryParse(v);
                  if (intPrice == null) return 'Harga tidak valid';
                  if (intPrice > 100000) return 'Maksimal Rp 100.000 / 15 Menit';
                  if (intPrice < 1000) return 'Minimal Rp 1.000 / 15 Menit';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _label('KETERANGAN TAMBAHAN'),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                decoration: _neoInputDecoration('Contoh: Kondisi baru, edisi terbatas', Icons.notes),
              ),
              const SizedBox(height: 40),
              
              InkWell(
                onTap: _isSaving ? null : _save,
                child: Container(
                  width: double.infinity, height: 60,
                  decoration: BoxDecoration(
                    color: _isSaving ? Colors.grey : const Color(0xFFB9F6CA), borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: _isSaving ? null : const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSaving) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black))
                      else Icon(isEditing ? Icons.save : Icons.add_circle, color: Colors.black),
                      const SizedBox(width: 12),
                      Text(isEditing ? 'SIMPAN PERUBAHAN' : 'TAMBAH MOBIL', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black87)));
}