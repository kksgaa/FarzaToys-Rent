import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_store.dart';
import '../models/car.dart';
import '../main.dart';

class RentalFormScreen extends StatefulWidget {
  final String? carId;
  const RentalFormScreen({super.key, this.carId});

  @override
  State<RentalFormScreen> createState() => _RentalFormScreenState();
}

class _RentalFormScreenState extends State<RentalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: '.');
  final _phoneCtrl = TextEditingController(text: '.');
  final _addressCtrl = TextEditingController(text: '.');
  Car? _selectedCar;
  int _durationMinutes = 15;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.carId != null) {
        final store = context.read<AppStore>();
        setState(() => _selectedCar = store.getCarById(widget.carId!));
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  double get _totalPrice => (_durationMinutes / 15) * Car.pricePerSession;
  DateTime get _estimatedEnd =>
      DateTime.now().add(Duration(minutes: _durationMinutes));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCar == null) {
      showSnackBarWithOK('Pilih mobil terlebih dahulu');
      return;
    }
    setState(() => _isSaving = true);
    final store = context.read<AppStore>();
    final navigator = Navigator.of(context);
    final carId = widget.carId;
    try {
      await store.addRental(
        car: _selectedCar!,
        renterName: _nameCtrl.text.trim().isEmpty ? '.' : _nameCtrl.text.trim(),
        renterPhone:
            _phoneCtrl.text.trim().isEmpty ? '.' : _phoneCtrl.text.trim(),
        renterAddress:
            _addressCtrl.text.trim().isEmpty ? '.' : _addressCtrl.text.trim(),
        durationMinutes: _durationMinutes,
      );
      navigator.pop();
      if (carId != null) navigator.pop();
      showSnackBarWithOK('Penyewaan berhasil dibuat!',
          backgroundColor: Colors.green);
    } catch (_) {
      showSnackBarWithOK('Gagal membuat penyewaan',
          backgroundColor: Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final currFmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final timeFmt = DateFormat('HH:mm', 'id_ID');

    return Scaffold(
      appBar: AppBar(title: const Text('Form Penyewaan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Info default ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Data penyewa diisi "." secara default. Isi jika sempat.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Pilih Mobil ──────────────────────────────────────────
              _label('Pilih Mobil *'),
              if (widget.carId != null && _selectedCar != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kPrimaryLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car, color: kPrimary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selectedCar!.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('Warna: ${_selectedCar!.color}',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<Car>(
                  decoration: const InputDecoration(
                      hintText: 'Pilih mobil yang tersedia'),
                  items: store.availableCars
                      .map((car) => DropdownMenuItem(
                            value: car,
                            child: Text('${car.name} (${car.color})'),
                          ))
                      .toList(),
                  onChanged: (car) => setState(() => _selectedCar = car),
                  validator: (v) =>
                      v == null ? 'Pilih mobil terlebih dahulu' : null,
                ),
              const SizedBox(height: 16),

              // ── Nama Penyewa ─────────────────────────────────────────
              _label('Nama Penyewa'),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    hintText: 'Nama lengkap (opsional)',
                    prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 16),

              // ── No. Telepon ──────────────────────────────────────────
              _label('No. Telepon'),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    hintText: '08xxxxxxxxxx (opsional)',
                    prefixIcon: Icon(Icons.phone)),
              ),
              const SizedBox(height: 16),

              // ── Alamat ───────────────────────────────────────────────
              _label('Alamat'),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                    hintText: 'Alamat penyewa (opsional)',
                    prefixIcon: Icon(Icons.location_on)),
              ),
              const SizedBox(height: 20),

              // ── Durasi ───────────────────────────────────────────────
              _label('Durasi Penyewaan'),
              Card(
                elevation: 0,
                color: kPrimaryLight.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [15, 30, 45, 60, 90, 120].map((min) {
                          final selected = _durationMinutes == min;
                          return GestureDetector(
                            onTap: () => setState(() => _durationMinutes = min),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? kPrimary : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: selected
                                        ? kPrimary
                                        : Colors.grey.shade300),
                              ),
                              child: Text(
                                min < 60
                                    ? '${min}m'
                                    : '${min ~/ 60}j${min % 60 > 0 ? ' ${min % 60}m' : ''}',
                                style: TextStyle(
                                  color:
                                      selected ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: kPrimary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Slider(
                              value: _durationMinutes.toDouble(),
                              min: 15,
                              max: 180,
                              divisions: 11,
                              activeColor: kPrimary,
                              label: '$_durationMinutes menit',
                              onChanged: (v) =>
                                  setState(() => _durationMinutes = v.toInt()),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: kPrimary,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              '$_durationMinutes m',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Info Waktu ───────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.play_circle,
                          color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Text('Mulai: ${timeFmt.format(DateTime.now())}',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.stop_circle,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text('Selesai: ${timeFmt.format(_estimatedEnd)}',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.schedule, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Text('Durasi: $_durationMinutes menit',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Total Biaya ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [kPrimaryDark, kAccent]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Total Biaya',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      currFmt.format(_totalPrice),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_durationMinutes ~/ 15} sesi × ${currFmt.format(20000)}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Tombol Konfirmasi ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check, size: 22),
                  label: const Text('Konfirmasi Penyewaan',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      );
}
