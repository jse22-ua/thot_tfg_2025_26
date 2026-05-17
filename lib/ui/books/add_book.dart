import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:thot_tfg_2025_26/utils/validators.dart';

void showAddBook(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const AddBook();
    },
  );
}

class AddBook extends StatefulWidget {
  final bool isSale;
  const AddBook({super.key, this.isSale = false});

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  late MobileScannerController controller;
  bool isScanCompleted = false;

  Future<void> _showManualEntryDialog() async {
    final TextEditingController manualController = TextEditingController();
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Entrada Manual", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A3A5F))),
        content: TextField(
          controller: manualController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Escribe el ISBN (13 dígitos)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (Validators.validateISBN(manualController.text)) {
                Navigator.pop(context, manualController.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("ISBN no válido")),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC5A021)),
            child: const Text("ACEPTAR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    controller.dispose(); // ¡ESTO libera la memoria y la cámara!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFFFDF5E6), // Papiro
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Cabecera
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Escanear Código de Barras",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A3A5F),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF1A3A5F), size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, height: 1),

          // Escáner Real
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Cámara de mobile_scanner
                    MobileScanner(
                      controller: this.controller,
                      onDetect: (capture) {
                        if (!isScanCompleted) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            if (barcode.rawValue != null) {
                              isScanCompleted = true;
                              final String code = barcode.rawValue!;
                              debugPrint('Código detectado: $code');

                              if(Validators.validateISBN(code)){
                                Navigator.pop(context, code);
                                break;
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("No es el ISBN de un libro"),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                Navigator.pop(context);
                                break;
                              }

                            }
                          }
                        }
                      },
                    ),

                    // Superposición visual (UI del escáner)
                    IgnorePointer(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 160,
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24, width: 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                Positioned(top: 0, left: 0, child: _ScannerCorner(isTop: true, isLeft: true)),
                                Positioned(top: 0, right: 0, child: _ScannerCorner(isTop: true, isLeft: false)),
                                Positioned(bottom: 0, left: 0, child: _ScannerCorner(isTop: false, isLeft: true)),
                                Positioned(bottom: 0, right: 0, child: _ScannerCorner(isTop: false, isLeft: false)),

                                Center(
                                  child: Container(
                                    width: double.infinity,
                                    height: 2,
                                    margin: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      boxShadow: [
                                        BoxShadow(color: Colors.red, blurRadius: 4, spreadRadius: 1)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Positioned(
                            bottom: 40,
                            child: Text(
                              "Centra el código de barras en la línea",
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Botón manual
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0, left: 20, right: 20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () {
                  if (widget.isSale) {
                    _showManualEntryDialog();
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.edit, color: Color(0xFF1A3A5F)),
                label: const Text("INTRODUCIR MANUALMENTE", style: TextStyle(color: Color(0xFF1A3A5F), fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1A3A5F), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerCorner extends StatelessWidget {
  final bool isTop;
  final bool isLeft;
  const _ScannerCorner({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Color(0xFFC5A021), width: 4) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Color(0xFFC5A021), width: 4) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Color(0xFFC5A021), width: 4) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Color(0xFFC5A021), width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}
