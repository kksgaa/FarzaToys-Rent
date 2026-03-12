import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_store.dart';
import '../models/rental.dart';
import '../main.dart';

class RentalDetailScreen extends StatelessWidget {
  final String rentalId;
  const RentalDetailScreen({super.key, required this.rentalId});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final rental = store.getRentalById(rentalId);

    if (rental == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Penyewaan')),
        body: const Center(child: Text('Data penyewaan tidak ditemukan')),
      );
    }

    final currFmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final timeFmt = DateFormat('HH:mm', 'id_ID');
    final dateFmt = DateFormat('dd MMMM yyyy', 'id_ID');

    final statusColor = rental.status == 'active'
        ? Colors.orange
        : rental.status == 'returned'
            ? Colors.green
            : Colors.red;
    final statusText = rental.status == 'active'
        ? 'Aktif'
        : rental.status == 'returned'
            ? 'Selesai'
            : 'Dibatalkan';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Penyewaan'),
        actions: [
          if (rental.status == 'active')
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, store, rental),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kPrimaryDark, kAccent]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.directions_car,
                      color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(rental.carName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  Text('Warna: ${rental.car?.color ?? '-'}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(statusText,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Informasi Penyewa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _InfoRow(
                        icon: Icons.person,
                        label: 'Nama',
                        value: rental.renterName),
                    _InfoRow(
                        icon: Icons.phone,
                        label: 'Telepon',
                        value: rental.renterPhone),
                    _InfoRow(
                        icon: Icons.location_on,
                        label: 'Alamat',
                        value: rental.renterAddress),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Informasi Penyewaan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _InfoRow(
                        icon: Icons.calendar_today,
                        label: 'Tanggal',
                        value: dateFmt.format(rental.startTime)),
                    _InfoRow(
                        icon: Icons.play_circle,
                        label: 'Mulai',
                        value: timeFmt.format(rental.startTime)),
                    _InfoRow(
                        icon: Icons.stop_circle,
                        label: 'Selesai',
                        value: timeFmt.format(rental.endTime)),
                    _InfoRow(
                        icon: Icons.schedule,
                        label: 'Durasi',
                        value:
                            '${rental.durationMinutes} menit (${rental.sessions} sesi)'),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.attach_money,
                      label: 'Total',
                      value:
                          '${rental.sessions} sesi × ${currFmt.format(20000)} = ${currFmt.format(rental.totalPrice)}',
                      highlight: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (rental.status == 'active') ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmReturn(context, store, rental),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Tandai Selesai',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context, store, rental),
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text('Batalkan Penyewaan',
                      style: TextStyle(fontSize: 16, color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmReturn(BuildContext context, AppStore store, Rental rental) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Selesai'),
        content: Text(
            'Tandai "${rental.carName}" sebagai sudah selesai disewa?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await store.returnCar(rental.id);
              showSnackBarWithOK('Penyewaan selesai!',
                  backgroundColor: Colors.green);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppStore store, Rental rental) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Penyewaan?'),
        content: const Text('Data penyewaan ini akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              Navigator.pop(context);
              await store.deleteRental(rental.id);
              showSnackBarWithOK('Penyewaan berhasil dihapus');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.highlight = false});

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
            child: Text(
              value,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                fontSize: highlight ? 15 : 14,
                color: highlight ? kPrimary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
