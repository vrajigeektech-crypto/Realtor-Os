import 'package:flutter/material.dart';

// ── Logo widget: primary URL → explicit fallback URL → initials ────────────
class _CrmLogoWidget extends StatefulWidget {
  final String name;
  final String primaryUrl;
  final String? fallbackUrl;
  final bool isConnected;

  const _CrmLogoWidget({
    required this.name,
    required this.primaryUrl,
    this.fallbackUrl,
    required this.isConnected,
  });

  @override
  State<_CrmLogoWidget> createState() => _CrmLogoWidgetState();
}

class _CrmLogoWidgetState extends State<_CrmLogoWidget> {
  // 0 = try primary, 1 = try fallback, 2 = show initials
  int _attempt = 0;

  String get _currentUrl {
    if (_attempt == 0) return widget.primaryUrl;
    return widget.fallbackUrl ?? '';
  }

  String get _initials => widget.name
      .split(' ')
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0].toUpperCase())
      .join();

  void _onError() {
    if (!mounted) return;
    if (_attempt == 0 && widget.fallbackUrl != null) {
      setState(() => _attempt = 1);
    } else {
      setState(() => _attempt = 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_attempt == 2 || _currentUrl.isEmpty) {
      return _Initials(
        text: _initials,
        isConnected: widget.isConnected,
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Image.network(
            _currentUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _onError());
              return const SizedBox.shrink();
            },
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: widget.isConnected
                        ? Colors.green
                        : const Color(0xFFAAAAAA),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String text;
  final bool isConnected;
  const _Initials({required this.text, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isConnected
            ? Colors.green.withOpacity(0.18)
            : const Color(0xFF383838),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isConnected ? Colors.green : Colors.white60,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

// ── Main card widget ───────────────────────────────────────────────────────
class CrmConnectionCard extends StatelessWidget {
  final String name;
  final String logoPath;
  final String? logoUrl;
  final String? logoUrlFallback;
  final bool isConnected;
  final bool isLoading;
  final DateTime? connectedAt;
  final Map<String, dynamic>? metadata;
  final VoidCallback onTap;
  final VoidCallback? onManage;

  const CrmConnectionCard({
    Key? key,
    required this.name,
    required this.logoPath,
    this.logoUrl,
    this.logoUrlFallback,
    required this.isConnected,
    this.isLoading = false,
    this.connectedAt,
    this.metadata,
    required this.onTap,
    this.onManage,
  }) : super(key: key);

  String? _accountLabel() {
    if (metadata == null) return null;
    final candidate = metadata!['account_name'] ??
        metadata!['accountName'] ??
        metadata!['team_name'] ??
        metadata!['teamName'] ??
        metadata!['system_name'] ??
        metadata!['systemName'] ??
        metadata!['name'];
    return candidate?.toString();
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    final months = (diff.inDays / 30).floor();
    if (months == 1) return '1 mo ago';
    if (months < 12) return '${months}mo ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  Widget _logo() {
    final url = logoUrl ?? '';
    if (url.isEmpty) {
      final initials = name
          .split(' ')
          .where((w) => w.isNotEmpty)
          .take(2)
          .map((w) => w[0].toUpperCase())
          .join();
      return _Initials(text: initials, isConnected: isConnected);
    }
    return _CrmLogoWidget(
      name: name,
      primaryUrl: url,
      fallbackUrl: logoUrlFallback,
      isConnected: isConnected,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountLabel = _accountLabel();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isConnected
              ? const Color(0xFF1e2d1e)
              : const Color(0xFF2a2a2a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConnected
                ? Colors.green.withOpacity(0.35)
                : Colors.white10,
            width: isConnected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _logo(),
            const SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                color: isConnected ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight:
                    isConnected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFFd4a574)),
                ),
              )
            else if (isConnected) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 13),
                  SizedBox(width: 4),
                  Text(
                    'Connected',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (accountLabel != null) ...[
                const SizedBox(height: 3),
                Text(
                  accountLabel,
                  style: const TextStyle(
                    color: Color(0xFFd4a574),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (connectedAt != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Since ${_formatDate(connectedAt!)}',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onManage ?? onTap,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1a3a2a),
                          border: Border.all(
                              color: Colors.green.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Manage',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        border: Border.all(
                            color: Colors.red.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.link_off,
                          color: Colors.red, size: 13),
                    ),
                  ),
                ],
              ),
            ] else
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 7),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF4a5568)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Connect',
                  style: TextStyle(
                      color: Color(0xFF9ca3af), fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
