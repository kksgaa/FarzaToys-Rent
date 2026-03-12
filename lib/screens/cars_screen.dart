import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_store.dart';
import '../models/car.dart';
import '../main.dart';
import 'car_form_screen.dart';
import 'car_detail_screen.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  bool _fabVisible = true;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Mobil'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text('${store.cars.length} unit',
                style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: store.isLoading
          ? const Center(child: CircularProgressIndicator())
          : store.cars.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car_outlined,
                          size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Belum ada mobil',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Tap + untuk menambah mobil',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification &&
                        notification.scrollDelta != null) {
                      if (notification.scrollDelta! > 0 && _fabVisible) {
                        setState(() => _fabVisible = false);
                      } else if (notification.scrollDelta! < 0 && !_fabVisible) {
                        setState(() => _fabVisible = true);
                      }
                    }
                    return false;
                  },
                  child: RefreshIndicator(
                    onRefresh: () => store.loadCars(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: store.cars.length,
                      itemBuilder: (ctx, i) {
                        final car = store.cars[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        CarDetailScreen(carId: car.id))),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60, height: 60,
                                    decoration: BoxDecoration(
                                      color: kPrimaryLight.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.directions_car,
                                        color: kPrimary, size: 34),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(car.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        Text('Warna: ${car.color}',
                                            style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13)),
                                        const SizedBox(height: 4),
                                        const Text('Rp 20.000 / 15 menit',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: kPrimary)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: car.isAvailable
                                              ? Colors.green.shade50
                                              : Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          car.isAvailable ? 'Tersedia' : 'Disewa',
                                          style: TextStyle(
                                            color: car.isAvailable
                                                ? Colors.green
                                                : Colors.orange,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20),
                                            onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        CarFormScreen(car: car))),
                                            style: IconButton.styleFrom(
                                                backgroundColor: Colors.blue.shade50),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          const SizedBox(width: 4),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20),
                                            onPressed: () =>
                                                _confirmDelete(context, store, car),
                                            style: IconButton.styleFrom(
                                                backgroundColor: Colors.red.shade50,
                                                foregroundColor: Colors.red),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        offset: _fabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _fabVisible ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            onPressed: _fabVisible
                ? () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CarFormScreen()))
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Mobil'),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppStore store, Car car) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Mobil?'),
        content: Text('Apakah Anda yakin ingin menghapus "${car.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await store.deleteCar(car.id);
              showSnackBarWithOK('${car.name} berhasil dihapus');
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