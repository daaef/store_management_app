import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'stoppable_service.dart';

class SocketHelper extends StoppableService {
  SocketHelper._();

  static final SocketHelper instance = SocketHelper._();

  final PublishSubject<Map<String, dynamic>> _ordersSubject =
      PublishSubject<Map<String, dynamic>>();

  final PublishSubject<Map<String, dynamic>> _statsSubject =
      PublishSubject<Map<String, dynamic>>();

  WebSocketChannel? _ordersChannel;
  WebSocketChannel? _statsChannel;

  StreamSubscription<dynamic>? _ordersSubscription;
  StreamSubscription<dynamic>? _statsSubscription;

  bool _isInitialized = false;

  String _storeId = '';

  void initialiseStoreOrdersChannel(String storeId) {
    _storeId = storeId;
    log('SocketHelper: Initialising orders socket for store: $storeId');
    log('SocketHelper: WebSocket URL: wss://lastmile.fainzy.tech/ws/soc/store_$storeId/');
    
    try {
      // Close existing connection if any
      _ordersSubscription?.cancel();
      _ordersChannel?.sink.close();
      
      _ordersChannel = IOWebSocketChannel.connect(
        Uri.parse('wss://lastmile.fainzy.tech/ws/soc/store_$storeId/'),
      );
      log('SocketHelper: Orders WebSocket connection established successfully');
      _startListeningToOrdersChannel();
      _isInitialized = true;
      log('SocketHelper: Orders channel initialized and listening');
    } catch (e) {
      log('SocketHelper: Error initializing orders channel - $e');
      _isInitialized = false;
    }
  }

  void initialiseStoreStatsChannel(String storeId) {
    _storeId = storeId;
    log('SocketHelper: Initialising stats socket for store: $storeId');
    
    try {
      _statsChannel = IOWebSocketChannel.connect(
        Uri.parse('wss://lastmile.fainzy.tech/ws/soc/store_statistics_$storeId/'),
      );
      log('SocketHelper: Stats WebSocket connection established successfully');
      _startListeningToStatsChannel();
      log('SocketHelper: Stats channel initialized and listening');
    } catch (e) {
      log('SocketHelper: Error initializing stats channel - $e');
    }
  }

  void _startListeningToOrdersChannel() {
    if (_ordersChannel == null) return;
    
    log('SocketHelper: Starting to listen on orders channel');
    _ordersSubscription = _ordersChannel!.stream.listen(
      (dynamic event) {
        log('SocketHelper: New order event received =============== $event');
        try {
          final data = jsonDecode(event as String) as Map<String, dynamic>;
          _ordersSubject.add(data);
        } catch (e) {
          log('SocketHelper: Error parsing order event - $e');
        }
      },
      onDone: () {
        log('SocketHelper: Orders socket closed =============== ${_ordersChannel?.closeReason}');
        _reConnectWs();
      },
      onError: (e) {
        log('SocketHelper: Orders socket error =============== $e');
        _reConnectWs();
      },
    );
    log('SocketHelper: Orders channel listener started successfully');
  }

  void _startListeningToStatsChannel() {
    if (_statsChannel == null) return;
    
    log('SocketHelper: Starting to listen on stats channel');
    _statsSubscription = _statsChannel!.stream.listen(
      (dynamic event) {
        log('SocketHelper: New stats event received =============== $event');
        try {
          final data = jsonDecode(event as String) as Map<String, dynamic>;
          _statsSubject.add(data);
        } catch (e) {
          log('SocketHelper: Error parsing stats event - $e');
        }
      },
      onDone: () {
        log('SocketHelper: Stats socket closed =============== ${_statsChannel?.closeReason}');
        _reConnectWs();
      },
      onError: (e) {
        log('SocketHelper: Stats socket error =============== $e');
        _reConnectWs();
      },
    );
    log('SocketHelper: Stats channel listener started successfully');
  }

  Stream<Map<String, dynamic>> orderStream() => _ordersSubject.stream;
  Stream<Map<String, dynamic>> statsStream() => _statsSubject.stream;

  /// Listen to all order updates from the websocket
  Stream<Map<String, dynamic>> listenToAllOrders() {
    return orderStream().map((event) {
      try {
        if (event['message'] != null) {
          final data = jsonDecode(event['message'] as String) as Map<String, dynamic>;
          return data;
        }
        return event;
      } catch (e) {
        log('SocketHelper: Error parsing order event in listenToAllOrders - $e');
        return <String, dynamic>{};
      }
    }).where((event) => event.isNotEmpty);
  }

  /// Listen to a specific order updates from the websocket
  Stream<Map<String, dynamic>> listenToOrderUpdates(int orderId) {
    return listenToAllOrders().where((orderData) {
      return orderData['id'] == orderId;
    });
  }

  bool get isInitialized => _isInitialized;

  @override
  void start() {
    super.start();
    _ordersSubscription?.resume();
    _statsSubscription?.resume();
    
    log('SocketHelper: Service started successfully');
  }

  @override
  void stop() {
    super.stop();
    _ordersSubscription?.pause(_resumeSignal());
    _statsSubscription?.pause(_resumeSignal());
    
    log('SocketHelper: Service stopped successfully');
  }

  void disconnect() {
    stop();
    _isInitialized = false;

    _ordersSubscription?.cancel();
    _statsSubscription?.cancel();
    
    _ordersChannel?.sink.close();
    _statsChannel?.sink.close();
    
    _ordersChannel = null;
    _statsChannel = null;
    _ordersSubscription = null;
    _statsSubscription = null;
    
    log('SocketHelper: Disconnected all channels successfully');
  }

  Future<void> _resumeSignal() async => true;

  void _reConnectWs() {
    if (serviceStopped || _storeId.isEmpty) return;
    
    log('SocketHelper: Attempting to reconnect WebSocket...');
    
    Future<void>.delayed(const Duration(milliseconds: 1000)).then((_) {
      if (serviceStopped) return;
      
      try {
        if (_ordersChannel != null) {
          _ordersChannel = IOWebSocketChannel.connect(
            Uri.parse('wss://lastmile.fainzy.tech/ws/soc/store_$_storeId/'),
          );
          log('SocketHelper: Orders channel reconnected successfully');
          _startListeningToOrdersChannel();
        }
        
        if (_statsChannel != null) {
          _statsChannel = IOWebSocketChannel.connect(
            Uri.parse('wss://lastmile.fainzy.tech/ws/soc/store_statistics_$_storeId/'),
          );
          log('SocketHelper: Stats channel reconnected successfully');
          _startListeningToStatsChannel();
        }
        
        log('SocketHelper: WebSocket reconnection completed successfully');
      } catch (e) {
        log('SocketHelper: Reconnection failed - $e. Retrying...');
        _reConnectWs(); // Try again
      }
    });
  }
}
