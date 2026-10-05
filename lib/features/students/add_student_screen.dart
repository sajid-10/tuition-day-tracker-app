import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'student_providers.dart';

class AddStudentScreen extends ConsumerStatefulWidget {
  const AddStudentScreen({super.key});

  @override
  ConsumerState<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends ConsumerState<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _durationController = TextEditingController(text: '120');
  final _thresholdController = TextEditingController(text: '120');
  final _targetDaysController = TextEditingController(text: '12');
  final _paymentRateController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  int _radiusMeters = 100;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _durationController.dispose();
    _thresholdController.dispose();
    _targetDaysController.dispose();
    _paymentRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.addStudent)),
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
            _sectionTitle(context, strings.studentDetails),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: strings.studentName,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? strings.studentNameRequired
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: strings.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: strings.address,
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, strings.locationCoordinates),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: InputDecoration(labelText: strings.latitude),
                    validator: (value) => _validateCoordinate(
                      value,
                      otherValue: _longitudeController.text,
                      minimum: -90,
                      maximum: 90,
                      message: strings.invalidCoordinates,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: InputDecoration(labelText: strings.longitude),
                    validator: (value) => _validateCoordinate(
                      value,
                      otherValue: _latitudeController.text,
                      minimum: -180,
                      maximum: 180,
                      message: strings.invalidCoordinates,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _radiusMeters,
              decoration: InputDecoration(labelText: strings.geofenceRadius),
              items: const [50, 75, 100, 150, 200]
                  .map(
                    (radius) => DropdownMenuItem(
                      value: radius,
                      child: Text('$radius ${strings.meterShort}'),
                    ),
                  )
                  .toList(),
              onChanged: (radius) {
                if (radius != null) {
                  setState(() => _radiusMeters = radius);
                }
              },
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, strings.sessionDuration),
            const SizedBox(height: 12),
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: strings.sessionDuration,
                suffixText: strings.minuteUnit,
              ),
              validator: (value) =>
                  _validateInteger(value, strings: strings, minimum: 1),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _thresholdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: strings.tuitionThreshold,
                suffixText: strings.minuteUnit,
              ),
              validator: (value) =>
                  _validateInteger(value, strings: strings, minimum: 1),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _targetDaysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: strings.paymentTargetDays,
                suffixText: strings.daysUnit,
              ),
              validator: (value) =>
                  _validateInteger(value, strings: strings, minimum: 1),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, strings.ratePerDay),
            const SizedBox(height: 12),
            TextFormField(
              controller: _paymentRateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: strings.paymentRate,
                prefixText: '৳ ',
              ),
              validator: (value) =>
                  _validateInteger(value, strings: strings, minimum: 0),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: strings.notes,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium
        ?.copyWith(fontWeight: FontWeight.w700),
  );

  String? _validateCoordinate(
    String? value, {
    required String otherValue,
    required double minimum,
    required double maximum,
    required String message,
  }) {
    final text = value?.trim() ?? '';
    final otherText = otherValue.trim();
    if (text.isEmpty && otherText.isEmpty) return null;
    final coordinate = double.tryParse(text);
    if (coordinate == null || coordinate < minimum || coordinate > maximum) {
      return message;
    }
    return null;
  }

  String? _validateInteger(
    String? value, {
    required AppLocalizations strings,
    required int minimum,
  }) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null) return strings.invalidNumber;
    if (parsed < minimum) return strings.invalidNumber;
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    if ((latitude == null) != (longitude == null)) {
      final strings = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.invalidCoordinates)));
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(studentRepositoryProvider)
          .addStudent(
            name: _nameController.text,
            phone: _phoneController.text,
            address: _addressController.text,
            latitude: latitude,
            longitude: longitude,
            geofenceRadiusMeters: _radiusMeters,
            sessionDurationMinutes: int.parse(_durationController.text),
            tuitionDayThresholdMinutes: int.parse(_thresholdController.text),
            completedDaysTarget: int.parse(_targetDaysController.text),
            paymentRate: int.parse(_paymentRateController.text),
            notes: _notesController.text,
          );
      if (mounted) Navigator.of(context).pop(true);
    } on Exception catch (error) {
      debugPrint('Unable to save student: $error');
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
