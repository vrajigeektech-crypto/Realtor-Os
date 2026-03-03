import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// ─────────────────────────────────────────────────
/// LedgerTable — renders a list of ledger transactions
/// in a clean tabular style.  Automatically switches
/// to a scrollable single-column card list on mobile.
/// ─────────────────────────────────────────────────

class LedgerColumn {
  const LedgerColumn({
    required this.header,
    required this.flex,
    required this.cellBuilder,
  });

  final String header;
  final int flex;
  final Widget Function(LedgerRow row) cellBuilder;
}

class LedgerRow {
  const LedgerRow({
    required this.date,
    required this.actionType,
    required this.dealLead,
    this.fundingSource,
    this.outcome,
    this.fundingBadge,
    this.isBold = false,
  });

  final String date;
  final String actionType;
  final String dealLead;
  final String? fundingSource;
  final String? outcome;
  final Widget? fundingBadge;
  final bool isBold;
}

class LedgerTable extends StatelessWidget {
  const LedgerTable({
    super.key,
    required this.rows,
    this.compact = false,
    this.footerText,
  });

  final List<LedgerRow> rows;
  final bool compact;     // true → show only 3 columns (compact top card)
  final String? footerText;

  @override
  Widget build(BuildContext context) {
    final cols = compact ? _compactCols() : _fullCols();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ──────────────────────────────
        Row(
          children: [
            for (final col in cols) ...[
              Expanded(
                flex: col.flex,
                child: Text(
                  col.header,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ],
        ),
        const Divider(color: AppTheme.borderColor, height: 20),

        // ── Data rows ────────────────────────────────
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No entries yet',
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
            ),
          )
        else
          ...rows.map((row) => _DataRow(row: row, cols: cols)),

        // ── Footer ───────────────────────────────────
        if (footerText != null) ...[
          const Divider(color: AppTheme.borderColor, height: 16),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                footerText!,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted,
                size: 16,
              ),
            ],
          ),
        ],
      ],
    );
  }

  List<LedgerColumn> _compactCols() => [
        LedgerColumn(
          header: 'Date',
          flex: 2,
          cellBuilder: (r) => _CellText(r.date, muted: true),
        ),
        LedgerColumn(
          header: 'Action Type',
          flex: 3,
          cellBuilder: (r) => _CellText(r.actionType, bold: r.isBold),
        ),
        LedgerColumn(
          header: 'Deal / Lead',
          flex: 4,
          cellBuilder: (r) => Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              _CellText(r.dealLead),
              if (r.fundingBadge != null) r.fundingBadge!,
            ],
          ),
        ),
      ];

  List<LedgerColumn> _fullCols() => [
        LedgerColumn(
          header: 'Date',
          flex: 2,
          cellBuilder: (r) => _CellText(r.date, muted: true),
        ),
        LedgerColumn(
          header: 'Action Type',
          flex: 3,
          cellBuilder: (r) => _CellText(r.actionType, bold: r.isBold),
        ),
        LedgerColumn(
          header: 'Deal / Lead',
          flex: 3,
          cellBuilder: (r) => _CellText(r.dealLead),
        ),
        LedgerColumn(
          header: 'Funding Source',
          flex: 3,
          cellBuilder: (r) =>
              _CellText(r.fundingSource ?? '—', muted: true),
        ),
        LedgerColumn(
          header: 'Outcome',
          flex: 3,
          cellBuilder: (r) => _CellText(
            r.outcome ?? '—',
            accent: r.outcome != null && r.isBold,
          ),
        ),
      ];
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.row, required this.cols});
  final LedgerRow row;
  final List<LedgerColumn> cols;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final col in cols)
            Expanded(
              flex: col.flex,
              child: col.cellBuilder(row),
            ),
        ],
      ),
    );
  }
}

class _CellText extends StatelessWidget {
  const _CellText(
    this.text, {
    this.muted = false,
    this.bold = false,
    this.accent = false,
  });
  final String text;
  final bool muted, bold, accent;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: accent
            ? AppTheme.accent
            : muted
                ? AppTheme.textSecondary
                : AppTheme.textPrimary,
        fontSize: 13,
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
