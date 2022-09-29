import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_ume/core/ui/root_widget.dart';

import '../bean/fps_info.dart';
import '../util/collection_util.dart';
import 'fps_page.dart';

class PerformanceObserverWidget extends StatefulWidget {
  const PerformanceObserverWidget({Key? key}) : super(key: key);

  @override
  _PerformanceObserverWidgetState createState() => _PerformanceObserverWidgetState();
}

class _PerformanceObserverWidgetState extends State<PerformanceObserverWidget> {
  bool startRecording = false;
  bool fpsPageShowing = false;

  late Function(List<FrameTiming>) monitor;
  OverlayEntry? fpsInfoPage;

  @override
  void initState() {
    super.initState();
    monitor = (timings) {
      double duration = 0;
      timings.forEach((element) {
        FrameTiming frameTiming = element;
        duration = frameTiming.totalSpan.inMilliseconds.toDouble();
        FpsInfo fpsInfo = new FpsInfo();
        fpsInfo.totalSpan = max(16.7, duration);
        CommonStorage.instance!.save(fpsInfo);
      });
    };
    Future.delayed(Duration(milliseconds: 200), () => fpsMonitor());
  }

  @override
  void dispose() {
    stop();
    startRecording = false;
    CommonStorage.instance!.clear();
    // fpsInfoPage!.remove();
    // fpsPageShowing = false;
    super.dispose();
  }

  void start() {
    WidgetsBinding.instance.addTimingsCallback(monitor);
  }

  void stop() {
    WidgetsBinding.instance.removeTimingsCallback(monitor);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PerformanceOverlay.allEnabled(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Click To Scan Record',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        fpsMonitor();
      },
    );
  }

  void fpsMonitor() {
    if (!startRecording) {
      setState(() {
        start();
        startRecording = true;
      });
    } else {
      if (!fpsPageShowing) {
        stop();
        if (fpsInfoPage == null) {
          fpsInfoPage = OverlayEntry(builder: (c) {
            return Scaffold(
              body: Column(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        fpsInfoPage!.remove();
                        fpsPageShowing = false;
                        start();
                      },
                      child: Container(
                        color: Color(0x33999999),
                      ),
                    ),
                  ),
                  Container(
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          FpsPage(),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      )),
                ],
              ),
              backgroundColor: Color(0x33999999),
            );
          });
        }
        fpsPageShowing = true;
        overlayKey.currentState?.insert(fpsInfoPage!);
      }
    }
  }
}
