import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_store.dart';
import '../widgets/custom_app_bar.dart';
import '../main.dart'; 

class RentalDetailScreen extends StatelessWidget {
  final String rentalId;
  const RentalDetailScreen({super.key, required this.rentalId});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final rental = store.getRentalById(rentalId);

    if (rental == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(title: 'DETAIL PENYEWAAN'),
        body: Center(child: Text('Data penyewaan tidak ditemukan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
      );
    }

    final carData = store.getCarById(rental.carId);
    final currFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final timeFmt = DateFormat('HH:mm', 'id_ID');
    final dateFmt = DateFormat('dd MMMM yyyy', 'id_ID');

    final statusColor = rental.status == 'active' ? const Color(0xFFFFD180) : rental.status == 'returned' ? const Color(0xFFB9F6CA) : const Color(0xFFFF8A80); 
    final statusText = rental.status == 'active' ? 'AKTIF' : rental.status == 'returned' ? 'SELESAI' : 'DIBATALKAN';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'DETAIL PENYEWAAN'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF80DEEA), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black, width: 4), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6), blurRadius: 0)]),
              child: Column(
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black, width: 3)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: (carData?.imageUrl != null && carData!.imageUrl!.trim().isNotEmpty)
                          ? Image.network(carData.imageUrl!, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, color: Colors.black, size: 50))
                          : const Icon(Icons.directions_car, color: Colors.black, size: 60),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(rental.carName.toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                  Text('WARNA: ${carData?.color.toUpperCase() ?? '-'}', style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: statusColor, border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8)),
                    child: Text(statusText, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            const Text('INFORMASI PENYEWA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFFFF59D), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)]),
              child: Column(
                children: [
                  _InfoRow(icon: Icons.person, label: 'NAMA', value: rental.renterName.toUpperCase()),
                  _InfoRow(icon: Icons.phone, label: 'TELEPON', value: rental.renterPhone.toUpperCase()),
                  _InfoRow(icon: Icons.child_care, label: 'ANAK', value: rental.renterAddress.toUpperCase()),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            const Text('INFORMASI PENYEWAAN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)]),
              child: Column(
                children: [
                  _InfoRow(icon: Icons.calendar_today, label: 'TANGGAL', value: dateFmt.format(rental.startTime).toUpperCase()),
                  _InfoRow(icon: Icons.play_circle, label: 'MULAI', value: timeFmt.format(rental.startTime)),
                  _InfoRow(icon: Icons.stop_circle, label: 'SELESAI', value: timeFmt.format(rental.endTime)),
                  _InfoRow(icon: Icons.schedule, label: 'DURASI', value: '${rental.durationMinutes} MENIT'),
                  const Divider(color: Colors.black, thickness: 2, height: 32),
                  _InfoRow(icon: Icons.attach_money, label: 'TOTAL HARGA', value: currFmt.format(rental.totalPrice), highlight: true),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: rental.isPaid ? const Color(0xFFB9F6CA) : const Color(0xFFFF8A80), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black, width: 2)),
                        child: Icon(rental.isPaid ? Icons.check : Icons.close, color: Colors.black, size: 16),
                      ),
                      const SizedBox(width: 12),
                      const Text('PEMBAYARAN: ', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black54)),
                      Text(rental.isPaid ? 'LUNAS' : 'BELUM BAYAR', style: TextStyle(fontWeight: FontWeight.w900, color: rental.isPaid ? Colors.green.shade700 : Colors.red.shade700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            if (rental.status == 'active') ...[
              InkWell(
                onTap: () => _confirmReturn(context, store, rental),
                child: Container(
                  width: double.infinity, height: 56,
                  decoration: BoxDecoration(color: const Color(0xFFB9F6CA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)]),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.black), SizedBox(width: 8), Text('TANDAI SELESAI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0))]),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _confirmDelete(context, store, rental),
                child: Container(
                  width: double.infinity, height: 56,
                  decoration: BoxDecoration(color: const Color(0xFFFF8A80), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)]),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cancel, color: Colors.black), SizedBox(width: 8), Text('BATALKAN PENYEWAAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0))]),
                ),
              ),
            ] else ...[
              InkWell(
                onTap: () => _confirmDelete(context, store, rental),
                child: Container(
                  width: double.infinity, height: 56,
                  decoration: BoxDecoration(color: const Color(0xFFFF8A80), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)]),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.delete_forever, color: Colors.black), SizedBox(width: 8), Text('HAPUS RIWAYAT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0))]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmReturn(BuildContext context, AppStore store, dynamic rental) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black, width: 3)),
        title: const Text('KONFIRMASI SELESAI', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tandai "${rental.carName.toUpperCase()}" sebagai sudah selesai disewa?', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            if (!rental.isPaid) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFF8A80), border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.black), SizedBox(width: 8),
                    Expanded(child: Text('BELUM BAYAR!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
                  ],
                ),
              ),
            ]
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('BATAL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
          if (!rental.isPaid)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await store.returnCar(rental.id);
                showSnackBarWithOK('Penyewaan Selesai (Masih Ngutang)');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, side: const BorderSide(color: Colors.black, width: 2), elevation: 0),
              child: const Text('TETAP NGUTANG', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (!rental.isPaid) await store.updatePaymentStatus(rental.id, true); 
              await store.returnCar(rental.id);
              showSnackBarWithOK(rental.isPaid ? 'Penyewaan Selesai!' : 'Penyewaan Selesai & LUNAS!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB9F6CA), foregroundColor: Colors.black, side: const BorderSide(color: Colors.black, width: 2), elevation: 0),
            child: Text(!rental.isPaid ? 'LUNAS & SELESAI' : 'YA, SELESAI', style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppStore store, dynamic rental) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black, width: 3)),
        title: Text(rental.status == 'active' ? 'BATALKAN PENYEWAAN?' : 'HAPUS RIWAYAT?', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
        content: const Text('Data penyewaan ini akan dihapus secara permanen.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('BATAL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              Navigator.pop(context);
              await store.deleteRental(rental.id);
              showSnackBarWithOK('Data berhasil dihapus');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A80), foregroundColor: Colors.black, side: const BorderSide(color: Colors.black, width: 2), elevation: 0),
            child: const Text('HAPUS', style: TextStyle(fontWeight: FontWeight.w900)),
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
  
  const _InfoRow({required this.icon, required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final iconBg = highlight ? const Color(0xFFEA80FC) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black, width: 2)),
            child: Icon(icon, color: Colors.black, size: 16),
          ),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black54)),
          Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: highlight ? 20 : 14, color: Colors.black))),
        ],
      ),
    );
  }
}