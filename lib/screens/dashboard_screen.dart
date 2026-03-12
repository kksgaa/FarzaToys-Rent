import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_store.dart';
import '../main.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final currFmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final totalRevenue =
        store.rentals.fold<double>(0, (s, r) => s + r.totalPrice);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('🚗 ToyCar Rental'),
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            expandedHeight: 140,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text('Ringkasan',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _StatCard(
                            icon: Icons.directions_car,
                            label: 'Total Mobil',
                            value: store.cars.length.toString(),
                            color: Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatCard(
                            icon: Icons.check_circle,
                            label: 'Tersedia',
                            value: store.availableCars.length.toString(),
                            color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _StatCard(
                            icon: Icons.receipt_long,
                            label: 'Aktif Disewa',
                            value: store.activeRentals.length.toString(),
                            color: Colors.orange)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatCard(
                            icon: Icons.attach_money,
                            label: 'Total Pendapatan',
                            value: currFmt.format(totalRevenue),
                            color: kPrimary,
                            small: true)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Penyewaan Terbaru',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (store.rentals.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Belum ada penyewaan',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ...store.rentals.reversed
                      .take(5)
                      .map((r) => _RecentRentalCard(rental: r)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool small;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color,
      this.small = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: small ? 13 : 22, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _RecentRentalCard extends StatelessWidget {
  final dynamic rental;
  const _RecentRentalCard({required this.rental});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm', 'id_ID');
    final dateFmt = DateFormat('dd MMM', 'id_ID');
    final cfmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    Color statusColor = rental.status == 'active'
        ? Colors.orange
        : rental.status == 'returned'
            ? Colors.green
            : Colors.red;
    String statusText = rental.status == 'active'
        ? 'Aktif'
        : rental.status == 'returned'
            ? 'Selesai'
            : 'Dibatalkan';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kPrimaryLight.withValues(alpha: 0.3),
          child: const Icon(Icons.directions_car, color: kPrimary),
        ),
        title: Text(rental.carName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${rental.renterName} • ${dateFmt.format(rental.startTime)} ${timeFmt.format(rental.startTime)}–${timeFmt.format(rental.endTime)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(cfmt.format(rental.totalPrice),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(statusText,
                  style: TextStyle(color: statusColor, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}
