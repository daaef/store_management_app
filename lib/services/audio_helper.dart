import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// Audio helper for playing order notification sounds (matches last_mile_store exactly)
class AudioHelper {
  // Map to track audio players for each order (matches last_mile_store)
  static final Map<int, AudioPlayer> _orderAudioPlayers = {};
  
  // Language support (matches last_mile_store)
  static String _language = 'ENG';
  
  /// Set audio language based on locale (matches last_mile_store)
  static void setLanguage(Locale locale) {
    if (locale.languageCode == 'en') {
      _language = 'ENG';
    } else if (locale.languageCode == 'ja') {
      _language = 'JAP';
    }
    log('🌐 Audio language set to: $_language for locale: ${locale.languageCode}');
  }
  
  /// Play notification sound for new order (matches last_mile_store flow)
  static Future<void> playNewOrderSound(int orderId) async {
    try {
      log('🔊 Attempting to play new order sound for order $orderId');

      // If a sound is already playing for this order, stop it.
      if (_orderAudioPlayers.containsKey(orderId) &&
          _orderAudioPlayers[orderId]!.state == PlayerState.playing) {
        log('🛑 Stopping existing sound for order $orderId');
        await stopSound(orderId);
      }

      // Create a new AudioPlayer for this order.
      AudioPlayer orderPlayer = AudioPlayer();
      _orderAudioPlayers[orderId] = orderPlayer;

      final soundFile = 'sounds/accept_order_$_language.wav';
      log('🎵 Playing sound file: $soundFile');

      // Add listeners to monitor playback state
      orderPlayer.onPlayerStateChanged.listen((PlayerState state) {
        log('🎵 Audio player state changed to: $state for order $orderId');
      });

      orderPlayer.onPlayerComplete.listen((_) {
        log('🎵 Audio playback completed for order $orderId');
      });

      // Set audio configuration for better reliability (matches last_mile_store)
      await orderPlayer.setReleaseMode(ReleaseMode.loop);
      await orderPlayer.setVolume(1.0); // Ensure volume is at maximum
      
      await orderPlayer.play(AssetSource(soundFile));
      
      log('✅ Successfully started playing sound for order $orderId');
    } catch (e, stackTrace) {
      log('❌ Error playing new order sound for order $orderId: $e');
      log('Stack trace: $stackTrace');
    }
  }
  
  /// Play sound when robot arrives for pickup (matches last_mile_store)
  static Future<void> playRobotArrivedSound(int orderId) async {
    try {
      log('🤖 Playing robot arrived sound for order $orderId');
      
      if (_orderAudioPlayers.containsKey(orderId) &&
          _orderAudioPlayers[orderId]!.state == PlayerState.playing) {
        await stopSound(orderId);
      }

      // Create a new AudioPlayer for this order.
      AudioPlayer orderPlayer = AudioPlayer();
      _orderAudioPlayers[orderId] = orderPlayer;

      int playCount = 0;
      orderPlayer.onPlayerComplete.listen((event) async {
        if (playCount < 1) {
          playCount++;
          await orderPlayer.play(
              AssetSource('sounds/robot_arrived_for_pickup_$_language.wav'));
        } else {
          await stopSound(orderId);
        }
      });

      await orderPlayer
          .play(AssetSource('sounds/robot_arrived_for_pickup_$_language.wav'));
      
      log('✅ Successfully started robot arrived sound for order $orderId');
    } catch (e) {
      log('❌ Error playing robot arrived sound for order $orderId: $e');
    }
  }
  
  /// Play sound when payment is confirmed (matches last_mile_store)
  static Future<void> playPaymentConfirmedSound(int orderId) async {
    try {
      log('💳 Playing payment confirmed sound for order $orderId');
      
      if (_orderAudioPlayers.containsKey(orderId) &&
          _orderAudioPlayers[orderId]!.state == PlayerState.playing) {
        await stopSound(orderId);
      }

      // Create a new AudioPlayer for this order.
      AudioPlayer orderPlayer = AudioPlayer();
      _orderAudioPlayers[orderId] = orderPlayer;

      await orderPlayer
          .play(AssetSource('sounds/payment_confirmed_$_language.mp3'));
      
      log('✅ Successfully started payment confirmed sound for order $orderId');
    } catch (e) {
      log('❌ Error playing payment confirmed sound for order $orderId: $e');
    }
  }
  
  /// Stop sound for specific order (matches last_mile_store)
  static Future<void> stopSound(int orderId) async {
    try {
      if (_orderAudioPlayers.containsKey(orderId)) {
        await _orderAudioPlayers[orderId]!.stop();
        await _orderAudioPlayers[orderId]!.dispose();
        _orderAudioPlayers.remove(orderId);
        log('🛑 Stopped and disposed sound for order $orderId');
      }
    } catch (e) {
      log('❌ Error stopping sound for order $orderId: $e');
    }
  }
  
  /// Stop all playing sounds
  static Future<void> stopAllSounds() async {
    try {
      log('🛑 Stopping all sounds');
      
      for (final entry in _orderAudioPlayers.entries) {
        await entry.value.stop();
        await entry.value.dispose();
      }
      _orderAudioPlayers.clear();
      
      log('✅ All sounds stopped and disposed');
    } catch (e) {
      log('❌ Error stopping all sounds: $e');
    }
  }

  /// Test method to manually trigger audio playback (matches last_mile_store)
  static Future<void> testAudioPlayback() async {
    log('🧪 Testing audio playback...');
    try {
      AudioPlayer testPlayer = AudioPlayer();
      await testPlayer.play(AssetSource('sounds/accept_order_$_language.wav'));
      log('✅ Test audio playback successful');
      
      // Auto-dispose after testing
      testPlayer.onPlayerComplete.listen((_) {
        testPlayer.dispose();
      });
    } catch (e) {
      log('❌ Test audio playbook failed: $e');
    }
  }
}
