import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/gen/assets.gen.dart';
import 'package:tencent_calls_uikit/src/gen/colors.gen.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/circle_button.dart';
import 'package:tencent_calls_uikit/src/utils/permission.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class SingleFunctionWidget {
  /// Refactor
  static Widget buildFunctionWidget(Function close) {
    final callStatus = CallState.instance.selfUser.callStatus;
    final callRole = CallState.instance.selfUser.callRole;
    final mediaType = CallState.instance.mediaType;

    if (callStatus == TUICallStatus.waiting) {
      return _buildWaitingWidget(callRole, mediaType, close);
    }

    if (callStatus == TUICallStatus.accept) {
      return _buildAcceptedWidget(mediaType, close);
    }

    return const SizedBox.shrink();
  }

  static Widget _buildAcceptedWidget(
    TUICallMediaType mediaType,
    Function close,
  ) {
    if (mediaType == TUICallMediaType.audio) {
      return _buildAudioCallerWaitingAndAcceptedView(close);
    }

    return _buildVideoCallerAndCalleeAcceptedView(close);
  }

  static Widget _buildWaitingWidget(
    TUICallRole callRole,
    TUICallMediaType mediaType,
    Function close,
  ) {
    if (TUICallRole.caller == callRole) {
      if (mediaType == TUICallMediaType.audio) {
        return _buildAudioCallerWaitingAndAcceptedView(close);
      }

      if (CallState.instance.showVirtualBackgroundButton) {
        return _buildVBgVideoCallerWaitingView(close);
      }

      return _buildVideoCallerWaitingView(close);
    }

    return _buildAudioAndVideoCalleeWaitingView(close);
  }

  static Widget _buildAudioCallerWaitingAndAcceptedView(Function close) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMicControlButton(),
        _buildHangupButton(close),
        _buildSpeakerphoneButton(),
      ],
    );
  }

  static Widget _buildVideoCallerWaitingView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _buildSwitchCameraButton(),
          _buildHangupButton(close),
          _buildCameraControlButton(),
        ]),
      ],
    );
  }

  static Widget _buildVBgVideoCallerWaitingView(Function close) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 44),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSwitchCameraButton(),
              _buildVirtualBackgroundButton(),
              _buildCameraControlButton(),
              _buildHangupButton(close),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildVideoCallerAndCalleeAcceptedView(Function close) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMicControlButton(),
              const Spacer(),
              _buildCameraControlButton(),
              const Spacer(),
              _buildHangupButton(close),
              const Spacer(),
              _buildVirtualBackgroundButton(),
              const Spacer(),
              _buildSwitchCameraButton(),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildAudioAndVideoCalleeWaitingView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FuncButton.circleTips(
              path: Assets.icons.deny.path,
              fit: BoxFit.cover,
              iconHeight: 40,
              padding: const EdgeInsets.all(16),
              onPressed: () => _handleReject(close),
              backgroundColor: ColorName.color0xFFFE090E,
              tips: 'Từ chối',
              // tips: CallKit_t("hangUp"),
            ),
            FuncButton.circleTips(
              path: Assets.icons.accept.path,
              fit: BoxFit.cover,
              iconHeight: 40,
              padding: const EdgeInsets.all(16),
              onPressed: _handleAccept,
              backgroundColor: ColorName.color0xFF0094FF,
              tips: 'Chấp nhận',
              // tips: CallKit_t("accept"),
            ),
          ],
        )
      ],
    );
  }

  static _handleSwitchMic() async {
    if (CallState.instance.isMicrophoneMute) {
      CallState.instance.isMicrophoneMute = false;
      await CallManager.instance.openMicrophone();
    } else {
      CallState.instance.isMicrophoneMute = true;
      await CallManager.instance.closeMicrophone();
    }
    TUICore.instance.notifyEvent(setStateEvent);
  }

  static _handleSwitchAudioDevice() async {
    if (CallState.instance.audioDevice == TUIAudioPlaybackDevice.earpiece) {
      CallState.instance.audioDevice = TUIAudioPlaybackDevice.speakerphone;
    } else {
      CallState.instance.audioDevice = TUIAudioPlaybackDevice.earpiece;
    }
    await CallManager.instance
        .selectAudioPlaybackDevice(CallState.instance.audioDevice);
    TUICore.instance.notifyEvent(setStateEvent);
  }

  static Widget _buildSpeakerphoneButton() {
    var path = Assets.icons.handsfree.path;
    var backgroundColor = ColorName.color0xFFFFFFFF.withOpacity(0.20);
    var iconColor = ColorName.color0xFFFFFFFF;
    if (CallState.instance.audioDevice == TUIAudioPlaybackDevice.speakerphone) {
      path = Assets.icons.handsfreeOn.path;
      backgroundColor = ColorName.color0xFFFFFFFF;
      iconColor = ColorName.color0xFF000000;
    }

    return FuncButton.circle(
      path: path,
      fit: BoxFit.cover,
      padding: const EdgeInsets.all(14),
      onPressed: _handleSwitchAudioDevice,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
    );
  }

  static Widget _buildCameraControlButton() {
    var path = Assets.icons.cameraOff.path;
    var backgroundColor = ColorName.color0xFFFFFFFF;
    var iconColor = ColorName.color0xFF000000;
    if (CallState.instance.isCameraOpen) {
      path = Assets.icons.cameraOn.path;
      backgroundColor = ColorName.color0xFFFFFFFF.withOpacity(0.20);
      iconColor = ColorName.color0xFFFFFFFF;
    }

    return FuncButton.circle(
      path: path,
      fit: BoxFit.cover,
      iconHeight: 26,
      padding: const EdgeInsets.all(12),
      onPressed: _handleOpenCloseCamera,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
    );
  }

  static Widget _buildMicControlButton() {
    var path = Assets.icons.mute.path;
    var backgroundColor = ColorName.color0xFFFFFFFF.withOpacity(0.20);
    var iconColor = ColorName.color0xFFFFFFFF;
    if (CallState.instance.isMicrophoneMute) {
      path = Assets.icons.muteOn.path;
      backgroundColor = ColorName.color0xFFFFFFFF;
      iconColor = ColorName.color0xFF000000;
    }

    return FuncButton.circle(
      path: path,
      fit: BoxFit.cover,
      padding: const EdgeInsets.all(14),
      onPressed: _handleSwitchMic,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
    );
  }

  static Widget _buildHangupButton(Function close) {
    return FuncButton.circle(
      path: Assets.icons.hangup.path,
      fit: BoxFit.cover,
      iconHeight: 26,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      onPressed: () => _handleHangUp(close),
      backgroundColor: ColorName.color0xFFFE090E,
    );
  }

  static Widget _buildSwitchCameraButton() {
    var backgroundColor = ColorName.color0xFFFFFFFF.withOpacity(0.20);
    var iconColor = ColorName.color0xFFFFFFFF;
    if (CallState.instance.camera == TUICamera.back) {
      backgroundColor = ColorName.color0xFFFFFFFF;
      iconColor = ColorName.color0xFF000000;
    }
    if (!CallState.instance.isCameraOpen) {
      iconColor = ColorName.color0xFF000000.withOpacity(0.30);
      backgroundColor = ColorName.color0xFFFFFFFF.withOpacity(0.20);
    }

    return FuncButton.circle(
      path: Assets.icons.switchCamera.path,
      fit: BoxFit.cover,
      iconHeight: 26,
      padding: const EdgeInsets.all(12),
      onPressed: !CallState.instance.isCameraOpen ? null : _handleSwitchCamera,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
    );
  }

  static Widget _buildVirtualBackgroundButton() {
    var backgroundColor = ColorName.color0xFFFFFFFF.withOpacity(0.20);
    var iconColor = ColorName.color0xFFFFFFFF;
    if (CallState.instance.enableBlurBackground) {
      backgroundColor = ColorName.color0xFFFFFFFF;
      iconColor = ColorName.color0xFF000000;
    }

    if (!CallState.instance.isCameraOpen) {
      iconColor = ColorName.color0xFF000000.withOpacity(0.30);
      backgroundColor = ColorName.color0xFFFFFFFF.withOpacity(0.20);
    }

    return FuncButton.circle(
      path: Assets.icons.blurBackground.path,
      fit: BoxFit.cover,
      padding: const EdgeInsets.all(14),
      onPressed:
          !CallState.instance.isCameraOpen ? null : _handleOpenBlurBackground,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
    );
  }

  static _handleHangUp(Function close) async {
    await CallManager.instance.hangup();
    close();
  }

  static _handleReject(Function close) async {
    await CallManager.instance.reject();
    close();
  }

  static _handleAccept() async {
    PermissionResult permissionRequestResult = PermissionResult.requesting;
    if (Platform.isAndroid) {
      permissionRequestResult =
          await Permission.request(CallState.instance.mediaType);
    }
    if (permissionRequestResult == PermissionResult.granted || Platform.isIOS) {
      await CallManager.instance.accept();
      CallState.instance.selfUser.callStatus = TUICallStatus.accept;
    } else {
      CallManager.instance.showToast(CallKit_t("insufficientPermissions"));
    }
    TUICore.instance.notifyEvent(setStateEvent);
  }

  static void _handleOpenCloseCamera() async {
    CallState.instance.isCameraOpen = !CallState.instance.isCameraOpen;
    if (CallState.instance.isCameraOpen) {
      await CallManager.instance.openCamera(
        CallState.instance.camera,
        CallState.instance.selfUser.viewID,
      );
    } else {
      await CallManager.instance.closeCamera();
    }
    TUICore.instance.notifyEvent(setStateEvent);
  }

  static void _handleOpenBlurBackground() async {
    CallState.instance.enableBlurBackground =
        !CallState.instance.enableBlurBackground;
    await CallManager.instance
        .setBlurBackground(CallState.instance.enableBlurBackground);
    TUICore.instance.notifyEvent(setStateEvent);
  }

  static void _handleSwitchCamera() async {
    if (TUICamera.front == CallState.instance.camera) {
      CallState.instance.camera = TUICamera.back;
    } else {
      CallState.instance.camera = TUICamera.front;
    }
    await CallManager.instance.switchCamera(CallState.instance.camera);
    TUICore.instance.notifyEvent(setStateEvent);
  }
}
