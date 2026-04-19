import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_store.dart';
import '../models/car.dart';
import '../notification_service.dart';
import '../widgets/custom_app_bar.dart';
import '../main.dart';

class RentalFormScreen extends StatefulWidget {
  final String? carId;
  final String? initialName;
  final String? queueId;

  const RentalFormScreen({super.key, this.carId, this.initialName, this.queueId});

  @override
  State<RentalFormScreen> createState() => _RentalFormScreenState();
}

class _RentalFormScreenState extends State<RentalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: '.');
  final _phoneCtrl = TextEditingController(text: '.');
  final _addressCtrl = TextEditingController(text: '.');

  String? _selectedCarId;
  int _durationMinutes = 15;
  bool _isSaving = false;
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null && widget.initialName != '.') {
      _nameCtrl.text = widget.initialName!;
    }
    if (widget.carId != null) {
      _selectedCarId = widget.carId;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Car? _getSelectedCar(AppStore store) {
    if (_selectedCarId == null) return null;
    return store.getCarById(_selectedCarId!);
  }

  int _calculateTotalPrice(AppStore store) {
    final car = _getSelectedCar(store);
    if (_durationMinutes == 1 || car == null) return 0;
    return (_durationMinutes ~/ 15) * car.pricePer15Mins;
  }

  DateTime get _estimatedEnd => DateTime.now().add(Duration(minutes: _durationMinutes));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final store = context.read<AppStore>();
    final selectedCar = _getSelectedCar(store);

    if (selectedCar == null) {
      showSnackBarWithOK('Pilih mobil terlebih dahulu', backgroundColor: const Color(0xFFFFD180));
      return;
    }

    setState(() => _isSaving = true);

    try {
      String namaPenyewa = _nameCtrl.text.trim().isEmpty || _nameCtrl.text.trim() == '.' ? 'Penyewa' : _nameCtrl.text.trim();

      await store.addRental(
        car: selectedCar,
        renterName: _nameCtrl.text.trim().isEmpty ? '.' : _nameCtrl.text.trim(),
        renterPhone: _phoneCtrl.text.trim().isEmpty ? '.' : _phoneCtrl.text.trim(),
        renterAddress: _addressCtrl.text.trim().isEmpty ? '.' : _addressCtrl.text.trim(),
        durationMinutes: _durationMinutes,
        isPaid: _isPaid,
      );

      if (widget.queueId != null) {
        await store.removeQueue(widget.queueId!);
      }

      int alarmSeconds = _durationMinutes * 60;
      await NotificationService.scheduleNotification(
        id: selectedCar.id.hashCode,
        title: 'WAKTU HABIS! ⏰',
        body: 'Unit ${selectedCar.name} atas nama $namaPenyewa sudah selesai.',
        seconds: alarmSeconds,
      );

      if (mounted) {
        Navigator.pop(context);
        showSnackBarWithOK('Penyewaan berhasil!');
      }
    } catch (e) {
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
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final currFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final timeFmt = DateFormat('HH:mm', 'id_ID');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'FORM PENYEWAAN'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoDefault(),
              const SizedBox(height: 24),
              _label('PILIH MOBIL *'),
              _buildCarSelector(store),
              const SizedBox(height: 20),
              _label('NAMA PENYEWA'),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\.]'))],
                decoration: _neoInputDecoration('Nama lengkap (opsional)', Icons.person),
              ),
              const SizedBox(height: 20),
              _label('NO. TELEPON'),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                decoration: _neoInputDecoration('08xxxxxxxxxx (opsional)', Icons.phone),
              ),
              const SizedBox(height: 20),
              _label('DESKRIPSI ANAK'),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                decoration: _neoInputDecoration('Ciri-ciri anak (Cth: Baju merah)', Icons.child_care),
              ),
              const SizedBox(height: 24),
              _label('STATUS PEMBAYARAN'),
              Container(
                decoration: BoxDecoration(
                    color: _isPaid ? const Color(0xFFB9F6CA) : const Color(0xFFFF8A80),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)]),
                child: SwitchListTile(
                  title: const Text('SUDAH BAYAR?', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: Text(_isPaid ? 'PEMBAYARAN LUNAS' : 'BAYAR NANTI (HUTANG)', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 12)),
                  value: _isPaid,
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.black,
                  onChanged: (val) => setState(() => _isPaid = val),
                  secondary: Icon(_isPaid ? Icons.check_circle : Icons.warning_amber_rounded, color: Colors.black, size: 30),
                ),
              ),
              const SizedBox(height: 24),
              _label('DURASI PENYEWAAN'),
              _buildDurationPicker(),
              const SizedBox(height: 24),
              _buildTimeSummary(timeFmt),
              const SizedBox(height: 24),
              _buildPriceCard(currFmt, store),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoDefault() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFFFF59D), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black, width: 2)),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.black, size: 24), SizedBox(width: 12),
          Expanded(child: Text('Data penyewa otomatis diisi "." jika kosong.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black))),
        ],
      ),
    );
  }

  Widget _buildCarSelector(AppStore store) {
    List<Car> carList = List.from(store.availableCars);
    if (_selectedCarId != null && !carList.any((c) => c.id == _selectedCarId)) {
      Car? targetedCar = store.getCarById(_selectedCarId!);
      if (targetedCar != null) carList.add(targetedCar);
    }
    return DropdownButtonFormField<String?>(
      value: _selectedCarId,
      isExpanded: true, dropdownColor: Colors.white,
      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 16),
      hint: const Text('Pilih mobil...', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w900)),
      decoration: InputDecoration(
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
      ),
      items: carList.map((car) => DropdownMenuItem<String?>(
                value: car.id,
                child: Text('${car.name.toUpperCase()} ${!car.isAvailable ? "(DISEWA)" : ""}', style: TextStyle(color: car.isAvailable ? Colors.black : Colors.red), overflow: TextOverflow.ellipsis),
              )).toList(),
      onChanged: (val) => setState(() => _selectedCarId = val),
      validator: (v) => v == null ? 'Pilih mobil dahulu' : null,
    );
  }

  Widget _buildDurationPicker() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)]),
        child: Column(
          children: [
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [1, 15, 30, 45, 60, 90, 120].map((min) {
                final selected = _durationMinutes == min;
                return InkWell(
                  onTap: () => setState(() => _durationMinutes = min),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: selected ? (min == 1 ? const Color(0xFFFF8A80) : const Color(0xFF80DEEA)) : Colors.white,
                        border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8)),
                    child: Text(min == 1 ? '1M (TES)' : (min < 60 ? '${min}M' : '${min ~/ 60}J${min % 60 > 0 ? ' ${min % 60}M' : ''}'), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: const SliderThemeData(activeTrackColor: Colors.black, thumbColor: Color(0xFFEA80FC), trackHeight: 6), 
              child: Slider(
                value: _durationMinutes < 15 ? 15.0 : _durationMinutes.toDouble(),
                min: 15, max: 180, divisions: 11, label: '$_durationMinutes Menit',
                onChanged: (v) => setState(() => _durationMinutes = v.toInt()),
              ),
            ),
          ],
        ),
      );

  Widget _buildTimeSummary(DateFormat timeFmt) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF80DEEA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)]),
      child: Column(
        children: [
          Row(children: [const Icon(Icons.play_circle, color: Colors.black), const SizedBox(width: 8), Text('MULAI: ${timeFmt.format(DateTime.now())}', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black))]),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.stop_circle, color: Colors.black), const SizedBox(width: 8), Text('SELESAI: ${timeFmt.format(_estimatedEnd)}', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black))]),
        ],
      ),
    );
  }

  Widget _buildPriceCard(NumberFormat currFmt, AppStore store) {
    final car = _getSelectedCar(store);
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFEA80FC), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black, width: 4), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6), blurRadius: 0)]),
      child: Column(
        children: [
          const Text('TOTAL BIAYA', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14)),
          Text(currFmt.format(_calculateTotalPrice(store)), style: const TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w900)),
          Text('${_durationMinutes == 1 ? 0 : _durationMinutes ~/ 15} SESI × ${currFmt.format(car?.pricePer15Mins ?? 20000)}', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() => InkWell(
        onTap: _isSaving ? null : _save,
        child: Container(
          width: double.infinity, height: 64,
          decoration: BoxDecoration(
              color: _isSaving ? Colors.grey : const Color(0xFFB9F6CA), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: _isSaving ? null : const [BoxShadow(color: Colors.black, offset: Offset(5, 5), blurRadius: 0)]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSaving) const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black)) else const Icon(Icons.check_circle, color: Colors.black, size: 28),
              const SizedBox(width: 12),
              const Text('KONFIRMASI SEWA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
            ],
          ),
        ),
      );

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black87)));
}