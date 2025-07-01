import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  Timer? _connectionTimeoutTimer;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  String? _lastUrl;
  
  // Enhanced connection parameters matching last_mile_store pattern
  static const int _maxReconnectAttempts = 10;
  static const Duration _initialReconnectDelay = Duration(seconds: 1);
  static const Duration _maxReconnectDelay = Duration(seconds: 5);
  static const Duration _pingInterval = Duration(milliseconds: 500);
  static const Duration _connectionTimeout = Duration(milliseconds: 1000);

  // Stream controllers for different message types
  final StreamController<Map<String, dynamic>> _orderUpdateController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _connectionStatusController = 
      StreamController<String>.broadcast();

  // Getters for streams
  Stream<Map<String, dynamic>> get orderUpdates => _orderUpdateController.stream;
  Stream<String> get connectionStatus => _connectionStatusController.stream;

  // Helper method for timestamped logging
  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    dev.log('[$timestamp] $message');
  }

  Future<void> connect(String url) async {
    if (_isConnecting || _isConnected) {
      _log('WebSocket already connecting or connected');
      return;
    }
    
    _lastUrl = url;
    _isConnecting = true;
    _shouldReconnect = true;

    try {
      await _performConnection(url);
    } catch (e) {
      _log('WebSocket connection failed: $e');
      _connectionStatusController.add('Connection failed');
      _isConnecting = false;
      _scheduleReconnect();
    }
  }

  Future<void> _performConnection(String url) async {
    try {
      _log('WebSocket attempting connection to: $url');
      
      // Create connection with timeout
      _channel = IOWebSocketChannel.connect(
        Uri.parse(url),
        protocols: ['websocket'],
        connectTimeout: _connectionTimeout,
      );

      // Wait for connection to be ready with timeout
      _connectionTimeoutTimer?.cancel();
      _connectionTimeoutTimer = Timer(_connectionTimeout, () {
        if (!_isConnected) {
          _log('WebSocket connection timeout');
          _handleConnectionFailure('Connection timeout');
        }
      });

      await _channel!.ready.timeout(_connectionTimeout);
      
      _connectionTimeoutTimer?.cancel();
      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      
      _log('WebSocket connected successfully to: $url');
      _connectionStatusController.add('Connected');
      _startPingTimer();
      
      // Listen to incoming messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
        cancelOnError: false,
      );
      
    } catch (e) {
      _connectionTimeoutTimer?.cancel();
      _isConnecting = false;
      _isConnected = false;
      _log('WebSocket connection error: $e');
      throw Exception('Failed to connect to WebSocket: $e');
    }
  }

  void _handleMessage(dynamic message) {
    try {
      if (kDebugMode) {
        _log('WebSocket message received: $message');
      }

      // Handle ping/pong responses
      if (message == 'pong') {
        _log('WebSocket received pong response');
        return;
      }

      // Parse JSON message
      final Map<String, dynamic> data = json.decode(message);
      
      // Check if this is a wrapped message format with nested JSON
      if (data.containsKey('message') && data['message'] is String) {
        try {
          final Map<String, dynamic> nestedData = json.decode(data['message']);
          _log('Parsed nested order data: ${nestedData['id']}');
          _orderUpdateController.add(nestedData);
          return;
        } catch (e) {
          _log('Error parsing nested message JSON: $e');
        }
      }
      
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
          _log('Broadcasting message with type: $type');
          _orderUpdateController.add(data);
      }
    } catch (e) {
      _log('Error parsing WebSocket message: $e');
    }
  }

  void _handleError(dynamic error) {
    _log('WebSocket error: $error');
    _isConnected = false;
    _connectionStatusController.add('Error: $error');
    _scheduleReconnect();
  }

  void _handleDisconnection() {
    _log('WebSocket disconnected');
    _isConnected = false;
    _connectionStatusController.add('Disconnected');
    _stopPingTimer();
    
    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  void _handleConnectionFailure(String reason) {
    _log('WebSocket connection failed: $reason');
    _isConnected = false;
    _isConnecting = false;
    _connectionStatusController.add('Failed: $reason');
    
    try {
      _channel?.sink.close(status.abnormalClosure);
    } catch (e) {
      _log('Error closing failed connection: $e');
    }
    _channel = null;
    
    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      _log('Max reconnection attempts reached or reconnection disabled');
      _connectionStatusController.add('Disconnected - Max retries reached');
      return;
    }

    _reconnectAttempts++;
    
    // Exponential backoff with jitter
    final baseDelay = _initialReconnectDelay.inSeconds * pow(2, _reconnectAttempts - 1);
    final maxDelay = _maxReconnectDelay.inSeconds;
    final delaySeconds = min(baseDelay.toInt(), maxDelay);
    
    // Add jitter to prevent thundering herd
    final jitter = (delaySeconds * 0.1 * (0.5 - Random().nextDouble())).round();
    final finalDelay = Duration(seconds: delaySeconds + jitter);

    _log('Scheduling reconnection attempt $_reconnectAttempts in ${finalDelay.inSeconds}s');
    _connectionStatusController.add('Reconnecting in ${finalDelay.inSeconds}s...');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(finalDelay, () {
      if (_shouldReconnect && _lastUrl != null && !_isConnected && !_isConnecting) {
        _log('Attempting reconnection $_reconnectAttempts');
        connect(_lastUrl!);
      }
    });
  }

  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(_pingInterval, (timer) {
      if (_isConnected && _channel != null) {
        send('ping');
      } else {
        timer.cancel();
      }
    });
    dev.log('WebSocket ping timer started');
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void send(String message) {
    try {
      if (_isConnected && _channel != null) {
        _channel!.sink.add(message);
        if (kDebugMode && message != 'ping' && message != 'pong') {
          dev.log('WebSocket message sent: $message');
        }
      } else {
        dev.log('Cannot send message: WebSocket not connected');
      }
    } catch (e) {
      dev.log('Error sending WebSocket message: $e');
      _handleConnectionFailure('Send error: $e');
    }
  }

  void sendJson(Map<String, dynamic> data) {
    try {
      final jsonString = json.encode(data);
      send(jsonString);
    } catch (e) {
      dev.log('Error encoding JSON message: $e');
    }
  }

  bool get isConnected => _isConnected;

  void disconnect() {
    dev.log('WebSocket disconnecting manually');
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _stopPingTimer();
    _connectionTimeoutTimer?.cancel();
    
    _isConnected = false;
    _isConnecting = false;
    
    try {
      _channel?.sink.close(status.normalClosure);
    } catch (e) {
      dev.log('Error closing WebSocket: $e');
    }
    
    _channel = null;
    _connectionStatusController.add('Disconnected');
  }

  void dispose() {
    disconnect();
    _orderUpdateController.close();
    _connectionStatusController.close();
  }
}
