class EmployeeReport {
  final String employeeName;
  final String chairName;
  final int servicesCount;
  final double totalGenerated;
  final double commission;
  final List<ServiceDetail> details;

  EmployeeReport({
    required this.employeeName,
    required this.chairName,
    required this.servicesCount,
    required this.totalGenerated,
    required this.commission,
    this.details = const [],
  });
}

class ServiceDetail {
  final DateTime date;
  final String service;
  final String client;
  final int quantity;
  final double unitPrice;
  final double total;
  final double commission;

  ServiceDetail({
    required this.date,
    required this.service,
    required this.client,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.commission,
  });
}
