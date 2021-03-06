import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

CountdownController useCountdown(
  int duration, {
  bool disposeOnEnd = false,
  Function(int tick)? onTick,
}) {
  return use(_CountdownHook(duration, disposeOnEnd, onTick));
}

class CountdownController {
  int _tick;
  int _duration;
  get duration => _duration;

  CountdownController(int duration)
      : _duration = duration,
        _tick = duration;

  int get tick => _tick;
  bool get isFinished => _tick <= 0;

  void reset([int? newDuration]) {
    _duration = newDuration ?? _duration;
    _tick = newDuration ?? 0;
  }
}

// controller private methods
class _CountdownController extends CountdownController {
  _CountdownController(int _tick) : super(_tick);

  void tickDown() {
    _tick--;
  }
}

class _CountdownHook extends Hook<CountdownController> {
  final int duration;
  final bool disposeOnEnd;
  final Function(int tick)? onTick;

  const _CountdownHook(this.duration, this.disposeOnEnd, this.onTick);

  @override
  __CountdownHookState createState() => __CountdownHookState();
}

class __CountdownHookState
    extends HookState<CountdownController, _CountdownHook> {
  late final _CountdownController _controller;
  Timer? _timer;

  @override
  void initHook() {
    super.initHook();

    _controller = _CountdownController(hook.duration);

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_controller.tick > 0) {
        setState(() => _controller.tickDown());
        hook.onTick?.call(_controller.tick);
      }

      if (hook.disposeOnEnd && _controller.tick <= 0) {
        _timer?.cancel();
      }
    });
  }

  @override
  CountdownController build(BuildContext context) {
    return _controller;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
