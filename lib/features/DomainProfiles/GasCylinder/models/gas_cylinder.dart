class GasCylinder {
  final String gasCylinderCode;
  final int? cylinderQuantity;
  final String? cylinderType;
  final String? cylinderWeight;
  final DateTime? manufacturingDate;
  final bool approved;
  final int? companySupplierId; // Nuevo campo para el proveedor

  GasCylinder({
    required this.gasCylinderCode,
    this.cylinderQuantity,
    this.cylinderType,
    this.cylinderWeight,
    this.manufacturingDate,
    this.approved = false,
    this.companySupplierId, // Inicialización del nuevo campo
  });

  // Método para crear una instancia de GasCylinder a partir de un JSON
  factory GasCylinder.fromJson(Map<String, dynamic> json) {
    return GasCylinder(
      gasCylinderCode: json['gas_cylinder_code'],
      cylinderQuantity: json['cylinder_quantity'],
      cylinderType: json['cylinder_type'],
      cylinderWeight: json['cylinder_weight'],
      manufacturingDate: json['manufacturing_date'] != null 
          ? DateTime.parse(json['manufacturing_date']) 
          : null,
      approved: json['approved'] == 1 || json['approved'] == true,
      companySupplierId: json['company_supplier_id'], // Asignación del nuevo campo
    );
  }

  // Método para convertir una instancia de GasCylinder a JSON
  Map<String, dynamic> toJson() {
    return {
      'gas_cylinder_code': gasCylinderCode,
      'cylinder_quantity': cylinderQuantity,
      'cylinder_type': cylinderType,
      'cylinder_weight': cylinderWeight,
      'manufacturing_date': manufacturingDate?.toIso8601String(),
      'approved': approved ? 1 : 0,
      'company_supplier_id': companySupplierId, // Conversión del nuevo campo
    };
  }
}
