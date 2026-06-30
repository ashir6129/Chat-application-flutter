import 'package:flutter/material.dart';

class TabScrollToTop {
  static final Map<int, VoidCallback> _callbacks = {};

  static void register(int index, VoidCallback callback) {
    _callbacks[index] = callback;
  }

  static void unregister(int index) {
    _callbacks.remove(index);
  }

  static void trigger(int index) {
    _callbacks[index]?.call();
  }
}
