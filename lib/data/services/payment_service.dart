// lib/data/services/payment_service.dart
// Abre el flujo de PayPal (sandbox) en un WebView interno y retorna true/false.
// No realiza cobro real; sirve como demostración con SDK oficial.

import 'package:flutter/material.dart';
import '../../features/orders/ui/paypal_webview_page.dart';

class PaymentService {
  Future<bool> openCheckout({
    required BuildContext context,
    required double amount,
  }) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaypalWebviewPage(amount: amount),
        fullscreenDialog: true,
      ),
    );
    return ok ?? false;
  }
}
