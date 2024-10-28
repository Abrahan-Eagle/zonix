import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Asegúrate de añadir esto a tu pubspec.yaml
import 'package:zonix/features/DomainProfiles/Documents/models/document.dart';

class DocumentDetailScreen extends StatelessWidget {
  final Document document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Documento'),
      ),
      body: _buildDocumentDetails(context),
    );
  }

  Widget _buildDocumentDetails(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          _buildBackgroundImage(context), // Imagen de fondo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem(context, 'Documento N.º: ${document.number ?? 'N/A'}', isHeader: true),
                _buildDetailItem(context, 'Tipo: ${translateDocumentType(document.type ?? 'Desconocido')}'),
                _buildDetailItem(
                  context,
                  'Estado: ${getStatusSpanish(document.getApprovedStatus())}',
                  textColor: getStatusColor(document.getApprovedStatus()),
                ),
                const SizedBox(height: 20), // Espacio adicional antes de los campos específicos
                _buildSpecificFields(context), // Campos específicos según el tipo
                const SizedBox(height: 10), // Espacio antes de la fecha de creación
                _buildDetailItem(context, 'Fecha de Creación: ${_formatDate(document.issuedAt)}'),
                if (document.type == 'ci' || document.type == 'passport' || document.type == 'rif' || document.type == 'neighborhood_association') 
                  _buildDetailItem(context, 'Fecha de Emisión: ${_formatDate(document.issuedAt)}'),
                if (document.type == 'ci' || document.type == 'passport' || document.type == 'rif' || document.type == 'neighborhood_association') 
                  _buildDetailItem(context, 'Fecha de Expiración: ${_formatDate(document.expiresAt)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String text,
      {bool isHeader = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Separación uniforme
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 20 : 16,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: textColor ?? Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(BuildContext context) {
    Color logoColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Positioned(
      right: -110,
      bottom: -30,
      child: SizedBox(
        width: 425,
        height: 425,
        child: Opacity(
          opacity: 0.3,
          child: Image.asset(
            'assets/images/splash_logo_dark.png',
            fit: BoxFit.cover,
            color: logoColor,
            colorBlendMode: BlendMode.modulate,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return date.toLocal().toString().split(' ')[0];
  }

  String translateDocumentType(String type) {
    switch (type) {
      case 'ci':
        return 'Cédula';
      case 'rif':
        return 'RIF';
      case 'neighborhood_association':
        return 'Asoc. Vecinos';
      case 'passport':
        return 'Pasaporte';
      default:
        return 'Desconocido';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusSpanish(String status) {
    switch (status) {
      case 'approved':
        return 'Aprobado';
      case 'pending':
        return 'Pendiente';
      case 'rejected':
        return 'Rechazado';
      default:
        return 'Desconocido';
    }
  }

  Widget _buildSpecificFields(BuildContext context) {
    List<Widget> fields = [];

    switch (document.type) {
      case 'ci':
      case 'passport':
      case 'rif':
      case 'neighborhood_association':
        // Crear un Row para los botones de imagen
        fields.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildImageButton(context, document.frontImage, 'Foto Frontal', Icons.photo),
              ),
              const SizedBox(width: 16), // Espaciado entre los botones
              Expanded(
                child: _buildImageButton(context, document.backImage, 'Foto Trasera', Icons.photo),
              ),
            ],
          ),
        );

        if (document.type == 'rif') {
          fields.add(const SizedBox(height: 16)); // Espacio antes del domicilio fiscal
          fields.add(_buildDetailItem(context, 'Domicilio Fiscal: ${document.taxDomicile ?? 'N/A'}'));
          fields.add(const SizedBox(height: 16)); // Espacio antes de la URL
          fields.add(_buildRifUrlField(context, document.rifUrl));
        }

        if (document.type == 'neighborhood_association') {
          fields.add(const SizedBox(height: 16)); // Espacio antes del domicilio fiscal
          fields.add(_buildDetailItem(context, 'Domicilio Fiscal: ${document.taxDomicile ?? 'N/A'}'));
        }
        break;

      default:
        fields.add(const Text('No hay campos disponibles para este tipo de documento.'));
        break;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: fields);
  }

  Widget _buildRifUrlField(BuildContext context, String? rifUrl) {
    return GestureDetector(
      onTap: () {
        if (rifUrl != null && rifUrl.isNotEmpty) {
          _launchURL(rifUrl);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay URL disponible')),
          );
        }
      },
      child: Text(
        'URL del RIF: ${rifUrl ?? 'N/A'}',
        style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir el enlace: $url';
    }
  }

  Widget _buildImageButton(BuildContext context, String? imageUrl, String label, IconData icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(100, 40), // Tamaño más pequeño
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Redondear las esquinas
        ),
        backgroundColor: Colors.blue, // Cambiar el color de fondo si es necesario
      ),
      icon: Icon(icon, size: 18, color: Colors.white), // Icono más pequeño
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)), // Texto más pequeño
      onPressed: () {
        if (imageUrl != null && imageUrl.isNotEmpty) {
          _showImageDialog(context, imageUrl);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay imagen disponible')),
          );
        }
      },
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(0), // Elimina el espaciado
          child: Container(
            // Container que ocupa todo el espacio disponible
            width: double.infinity,
            height: double.infinity,
            child: OrientationBuilder(
              builder: (context, orientation) {
                return Image.network(
                  imageUrl,
                  fit: BoxFit.cover, // Ajustar para cubrir toda la pantalla
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                );
              },
            ),
          ),
        );
      },
    );
  }
}