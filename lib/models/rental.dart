import 'car.dart';

class Rental {
  final String id;
  final String carId;    
  final String carName;  
  final Car? car;        
  String renterName;
  String renterPhone;
  String renterAddress;
  DateTime startTime;
  int durationMinutes;
  String status;

  Rental({
    required this.id,
    required this.carId,
    required this.carName,
    this.car,      
    required this.renterName,
    required this.renterPhone,
    required this.renterAddress,
    required this.startTime,
    required this.durationMinutes,
    this.status = 'active',
  });

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));
  double get totalPrice => (durationMinutes / 15) * Car.pricePerSession;
  int get sessions => durationMinutes ~/ 15;

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id:              json['id'] as String,
      carId:           json['car_id'] as String,
      carName:         json['car_name'] as String,
      renterName:      json['renter_name'] as String,
      renterPhone:     json['renter_phone'] as String,
      renterAddress:   json['renter_address'] as String,
      startTime:       DateTime.parse(json['start_time'] as String).toLocal(),
      durationMinutes: json['duration_minutes'] as int,
      status:          json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'car_id':           carId,
      'car_name':         carName,
      'renter_name':      renterName,
      'renter_phone':     renterPhone,
      'renter_address':   renterAddress,
      'start_time':       startTime.toUtc().toIso8601String(),
      'duration_minutes': durationMinutes,
      'status':           status,
    };
  }
}