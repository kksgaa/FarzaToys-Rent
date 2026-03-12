import 'package:flutter/foundation.dart';
import 'models/car.dart';
import 'models/rental.dart';
import 'services/supabase_service.dart';

class AppStore extends ChangeNotifier {
  AppStore();

  List<Car> _cars = [];
  List<Rental> _rentals = [];
  bool _isLoading = false; 

  List<Car> get cars => List.unmodifiable(_cars);
  List<Car> get availableCars => _cars.where((c) => c.isAvailable).toList();
  List<Rental> get rentals => List.unmodifiable(_rentals);
  List<Rental> get activeRentals =>
      _rentals.where((r) => r.status == 'active').toList();
  bool get isLoading => _isLoading;

  // Load data
Future<void> loadAll() async {
  _isLoading = true;
  notifyListeners();
  try {
    _cars    = await SupabaseService.fetchCars();
    _rentals = await SupabaseService.fetchRentals();
  } catch (e) {
    debugPrint('Error loading data: $e');
  }
  _isLoading = false;
  notifyListeners();
}

Future<void> loadCars() async {
  _cars = await SupabaseService.fetchCars();
  notifyListeners();
}

Future<void> loadRentals() async {
  _rentals = await SupabaseService.fetchRentals();
  notifyListeners();
}

  // ── Cars CRUD ─────────────────────────────────────────────────────────────
  Future<void> addCar(Car car) async {
    final newCar = await SupabaseService.addCar(car);
    _cars.add(newCar);
    notifyListeners();
  }

  Future<void> updateCar(Car updatedCar) async {
    final updated = await SupabaseService.updateCar(updatedCar);
    final index = _cars.indexWhere((c) => c.id == updatedCar.id);
    if (index != -1) {
      _cars[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteCar(String carId) async {
    await SupabaseService.deleteCar(carId);
    _cars.removeWhere((c) => c.id == carId);
    notifyListeners();
  }

  Car? getCarById(String id) {
    try {
      return _cars.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Rentals CRUD ──────────────────────────────────────────────────────────
  Future<void> addRental({
    required Car car,
    required String renterName,
    required String renterPhone,
    required String renterAddress,
    required int durationMinutes,
  }) async {
    final rental = Rental(
      id:              '',
      carId:           car.id,    
      carName:         car.name,  
      renterName:      renterName,
      renterPhone:     renterPhone,
      renterAddress:   renterAddress,
      startTime:       DateTime.now(),
      durationMinutes: durationMinutes,
    );
    final newRental = await SupabaseService.addRental(rental);
    _rentals.insert(0, newRental);
    await SupabaseService.setCarAvailability(car.id, false);
    final idx = _cars.indexWhere((c) => c.id == car.id);
    if (idx != -1) _cars[idx].isAvailable = false;
    notifyListeners();
  }

  Future<void> returnCar(String rentalId) async {
    await SupabaseService.updateRentalStatus(rentalId, 'returned');
    final idx = _rentals.indexWhere((r) => r.id == rentalId);
    if (idx != -1) {
      _rentals[idx].status = 'returned';
      await SupabaseService.setCarAvailability(_rentals[idx].carId, true);
      final carIdx = _cars.indexWhere((c) => c.id == _rentals[idx].carId);
      if (carIdx != -1) _cars[carIdx].isAvailable = true;
    }
    notifyListeners();
  }

  Future<void> deleteRental(String rentalId) async {
    final rental = getRentalById(rentalId);
    await SupabaseService.deleteRental(rentalId);
    if (rental != null && rental.status == 'active') {
      await SupabaseService.setCarAvailability(rental.carId, true);
      final carIdx = _cars.indexWhere((c) => c.id == rental.carId);
      if (carIdx != -1) _cars[carIdx].isAvailable = true;
    }
    _rentals.removeWhere((r) => r.id == rentalId);
    notifyListeners();
  }

  Rental? getRentalById(String id) {
    try {
      return _rentals.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
