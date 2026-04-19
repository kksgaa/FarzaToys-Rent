import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_store.dart';
import '../models/rental.dart';
import 'rental_form_screen.dart';
import 'rental_detail_screen.dart';
import 'register_screen.dart';
import '../notification_service.dart';
import '../main.dart';

class RentalsScreen extends StatefulWidget {
  const RentalsScreen({super.key});

  @override
  State<RentalsScreen> createState() => _RentalsScreenState();
}

class _RentalsScreenState extends State<RentalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      cancelText: 'BATAL',
      confirmText: 'PILIH',
      helpText: 'PILIH RENTANG TANGGAL',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDateRange = picked);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final activeRentals = store.activeRentals.toList();
    final pastRentals = store.rentals.where((r) => r.status != 'active').toList();
    final queues = store.queues.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MANAJEMEN SEWA', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFEB3B),
        elevation: 0,
        actions: const [CustomAppBarActions()], 
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Column(
            children: [
              Container(color: Colors.black, height: 4.0),
              TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                indicator: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                tabs: [
                  Tab(text: 'AKTIF (${activeRentals.length})'),
                  Tab(text: 'ANTREAN (${queues.length})'),
                  Tab(text: 'RIWAYAT (${pastRentals.length})'),
                ],
              ),
              Container(color: Colors.black, height: 4.0),
            ],
          ),
        ),
      ),
      body: store.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActiveList(activeRentals, store),
                _buildQueueTab(context, store),
                _buildPastList(pastRentals, store),
              ],
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)],
        ),
        child: FloatingActionButton(
          backgroundColor: _tabController.index == 0 ? const Color(0xFFB9F6CA) : _tabController.index == 1 ? const Color(0xFFFFF59D) : const Color(0xFF80DEEA),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          onPressed: () {
            if (_tabController.index == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RentalFormScreen()));
            } else if (_tabController.index == 1) {
              _showAddQueueDialog(context, store);
            } else if (_tabController.index == 2) {
              _selectDateRange();
            }
          },
          child: Icon(_tabController.index == 0 ? Icons.add : _tabController.index == 1 ? Icons.person_add : Icons.filter_alt, color: Colors.black, size: 30),
        ),
      ),
    );
  }

  Widget _buildActiveList(List<Rental> rentals, AppStore store) {
    if (rentals.isEmpty) return _buildEmptyState('TIDAK ADA SEWAAN AKTIF', Icons.receipt_long);
    final timeFmt = DateFormat('HH:mm', 'id_ID');
    final cfmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return RefreshIndicator(
      color: Colors.black,
      onRefresh: () => store.loadRentals(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        itemCount: rentals.length,
        itemBuilder: (ctx, i) {
          final rental = rentals[i];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RentalDetailScreen(rentalId: rental.id))),
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6), blurRadius: 0)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF59D), borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
                      border: Border(bottom: BorderSide(color: Colors.black, width: 3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(rental.carName.toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black))),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF80DEEA), border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8)),
                              child: Text('${rental.durationMinutes} MNT', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 10)),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _confirmPaymentUpdate(context, store, rental),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: rental.isPaid ? const Color(0xFFB9F6CA) : const Color(0xFFFF8A80),
                                  border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0)],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!rental.isPaid) const Icon(Icons.touch_app, size: 12, color: Colors.black),
                                    if (!rental.isPaid) const SizedBox(width: 4),
                                    Text(rental.isPaid ? 'LUNAS' : 'BELUM', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              const Icon(Icons.child_care, size: 20, color: Colors.black), const SizedBox(width: 8),
                              Text(rental.renterName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black))
                            ]),
                            Text(cfmt.format(rental.totalPrice), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('MULAI: ${timeFmt.format(rental.startTime)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black54)),
                            Text('SELESAI: ${timeFmt.format(rental.endTime)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        StreamBuilder(
                            stream: Stream.periodic(const Duration(seconds: 1)),
                            builder: (context, snapshot) {
                              final now = DateTime.now();
                              final totalSecs = rental.durationMinutes * 60;
                              final elapsedSecs = now.difference(rental.startTime).inSeconds;
                              double progress = totalSecs > 0 ? (elapsedSecs / totalSecs).clamp(0.0, 1.0) : 1.0;
                              final isOvertime = now.isAfter(rental.endTime);
                              final remaining = rental.endTime.difference(now);
                              String timeText = remaining.isNegative ? "WAKTU HABIS!" : "${remaining.inMinutes}m ${remaining.inSeconds % 60}s";
                              return Container(
                                height: 24, width: double.infinity,
                                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(12)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(children: [
                                    FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: progress, child: Container(color: isOvertime ? const Color(0xFFFF8A80) : const Color(0xFF80DEEA))),
                                    Center(child: Text(isOvertime ? 'WAKTU HABIS!' : timeText.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black))),
                                  ]),
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black, width: 3))),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _showExtendDialog(context, store, rental),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: const Color(0xFF80DEEA), border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0)]),
                              child: const Center(child: Text('+ WAKTU', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => _confirmReturn(context, store, rental),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: const Color(0xFFB9F6CA), border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0)]),
                              child: const Center(child: Text('SELESAI', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQueueTab(BuildContext context, AppStore store) {
    if (store.queues.isEmpty) return _buildEmptyState('TIDAK ADA ANTREAN', Icons.people_alt_outlined);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      itemCount: store.queues.length,
      itemBuilder: (itemCtx, index) {
        final q = store.queues[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)]),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFFFFF59D), border: Border.all(color: Colors.black, width: 2), shape: BoxShape.circle),
              child: Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black))),
            ),
            title: Text(q.renterName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('DATANG: ${DateFormat('HH:mm', 'id_ID').format(q.queuedAt)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                Text('INCAR: ${q.targetCarName?.toUpperCase() ?? 'APA SAJA'}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 12)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    if (q.targetCarId != null) {
                      final isStillRented = store.activeRentals.any((r) => r.carId == q.targetCarId);
                      if (isStillRented) {
                        _showCarStillRentedDialog(context, q.targetCarName);
                        return;
                      }
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (_) => RentalFormScreen(carId: q.targetCarId, initialName: q.renterName, queueId: q.id)));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFB9F6CA), border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.play_arrow, color: Colors.black, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => store.removeQueue(q.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFFF8A80), border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCarStillRentedDialog(BuildContext context, String? carName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black, width: 3)),
        title: Row(
          children: [
            const Icon(Icons.block, color: Color(0xFFFF8A80), size: 28), const SizedBox(width: 10),
            const Expanded(child: Text('MOBIL BELUM BISA DISEWA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFFF8A80), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black, width: 2)),
              child: Row(
                children: [
                  const Icon(Icons.directions_car, color: Colors.black, size: 28), const SizedBox(width: 10),
                  Expanded(child: Text('${carName?.toUpperCase() ?? 'MOBIL INI'} MASIH DALAM STATUS SEWA AKTIF.', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 13))),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('Tunggu hingga penyewaan saat ini selesai, baru bisa memulai sewa baru untuk mobil ini.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFF59D), foregroundColor: Colors.black, side: const BorderSide(color: Colors.black, width: 2), elevation: 0),
            child: const Text('MENGERTI', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildPastList(List<Rental> rentals, AppStore store) {
    List<Rental> filteredRentals = rentals;
    if (_selectedDateRange != null) {
      final start = DateUtils.dateOnly(_selectedDateRange!.start);
      final end = DateUtils.dateOnly(_selectedDateRange!.end).add(const Duration(days: 1, milliseconds: -1));
      filteredRentals = rentals.where((r) => (r.startTime.isAfter(start) || r.startTime.isAtSameMomentAs(start)) && r.startTime.isBefore(end)).toList();
    }
    if (filteredRentals.isEmpty && _selectedDateRange == null) return _buildEmptyState('BELUM ADA RIWAYAT', Icons.history);

    Map<String, List<Rental>> grouped = {};
    final dateFmt = DateFormat('yyyy-MM-dd');
    for (var r in filteredRentals) {
      final key = dateFmt.format(r.startTime);
      grouped.putIfAbsent(key, () => []).add(r);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        if (_selectedDateRange != null)
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFFFD180), border: Border.all(color: Colors.black, width: 3), borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.filter_alt, color: Colors.black, size: 20), const SizedBox(width: 8),
                  Text('${DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDateRange!.end)}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 11)),
                ]),
                InkWell(onTap: () => setState(() => _selectedDateRange = null), child: const Icon(Icons.close, color: Colors.black, size: 20)),
              ],
            ),
          ),
        Expanded(
          child: filteredRentals.isEmpty
              ? _buildEmptyState('TIDAK ADA DATA DI TANGGAL INI', Icons.event_busy)
              : RefreshIndicator(
                  color: Colors.black,
                  onRefresh: () => store.loadRentals(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    itemCount: sortedKeys.length,
                    itemBuilder: (ctx, i) {
                      final dateKey = sortedKeys[i];
                      final dateItems = grouped[dateKey]!;
                      final displayDate = DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(DateTime.parse(dateKey));
                      int dailyTotal = dateItems.fold(0, (sum, item) => (item.status == 'returned' && item.isPaid) ? sum + item.totalPrice : sum);
                      final cfmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                      final timeFmt = DateFormat('HH:mm', 'id_ID');

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 16), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(displayDate.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13)),
                                Text(cfmt.format(dailyTotal), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFB9F6CA), fontSize: 13)),
                              ],
                            ),
                          ),
                          ...dateItems.map((rental) {
                            final carData = store.getCarById(rental.carId);
                            final imageUrl = carData?.imageUrl;
                            return GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RentalDetailScreen(rentalId: rental.id))),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)]),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 80, height: 60,
                                            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8)),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: (imageUrl != null && imageUrl.trim().isNotEmpty) ? Image.network(imageUrl, fit: BoxFit.cover, width: 80, height: 60, errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.broken_image, color: Colors.black))) : const Center(child: Icon(Icons.directions_car, color: Colors.black, size: 36)),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(rental.carName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black)),
                                                const SizedBox(height: 4),
                                                Text('${rental.renterName}\n${rental.durationMinutes} MNT • ${timeFmt.format(rental.startTime)}–${timeFmt.format(rental.endTime)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(cfmt.format(rental.totalPrice), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black)),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(color: rental.isPaid ? const Color(0xFFB9F6CA) : const Color(0xFFFF8A80), border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(6)),
                                                child: Text(rental.isPaid ? 'LUNAS' : 'HUTANG', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!rental.isPaid)
                                      InkWell(
                                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(9)),
                                        onTap: () => _confirmLunasHistory(context, store, rental),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: const BoxDecoration(color: Color(0xFFFF8A80), border: Border(top: BorderSide(color: Colors.black, width: 3)), borderRadius: BorderRadius.vertical(bottom: Radius.circular(9))),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [Icon(Icons.payment, color: Colors.black, size: 18), SizedBox(width: 8), Text('TANDAI LUNAS', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 13))],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _confirmLunasHistory(BuildContext context, AppStore store, Rental rental) {
    final cfmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black, width: 3)),
        title: const Row(children: [Icon(Icons.payment, color: Colors.black, size: 24), SizedBox(width: 8), Text('TANDAI LUNAS', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black))]),
        content: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tandai penyewaan "${rental.carName.toUpperCase()}" atas nama ${rental.renterName.toUpperCase()} sebagai LUNAS?', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFFF59D), border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [const Icon(Icons.attach_money, color: Colors.black), const SizedBox(width: 8), Text(cfmt.format(rental.totalPrice), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black))]),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('BATAL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try { await store.updatePaymentStatus(rental.id, true); showSnackBarWithOK('Pembayaran berhasil dicatat sebagai LUNAS!'); } catch (e) { showSnackBarWithOK(e.toString(), backgroundColor: const Color(0xFFFF8A80)); }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB9F6CA), foregroundColor: Colors.black, side: const BorderSide(color: Colors.black, width: 2), elevation: 0),
            child: const Text('YA, LUNAS', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32), padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: const Color(0xFFE0E0E0), border: Border.all(color: Colors.black, width: 3), borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6), blurRadius: 0)]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: Colors.black), const SizedBox(height: 16),
            Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _confirmReturn(BuildContext context, AppStore store, Rental rental) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black, width: 3)),
        title: const Text('KONFIRMASI SELESAI', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Akhiri penyewaan "${rental.carName.toUpperCase()}"?', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            if (!rental.isPaid) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFF8A80), border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8)),
                child: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.black), SizedBox(width: 8), Expanded(child: Text('BELUM BAYAR!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)))]),
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
                await store.returnCar(rental.id); showSnackBarWithOK('Penyewaan Selesai (Masih Ngutang)');
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

  void _confirmPaymentUpdate(BuildContext context, AppStore store, Rental rental) {
    if (rental.isPaid) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black, width: 3)),
        title: const Text('UPDATE PEMBAYARAN', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
        content: Text('Tandai penyewaan "${rental.carName.toUpperCase()}" sebagai LUNAS?', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('BATAL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try { await store.updatePaymentStatus(rental.id, true); showSnackBarWithOK('Pembayaran berhasil diperbarui!'); } catch (e) { showSnackBarWithOK(e.toString(), backgroundColor: const Color(0xFFFF8A80)); }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB9F6CA), foregroundColor: Colors.black, side: const BorderSide(color: Colors.black, width: 2), elevation: 0),
            child: const Text('YA, LUNAS', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showExtendDialog(BuildContext context, AppStore store, Rental rental) {
    int selectedMins = 15;
    final priceCtrl = TextEditingController();
    final carData = store.getCarById(rental.carId);
    final carPrice = carData?.pricePer15Mins ?? 20000;

    void updatePrice(int mins) => priceCtrl.text = ((mins ~/ 15) * carPrice).toString();
    updatePrice(selectedMins);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSB) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black, width: 3)),
          title: const Text('TAMBAH WAKTU SEWA', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('MOBIL: ${rental.carName.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black87)),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'DURASI TAMBAHAN', labelStyle: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black54),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
                ),
                dropdownColor: Colors.white, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                value: selectedMins, 
                items: [15, 30, 45, 60, 90, 120].map((m) => DropdownMenuItem(value: m, child: Text('$m Menit', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black)))).toList(),
                onChanged: (val) { if (val != null) { setStateSB(() => selectedMins = val); updatePrice(val); } },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceCtrl, keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'BIAYA TAMBAHAN', labelStyle: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black54),
                  prefixText: 'Rp ', filled: true, fillColor: const Color(0xFFFFF59D),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('BATAL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
            ElevatedButton(
              onPressed: () async {
                final cleanStr = priceCtrl.text.replaceAll('.', '').replaceAll(',', '');
                final price = int.tryParse(cleanStr) ?? 0;
                Navigator.pop(ctx);
                try {
                  await store.extendRentalTime(rental.id, selectedMins, price);
                  final updatedRental = store.getRentalById(rental.id);
                  if (updatedRental != null) {
                    final remainingSeconds = updatedRental.endTime.difference(DateTime.now()).inSeconds;
                    if (remainingSeconds > 0) {
                      await NotificationService.scheduleNotification(id: rental.carId.hashCode, title: 'WAKTU HABIS! ⏰', body: 'Unit ${rental.carName} atas nama ${rental.renterName} sudah selesai.', seconds: remainingSeconds);
                    }
                  }
                  showSnackBarWithOK('Waktu berhasil ditambah!');
                } catch (e) { showSnackBarWithOK(e.toString(), backgroundColor: const Color(0xFFFF8A80)); }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF80DEEA), foregroundColor: Colors.black, side: const BorderSide(color: Colors.black, width: 2), elevation: 0),
              child: const Text('SIMPAN', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddQueueDialog(BuildContext context, AppStore store) {
    final nameCtrl = TextEditingController();
    String? selectedCarId;
    String? selectedCarName;
    final selectableCars = store.cars.where((car) {
      final isRented = store.activeRentals.any((r) => r.carId == car.id);
      return car.isAvailable || isRented;
    }).toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.black, width: 3)),
          title: const Text('TAMBAH ANTREAN', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl, textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\.]'))],
                decoration: InputDecoration(
                  labelText: 'NAMA PENYEWA', labelStyle: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black54),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                isExpanded: true, hint: const Text('APA SAJA', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w900)),
                decoration: InputDecoration(
                  labelText: 'INCAR MOBIL (OPSIONAL)', labelStyle: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black54),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
                ),
                dropdownColor: Colors.white, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                value: selectedCarId,
                items: selectableCars.map((car) {
                  final isRented = store.activeRentals.any((r) => r.carId == car.id);
                  return DropdownMenuItem(value: car.id, child: Text('${car.name.toUpperCase()} ${isRented ? "(DISEWA)" : ""}', overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, color: isRented ? Colors.orange : Colors.black)));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCarId = val;
                    selectedCarName = val != null ? store.cars.firstWhere((c) => c.id == val).name : null;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('BATAL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
            ElevatedButton(
              onPressed: () {
                final inputName = nameCtrl.text.trim();
                final finalName = inputName.isEmpty ? "." : inputName;
                store.addQueue(finalName, targetCarId: selectedCarId, targetCarName: selectedCarName);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFF59D), foregroundColor: Colors.black, side: const BorderSide(color: Colors.black, width: 2), elevation: 0),
              child: const Text('SIMPAN', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      }),
    );
  }
}

