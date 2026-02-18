/// QR Code Saver Platform Interface
/// Author: ZF_Clark
/// Description: Platform-aware export for QR code saving functionality. Automatically selects the correct implementation based on the current platform.
/// Last Modified: 2026/02/19
library;

export 'qr_code_saver_stub.dart'
    if (dart.library.js_interop) 'qr_code_saver_web.dart';
