import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/local/database/app_database.dart';
import '../../l10n/app_localizations.dart';
import 'student_providers.dart';

class TuitionLocationEditorScreen extends ConsumerStatefulWidget {
  const TuitionLocationEditorScreen({required this.student, super.key});

  final Student student;

  @override
  ConsumerState<TuitionLocationEditorScreen> createState() =>
      _TuitionLocationEditorScreenState();
}

class _TuitionLocationEditorScreenState
    extends ConsumerState<TuitionLocationEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _thresholdController;
  late final TextEditingController _targetDaysController;
  late int _radiusMeters;
  bool _gettingLocation = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _latitudeController = TextEditingController(
      text: widget.student.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.student.longitude?.toString() ?? '',
    );
    _thresholdController = TextEditingController(
      text: '${widget.student.tuitionDayThresholdMinutes}',
    );
    _targetDaysController = TextEditingController(
      text: '${widget.student.completedDaysTarget}',
    );
    _radiusMeters = widget.student.geofenceRadiusMeters;
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _thresholdController.dispose();
    _targetDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.editTuitionLocation)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(strings.saveStudent),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.student.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _latitudeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(
                labelText: strings.latitude,
                prefixIcon: const Icon(Icons.north_outlined),
              ),
              validator: (value) => _validateCoordinate(
                value,
                minimum: -90,
                maximum: 90,
                strings: strings,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _longitudeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(
                labelText: strings.longitude,
                prefixIcon: const Icon(Icons.east_outlined),
              ),
              validator: (value) => _validateCoordinate(
                value,
                minimum: -180,
                maximum: 180,
                strings: strings,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _gettingLocation ? null : _useCurrentLocation,
              icon: _gettingLocation
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(strings.useCurrentLocation),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              initialValue: _radiusMeters,
              decoration: InputDecoration(labelText: strings.geofenceRadius),
              items: const [50, 75, 100, 150, 200]
                  .map(
                    (radius) => DropdownMenuItem(
                      value: radius,
                      child: Text('$radius m'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _radiusMeters = value);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _thresholdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: strings.tuitionThreshold,
                suffixText: strings.minuteUnit,
              ),
              validator: (value) => _validatePositiveInteger(value, strings),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _targetDaysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: strings.paymentTargetDays,
                suffixText: strings.daysUnit,
              ),
              validator: (value) => _validatePositiveInteger(value, strings),
            ),
            const SizedBox(height: 12),
            Text(
              strings.locationBackgroundNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateCoordinate(
    String? value, {
    required double minimum,
    required double maximum,
    required AppLocalizations strings,
  }) {
    final coordinate = double.tryParse(value?.trim() ?? '');
    if (coordinate == null || coordinate < minimum || coordinate > maximum) {
      return strings.invalidCoordinates;
    }
    return null;
  }

  String? _validatePositiveInteger(String? value, AppLocalizations strings) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null || number <= 0) return strings.invalidNumber;
    return null;
  }

  Future<void> _useCurrentLocation() async {
    final strings = AppLocalizations.of(context)!;
    setState(() => _gettingLocation = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw LocationSelectionException(strings.locationServicesDisabled);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw LocationSelectionException(strings.locationPermissionDenied);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      _latitudeController.text = position.latitude.toStringAsFixed(6);
      _longitudeController.text = position.longitude.toStringAsFixed(6);
    } on Exception catch (error) {
      if (mounted) {
        final message = error is LocationSelectionException
            ? error.message
            : strings.locationReadFailed;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(studentRepositoryProvider)
          .updateStudent(
            id: widget.student.id,
            name: widget.student.name,
            phone: widget.student.phone,
            address: widget.student.address,
            latitude: double.parse(_latitudeController.text.trim()),
            longitude: double.parse(_longitudeController.text.trim()),
            geofenceRadiusMeters: _radiusMeters,
            sessionDurationMinutes: widget.student.sessionDurationMinutes,
            tuitionDayThresholdMinutes: int.parse(_thresholdController.text),
            paymentRate: widget.student.paymentRate,
            completedDaysTarget: int.parse(_targetDaysController.text),
            notes: widget.student.notes,
          );
      if (mounted) Navigator.of(context).pop(true);
    } on Exception catch (error) {
      debugPrint('Unable to save tuition location: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.unknownError)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class LocationSelectionException implements Exception {
  const LocationSelectionException(this.message);

  final String message;
}
