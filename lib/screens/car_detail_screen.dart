import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_store.dart';
import '../main.dart';
import 'car_form_screen.dart';
import 'rental_form_screen.dart';

class CarDetailScreen extends StatelessWidget {
  final String carId;
  const CarDetailScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final car   = store.getCarById(carId);
    if (car == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Mobil')),
        body: const Center(child: Text('Mobil tidak ditemukan')),
      );
    }
    final cfmt       = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final timeFmt    = DateFormat('HH:mm', 'id_ID');
    final carRentals = store.rentals.where((r) => r.carId == carId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(car.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CarFormScreen(car: car)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: kPrimaryLight.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.directions_car, color: kPrimary, size: 72),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: car.isAvailable ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  car.isAvailable ? '✓ Tersedia untuk Disewa' : '⚠ Sedang Disewa',
                  style: TextStyle(
                      color: car.isAvailable ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _InfoRow(icon: Icons.label,        label: 'Nama',        value: car.name),
                    _InfoRow(icon: Icons.palette,      label: 'Warna',       value: car.color),
                    _InfoRow(icon: Icons.attach_money, label: 'Harga',       value: '${cfmt.format(20000)} / 15 menit'),
                    if (car.note.isNotEmpty)
                      _InfoRow(icon: Icons.notes,     label: 'Keterangan',  value: car.note),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Riwayat Penyewaan (${carRentals.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (carRentals.isEmpty)
              const Center(
                  child: Text('Belum pernah disewa',
                      style: TextStyle(color: Colors.grey)))
            else
              ...carRentals.map((r) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: kPrimary),
                      title: Text(r.renterName),
                      subtitle: Text(
                          '${r.durationMinutes} menit • ${timeFmt.format(r.startTime)}–${timeFmt.format(r.endTime)}'),
                      trailing: Text(cfmt.format(r.totalPrice),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: kPrimary)),
                    ),
                  )),
          ],
        ),
      ),
      bottomNavigationBar: car.isAvailable
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RentalFormScreen(carId: carId)),
                ),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Sewakan Mobil Ini',
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          : null,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kPrimary, size: 20),
          const SizedBox(width: 12),
          Text('$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.grey)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
