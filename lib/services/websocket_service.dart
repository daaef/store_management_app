import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _pingInterval = Duration(seconds: 30);

  // Stream controllers for different message types
  final StreamController<Map<String, dynamic>> _orderUpdateController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _connectionStatusController = 
      StreamController<String>.broadcast();

  // Getters for streams
  Stream<Map<String, dynamic>> get orderUpdates => _orderUpdateController.stream;
  Stream<String> get connectionStatus => _connectionStatusController.stream;

  String? _lastUrl;

  Future<void> connect(String url) async {
    if (_isConnecting) return;
    
    _lastUrl = url;
    _isConnecting = true;
    _shouldReconnect = true;

    try {
      await _performConnection(url);
    } catch (e) {
      if (kDebugMode) {
        print('WebSocket connection failed: $e');
      }
      _connectionStatusController.add('Connection failed');
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _performConnection(String url) async {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(url),
        protocols: ['websocket'],
      );

      await _channel!.ready;
      
      if (kDebugMode) {
        print('WebSocket connected successfully to: $url');
      }
      
      _connectionStatusController.add('Connected');
      _reconnectAttempts = 0;
      _startPingTimer();
      
      // Listen to incoming messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
        cancelOnError: false,
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('WebSocket connection error: $e');
      }
      throw Exception('Failed to connect to WebSocket: $e');
    }
  }

  void _handleMessage(dynamic message) {
    try {
      if (kDebugMode) {
        print('WebSocket message received: $message');
      }

      // Handle different message types
      if (message == 'pong') {
        // Pong response to our ping
        return;
      }

      final Map<String, dynamic> data = json.decode(message);
      final String? type = data['type'] as String?;

      switch (type) {
        case 'order_update':
        case 'new_order':
        case 'order_status_change':
          _orderUpdateController.add(data);
          break;
        case 'ping':
          // Respond to server ping
          send('pong');
          break;
        default:
          if (kDebugMode) {
            print('Unknown message type: $type');
          }
          // Still broadcast the message in case other parts need it
          _orderUpdateController.add(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing WebSocket message: $e');
      }
    }
  }

  void _handleError(dynamic error) {
    if (kDebugMode) {
      print('WebSocket error: $error');
    }
    _connectionStatusController.add('Error: $error');
    _scheduleReconnect();
  }

  void _handleDisconnection() {
    if (kDebugMode) {
      print('WebSocket disconnected');
    }
    _connectionStatusController.add('Disconnected');
    _stopPingTimer();
    
    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      if (kDebugMode) {
        print('Max reconnection attempts reached or reconnection disabled');
      }
      _connectionStatusController.add('Disconnected - Max retries reached');
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(
      seconds: _reconnectDelay.inSeconds * _reconnectAttempts,
    );

    if (kDebugMode) {
      print('Scheduling reconnection attempt $_reconnectAttempts in ${delay.inSeconds}s');
    }

    _connectionStatusController.add('Reconnecting in ${delay.inSeconds}s...');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_shouldReconnect && _lastUrl != null) {
        connect(_lastUrl!);
      }
    });
  }

  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(_pingInterval, (timer) {
      if (_channel != null) {
        send('ping');
      } else {
        timer.cancel();
      }
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void send(String message) {
    try {
      if (_channel != null) {
        _channel!.sink.add(message);
        if (kDebugMode && message != 'ping' && message != 'pong') {
          print('WebSocket message sent: $message');
        }
      } else {
        if (kDebugMode) {
          print('Cannot send message: WebSocket not connected');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending WebSocket message: $e');
      }
    }
  }

  void sendJson(Map<String, dynamic> data) {
    try {
      final jsonString = json.encode(data);
      send(jsonString);
    } catch (e) {
      if (kDebugMode) {
        print('Error encoding JSON message: $e');
      }
    }
  }

  bool get isConnected => _channel != null;

  void disconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _stopPingTimer();
    
    try {
      _channel?.sink.close(status.normalClosure);
    } catch (e) {
      if (kDebugMode) {
        print('Error closing WebSocket: $e');
      }
    }
    
    _channel = null;
    _connectionStatusController.add('Disconnected');
    
    if (kDebugMode) {
      print('WebSocket disconnected manually');
    }
  }

  void dispose() {
    disconnect();
    _orderUpdateController.close();
    _connectionStatusController.close();
  }
}
