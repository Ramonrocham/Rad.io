import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

class RadioShareButton extends StatelessWidget {
  final Map<String, dynamic> radio;
  final Color iconColor;

  const RadioShareButton({
    super.key,
    required this.radio,
    this.iconColor = const Color(0xFFFF6B00), // Laranja padrão do Rad.io
  });

  void _showShareModal(BuildContext context) {
    // Preparamos o JSON que será lido futuramente
    final String qrContent = jsonEncode({
      'type': 'radio_station',
      'uuid': radio['stationuuid'],
      'name': radio['name'],
      'url': radio['url'] ?? radio['url_resolved'],
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Compartilhar Estação",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 25),
            // QR Code renderizado como Widget
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                /*errorCorrectionLevel: QrErrorCorrectLevel.H,
                embeddedImage: const AssetImage('assets/images/logo_icon.png'),
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(40, 40),
                ),*/
                data: qrContent,
                version: QrVersions.auto,
                size: 180.0,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              radio['name']?.toString().trim() ?? 'Rádio Desconhecida',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                // Copia para a área de transferência
                await Clipboard.setData(ClipboardData(text: radio['stationuuid'].toString().trim()));
                
                // Ignora o aviso do linter se o contexto não estiver montado
                if (!context.mounted) return;
                
                // Feedback visual para o usuário
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ID copiado para a área de transferência!'),
                    backgroundColor: Color(0xFF282828),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF282828), // Fundo cinza escuro para destacar sutilmente
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.copy, color: Color(0xFFFF6B00), size: 16), // Ícone copiar
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        radio['stationuuid']?.toString().trim() ?? 'UUID Desconhecido',
                        style: const TextStyle(
                          color: Colors.white70, 
                          fontSize: 12, 
                          fontFamily: 'monospace', // Dá um ar de "código"
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Aponte a câmera do Rad.io para este código",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.ios_share_rounded, color: iconColor),
      onPressed: () => _showShareModal(context),
    );
  }
}