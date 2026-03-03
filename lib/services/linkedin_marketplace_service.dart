import '../models/linkedin_marketplace_models.dart';

class LinkedInMarketplaceService {
  static final LinkedInMarketplaceService _instance = LinkedInMarketplaceService._internal();
  factory LinkedInMarketplaceService() => _instance;
  LinkedInMarketplaceService._internal();

  List<LinkedInService> getLinkedInServices() {
    return [
      // LinkedIn Authority Carousel
      LinkedInService(
        id: 'linkedin_carousel',
        title: 'LinkedIn Authority Carousel',
        description: 'Automate your LinkedIn presence with expert-driven, agent-branded carousel content.',
        whatThisIs: 'LinkedIn Authority Carousel – Posted as You\nA swipe-based LinkedIn carousel designed to position you as a knowledgeable, active professional in your market without you having to design, write, or post anything manually.\nThis format is optimized for education-first visibility, not hype. It builds trust with buyers, sellers, agents, and referral partners by delivering clear, useful insights in a way LinkedIn\'s algorithm favors.\nCarousels consistently outperform static posts on LinkedIn because they drive dwell time, saves, and profile clicks, which increases your reach beyond your immediate network.',
        whyThisIsShowing: '• You\'re actively working buyers, sellers, or referral relationships\n• Your LinkedIn profile needs consistent authority signals\n• Educational content improves trust before a DM or intro\n• Carousels increase reach without requiring video or daily posting\nMaintaining a visible, professional presence on LinkedIn compounds over time. This recommendation fills that gap automatically.',
        whatYouGet: [
          'Expert-written carousel copy tailored to real estate professionals',
          'Branded slides with your name, market, and positioning',
          'Education-forward or lifestyle-forward framing based on your audience',
          'Optimized slide structure for LinkedIn engagement',
          'Caption written to drive saves, comments, and profile views',
          'Added to your LinkedIn content queue'
        ],
        executionType: 'AI-Generated · Agent-Branded',
        format: 'LinkedIn Carousel (Swipe Slides)',
        posting: 'Manual approval required',
        turnaround: 'Within 24 hours',
        platform: 'LinkedIn',
        reuse: 'Slides can be repurposed for email, newsletters, or client follow-up.',
        tokenCost: 5,
        xpReward: 2,
        features: ['Educational', 'Authority', 'Lifestyle/Personal Brand', 'Conversation Starters'],
        postTypes: ['Market myths', 'Buyer or seller mistakes', 'Financing clarity', 'Process breakdowns'],
        primaryAction: 'Launch Workflow',
        secondaryActions: ['View Sample Output', 'Adjust Carousel Type (Education or Lifestyle)', 'Skip for Now'],
        category: 'Content Creation',
        status: 'Ready',
      ),

      // LinkedIn Video Insight
      LinkedInService(
        id: 'linkedin_video',
        title: 'LinkedIn Video Insight',
        description: 'Build authority and trust on LinkedIn with strategic video—without becoming a content creator.',
        whatThisIs: 'LinkedIn Video Insight – Posted as You\nA short-form LinkedIn video designed to position you as a credible, thoughtful real estate professional in-feed—without you needing to record, edit, or plan content.\nThis is not "social media fluff."\nThese videos are structured like mini podcasts, real-talk insights, or faceless explainers that feel native to LinkedIn\'s professional environment.\nThe goal is simple:\nWhen people think real estate, your name feels familiar and trustworthy.',
        whyThisIsShowing: '• Your network includes buyers, sellers, agents, or referral partners\n• Video builds trust faster than static posts\n• LinkedIn favors short, insight-driven video content\n• Staying visible reduces friction when opportunities arise\nThis recommendation fills the "I should be posting, but don\'t have time" gap—strategically.',
        whatYouGet: [
          'Expert-written talking points or script',
          'AI voice or faceless video applied if selected',
          'Branded visuals and captions',
          'LinkedIn-optimized formatting and length',
          'Caption written to encourage saves, comments, and profile views',
          'Added to your LinkedIn posting queue'
        ],
        executionType: 'AI-Generated · Agent-Branded',
        format: 'LinkedIn Native Video',
        posting: 'Manual approval required',
        turnaround: 'Within 24 hours',
        platform: 'LinkedIn',
        reuse: 'Video can be repurposed for email, DMs, or agent follow-ups.',
        tokenCost: 6,
        xpReward: 3,
        features: ['Mini Podcast (Face or AI Voice)', 'Real Talk (Direct + Human)', 'Faceless Authority Video'],
        postTypes: ['Market reality checks', 'Process clarity', 'Client expectations'],
        primaryAction: 'Launch Workflow',
        secondaryActions: ['View Sample Video', 'Choose Video Style (Podcast · Real Talk · Faceless)', 'Skip for Now'],
        category: 'Video Content',
        status: 'Ready',
      ),

      // LinkedIn Static Post
      LinkedInService(
        id: 'linkedin_static',
        title: 'LinkedIn Static Post',
        description: 'Stay visible on LinkedIn with professional, human posts that build trust without forcing content creation.',
        whatThisIs: 'LinkedIn Static Post – Posted as You\nA professionally written LinkedIn post featuring you and your real-world activity—clients, closings, travel, lifestyle moments, or milestones—positioned intentionally to reinforce credibility and trust.\nThis is not stock content and not generic motivation.\nThese posts turn everyday moments into brand signals that remind your network you are active, legitimate, and doing real business.\nThe goal is familiarity.\nFamiliarity turns into confidence.\nConfidence turns into conversations.',
        whyThisIsShowing: '• You have real-world activity worth signaling\n• Your LinkedIn presence needs consistency\n• Lifestyle and milestone posts strengthen credibility\n• Visibility compounds even when business is busy\nThis recommendation ensures your wins, movement, and presence don\'t go unseen.',
        whatYouGet: [
          'Expert-written LinkedIn caption tailored to your photo',
          'Professional tone aligned with real estate credibility',
          'Strategic framing (gratitude, insight, progress, reflection)',
          'Optimized formatting for LinkedIn feed engagement',
          'Hashtags and spacing applied correctly',
          'Added to your LinkedIn posting queue'
        ],
        executionType: 'AI-Generated · Agent-Branded',
        format: 'LinkedIn Static Post (Your Photo + Caption)',
        posting: 'Manual approval required',
        turnaround: 'Within 24 hours',
        platform: 'LinkedIn',
        reuse: 'Caption can be adapted for Instagram or email if needed.',
        tokenCost: 3,
        xpReward: 1,
        features: ['Client Wins & Closings', 'Testimonials & Social Proof', 'Lifestyle & Travel', 'Seasonal & Holiday Presence'],
        postTypes: ['Gratitude posts', 'Outcome-focused feedback', 'Work-life balance', 'Holiday reflections'],
        primaryAction: 'Launch Workflow',
        secondaryActions: ['Upload or Select Photo', 'Adjust Post Type (Closing · Testimonial · Lifestyle · Seasonal)', 'Skip for Now'],
        category: 'Social Media',
        status: 'Ready',
      ),

      // LinkedIn Profile Authority Optimization
      LinkedInService(
        id: 'linkedin_profile',
        title: 'LinkedIn Profile Authority Optimization',
        description: 'Turn your LinkedIn profile into a trust asset that works before you ever send a message.',
        whatThisIs: 'LinkedIn Profile Authority Optimization\nA strategic rewrite of your LinkedIn profile designed to position you as a credible, active, and relevant real estate professional the moment someone clicks your name.\nThis is not a design refresh.\nThis is positioning.\nYour profile becomes a silent closer that validates you before DMs, referrals, introductions, or inbound conversations happen.',
        whyThisIsShowing: '• You\'re active on LinkedIn or plan to be\n• Your profile was built passively, not strategically\n• Authority and clarity increase response rates\n• Strong profiles reduce friction in outreach\nMost agents lose momentum not because of their message—but because of their profile.',
        whatYouGet: [
          'Headline Rewrite - Optimized for LinkedIn search and instant credibility',
          'About Section Rewritten - Structured for trust, clarity, and conversion',
          'Featured Section Strategy - Clear guidance on what to showcase',
          'Experience Reframed - Your role rewritten to sound current, active, and relevant'
        ],
        executionType: 'Expert-Led · AI-Assisted',
        format: 'Full Profile Optimization',
        posting: 'Manual approval required',
        turnaround: '48 hours',
        platform: 'LinkedIn',
        reuse: 'Language can be repurposed for bio pages + media kits',
        tokenCost: 8,
        xpReward: 4,
        features: ['Headline Optimization', 'About Section Rewrite', 'Featured Strategy', 'Experience Reframing'],
        postTypes: ['Professional positioning', 'Authority building', 'Trust signals'],
        primaryAction: 'Optimize My Profile',
        secondaryActions: ['View Sample Profile', 'Ask a Question', 'Skip for Now'],
        category: 'Profile Optimization',
        status: 'Ready',
      ),

      // LinkedIn Weekly Posting System
      LinkedInService(
        id: 'linkedin_weekly',
        title: 'LinkedIn Weekly Posting System',
        description: 'A done-for-you content rhythm designed to keep you visible, relevant, and top-of-feed without writing a single post.',
        whatThisIs: 'LinkedIn Weekly Posting System — Posted as You\nA done-for-you content rhythm designed to keep you visible, relevant, and top-of-feed without writing a single post.\nThis service delivers professional weekly content that educates, builds authority, and maintains audience trust—without you creating, drafting, or scheduling manually.',
        whyThisIsShowing: '• You need consistent visibility to stay top-of-mind\n• You\'re not posting weekly on LinkedIn\n• Staying active builds credibility, leads, and inbound conversations',
        whatYouGet: [
          '2–3 posts per week (education, authority, personal/lifestyle)',
          'Written in your voice and tuned to your market',
          'Auto-scheduled into your posting queue',
          'Approval required before anything publishes',
          'Monthly snapshot of visibility + engagement trends'
        ],
        executionType: 'AI-Assisted · Agent-Positioned',
        format: 'Weekly Content System',
        posting: 'Manual approval required',
        turnaround: 'Content delivered weekly',
        platform: 'LinkedIn',
        reuse: 'Can be repurposed for Instagram, TikTok & email',
        tokenCost: 5,
        xpReward: 2,
        features: ['Weekly Planning', 'Content Creation', 'Scheduling', 'Analytics'],
        postTypes: ['Educational content', 'Authority posts', 'Personal/lifestyle updates'],
        primaryAction: 'Launch Workflow',
        secondaryActions: ['View Sample Calendar', 'Set Posting Preferences', 'Skip for Now'],
        category: 'Content System',
        status: 'Ready',
      ),
    ];
  }

  LinkedInService? getServiceById(String id) {
    try {
      return getLinkedInServices().firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }

  List<LinkedInService> getServicesByCategory(String category) {
    return getLinkedInServices().where((service) => service.category == category).toList();
  }
}
