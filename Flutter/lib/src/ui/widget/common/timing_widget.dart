import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/gen/colors.gen.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class TimingWidget extends StatefulWidget {
  const TimingWidget({Key? key}) : super(key: key);

  @override
  State<TimingWidget> createState() => _TimingWidgetState();
}

class _TimingWidgetState extends State<TimingWidget> {
  ITUINotificationCallback? refreshTimingCallBack;

  @override
  void initState() {
    super.initState();
    refreshTimingCallBack = (arg) {
      setState(() {});
    };
    TUICore.instance
        .registerEvent(setStateEventRefreshTiming, refreshTimingCallBack);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatCallTime(),
      textScaler: const TextScaler.linear(1.0),
      style: const TextStyle(
        color: ColorName.color0xFF00FF44,
        fontSize: 16,
        height: 1.25,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    TUICore.instance
        .unregisterEvent(setStateEventRefreshTiming, refreshTimingCallBack);
  }

  String _formatCallTime() {
    int hour = CallState.instance.timeCount ~/ 3600;
    String hourShow = hour <= 9 ? "0$hour" : "$hour";
    int minute = (CallState.instance.timeCount % 3600) ~/ 60;
    String minuteShow = minute <= 9 ? "0$minute" : "$minute";
    int second = CallState.instance.timeCount % 60;
    String secondShow = second <= 9 ? "0$second" : "$second";
    return hour > 0
        ? "$hourShow:$minuteShow:$secondShow"
        : "$minuteShow:$secondShow";
  }
}
