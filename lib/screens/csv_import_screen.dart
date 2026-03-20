import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/csv_import_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Entry point
// ─────────────────────────────────────────────────────────────────────────────

class CsvImportScreen extends StatefulWidget {
  /// The CRM to import into (e.g. 'followupboss').
  final String provider;

  /// Human-readable CRM name shown in headings.
  final String crmName;

  const CsvImportScreen({
    super.key,
    required this.provider,
    required this.crmName,
  });

  @override
  State<CsvImportScreen> createState() => _CsvImportScreenState();
}

// ─────────────────────────────────────────────────────────────────────────────
//  Steps
// ─────────────────────────────────────────────────────────────────────────────

enum _Step { upload, map, preview, importing, done }

// ─────────────────────────────────────────────────────────────────────────────
//  State
// ─────────────────────────────────────────────────────────────────────────────

class _CsvImportScreenState extends State<CsvImportScreen> {
  _Step _step = _Step.upload;

  // parsed CSV
  List<String> _headers = [];
  List<List<String>> _rows = [];
  List<CrmField> _mappings = [];

  // import state
  int _progressDone = 0;
  int _progressTotal = 0;
  CsvImportResult? _result;

  bool _pickingFile = false;
  String? _fileError;
  String? _fileName;

  final _service = CsvImportService();

  // ── file picking ─────────────────────────────────────────────────────────

  Future<void> _pickFile() async {
    setState(() {
      _pickingFile = true;
      _fileError = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _pickingFile = false);
        return;
      }

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        setState(() {
          _pickingFile = false;
          _fileError = 'Could not read file bytes. Please try again.';
        });
        return;
      }

