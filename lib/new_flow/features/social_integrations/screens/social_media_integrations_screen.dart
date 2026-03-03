import 'package:flutter/material.dart';

import '../controllers/social_media_integrations_controller.dart';
import '../controllers/social_media_integrations_state.dart';
import '../data/social_media_integrations_repository.dart';
import '../widgets/social_integrations_header.dart';
import '../widgets/integration_grid.dart';

class SocialMediaIntegrationsScreen extends StatefulWidget {
  const SocialMediaIntegrationsScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<SocialMediaIntegrationsScreen> createState() =>
      _SocialMediaIntegrationsScreenState();
}

class _SocialMediaIntegrationsScreenState
    extends State<SocialMediaIntegrationsScreen> {
  late final SocialMediaIntegrationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SocialMediaIntegrationsController(
      repository: SocialMediaIntegrationsRepository(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controller.load(userId: widget.userId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;
            final horizontalPadding = isWide ? 28.0 : 16.0;

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final state = _controller.state;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 18,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SocialIntegrationsHeader(
                            title: state.headerTitle ?? 'Social Media Integrations',
                            subtitle: state.headerSubtitle ?? 'Link your social media accounts.',
                            onRefresh: state.isLoading
                                ? null
                                : () => _controller.load(
                                      userId: widget.userId,
                                      forceRefresh: true,
                                    ),
                          ),
                          const SizedBox(height: 18),
                          _Body(
                            isWide: isWide,
                            state: state,
                            onRetry: () => _controller.load(
                              userId: widget.userId,
                              forceRefresh: true,
                            ),
                            onConnect: (key) => _controller.connect(
                              userId: widget.userId,
                              integrationKey: key,
                            ),
                            onDisconnect: (key) => _controller.disconnect(
                              userId: widget.userId,
                              integrationKey: key,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.isWide,
    required this.state,
    required this.onRetry,
    required this.onConnect,
    required this.onDisconnect,
  });

  final bool isWide;
  final SocialMediaIntegrationsState state;
  final VoidCallback onRetry;
  final Future<void> Function(String integrationKey) onConnect;
  final Future<void> Function(String integrationKey) onDisconnect;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.items.isEmpty) {
      return const _LoadingSkeleton();
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return _ErrorState(
        message: state.errorMessage!,
        onRetry: onRetry,
      );
    }

    return IntegrationGrid(
      isWide: isWide,
      items: state.filteredItems,
      busyKeys: state.busyKeys,
      onConnect: onConnect,
      onDisconnect: onDisconnect,
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = Border.all(color: theme.dividerColor.withOpacity(0.35));

    Widget box({double h = 120}) => Container(
          height: h,
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(0.55),
            border: border,
            borderRadius: BorderRadius.circular(14),
          ),
        );

    return LayoutBuilder(
      builder: (_, c) {
        final cols = c.maxWidth >= 980 ? 4 : (c.maxWidth >= 720 ? 2 : 1);
        final gap = 14.0;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: List.generate(
            cols * 2,
            (_) => SizedBox(
              width: (c.maxWidth - (gap * (cols - 1))) / cols,
              child: box(),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
