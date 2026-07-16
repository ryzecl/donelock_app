import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:donelock/core/utils/ui_utils.dart';

enum PomodoroState { idle, work, rest }

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  static const int workDuration = 25 * 60; // 25 minutes in seconds
  static const int restDuration = 5 * 60; // 5 minutes in seconds

  int _remainingTime = workDuration;
  PomodoroState _currentState = PomodoroState.idle;
  Timer? _timer;

  void _startTimer() {
    if (_timer != null && _timer!.isActive) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        _transitionState();
      }
    });
  }

  void _transitionState() {
    if (_currentState == PomodoroState.work) {
      setState(() {
        _currentState = PomodoroState.rest;
        _remainingTime = restDuration;
      });
      UIUtils.showSuccess(context, "Work time's up! Time to rest.");
      _startTimer();
    } else if (_currentState == PomodoroState.rest) {
      setState(() {
        _currentState = PomodoroState.work;
        _remainingTime = workDuration;
      });
      UIUtils.showSuccess(context, "Rest time's up! Let's get back to work.");
      _startTimer();
    }
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {});
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _currentState = PomodoroState.idle;
      _remainingTime = workDuration;
    });
  }

  void _onMainButtonPressed() {
    if (_currentState == PomodoroState.idle) {
      setState(() {
        _currentState = PomodoroState.work;
        _remainingTime = workDuration;
      });
      _startTimer();
    } else {
      if (_timer != null && _timer!.isActive) {
        _pauseTimer();
      } else {
        _startTimer();
      }
    }
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = _timer != null && _timer!.isActive;
    Color bgColor = const Color(0xFFF4F4F0);
    Color fgColor = Colors.black;

    if (_currentState == PomodoroState.work) {
      bgColor = const Color(0xFFFFD073); // Neo Yellow
      fgColor = Colors.black;
    } else if (_currentState == PomodoroState.rest) {
      bgColor = const Color(0xFF90A8ED); // Neo Purple
      fgColor = Colors.black;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: fgColor, size: 32),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "LOCK-IN",
          style: TextStyle(fontWeight: FontWeight.bold, color: fgColor, fontFamily: 'monospace', letterSpacing: 2),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentState == PomodoroState.idle
                    ? "READY TO FOCUS?"
                    : _currentState == PomodoroState.work
                        ? "DEEP WORK"
                        : "REST & RECOVER",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: fgColor,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: UIUtils.neoBox(
                  color: Colors.white,
                  borderColor: Colors.black,
                  borderWidth: 4,
                ),
                child: Center(
                  child: Text(
                    _formatTime(_remainingTime),
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: fgColor,
                        foregroundColor: bgColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        side: BorderSide(color: fgColor, width: 3),
                        elevation: 0,
                      ),
                      onPressed: _onMainButtonPressed,
                      child: Text(
                        _currentState == PomodoroState.idle
                            ? "START"
                            : isRunning
                                ? "PAUSE"
                                : "RESUME",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 2),
                      ),
                    ),
                  ),
                  if (_currentState != PomodoroState.idle) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black, width: 3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          elevation: 0,
                        ),
                        onPressed: _stopTimer,
                        child: const Text(
                          "STOP",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