      _processFile(file.name, bytes);
    } catch (e) {
      setState(() {
        _pickingFile = false;
        _fileError = 'Error picking file: $e';
      });
    }
  }

  void _processFile(String name, Uint8List bytes) {
    final parsed = CsvImportService.parseCsvBytes(bytes);

    if (parsed.headers.isEmpty) {
      setState(() {
        _pickingFile = false;
        _fileError = 'The file appears to be empty or could not be parsed.';
      });
      return;
    }

    setState(() {
      _pickingFile = false;
      _fileName = name;
      _headers = parsed.headers;
      _rows = parsed.rows;
      _mappings = CsvImportService.autoDetectMappings(parsed.headers);
      _step = _Step.map;
    });
  }

  // ── import ───────────────────────────────────────────────────────────────

  Future<void> _startImport() async {
    setState(() {
      _step = _Step.importing;
      _progressDone = 0;
      _progressTotal = _rows.length;
    });

    final result = await _service.importToFollowUpBoss(
      rows: _rows,
      mappings: _mappings,
      onProgress: (done, total) {
        if (mounted) setState(() => _progressDone = done);
      },
    );

    if (mounted) {
      setState(() {
        _result = result;
        _step = _Step.done;
      });
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.sidebarBg,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.white70, size: 18),
                onPressed: () {
                  if (_step == _Step.map || _step == _Step.preview) {
                    setState(() => _step = _Step.upload);
                  } else if (_step != _Step.importing) {
                    Navigator.of(context).pop();
                  }
                },
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Import Contacts from CSV',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            Text('→ ${widget.crmName}',
                style: TextStyle(
                    color: AppColors.copper.withOpacity(0.9), fontSize: 11)),
          ],
        ),
        actions: [
          if (_step == _Step.map)
            TextButton(
              onPressed: () => setState(() => _step = _Step.preview),
              child: const Text('Preview →',
                  style: TextStyle(color: AppColors.copper)),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case _Step.upload:
        return _UploadStep(
          key: const ValueKey('upload'),
          isLoading: _pickingFile,
          errorMessage: _fileError,
          onPickFile: _pickFile,
        );
      case _Step.map:
        return _MappingStep(
          key: const ValueKey('map'),
          fileName: _fileName ?? '',
          headers: _headers,
          rows: _rows,
          mappings: _mappings,
          onMappingChanged: (i, field) {
            setState(() => _mappings[i] = field);
          },
          onNext: () => setState(() => _step = _Step.preview),
          onBack: () => setState(() => _step = _Step.upload),
        );
      case _Step.preview:
        return _PreviewStep(
          key: const ValueKey('preview'),
          headers: _headers,
          rows: _rows,
          mappings: _mappings,
          onBack: () => setState(() => _step = _Step.map),
          onImport: _startImport,
        );
      case _Step.importing:
        return _ImportingStep(
          key: const ValueKey('importing'),
          done: _progressDone,
          total: _progressTotal,
        );
      case _Step.done:
        return _DoneStep(
          key: const ValueKey('done'),
          result: _result!,
          onDone: () => Navigator.of(context).pop(),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Step 1 — Upload
// ─────────────────────────────────────────────────────────────────────────────

class _UploadStep extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onPickFile;

  const _UploadStep({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepIndicator(current: 0),
            const SizedBox(height: 36),
            // drop-zone card
            GestureDetector(
              onTap: isLoading ? null : onPickFile,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.symmetric(vertical: 52, horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isLoading
                        ? AppColors.copper
                        : AppColors.copper.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: isLoading
                    ? const Column(
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.copper,
                            strokeWidth: 2,
                          ),
                          SizedBox(height: 16),
                          Text('Reading file…',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 14)),
                        ],
                      )
                    : Column(
                        children: [
                          Icon(Icons.upload_file_outlined,
                              color: AppColors.copper.withOpacity(0.7),
                              size: 52),
                          const SizedBox(height: 16),
                          const Text('Choose a CSV file',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to browse for a .csv file from your device.\n'
                            'The first row must contain column headers.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.45),
                                fontSize: 13,
                                height: 1.5),
                          ),
                        ],
                      ),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              _ErrorBanner(message: errorMessage!),
            ],
            const SizedBox(height: 32),
            // Format hints
            _FormatHints(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Step 2 — Column Mapping
// ─────────────────────────────────────────────────────────────────────────────

class _MappingStep extends StatelessWidget {
  final String fileName;
  final List<String> headers;
  final List<List<String>> rows;
  final List<CrmField> mappings;
  final void Function(int index, CrmField field) onMappingChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _MappingStep({
    super.key,
    required this.fileName,
    required this.headers,
    required this.rows,
    required this.mappings,
    required this.onMappingChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final mappedCount =
        mappings.where((f) => f != CrmField.ignore).length;
    final sampleRows = rows.take(3).toList();

    return Column(
      children: [
        _StepIndicator(current: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // file info row
                Row(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined,
                        color: AppColors.copper, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(fileName,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                    ),
                    _Chip(
                      label: '${rows.length} rows',
                      color: AppColors.copper,
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      label: '$mappedCount / ${headers.length} mapped',
                      color: mappedCount > 0
                          ? AppColors.approveText
                          : Colors.white38,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // mapping table
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Map CSV Columns',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        'We auto-detected fields based on your column names. '
                        'Adjust any mappings before importing.',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      // header row
                      _tableHeaderRow(),
                      const Divider(color: Color(0xFF2A2A2A), height: 12),
                      ...List.generate(headers.length, (i) {
                        final sample = sampleRows
                            .map((r) => i < r.length ? r[i] : '')
                            .where((v) => v.isNotEmpty)
                            .take(2)
                            .join(', ');
                        return _MappingRow(
                          header: headers[i],
                          sampleValue: sample,
                          mapping: mappings[i],
                          onChanged: (f) => onMappingChanged(i, f),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _BottomBar(
          leftLabel: '← Change file',
          onLeft: onBack,
          rightLabel: 'Preview →',
          onRight: onNext,
          rightEnabled: mappedCount > 0,
        ),
      ],
    );
  }

  Widget _tableHeaderRow() => Row(
        children: [
          Expanded(
              flex: 3,
              child: Text('CSV Column',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Expanded(
              flex: 3,
              child: Text('Sample Data',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Expanded(
              flex: 4,
              child: Text('Maps to CRM Field',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w600))),
        ],
      );
}

class _MappingRow extends StatelessWidget {
  final String header;
  final String sampleValue;
  final CrmField mapping;
  final ValueChanged<CrmField> onChanged;

  const _MappingRow({
    required this.header,
    required this.sampleValue,
    required this.mapping,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isIgnored = mapping == CrmField.ignore;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // CSV column name
          Expanded(
            flex: 3,
            child: Text(
              header,
              style: TextStyle(
                color: isIgnored ? Colors.white38 : Colors.white70,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // sample value
          Expanded(
            flex: 3,
            child: Text(
              sampleValue.isEmpty ? '—' : sampleValue,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.28), fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // dropdown
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: isIgnored
                    ? AppColors.surfaceDark
                    : AppColors.copper.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isIgnored
                      ? AppColors.divider
                      : AppColors.copper.withOpacity(0.35),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CrmField>(
                  value: mapping,
                  dropdownColor: AppColors.surfaceDark,
                  style: TextStyle(
                    color: isIgnored ? Colors.white38 : AppColors.copperLight,
                    fontSize: 13,
                  ),
                  icon: Icon(Icons.expand_more,
                      color: isIgnored ? Colors.white24 : AppColors.copper,
                      size: 16),
                  isExpanded: true,
                  items: CrmField.values
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(
                              f.label,
                              style: TextStyle(
                                color: f == CrmField.ignore
                                    ? Colors.white38
                                    : Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (f) {
                    if (f != null) onChanged(f);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Step 3 — Preview
// ─────────────────────────────────────────────────────────────────────────────

class _PreviewStep extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  final List<CrmField> mappings;
  final VoidCallback onBack;
  final VoidCallback onImport;

  const _PreviewStep({
    super.key,
    required this.headers,
    required this.rows,
    required this.mappings,
    required this.onBack,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    // Build preview contacts using the current mappings
    final previewRows = rows.take(10).toList();
    final contacts =
        previewRows.map((r) => CsvImportService.buildContact(r, mappings)).toList();

    // Count contacts that would be imported vs skipped
    final validCount = rows.where((r) {
      final c = CsvImportService.buildContact(r, mappings);
      final firstName = (c['firstName'] as String?) ?? '';
      return firstName.isNotEmpty ||
          (c['emails'] as List?)?.isNotEmpty == true ||
          (c['phones'] as List?)?.isNotEmpty == true;
    }).length;
    final skipCount = rows.length - validCount;

    return Column(
      children: [
        _StepIndicator(current: 2),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // summary row
                Row(
                  children: [
                    _Chip(
                        label: '$validCount contacts to import',
                        color: AppColors.approveText),
                    if (skipCount > 0) ...[
                      const SizedBox(width: 8),
                      _Chip(
                          label: '$skipCount will be skipped (no name/email/phone)',
                          color: Colors.white38),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Preview',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text(
                            'Showing first ${previewRows.length} of ${rows.length}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...contacts.map((c) => _ContactPreviewCard(contact: c)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _BottomBar(
          leftLabel: '← Edit mapping',
          onLeft: onBack,
          rightLabel: 'Import $validCount contacts →',
          onRight: validCount > 0 ? onImport : null,
          rightEnabled: validCount > 0,
        ),
      ],
    );
  }
}

class _ContactPreviewCard extends StatelessWidget {
  final Map<String, dynamic> contact;

  const _ContactPreviewCard({required this.contact});

  @override
  Widget build(BuildContext context) {
    final firstName = (contact['firstName'] as String?) ?? '';
    final lastName = (contact['lastName'] as String?) ?? '';
    final name =
        [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    final emails = (contact['emails'] as List<String>?) ?? [];
    final phones = (contact['phones'] as List<String>?) ?? [];
    final tags = (contact['tags'] as List<String>?) ?? [];
    final stage = (contact['stage'] as String?) ?? '';

    final initials = [
      firstName.isNotEmpty ? firstName[0] : '',
      lastName.isNotEmpty ? lastName[0] : '',
    ].join().toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.copper.withOpacity(0.15),
              child: Text(
                initials.isEmpty ? '?' : initials,
                style: TextStyle(
                    color: AppColors.copperLight,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? '(no name)' : name,
                    style: TextStyle(
                      color: name.isEmpty ? Colors.white38 : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (emails.isNotEmpty || phones.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 12,
                      children: [
                        if (emails.isNotEmpty)
                          _iconText(Icons.email_outlined, emails.first),
                        if (phones.isNotEmpty)
                          _iconText(Icons.phone_outlined, phones.first),
                      ],
                    ),
                  ],
                  if (tags.isNotEmpty || stage.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (stage.isNotEmpty)
                          _tagChip(stage, Colors.white24, Colors.white54),
                        ...tags.take(3).map((t) => _tagChip(
                            t,
                            AppColors.copper.withOpacity(0.12),
                            AppColors.copperLight.withOpacity(0.8))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white30, size: 11),
          const SizedBox(width: 3),
          Text(text,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      );

  Widget _tagChip(String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(4)),
        child: Text(label, style: TextStyle(color: fg, fontSize: 10)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Step 4 — Importing
// ─────────────────────────────────────────────────────────────────────────────

class _ImportingStep extends StatelessWidget {
  final int done;
  final int total;

  const _ImportingStep({super.key, required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? done / total : 0.0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload_outlined,
                color: AppColors.copper, size: 52),
            const SizedBox(height: 24),
            const Text('Importing contacts…',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              'Please keep this screen open.',
              style:
                  TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
            ),
            const SizedBox(height: 32),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: AppColors.divider,
                color: AppColors.copper,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$done / $total',
              style: const TextStyle(
                  color: AppColors.copperLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Step 5 — Done
// ─────────────────────────────────────────────────────────────────────────────

class _DoneStep extends StatelessWidget {
  final CsvImportResult result;
  final VoidCallback onDone;

  const _DoneStep({super.key, required this.result, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final allOk = result.failed == 0;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              allOk ? Icons.check_circle_outline : Icons.warning_amber_outlined,
              color: allOk ? AppColors.approveText : AppColors.pendingText,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              allOk ? 'Import Complete!' : 'Import Finished with Errors',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // stat cards
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statCard(
                    '${result.imported}', 'Imported', AppColors.approveText),
                const SizedBox(width: 12),
                if (result.skipped > 0)
                  _statCard('${result.skipped}', 'Skipped', Colors.white38),
                if (result.skipped > 0) const SizedBox(width: 12),
                if (result.failed > 0)
                  _statCard('${result.failed}', 'Failed', AppColors.rejectText),
              ],
            ),
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 24),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Errors (${result.errors.length})',
                        style: const TextStyle(
                            color: AppColors.rejectText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...result.errors.take(20).map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(e,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.55),
                                    fontSize: 12)),
                          ),
                        ),
                    if (result.errors.length > 20)
                      Text('… and ${result.errors.length - 20} more',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 12)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.copper,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child:
                    const Text('Done', style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(color: color.withOpacity(0.7), fontSize: 12)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current; // 0..4

  const _StepIndicator({required this.current});

  static const _labels = ['Upload', 'Map', 'Preview', 'Import', 'Done'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: AppColors.sidebarBg,
      child: Row(
        children: List.generate(_labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 1,
                color: (i ~/ 2) < current
                    ? AppColors.copper
                    : AppColors.divider,
              ),
            );
          }
          final step = i ~/ 2;
          final isActive = step == current;
          final isDone = step < current;
          return _StepDot(
            label: _labels[step],
            isActive: isActive,
            isDone: isDone,
          );
        }),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDone;

  const _StepDot(
      {required this.label, required this.isActive, required this.isDone});

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppColors.copper
        : isDone
            ? AppColors.approveText
            : Colors.white24;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.copper
                : isDone
                    ? AppColors.approveText.withOpacity(0.15)
                    : AppColors.divider,
            border: Border.all(color: color),
          ),
          child: isDone
              ? const Icon(Icons.check, color: AppColors.approveText, size: 13)
              : null,
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String leftLabel;
  final VoidCallback? onLeft;
  final String rightLabel;
  final VoidCallback? onRight;
  final bool rightEnabled;

  const _BottomBar({
    required this.leftLabel,
    required this.onLeft,
    required this.rightLabel,
    required this.onRight,
    this.rightEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: onLeft,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white54,
              side: const BorderSide(color: Colors.white24),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(leftLabel, style: const TextStyle(fontSize: 13)),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: rightEnabled ? onRight : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  rightEnabled ? AppColors.copper : AppColors.divider,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.divider,
              disabledForegroundColor: Colors.white30,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(rightLabel, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.rejectBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.rejectText.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.rejectText, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: AppColors.rejectText, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _FormatHints extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CSV Format Tips',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ..._hints.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: AppColors.copper.withOpacity(0.6), size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(h,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 12,
                              height: 1.4)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 10),
          Text('Recognized column names include: First Name, Last Name, Email, '
              'Phone, Mobile, Cell, Tags, Stage, Notes, Address, City, State, ZIP',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.28),
                  fontSize: 11,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  static const _hints = [
    'The first row must be column headers (e.g. "First Name", "Email").',
    'Contacts without a name, email, or phone will be skipped.',
    'Multiple emails or tags in one cell can be separated by commas or semicolons.',
    'Column names are matched case-insensitively — "first name" and "First Name" both work.',
  ];
}

Widget _card({required Widget child}) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
