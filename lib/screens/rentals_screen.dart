import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_store.dart';
import '../models/rental.dart';
import '../main.dart';
import 'rental_form_screen.dart';
import 'rental_detail_screen.dart';

class RentalsScreen extends StatefulWidget {
  const RentalsScreen({super.key});

  @override
  State<RentalsScreen> createState() => _RentalsScreenState();
}

class _RentalsScreenState extends State<RentalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _fabVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store  = context.watch<AppStore>();
    final active  = store.rentals.where((r) => r.status == 'active').toList();
    final history = store.rentals.where((r) => r.status != 'active').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Penyewaan'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'Aktif (${active.length})'),
            Tab(text: 'Riwayat (${history.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ScrollFABWrapper(
            onScrollDown: () => setState(() => _fabVisible = false),
            onScrollUp:   () => setState(() => _fabVisible = true),
            child: _RentalList(rentals: active, isActive: true),
          ),
          _ScrollFABWrapper(
            onScrollDown: () => setState(() => _fabVisible = false),
            onScrollUp:   () => setState(() => _fabVisible = true),
            child: _RentalList(rentals: history, isActive: false),
          ),
        ],
      ),

      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        offset: _fabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _fabVisible ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            onPressed: _fabVisible
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RentalFormScreen()),
                    )
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Buat Penyewaan'),
          ),
        ),
      ),
    );
  }
}

class _ScrollFABWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback onScrollDown;
  final VoidCallback onScrollUp;

  const _ScrollFABWrapper({
    required this.child,
    required this.onScrollDown,
    required this.onScrollUp,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          if (notification.scrollDelta != null) {
            if (notification.scrollDelta! > 0) {
              onScrollDown();
            } else {
              onScrollUp();
            }
          }
        }
        return false;
      },
      child: child,
    );
  }
}

class _RentalList extends StatelessWidget {
  final List<Rental> rentals;
  final bool isActive;
  const _RentalList({required this.rentals, required this.isActive});

  @override
  Widget build(BuildContext context) {
    if (rentals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? Icons.receipt_long_outlined : Icons.history,
                size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              isActive ? 'Tidak ada penyewaan aktif' : 'Belum ada riwayat',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final currFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final timeFmt = DateFormat('HH:mm', 'id_ID');

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: rentals.length,
      itemBuilder: (ctx, i) {
        final r           = rentals[i];
        final statusColor = r.status == 'active'
            ? Colors.orange
            : r.status == 'returned'
                ? Colors.green
                : Colors.red;
        final statusText  = r.status == 'active'
            ? 'Aktif'
            : r.status == 'returned'
                ? 'Selesai'
                : 'Dibatalkan';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (_) => RentalDetailScreen(rentalId: r.id)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(r.carName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(statusText,
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 15, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(r.renterName,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                      const SizedBox(width: 16),
                      const Icon(Icons.phone, size: 15, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(r.renterPhone,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 15, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${timeFmt.format(r.startTime)} → ${timeFmt.format(r.endTime)}  •  ${r.durationMinutes} menit',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(currFmt.format(r.totalPrice),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: kPrimary)),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
