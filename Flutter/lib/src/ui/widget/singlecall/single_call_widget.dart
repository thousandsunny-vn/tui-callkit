import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/data/user.dart';
import 'package:tencent_calls_uikit/src/gen/assets.gen.dart';
import 'package:tencent_calls_uikit/src/gen/colors.gen.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_navigator_observer.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/circle_button.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/timing_widget.dart';
import 'package:tencent_calls_uikit/src/ui/widget/singlecall/single_function_widget.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class SingleCallWidget extends StatefulWidget {
  final Function close;

  const SingleCallWidget({
    Key? key,
    required this.close,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SingleCallWidgetState();
}

class _SingleCallWidgetState extends State<SingleCallWidget> {
  ITUINotificationCallback? setSateCallBack;
  bool _hadShowAcceptText = false;
  bool _isShowAcceptText = false;
  double _smallViewTop = 128;
  double _smallViewRight = 20;
  bool _isOnlyShowBigVideoView = false;

  final Widget _localVideoView = TUIVideoView(
      key: CallState.instance.selfUser.key,
      onPlatformViewCreated: (viewId) {
        CallState.instance.selfUser.viewID = viewId;
        if (CallState.instance.isCameraOpen) {
          CallManager.instance.openCamera(CallState.instance.camera, viewId);
        }
      });

  final Widget _remoteVideoView = TUIVideoView(
    key: CallState.instance.remoteUserList.isEmpty
        ? GlobalKey()
        : CallState.instance.remoteUserList[0].key,
    onPlatformViewCreated: (viewId) {
      CallState.instance.remoteUserList[0].viewID = viewId;
      CallManager.instance
          .startRemoteView(CallState.instance.remoteUserList[0].id, viewId);
    },
  );

  TUICallStatus get _callStatus => CallState.instance.selfUser.callStatus;

  TUICallMediaType get _mediaType => CallState.instance.mediaType;

  bool get _isLocalViewBig {
    return _callStatus == TUICallStatus.waiting ||
        (!CallState.instance.isChangedBigSmallVideo);
  }

  String get _remoteAvatar {
    if (CallState.instance.remoteUserList.isNotEmpty) {
      return StringStream.makeNull(
        CallState.instance.remoteUserList[0].avatar,
        Constants.defaultAvatar,
      );
    }

    return '';
  }

  bool get _isRemoteViewSmall {
    return _callStatus != TUICallStatus.accept ||
        !CallState.instance.isChangedBigSmallVideo;
  }

  bool get _remoteVideoAvailable {
    if (CallState.instance.remoteUserList.isNotEmpty) {
      return CallState.instance.remoteUserList[0].videoAvailable;
    }

    return false;
  }

  bool get _remoteAudioAvailable {
    if (CallState.instance.remoteUserList.isNotEmpty) {
      return CallState.instance.remoteUserList[0].audioAvailable;
    }

    return false;
  }

  String get _selfAvatar {
    return StringStream.makeNull(
      CallState.instance.selfUser.avatar,
      Constants.defaultAvatar,
    );
  }

  bool get _isCameraOpen => CallState.instance.isCameraOpen;

  String get _nickname {
    var showName = '';
    if (CallState.instance.remoteUserList.isNotEmpty) {
      showName = User.getUserDisplayName(CallState.instance.remoteUserList[0]);
    }

    return showName;
  }

  @override
  void initState() {
    super.initState();
    setSateCallBack = (arg) {
      if (mounted) {
        setState(() {});
      }
    };
    TUICore.instance.registerEvent(setStateEvent, setSateCallBack);
  }

  @override
  dispose() {
    super.dispose();
    TUICore.instance.unregisterEvent(setStateEvent, setSateCallBack);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarEmpty(),
      extendBodyBehindAppBar: true,
      body: Container(
        color: _getBackgroundColor(),
        child: Stack(
          alignment: Alignment.topLeft,
          fit: StackFit.expand,
          children: [
            _buildBackground(),
            _buildBigVideoWidget(),
            if (!_isOnlyShowBigVideoView) _buildSmallVideoWidget(),
            if (!_isOnlyShowBigVideoView) _buildFloatingWindowBtnWidget(),
            if (!_isOnlyShowBigVideoView) _buildVideoTimerWidget(),
            if (!_isOnlyShowBigVideoView) _buildUserInfoAndTimerWidget(),
            if (!_isOnlyShowBigVideoView) _buildHintTextWidget(),
            if (!_isOnlyShowBigVideoView) _buildTextDisableCamera(),
            if (!_isOnlyShowBigVideoView) _buildFunctionButtonWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextDisableCamera() {
    if (_mediaType == TUICallMediaType.video &&
        _callStatus == TUICallStatus.accept &&
        !_remoteVideoAvailable) {
      return Positioned(
        bottom: 142,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              Assets.icons.cameraOff.path,
              width: 18,
              height: 18,
              package: 'tencent_calls_uikit',
            ),
            const Gap(4),
            Text(
              '$_nickname đang tắt Camera',
              style: const TextStyle(
                color: ColorName.color0xFFFFFFFF,
                fontSize: 14,
                height: 1.50,
              ),
            )
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  AppBar _appBarEmpty() {
    return AppBar(
      toolbarHeight: 0,
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildBackground() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image(
          height: double.infinity,
          image: NetworkImage(_remoteAvatar),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/user_icon.png',
            package: 'tencent_calls_uikit',
          ),
        ),
        Opacity(
          opacity: 1,
          child: Container(
            color: const Color.fromRGBO(45, 45, 45, 0.9),
          ),
        )
      ],
    );
  }

  _buildFloatingWindowBtnWidget() {
    return CallState.instance.enableFloatWindow
        ? Positioned(
            left: 12,
            top: 52,
            child: FuncButton.circle(
              onPressed: _openFloatWindow,
              padding: const EdgeInsets.all(8),
              iconHeight: 26,
              path: Assets.icons.floatingButton.path,
            ),
          )
        : const SizedBox();
  }

  Widget _buildVideoTimerWidget() {
    if (_mediaType == TUICallMediaType.video &&
        _callStatus == TUICallStatus.accept) {
      return Positioned(
        left: 0,
        right: 0,
        top: 52,
        child: Column(
          children: [
            Text(
              _nickname,
              style: const TextStyle(
                height: 1.22,
                color: ColorName.color0xFFFFFFFF,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.01,
              ),
            ),
            const Gap(4),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: const TimingWidget(),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildUserInfoAndTimerWidget() {
    final userInfoWidget = Positioned(
      top: MediaQuery.of(context).size.height / 5,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Image(
              image: NetworkImage(_remoteAvatar),
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stackTrace) => Image.asset(
                'assets/images/user_icon.png',
                package: 'tencent_calls_uikit',
              ),
            ),
          ),
          const Gap(12),
          Text(
            _nickname,
            textScaler: const TextScaler.linear(1.0),
            style: const TextStyle(
              fontSize: 24,
              color: ColorName.color0xFFFFFFFF,
              fontWeight: FontWeight.w500,
              height: 1.40,
            ),
          ),
          const Gap(8),
          if (_callStatus == TUICallStatus.accept) const TimingWidget()
        ],
      ),
    );

    if (_mediaType == TUICallMediaType.video &&
        _callStatus == TUICallStatus.accept) {
      return const SizedBox.shrink();
    }
    return userInfoWidget;
  }

  Widget _buildHintTextWidget() {
    final callRole = CallState.instance.selfUser.callRole;

    if (callRole == TUICallRole.caller &&
        _callStatus == TUICallStatus.accept &&
        CallState.instance.timeCount < 1) {
      if (!_hadShowAcceptText) {
        _isShowAcceptText = true;
        Timer(const Duration(seconds: 1), () {
          setState(() {
            _isShowAcceptText = false;
            _hadShowAcceptText = true;
          });
        });
      }
    }

    return Positioned(
      top: MediaQuery.of(context).size.height * 2 / 3,
      width: MediaQuery.of(context).size.width,
      child: _hintText(callRole),
    );
  }

  Widget _hintText(TUICallRole callRole) {
    String hintText = '';
    TextStyle textStyle;

    if (_isShowAcceptText) {
      hintText = 'Đã kết nối';
      textStyle = const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: ColorName.color0xFFFFFFFF,
      );
    } else {
      hintText = _hintTextStatus(
        callRole,
        _callStatus == TUICallStatus.waiting,
      );
      textStyle = const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: ColorName.color0xFFFFFFFF,
      );
    }

    return Center(
      child: hintText.isNotEmpty
          ? Text(
              hintText,
              textScaler: const TextScaler.linear(1.0),
              style: textStyle,
            )
          : const SizedBox.shrink(),
    );
  }

  String _hintTextStatus(TUICallRole callRole, bool isWaiting) {
    String textStatus = '';
    final networkQualityReminder = CallState.instance.networkQualityReminder;

    if (isWaiting && callRole == TUICallRole.called) {
      textStatus = _mediaType == TUICallMediaType.audio
          ? 'Cuộc gọi đến'
          : 'Cuộc gọi video...';
    } else if (networkQualityReminder == NetworkQualityHint.local) {
      textStatus = 'Đang tìm cách kết nối lại...';
    } else if (networkQualityReminder == NetworkQualityHint.remote) {
      textStatus = CallKit_t("Mạng bên kia chất lượng thấp");
    } else if (isWaiting) {
      textStatus = CallKit_t("Đang kết nối với người nhận...");
    }

    return textStatus;
  }

  Widget _buildFunctionButtonWidget() {
    return Positioned(
      left: 0,
      bottom: 50,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [SingleFunctionWidget.buildFunctionWidget(widget.close)],
      ),
    );
  }

  Widget _buildBigVideoWidget() {
    if (_mediaType == TUICallMediaType.video) {
      return InkWell(
        onTap: () {
          setState(() {
            _isOnlyShowBigVideoView = !_isOnlyShowBigVideoView;
          });
        },
        child: ColoredBox(
          color: Colors.black54,
          child: Stack(
            children: [
              if (_callStatus == TUICallStatus.accept)
                Visibility(
                  visible: (_isLocalViewBig
                      ? !_isCameraOpen
                      : !_remoteVideoAvailable),
                  child: Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image(
                        image: NetworkImage(
                          _isLocalViewBig ? _selfAvatar : _remoteAvatar,
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Image.asset(
                            'assets/images/user_icon.png',
                            package: 'tencent_calls_uikit',
                          );
                        },
                      ),
                    ),
                  ),
                ),
              Opacity(
                opacity: _isLocalViewBig
                    ? _getOpacityByVis(_isCameraOpen)
                    : _getOpacityByVis(_remoteVideoAvailable),
                child: _isLocalViewBig ? _localVideoView : _remoteVideoView,
              )
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSmallVideoWidget() {
    if (_mediaType == TUICallMediaType.audio) {
      return const SizedBox();
    }

    var smallVideoWidget = _callStatus == TUICallStatus.accept
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 180,
              width: 110,
              color: Colors.black54,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Visibility(
                    visible: (_isRemoteViewSmall
                        ? !_remoteVideoAvailable
                        : !_isCameraOpen),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: Image(
                        image: NetworkImage(
                          _isRemoteViewSmall ? _remoteAvatar : _selfAvatar,
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/user_icon.png',
                          package: 'tencent_calls_uikit',
                        ),
                      ),
                    ),
                  ),
                  Opacity(
                      opacity: _isRemoteViewSmall
                          ? _getOpacityByVis(_remoteVideoAvailable)
                          : _getOpacityByVis(_isCameraOpen),
                      child: _isRemoteViewSmall
                          ? _remoteVideoView
                          : _localVideoView),
                  Positioned(
                    left: 5,
                    bottom: 5,
                    width: 20,
                    height: 20,
                    child: (_isRemoteViewSmall && !_remoteAudioAvailable)
                        ? Image.asset(
                            'assets/images/audio_unavailable_grey.png',
                            package: 'tencent_calls_uikit',
                          )
                        : const SizedBox.shrink(),
                  )
                ],
              ),
            ),
          )
        : const SizedBox.shrink();

    return Positioned(
      top: 110,
      right: 16,
      child: GestureDetector(
        onTap: () {
          _changeVideoView();
        },
        onPanUpdate: (DragUpdateDetails e) {
          if (_mediaType == TUICallMediaType.video) {
            _smallViewRight -= e.delta.dx;
            _smallViewTop += e.delta.dy;
            if (_smallViewTop < 100) {
              _smallViewTop = 100;
            }
            if (_smallViewTop > MediaQuery.of(context).size.height - 216) {
              _smallViewTop = MediaQuery.of(context).size.height - 216;
            }
            if (_smallViewRight < 0) {
              _smallViewRight = 0;
            }
            if (_smallViewRight > MediaQuery.of(context).size.width - 110) {
              _smallViewRight = MediaQuery.of(context).size.width - 110;
            }
            setState(() {});
          }
        },
        child: SizedBox(
          width: 110,
          child: smallVideoWidget,
        ),
      ),
    );
  }

  void _changeVideoView() {
    if (_mediaType == TUICallMediaType.audio ||
        _callStatus == TUICallStatus.waiting) {
      return;
    }

    setState(() {
      CallState.instance.isChangedBigSmallVideo =
          !CallState.instance.isChangedBigSmallVideo;
    });
  }

  double _getOpacityByVis(bool vis) {
    return vis ? 1.0 : 0;
  }

  void _openFloatWindow() async {
    if (Platform.isAndroid) {
      bool result = await TUICallKitPlatform.instance.hasFloatPermission();
      if (!result) {
        return;
      }
    }
    TUICallKitNavigatorObserver.getInstance().exitCallingPage();
    CallManager.instance.openFloatWindow();
  }

  Color _getBackgroundColor() {
    return _mediaType == TUICallMediaType.audio
        ? const Color(0xFFF2F2F2)
        : const Color(0xFF444444);
  }
}
