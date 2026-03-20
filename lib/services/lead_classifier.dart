// Rule-based lead scoring engine (used as fallback when AI is unavailable).
//
// Contacts are evaluated against weighted signals drawn from stage, tags,
// source, recency, and contact completeness. The bucket with the highest
// score wins; a normalised 0–100 confidence is derived from the margin.

// ─────────────────────────────────────────────────────────────────────────────
//  Public types
// ─────────────────────────────────────────────────────────────────────────────

enum LeadBucket {
  hot,
  warm,
  cold,
  junk;

  String get label => const {
        LeadBucket.hot: 'Hot Lead',
        LeadBucket.warm: 'Warm Lead',
        LeadBucket.cold: 'Cold Lead',
        LeadBucket.junk: 'Junk',
      }[this]!;

  String get emoji => const {
        LeadBucket.hot: '🔥',
        LeadBucket.warm: '🌤',
        LeadBucket.cold: '❄️',
        LeadBucket.junk: '🚫',
      }[this]!;
}

class LeadClassification {
  final LeadBucket bucket;

  /// 0–100. How confident the engine is in this bucket assignment.
  final int confidence;

  /// Short human-readable signal labels that drove the decision.
  final List<String> signals;

  // ── AI-enriched fields ────────────────────────────────────────────────────
  /// e.g. "buy now", "just browsing", "researching", "selling", "spam"
  final String intent;

  /// "high", "medium", or "low"
  final String urgency;

  /// Extracted budget string, e.g. "80L", "$500k", or "unknown"
  final String budget;

  /// "buyer", "seller", "renter", "investor", or "unknown"
  final String category;

  /// True when an LLM produced this classification (false = rule-based).
  final bool aiClassified;

