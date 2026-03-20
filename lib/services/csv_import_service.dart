import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'followupboss_contact_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Field enum
// ─────────────────────────────────────────────────────────────────────────────

enum CrmField {
  firstName,
  lastName,
  email,
  phone,
  tags,
  stage,
  note,
  address,
  city,
  state,
  zip,
  ignore,
}

extension CrmFieldLabel on CrmField {
  String get label => const {
        CrmField.firstName: 'First Name',
        CrmField.lastName: 'Last Name',
        CrmField.email: 'Email',
        CrmField.phone: 'Phone',
        CrmField.tags: 'Tags',
        CrmField.stage: 'Stage',
        CrmField.note: 'Notes',
        CrmField.address: 'Address',
        CrmField.city: 'City',
        CrmField.state: 'State / Province',
        CrmField.zip: 'ZIP / Postal Code',
        CrmField.ignore: '— Ignore —',
      }[this]!;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Result model
// ─────────────────────────────────────────────────────────────────────────────

class CsvImportResult {
  final int total;
  final int imported;
  final int skipped;
  final int failed;
  final List<String> errors;

  const CsvImportResult({
    required this.total,
    required this.imported,
    required this.skipped,
    required this.failed,
    required this.errors,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Service
// ─────────────────────────────────────────────────────────────────────────────

class CsvImportService {
  // ---------------------------------------------------------------------------
  // Normalization dictionary: lowercase CSV header → CrmField
  // ---------------------------------------------------------------------------
  static final Map<String, CrmField> _normMap = {
    // firstName
    'first name': CrmField.firstName,
    'firstname': CrmField.firstName,
    'first_name': CrmField.firstName,
    'fname': CrmField.firstName,
    'given name': CrmField.firstName,
    'given_name': CrmField.firstName,
    'first': CrmField.firstName,
    'contact first name': CrmField.firstName,
    // lastName
    'last name': CrmField.lastName,
    'lastname': CrmField.lastName,
    'last_name': CrmField.lastName,
    'lname': CrmField.lastName,
    'surname': CrmField.lastName,
    'family name': CrmField.lastName,
    'family_name': CrmField.lastName,
    'last': CrmField.lastName,
    'contact last name': CrmField.lastName,
    // email
    'email': CrmField.email,
    'email address': CrmField.email,
    'email_address': CrmField.email,
    'e-mail': CrmField.email,
    'emails': CrmField.email,
    'email 1': CrmField.email,
    'email1': CrmField.email,
    'primary email': CrmField.email,
    'contact email': CrmField.email,
    // phone
    'phone': CrmField.phone,
    'phone number': CrmField.phone,
    'phone_number': CrmField.phone,
    'mobile': CrmField.phone,
    'mobile phone': CrmField.phone,
    'cell': CrmField.phone,
    'cell phone': CrmField.phone,
    'telephone': CrmField.phone,
    'phone 1': CrmField.phone,
    'phone1': CrmField.phone,
    'contact phone': CrmField.phone,
    'mobile number': CrmField.phone,
    // tags
    'tags': CrmField.tags,
    'tag': CrmField.tags,
    'labels': CrmField.tags,
    'categories': CrmField.tags,
    'keywords': CrmField.tags,
    // stage
    'stage': CrmField.stage,
    'lead stage': CrmField.stage,
    'status': CrmField.stage,
    'lead status': CrmField.stage,
    'pipeline stage': CrmField.stage,
    // notes
    'notes': CrmField.note,
    'note': CrmField.note,
    'comments': CrmField.note,
    'comment': CrmField.note,
    'description': CrmField.note,
    'memo': CrmField.note,
    // address
    'address': CrmField.address,
    'street address': CrmField.address,
    'street': CrmField.address,
    'address 1': CrmField.address,
    'address1': CrmField.address,
    'mailing address': CrmField.address,
    // city
    'city': CrmField.city,
    'town': CrmField.city,
    // state
    'state': CrmField.state,
    'province': CrmField.state,
    'state/province': CrmField.state,
    'region': CrmField.state,
    // zip
    'zip': CrmField.zip,
    'zip code': CrmField.zip,
    'zipcode': CrmField.zip,
    'postal code': CrmField.zip,
    'postcode': CrmField.zip,
    'postal_code': CrmField.zip,
  };

  /// Auto-detect the [CrmField] for a given CSV column header.
  static CrmField autoDetect(String header) =>
      _normMap[header.trim().toLowerCase()] ?? CrmField.ignore;

  /// Returns auto-detected field for each header in [headers].
  static List<CrmField> autoDetectMappings(List<String> headers) =>
      headers.map(autoDetect).toList();

  // ---------------------------------------------------------------------------
  // CSV parsing  (RFC-4180-compatible state machine, no extra dependencies)
  // ---------------------------------------------------------------------------

  /// Parse UTF-8 CSV [bytes] and return `(headers, rows)`.
  ///
  /// The first row is always treated as the header row.
  static ({List<String> headers, List<List<String>> rows}) parseCsvBytes(
      Uint8List bytes) {
    final text = utf8.decode(bytes, allowMalformed: true);
    return parseCsvText(text);
  }

  /// Parse a raw CSV [text] string and return `(headers, rows)`.
  static ({List<String> headers, List<List<String>> rows}) parseCsvText(
      String text) {
    final allRows = _splitCsv(text);
    if (allRows.isEmpty) return (headers: [], rows: []);
    // Filter out rows that are shorter than headers to normalize ragged CSVs
    final headers = allRows.first;
    final rows = allRows
        .skip(1)
        .where((r) => r.any((c) => c.isNotEmpty))
        .map((r) {
          // Pad short rows with empty strings so callers can index by column
          if (r.length < headers.length) {
            return [...r, ...List.filled(headers.length - r.length, '')];
          }
          return r;
        })
        .toList();
    return (headers: headers, rows: rows);
  }

  static List<List<String>> _splitCsv(String text) {
    final src = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final rows = <List<String>>[];
    final currentRow = <String>[];
    final field = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < src.length; i++) {
      final c = src[i];
      if (inQuotes) {
        if (c == '"') {
          // Escaped quote inside quoted field ("") → emit single "
          if (i + 1 < src.length && src[i + 1] == '"') {
            field.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          field.write(c);
        }
      } else {
        if (c == '"') {
          inQuotes = true;
        } else if (c == ',') {
          currentRow.add(field.toString().trim());
          field.clear();
        } else if (c == '\n') {
          currentRow.add(field.toString().trim());
          field.clear();
          if (currentRow.isNotEmpty &&
              !(currentRow.length == 1 && currentRow[0].isEmpty)) {
            rows.add(List<String>.from(currentRow));
          }
          currentRow.clear();
        } else {
          field.write(c);
        }
      }
    }
    // Handle last field / row (no trailing newline)
    currentRow.add(field.toString().trim());
    if (currentRow.isNotEmpty &&
        !(currentRow.length == 1 && currentRow[0].isEmpty)) {
      rows.add(List<String>.from(currentRow));
    }
    return rows;
  }

  // ---------------------------------------------------------------------------
  // Contact builder
  // ---------------------------------------------------------------------------

  /// Map a single [row] to a contact `Map` using [mappings].
  static Map<String, dynamic> buildContact(
    List<String> row,
    List<CrmField> mappings,
  ) {
    final result = <String, dynamic>{};
    final emails = <String>[];
    final phones = <String>[];
    final tags = <String>[];

    for (int i = 0; i < mappings.length; i++) {
      if (i >= row.length) continue;
      final raw = row[i].trim();
      if (raw.isEmpty) continue;

      switch (mappings[i]) {
        case CrmField.firstName:
          result['firstName'] = raw;
        case CrmField.lastName:
          result['lastName'] = raw;
        case CrmField.email:
          emails.addAll(
            raw
                .split(RegExp(r'[;,]'))
                .map((e) => e.trim())
                .where((e) => e.contains('@')),
          );
        case CrmField.phone:
          phones.add(raw);
        case CrmField.tags:
          tags.addAll(
            raw
                .split(RegExp(r'[;,]'))
                .map((t) => t.trim())
                .where((t) => t.isNotEmpty),
          );
        case CrmField.stage:
          result['stage'] = raw;
        case CrmField.note:
          result['note'] = raw;
        case CrmField.address:
          result['street'] = raw;
        case CrmField.city:
          result['city'] = raw;
        case CrmField.state:
          result['state'] = raw;
        case CrmField.zip:
          result['zip'] = raw;
        case CrmField.ignore:
          break;
      }
    }

    if (emails.isNotEmpty) result['emails'] = emails;
    if (phones.isNotEmpty) result['phones'] = phones;
    if (tags.isNotEmpty) result['tags'] = tags;

    // Keep address parts as individual keys so the importer can build the
    // correct FUB `addresses` array structure.  Keys: street, city, state, zip.

    return result;
  }

  // ---------------------------------------------------------------------------
  // Import
  // ---------------------------------------------------------------------------

  /// Imports all [rows] into Follow Up Boss, using [mappings] to map columns.
  ///
  /// Calls [onProgress] after each contact attempt: `(done, total)`.
  Future<CsvImportResult> importToFollowUpBoss({
    required List<List<String>> rows,
    required List<CrmField> mappings,
    required void Function(int done, int total) onProgress,
    FollowUpBossContactService? contactService,
  }) async {
    final service = contactService ?? FollowUpBossContactService();
    int imported = 0, skipped = 0, failed = 0;
    final errors = <String>[];

    for (int i = 0; i < rows.length; i++) {
      final contact = buildContact(rows[i], mappings);
      final firstName = (contact['firstName'] as String?) ?? '';
      final hasIdentifier = firstName.isNotEmpty ||
          (contact['emails'] as List?)?.isNotEmpty == true ||
          (contact['phones'] as List?)?.isNotEmpty == true;

      if (!hasIdentifier) {
        skipped++;
        onProgress(i + 1, rows.length);
        continue;
      }

      try {
        // Build the FUB addresses array from individual address parts.
        final addressObj = <String, String>{};
        for (final k in ['street', 'city', 'state', 'zip']) {
          final v = contact[k] as String?;
          if (v != null && v.isNotEmpty) addressObj[k] = v;
        }

        final created = await service.createPerson(
          firstName: firstName,
          lastName: contact['lastName'] as String?,
          emails: (contact['emails'] as List<String>?) ?? [],
          phones: (contact['phones'] as List<String>?) ?? [],
          tags: (contact['tags'] as List<String>?) ?? [],
          extraFields: {
            if ((contact['stage'] as String?)?.isNotEmpty == true)
              'stage': contact['stage'],
            if (addressObj.isNotEmpty) 'addresses': [addressObj],
          },
        );

        // Notes are not accepted on the people endpoint — post separately.
        final note = contact['note'] as String?;
        if (note != null && note.isNotEmpty) {
          final personId = created['id'] as int?;
          if (personId != null) {
            await service.createNote(personId: personId, body: note);
          }
        }

        imported++;
      } catch (e) {
        failed++;
        final msg = e.toString().split('\n').first;
        errors.add('Row ${i + 2}: $msg');
        debugPrint('❌ [CSV Import] Row ${i + 2} failed: $e');
      }

      onProgress(i + 1, rows.length);
    }

    return CsvImportResult(
      total: rows.length,
      imported: imported,
      skipped: skipped,
      failed: failed,
      errors: errors,
    );
  }
}
