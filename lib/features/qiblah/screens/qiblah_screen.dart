import 'dart:async';
import 'dart:math' show pi;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:thekr_app/core/services/prayer_service.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/widgets/app_scaffold.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/features/qiblah/services/magnetic_declination.dart';

@RoutePage()
class QiblahScreen extends StatefulWidget {
  const QiblahScreen({Key? key}) : super(key: key);

  @override
  _QiblahScreenState createState() => _QiblahScreenState();
}

class _QiblahScreenState extends State<QiblahScreen> {
  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'اتجاه القبلة',
      body: FutureBuilder(
        future: _deviceSupport,
        builder: (_, AsyncSnapshot<bool?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error.toString()}",
                style: context.textStyles.bodyMedium,
              ),
            );
          }
          if (snapshot.data!) {
            return QiblahCompass();
          } else {
            return Center(
              child: Text(
                "Your device is not supported",
                style: context.textStyles.bodyMedium,
              ),
            );
          }
        },
      ),
    );
  }
}

///////////////////////////////////////////
class LocationErrorWidget extends StatelessWidget {
  final String? error;
  final Function? callback;

  const LocationErrorWidget({Key? key, this.error, this.callback})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppIcon(HugeIcons.strokeRoundedLocationOffline01, size: 150, color: context.colors.error),
          const SizedBox(height: 32),
          Text(
            error!,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            child: const Text("أعد المحاولة"),
            onPressed: () {
              if (callback != null) callback!();
            },
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////
class QiblahCompass extends StatefulWidget {
  @override
  _QiblahCompassState createState() => _QiblahCompassState();
}

class _QiblahCompassState extends State<QiblahCompass> {
  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();

  get stream => _locationStreamController.stream;

  Future<void> _checkLocationStatus() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        await PrayerService.refreshLocation();
      }

      final s = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(s);
    } catch (e) {
      debugPrint("Error checking location: $e");
      final s = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(s);
    }
  }

  @override
  void initState() {
    _checkLocationStatus();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _locationStreamController.close();
    FlutterQiblah().dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: stream,
        builder: (context, AsyncSnapshot<LocationStatus> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.enabled == true) {
            switch (snapshot.data!.status) {
              case LocationPermission.always:
              case LocationPermission.whileInUse:
                return QiblahCompassWidget();

              case LocationPermission.denied:
                return LocationErrorWidget(
                  error: "تم رفض إذن خدمة الموقع",
                  callback: _checkLocationStatus,
                );
              case LocationPermission.deniedForever:
                return LocationErrorWidget(
                  error: "يجب تشغيل خدمة الموقع",
                  callback: _checkLocationStatus,
                );
              default:
                return Container();
            }
          } else {
            return LocationErrorWidget(
              error: "الرجاء تمكين خدمة الموقع",
              callback: _checkLocationStatus,
            );
          }
        },
      ),
    );
  }
}

class QiblahCompassWidget extends StatefulWidget {
  const QiblahCompassWidget({super.key});

  @override
  State<QiblahCompassWidget> createState() => _QiblahCompassWidgetState();
}

class _QiblahCompassWidgetState extends State<QiblahCompassWidget> {
  /// Tolerance (in degrees) within which the phone is considered facing Qibla.
  static const double _alignedTolerance = 3;

  /// The compass of the phone points to magnetic north, the Qibla bearing is
  /// measured from true north: this is the difference at the user's place.
  double _declination = 0;

  /// The compass says it is not sure (it needs the "figure eight" movement).
  bool _needsCalibration = false;
  StreamSubscription<CompassEvent>? _accuracySub;

  @override
  void initState() {
    super.initState();
    _loadDeclination();
    _accuracySub = FlutterCompass.events?.listen((event) {
      final low = (event.accuracy ?? 0) >= 45;
      if (low != _needsCalibration && mounted) {
        setState(() => _needsCalibration = low);
      }
    });
  }

  @override
  void dispose() {
    _accuracySub?.cancel();
    super.dispose();
  }

  Future<void> _loadDeclination() async {
    final location = await PrayerService.getLocation();
    if (!location.isKnown) return;
    final value = await MagneticDeclination.at(
      location.coordinates.latitude,
      location.coordinates.longitude,
    );
    if (mounted) setState(() => _declination = value);
  }

  @override
  Widget build(BuildContext context) {
    final compassSvg = SvgPicture.asset(AppAssets.compass, fit: BoxFit.contain);
    final needleSvg = SvgPicture.asset(AppAssets.needle, fit: BoxFit.contain);

    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream.where(
        (direction) =>
            direction.direction.isFinite && direction.qiblah.isFinite,
      ),
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final qiblahDirection = snapshot.data!;

        if (!qiblahDirection.direction.isFinite ||
            !qiblahDirection.qiblah.isFinite) {
          return const Center(child: CircularProgressIndicator());
        }

        final colors = context.colors;
        var delta = (qiblahDirection.qiblah + _declination) % 360;
        if (delta > 180) delta -= 360;
        final isAligned = delta.abs() <= _alignedTolerance;
        final accent = isAligned ? colors.success : colors.secondary;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: EdgeInsets.all(context.insets.md),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // Soft halo behind the dial, turns green once aligned.
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.35),
                            blurRadius: isAligned ? 48.r : 32.r,
                            spreadRadius: isAligned ? 6.r : 1.r,
                          ),
                        ],
                      ),
                    ),
                    Transform.rotate(
                      angle:
                          (qiblahDirection.direction + _declination) *
                          (pi / 180) *
                          -1,
                      child: compassSvg,
                    ),
                    Transform.rotate(
                      angle: (qiblahDirection.qiblah + _declination) * (pi / 180) * -1,
                      child: needleSvg,
                    ),
                    // Fixed marker showing where the phone is pointing.
                    Positioned(
                      top: 0,
                      child: AppIcon(
                        HugeIcons.strokeRoundedArrowDown01,
                        size: 36.sp,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.insets.lg),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: context.insets.lg,
                vertical: context.insets.sm + 2.w,
              ),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(context.corners.xl),
                border: Border.all(color: accent.withValues(alpha: 0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(
                    isAligned
                        ? HugeIcons.strokeRoundedCheckmarkCircle02
                        : HugeIcons.strokeRoundedCompass,
                    color: accent,
                    size: 22.sp,
                  ),
                  SizedBox(width: context.insets.sm),
                  Text(
                    isAligned
                        ? 'أنت في اتجاه القبلة'
                        : 'أدر هاتفك نحو الكعبة المشرفة',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.insets.md),
            Text(
              qiblahDirection.offset.isFinite
                  ? '${qiblahDirection.offset.toStringAsFixed(1)}° عن الشمال'
                  : '...',
              style: context.textStyles.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            if (_needsCalibration) ...[
              SizedBox(height: context.insets.sm),
              Text(
                'البوصلة غير دقيقة، حرّك هاتفك على شكل ٨ لمعايرتها',
                textAlign: TextAlign.center,
                style: context.textStyles.bodySmall?.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
