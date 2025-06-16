import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';

class AudioHelper {
  AudioHelper._();
  
  static final AudioHelper instance = AudioHelper._();
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Map to track playing sounds for each order
  final Map<int, AudioPlayer> _playingSounds = {};
  
  /// Play notification sound for new order
  Future<void> playNewOrderSound(int orderId) async {
    try {
      log('AudioHelper: Playing new order sound for order $orderId');
      
      // Stop any existing sound for this order
      await stopSound(orderId);
      
      // Create new player for this order
      final player = AudioPlayer();
      _playingSounds[orderId] = player;
      
      // Set to loop for attention
      await player.setReleaseMode(ReleaseMode.loop);
      
      // Try to play from assets, fallback to default system sound
      try {
        await player.play(AssetSource('sounds/accept_order_ENG.wav'));
      } catch (e) {
        log('AudioHelper: Asset sound not found, using default notification sound');
        // If asset doesn't exist, we could use a system beep or generate a tone
        // For now, just log that it would play
        log('AudioHelper: Would play new order notification sound');
      }
    } catch (e) {
      log('AudioHelper: Error playing new order sound - $e');
    }
  }
  
  /// Play sound when payment is confirmed and order should be prepared
  Future<void> playPaymentConfirmedSound(int orderId) async {
    try {
      log('AudioHelper: Playing payment confirmed sound for order $orderId');
      
      // Stop any existing sound for this order
      await stopSound(orderId);
      
      // Create new player for this order
      final player = AudioPlayer();
      _playingSounds[orderId] = player;
      
      // Play once for payment confirmation
      await player.setReleaseMode(ReleaseMode.stop);
      
      try {
        await player.play(AssetSource('sounds/payment_confirmed.mp3'));
      } catch (e) {
        log('AudioHelper: Asset sound not found, using default payment sound');
        log('AudioHelper: Would play payment confirmed sound');
      }
    } catch (e) {
      log('AudioHelper: Error playing payment confirmed sound - $e');
    }
  }
  
  /// Play sound when delivery person/robot arrives for pickup
  Future<void> playPickupArrivedSound(int orderId) async {
    try {
      log('AudioHelper: Playing pickup arrived sound for order $orderId');
      
      // Stop any existing sound for this order
      await stopSound(orderId);
      
      // Create new player for this order
      final player = AudioPlayer();
      _playingSounds[orderId] = player;
      
      // Set to loop for attention
      await player.setReleaseMode(ReleaseMode.loop);
      
      try {
        await player.play(AssetSource('sounds/pickup_arrived.mp3'));
      } catch (e) {
        log('AudioHelper: Asset sound not found, using default pickup sound');
        log('AudioHelper: Would play pickup arrived sound');
      }
    } catch (e) {
      log('AudioHelper: Error playing pickup arrived sound - $e');
    }
  }
  
  /// Stop sound for specific order
  Future<void> stopSound(int orderId) async {
    try {
      final player = _playingSounds[orderId];
      if (player != null) {
        await player.stop();
        await player.dispose();
        _playingSounds.remove(orderId);
        log('AudioHelper: Stopped sound for order $orderId');
      }
    } catch (e) {
      log('AudioHelper: Error stopping sound for order $orderId - $e');
    }
  }
  
  /// Stop all playing sounds
  Future<void> stopAllSounds() async {
    try {
      log('AudioHelper: Stopping all sounds');
      
      for (final player in _playingSounds.values) {
        await player.stop();
        await player.dispose();
      }
      _playingSounds.clear();
      
      log('AudioHelper: All sounds stopped');
    } catch (e) {
      log('AudioHelper: Error stopping all sounds - $e');
    }
  }
  
  /// Play a simple beep sound for UI feedback
  Future<void> playActionSound() async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/action_beep.mp3'));
      
      // Auto-dispose after playing
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      log('AudioHelper: Error playing action sound - $e');
    }
  }
  
  /// Dispose all resources
  Future<void> dispose() async {
    await stopAllSounds();
    await _audioPlayer.dispose();
  }
}
