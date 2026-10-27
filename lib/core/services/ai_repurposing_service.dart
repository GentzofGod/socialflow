import '../models/platform_output.dart';
import '../models/repurposed_campaign.dart';

class AiRepurposingService {
  const AiRepurposingService();

  /// Transform a single source idea into 4 synchronized social media assets
  Future<RepurposedCampaign> repurposeContent({
    required String sourceText,
    required String tone,
    required String targetAudience,
    required String callToAction,
    String? customApiKey,
  }) async {
    // Artificial slight delay for realistic generation animation if local
    await Future.delayed(const Duration(milliseconds: 900));

    final sanitizedSource = sourceText.trim();
    final firstSentence = sanitizedSource.split(RegExp(r'[.\n]')).first.trim();
    final title = firstSentence.length > 40
        ? '${firstSentence.substring(0, 40)}...'
        : (firstSentence.isNotEmpty ? firstSentence : 'New Campaign');

    // Generate LinkedIn Post
    final linkedIn = _synthesizeLinkedIn(
      source: sanitizedSource,
      tone: tone,
      audience: targetAudience,
      cta: callToAction,
    );

    // Generate Twitter Thread
    final twitter = _synthesizeTwitter(
      source: sanitizedSource,
      tone: tone,
      cta: callToAction,
    );

    // Generate Instagram Carousel
    final instagram = _synthesizeInstagram(
      source: sanitizedSource,
      tone: tone,
      cta: callToAction,
    );

    // Generate Newsletter Blast
    final newsletter = _synthesizeNewsletter(
      source: sanitizedSource,
      tone: tone,
      cta: callToAction,
    );

    return RepurposedCampaign(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      sourceText: sanitizedSource,
      tone: tone,
      targetAudience: targetAudience,
      callToAction: callToAction,
      createdAt: DateTime.now(),
      linkedIn: linkedIn,
      twitter: twitter,
      instagram: instagram,
      newsletter: newsletter,
    );
  }

  LinkedInPost _synthesizeLinkedIn({
    required String source,
    required String tone,
    required String audience,
    required String cta,
  }) {
    String hook = 'Most people get this completely wrong:';
    if (tone.contains('Story')) {
      hook = 'A year ago, I made a mistake that changed how I work forever.';
    } else if (tone.contains('Punchy')) {
      hook = 'Stop overcomplicating this. Here is the unvarnished truth:';
    } else if (tone.contains('Thought')) {
      hook = 'The biggest competitive advantage in 2026 isn\'t speed. It\'s clarity.';
    }

    final lessons = [
      'Focus on high-leverage workflows instead of brute-force hours.',
      'One deep insight repeated consistently beats 10 mediocre ideas.',
      'Systematize the repetitive friction so creativity has breathing room.',
      'Measure momentum by execution rate, not vanity planning.',
    ];

    return LinkedInPost(
      hook: hook,
      storyContext:
          'When working on $source, the hardest part isn\'t starting—it\'s maintaining momentum while scaling quality for $audience.',
      keyLessons: lessons,
      callToAction: cta.isNotEmpty
          ? cta
          : 'What has been your single biggest breakthrough this week? Drop it below 👇',
      hashtags: ['#OmniFlow', '#Productivity', '#ContentStrategy', '#CreatorEconomy', '#Growth'],
    );
  }

  TwitterThread _synthesizeTwitter({
    required String source,
    required String tone,
    required String cta,
  }) {
    final cleanCta = cta.isNotEmpty ? cta : 'If you found this valuable, follow for daily breakdowns!';

    return TwitterThread(
      tweets: [
        '1/5 🧵 Most people spend 10+ hours a week fighting content burnout.\n\nHere is the exact playbook to turn 1 raw idea into a full-scale distribution engine (without losing quality) 👇',
        '2/5 The Core Bottleneck:\n\n$source\n\nYou don\'t have an idea shortage. You have a distribution and formatting friction problem.',
        '3/5 The 80/20 Rule:\n\n• Step 1: Write once in high resolution.\n• Step 2: Extract the core framework.\n• Step 3: Format natively for the platform psychology.\n\nLinkedIn wants context. X wants velocity.',
        '4/5 Don\'t reinvent the wheel every morning.\n\nSystems scale. Random bursts of motivation crash. Automate the friction so your creative energy stays fresh.',
        '5/5 TL;DR:\n\n1. Stop writing from blank pages.\n2. Repurpose horizontally across channels.\n3. Build once, distribute 4x.\n\n$cleanCta 🚀',
      ],
    );
  }

