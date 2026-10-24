import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/env/env.dart';

/// Pantalla que renderiza el botón PayPal (sandbox) dentro de un WebView.
/// Usa el SDK JS oficial; al aprobar/cancelar, envía un postMessage al canal JS
/// 'FlutterPayPal' para que Flutter reciba 'success' o 'cancel'.
class PaypalWebviewPage extends StatefulWidget {
  final double amount;
  const PaypalWebviewPage({super.key, required this.amount});

  @override
  State<PaypalWebviewPage> createState() => _PaypalWebviewPageState();
}

class _PaypalWebviewPageState extends State<PaypalWebviewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterPayPal',
        onMessageReceived: (msg) {
          final text = msg.message; // 'success:ORDER_ID' | 'cancel'
          final ok = text.startsWith('success');
          Navigator.of(context).pop(ok);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _loading = false),
        ),
      )
      ..loadHtmlString(
        _buildHtml(clientId: Env.paypalClientIdSandbox, amount: widget.amount),
      );
  }

  String _buildHtml({required String clientId, required double amount}) {
    final total = amount.toStringAsFixed(2);
    // 👇 Mostramos COP en la UI, pero PayPal SDK sandbox lo dejamos en USD para evitar fricciones
    return '''
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>PayPal Sandbox Demo</title>
<script src="https://www.paypal.com/sdk/js?client-id=$clientId&currency=USD&intent=capture"></script>
<style>
  body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; padding: 16px; }
  .card { border-radius: 12px; border: 1px solid #e3e3e3; padding: 16px; }
  .ttl { font-weight: 700; margin-bottom: 8px; }
  .muted { color: #666; font-size: 14px; margin-bottom: 16px; }
  .fallback { margin-top:12px; background:#222; color:#fff; border:none; padding:12px 16px; width:100%; border-radius:10px; font-size:16px; }
</style>
</head>
<body>
  <div class="card">
    <div class="ttl">Pago seguro (Sandbox)</div>
    <div class="muted">Este es un flujo de demostración con PayPal Sandbox. No se realiza ningún cobro real.</div>
    <div><b>Total:</b> \$$total COP</div>
    <div id="paypal-button-container" style="margin-top:16px;"></div>

    <!-- Botón de respaldo por si el WebView bloquea pop-ups -->
    <button class="fallback" onclick="tryFallback()">Simular aprobación</button>
  </div>

  <script>
  // Render del botón PayPal
  paypal.Buttons({
    style: { shape: 'rect', color: 'gold', layout: 'vertical', label: 'paypal' },
    createOrder: function(data, actions) {
      return actions.order.create({
        purchase_units: [{ amount: { value: '$total' } }]
      });
    },
    onApprove: function(data, actions) {
      return actions.order.capture().then(function(details) {
        var orderId = (details && details.id) ? details.id : '';
        if (window.FlutterPayPal && window.FlutterPayPal.postMessage) {
          window.FlutterPayPal.postMessage('success:' + orderId);
        }
      });
    },  // 👈👈👈 ESTA COMA ES CLAVE

    onCancel: function (data) {
      if (window.FlutterPayPal && window.FlutterPayPal.postMessage) {
        window.FlutterPayPal.postMessage('cancel');
      }
    },
    onError: function (err) {
      if (window.FlutterPayPal && window.FlutterPayPal.postMessage) {
        window.FlutterPayPal.postMessage('cancel');
      }
    }
  }).render('#paypal-button-container');

  // Respaldo manual si el botón abre pop-ups bloqueadas en este dispositivo
  function tryFallback() {
    if (window.FlutterPayPal && window.FlutterPayPal.postMessage) {
      window.FlutterPayPal.postMessage('success');
    }
  }
</script>

</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PayPal (sandbox)')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