class CustomAppBarActions extends StatelessWidget {
  const CustomAppBarActions({super.key});
  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final isAdmin = currentUser?.email == 'admin@gmail.com';
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black, size: 28),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.black, width: 2)),
      onSelected: (String value) {
        if (value == 'register') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
        } else if (value == 'logout') {
          _confirmLogoutMenu(context);
        }
      },
      itemBuilder: (BuildContext context) {
        final List<PopupMenuEntry<String>> menuItems = [];
        if (isAdmin) {
          menuItems.add(const PopupMenuItem<String>(value: 'register', child: Row(children: [Icon(Icons.manage_accounts, color: Colors.black), SizedBox(width: 8), Text('Kelola Akun', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black))])));
        }
        menuItems.add(const PopupMenuItem<String>(value: 'logout', child: Row(children: [Icon(Icons.logout, color: Colors.redAccent), SizedBox(width: 8), Text('Keluar', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.redAccent))])));
        return menuItems;
      },
    );
  }

  void _confirmLogoutMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black, width: 3)),
        title: const Text('KELUAR?', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
        content: const Text('Yakin ingin keluar dari akun ini?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('BATAL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Supabase.instance.client.auth.signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A80), foregroundColor: Colors.black, side: const BorderSide(color: Colors.black, width: 2), elevation: 0),
            child: const Text('KELUAR', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}