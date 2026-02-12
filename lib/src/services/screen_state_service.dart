import 'package:flutter/services.dart';

class ScreenStateService {
  static const _eventChannel = EventChannel('baby_tracker/screen_state');

  Stream<String> get stateStream =>
      _eventChannel.receiveBroadcastStream().map((event) => '$event');
}