  const LeadClassification({
    required this.bucket,
    required this.confidence,
    required this.signals,
    this.intent = 'unknown',
    this.urgency = 'medium',
    this.budget = 'unknown',
    this.category = 'unknown',
    this.aiClassified = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Rule-based classifier (local fallback)
// ─────────────────────────────────────────────────────────────────────────────

class LeadClassifier {
  const LeadClassifier._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Classify a single contact map.  Returns a [LeadClassification].
  static LeadClassification classify(Map<String, dynamic> contact) {
    final ctx = _ContactContext.from(contact);
    return _score(ctx);
  }

  /// Classify all contacts and attach `'_classification'` onto each map in
  /// place.  Returns the same list (mutated) for convenience.
  static List<Map<String, dynamic>> classifyAll(
      List<Map<String, dynamic>> contacts) {
    for (final c in contacts) {
      c['_classification'] = classify(c);
    }
    return contacts;
  }

  // ---------------------------------------------------------------------------
  // Scoring
  // ---------------------------------------------------------------------------

  static LeadClassification _score(_ContactContext ctx) {
    final hot = _scoreHot(ctx);
    final warm = _scoreWarm(ctx);
    final cold = _scoreCold(ctx);
    final junk = _scoreJunk(ctx);

    final scores = {
      LeadBucket.hot: hot,
      LeadBucket.warm: warm,
      LeadBucket.cold: cold,
      LeadBucket.junk: junk,
    };

    // Winner = highest score. Tie-break: hot > warm > cold > junk.
    final sorted = scores.entries.toList()
      ..sort((a, b) {
        final cmp = b.value.score.compareTo(a.value.score);
        if (cmp != 0) return cmp;
        return a.key.index.compareTo(b.key.index);
      });

    final winner = sorted.first;
    final winnerScore = winner.value.score;
    final totalScore = scores.values.fold(0, (s, v) => s + v.score);

    int confidence;
    if (totalScore == 0) {
      confidence = 30;
    } else {
      confidence = ((winnerScore / totalScore) * 100).round().clamp(30, 99);
    }

    final bucket = winner.key;

    // Derive AI-style intent/urgency/category from the winning bucket.
    final (intent, urgency, category) = _bucketMeta(bucket, ctx);

    return LeadClassification(
      bucket: bucket,
      confidence: confidence,
      signals: winner.value.signals,
      intent: intent,
      urgency: urgency,
      budget: 'unknown',
      category: category,
      aiClassified: false,
    );
  }

  // ---------------------------------------------------------------------------
  // Per-bucket scorers
  // ---------------------------------------------------------------------------

  static _BucketScore _scoreHot(_ContactContext ctx) {
    int score = 0;
    final signals = <String>[];

    const hotStages = [
      'hot', 'active', 'interested', 'showing', 'offer', 'contract',
      'ready', 'buying', 'pre-approved', 'pre approved', 'under contract',
      'closing', 'pipeline', 'now',
    ];
    for (final kw in hotStages) {
      if (ctx.stage.contains(kw)) {
        score += 35;
        signals.add('Stage: ${ctx.rawStage}');
        break;
      }
    }

    const hotTags = [
      'hot', 'urgent', 'ready', 'motivated', 'callback', 'buy now',
      'showing', 'active', 'interested',
    ];
    for (final tag in ctx.tags) {
      for (final kw in hotTags) {
        if (tag.contains(kw)) {
          score += 20;
          signals.add('Tag: $tag');
          break;
        }
      }
    }

    // Very recent activity → hot signal
    if (ctx.daysSinceActivity != null && ctx.daysSinceActivity! <= 14) {
      score += 25;
      signals.add('Active ≤14 days');
    } else if (ctx.daysSinceActivity != null && ctx.daysSinceActivity! <= 30) {
      score += 15;
      signals.add('Active ≤30 days');
    }

    // Has both email and phone
    if (ctx.hasEmail && ctx.hasPhone) {
      score += 8;
      signals.add('Full contact info');
    }

    const hotSources = ['referral', 'sphere', 'past client', 'repeat', 'personal'];
    for (final kw in hotSources) {
      if (ctx.source.contains(kw)) {
        score += 12;
        signals.add('Source: ${ctx.rawSource}');
        break;
      }
    }

    return _BucketScore(score: score, signals: _dedup(signals));
  }

  static _BucketScore _scoreWarm(_ContactContext ctx) {
    int score = 0;
    final signals = <String>[];

    const warmStages = [
      'warm', 'nurture', 'follow up', 'follow-up', 'long term', 'long-term',
      'future', 'watching', '6 month', '12 month', 'someday', '1 year',
      'dpa', 'first time', 'first-time', 'down payment',
    ];
    for (final kw in warmStages) {
      if (ctx.stage.contains(kw)) {
        score += 30;
        signals.add('Stage: ${ctx.rawStage}');
        break;
      }
    }

    const warmTags = [
      'warm', 'nurture', 'long term', 'long-term', 'future', '6 months',
      '12 months', 'someday', 'watching', 'renter', 'follow up', 'buyer',
      'dpa', 'down payment', 'fha', 'first time', 'assistance',
    ];
    for (final tag in ctx.tags) {
      for (final kw in warmTags) {
        if (tag.contains(kw)) {
          score += 15;
          signals.add('Tag: $tag');
          break;
        }
      }
    }

    // Activity 30-90 days → warm nurturing window
    if (ctx.daysSinceActivity != null &&
        ctx.daysSinceActivity! > 14 &&
        ctx.daysSinceActivity! <= 90) {
      score += 18;
      signals.add('Activity 14-90 days');
    }

    // Activity 90-365 days → still salvageable
    if (ctx.daysSinceActivity != null &&
        ctx.daysSinceActivity! > 90 &&
        ctx.daysSinceActivity! <= 365) {
      score += 10;
      signals.add('Activity 90-365 days');
    }

    if (ctx.hasEmail || ctx.hasPhone) {
      score += 5;
      signals.add('Has contact info');
    }

    const warmSources = ['zillow', 'website', 'google', 'facebook', 'online', 'instagram'];
    for (final kw in warmSources) {
      if (ctx.source.contains(kw)) {
        score += 8;
        signals.add('Source: ${ctx.rawSource}');
        break;
      }
    }

    return _BucketScore(score: score, signals: _dedup(signals));
  }

  static _BucketScore _scoreCold(_ContactContext ctx) {
    int score = 0;
    final signals = <String>[];

    const coldStages = [
      'cold', 'inactive', 'unresponsive', 'archived', 'not interested',
      'lost', 'closed',
    ];
    for (final kw in coldStages) {
      if (ctx.stage.contains(kw)) {
        score += 35;
        signals.add('Stage: ${ctx.rawStage}');
        break;
      }
    }

    const coldTags = [
      'cold', 'not interested', 'no response', 'inactive', 'browsing',
      'just looking', 'researching',
    ];
    for (final tag in ctx.tags) {
      for (final kw in coldTags) {
        if (tag.contains(kw)) {
          score += 20;
          signals.add('Tag: $tag');
          break;
        }
      }
    }

    // Stale: no activity for more than a year
    if (ctx.daysSinceActivity != null && ctx.daysSinceActivity! > 365) {
      score += 25;
      signals.add('No activity >1 year');
    }

    // Older than 6 months, no recent activity
    if (ctx.daysSinceCreated != null &&
        ctx.daysSinceCreated! > 180 &&
        (ctx.daysSinceActivity == null || ctx.daysSinceActivity! > 90)) {
      score += 12;
      signals.add('Lead age >6 months, inactive');
    }

    return _BucketScore(score: score, signals: _dedup(signals));
  }

  static _BucketScore _scoreJunk(_ContactContext ctx) {
    int score = 0;
    final signals = <String>[];

    const junkStages = ['dead', 'removed', 'deleted', 'spam', 'test', 'fake'];
    for (final kw in junkStages) {
      if (ctx.stage.contains(kw)) {
        score += 45;
        signals.add('Stage: ${ctx.rawStage}');
        break;
      }
    }

    const junkTags = [
      'dead', 'spam', 'dnc', 'remove', 'unsubscribed', 'wrong number',
      'no contact', 'junk', 'fake', 'test',
    ];
    for (final tag in ctx.tags) {
      for (final kw in junkTags) {
        if (tag.contains(kw)) {
          score += 30;
          signals.add('Tag: $tag');
          break;
        }
      }
    }

    // Zero contact info → junk
    if (!ctx.hasEmail && !ctx.hasPhone) {
      score += 30;
      signals.add('No contact info');
    }

    return _BucketScore(score: score, signals: _dedup(signals));
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Derive human-readable (intent, urgency, category) for a bucket.
  static (String, String, String) _bucketMeta(
      LeadBucket bucket, _ContactContext ctx) {
    final hasBuyer = ctx.tags.any((t) =>
        t.contains('buyer') || t.contains('buy') || t.contains('purchase'));
    final hasSeller = ctx.tags.any(
        (t) => t.contains('seller') || t.contains('sell') || t.contains('list'));
    final hasRenter =
        ctx.tags.any((t) => t.contains('rent') || t.contains('renter'));
    final hasInvestor = ctx.tags
        .any((t) => t.contains('invest') || t.contains('investor'));

    String category = 'buyer';
    if (hasSeller) category = 'seller';
    if (hasRenter) category = 'renter';
    if (hasInvestor) category = 'investor';
    if (!hasBuyer && !hasSeller && !hasRenter && !hasInvestor) {
      category = 'unknown';
    }

    return switch (bucket) {
      LeadBucket.hot => ('buy now', 'high', category),
      LeadBucket.warm => ('researching', 'medium', category),
      LeadBucket.cold => ('just browsing', 'low', category),
      LeadBucket.junk => ('spam', 'low', 'unknown'),
    };
  }

  static List<String> _dedup(List<String> signals) =>
      signals.toSet().take(4).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
//  Internal helpers
// ─────────────────────────────────────────────────────────────────────────────

class _BucketScore {
  final int score;
  final List<String> signals;
  const _BucketScore({required this.score, required this.signals});
}

class _ContactContext {
  final String stage;
  final String rawStage;
  final List<String> tags;
  final String source;
  final String rawSource;
  final bool hasEmail;
  final bool hasPhone;
  final int? daysSinceActivity;
  final int? daysSinceCreated;

  const _ContactContext({
    required this.stage,
    required this.rawStage,
    required this.tags,
    required this.source,
    required this.rawSource,
    required this.hasEmail,
    required this.hasPhone,
    required this.daysSinceActivity,
    required this.daysSinceCreated,
  });

  factory _ContactContext.from(Map<String, dynamic> c) {
    final rawStage = c['stage'] as String? ?? '';
    final stage = rawStage.toLowerCase().trim();

    final rawTags = (c['tags'] as List? ?? []);
    final tags = rawTags.map((t) => t.toString().toLowerCase().trim()).toList();

    final rawSource = c['source'] as String? ?? '';
    final source = rawSource.toLowerCase().trim();

    final emails = c['emails'] as List? ?? [];
    final phones = c['phones'] as List? ?? [];

    final now = DateTime.now();

    int? daysSinceActivity;
    final activityRaw = c['lastActivity'] as String? ?? c['updated'] as String?;
    if (activityRaw != null) {
      final dt = DateTime.tryParse(activityRaw);
      if (dt != null) daysSinceActivity = now.difference(dt).inDays;
    }

    int? daysSinceCreated;
    final createdRaw = c['created'] as String?;
    if (createdRaw != null) {
      final dt = DateTime.tryParse(createdRaw);
      if (dt != null) daysSinceCreated = now.difference(dt).inDays;
    }

    return _ContactContext(
      stage: stage,
      rawStage: rawStage,
      tags: tags,
      source: source,
      rawSource: rawSource,
      hasEmail: emails.isNotEmpty,
      hasPhone: phones.isNotEmpty,
      daysSinceActivity: daysSinceActivity,
      daysSinceCreated: daysSinceCreated,
    );
  }
}
