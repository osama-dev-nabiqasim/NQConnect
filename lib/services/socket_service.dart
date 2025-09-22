// ignore_for_file: library_prefixes, avoid_print

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;

  void connect(
    String baseUrl,
    String userId, {
    Function(Map<String, dynamic>)? onNotification,
  }) {
    socket = IO.io(
      baseUrl, // e.g. http://10.0.2.2:5000
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.onConnect((_) {
      print('🔌 Socket connected');
      // Join a room with the user’s ID so the backend can target this user
      socket!.emit('join', userId);
    });

    // Listen for new notifications from the backend
    socket!.on('new-notification', (data) {
      print('📩 Socket received: $data');
      if (onNotification != null) {
        onNotification(Map<String, dynamic>.from(data));
      }
    });

    socket!.onDisconnect((_) => print('🔌 Socket disconnected'));
    socket!.connect();
  }

  void dispose() {
    socket?.disconnect();
    socket?.dispose();
  }
}