  InstagramCarousel _synthesizeInstagram({
    required String source,
    required String tone,
    required String cta,
  }) {
    final slides = [
      CarouselSlide(
        slideNumber: 1,
        headline: 'The 10-Minute Repurposing Framework',
        subheadline: 'How to turn 1 idea into 4 viral formats without burning out.',
        bulletPoints: ['Swipe to see the full breakdown ➡️'],
        visualPrompt:
            'Minimalist dark mode tech poster, neon indigo glowing badge, bold typography "REPURPOSE 10X", 4k studio lighting',
      ),
      CarouselSlide(
        slideNumber: 2,
        headline: 'The Problem: Creation Fatigue',
        subheadline: 'Why creating from scratch every day is a trap:',
        bulletPoints: [
          'Fragmented attention across platforms',
          'Inconsistent brand voice and positioning',
          'Hours wasted on manual reformatting',
        ],
        visualPrompt:
            'Clean isometric 3D illustration of a glowing holographic brain organizing social media cards, glassmorphism style',
      ),
      CarouselSlide(
        slideNumber: 3,
        headline: 'The Core Shift',
        subheadline: 'Shift from "Daily Content" to "Core Anchor Assets":',
        bulletPoints: [
          'Draft your primary anchor note: "$source"',
          'Extract high-signal quotes and tactical frameworks',
          'Let AI handle the cross-platform syntax',
        ],
        visualPrompt:
            'Abstract glowing node network branching into 4 vibrant streams: blue, cyan, purple, and emerald',
      ),
      CarouselSlide(
        slideNumber: 4,
        headline: 'The 4x Formula',
        subheadline: 'Deploy simultaneously across channels:',
        bulletPoints: [
          'LinkedIn: Professional takeaways & actionable lessons',
          'X / Twitter: High-speed thread with punchy hooks',
          'Instagram: Visual carousel with slide-by-slide value',
          'Email: Direct intimate update with single clear CTA',
        ],
        visualPrompt:
            'Sleek futuristic mobile UI showing multi-tab social publishing cards with subtle ambient glow',
      ),
      CarouselSlide(
        slideNumber: 5,
        headline: 'Save This For Later 📌',
        subheadline: 'Work smarter, not harder.',
        bulletPoints: [
          'Double tap if this resonated ❤️',
          'Share with a founder or creator who needs this 🚀',
          cta.isNotEmpty ? cta : 'Follow for more creator systems!',
        ],
        visualPrompt:
            'High contrast typography slide with elegant bookmark icon in glowing emerald and purple gradients',
      ),
    ];

    return InstagramCarousel(
      caption:
          'Stop spending 10 hours a week writing from blank canvases. 🛑\n\n'
          'Here is the exact multi-platform system we use to turn 1 core idea into an entire week of high-converting content.\n\n'
          'Swipe through the carousel above for the step-by-step breakdown! ➡️\n\n'
          'Drop a "⚡" in the comments if you want the full template.',
      slides: slides,
      hashtags: ['#CreatorEconomy', '#Founders', '#ContentMarketing', '#OmniFlow', '#SaaS', '#IndieHacker'],
    );
  }

  NewsletterBlast _synthesizeNewsletter({
    required String source,
    required String tone,
    required String cta,
  }) {
    return NewsletterBlast(
      subjectLineOptions: [
        'How to turn 1 idea into an entire week of content (without burning out)',
        'The unvarnished truth about content distribution in 2026',
        'Inside our new cross-platform creation engine ⚡',
      ],
      previewText: 'Stop starting from scratch every single morning. Here is the framework...',
      bodyMarkdown:
          'Hey there,\n\n'
          'If you\'ve ever sat in front of a blank screen at 8:00 AM wondering what to post on LinkedIn, Twitter, and your newsletter—this is for you.\n\n'
          'Here is the reality:\n'
          'The most prolific creators and founders don\'t write 10 different ideas. They write ONE great anchor idea and format it intelligently for 4 different psychological contexts.\n\n'
          '### The Core Insight\n'
          '$source\n\n'
          '### What This Means For You\n'
          '1. **Context Matters:** Twitter users want punchy velocity. LinkedIn users want career & business context. Newsletter readers want intimacy.\n'
          '2. **Friction Kills Consistency:** When reformatting takes more than 15 minutes, you skip it. Systematizing the pipeline removes the friction completely.\n'
          '3. **Compound Reach:** By distributing horizontally across channels, you multiply your surface area of luck by 4x without 4x the effort.',
      callToAction: cta.isNotEmpty
          ? cta
          : 'Read the full guide on our blog or reply with your biggest question.',
      postScript: 'We just rolled out the new OmniFlow multi-format export. Try it out and let us know what you think!',
    );
  }
}
