class CarouselSlide {
  final int slideNumber;
  final String headline;
  final String subheadline;
  final List<String> bulletPoints;
  final String visualPrompt;

  const CarouselSlide({
    required this.slideNumber,
    required this.headline,
    required this.subheadline,
    required this.bulletPoints,
    required this.visualPrompt,
  });

  factory CarouselSlide.fromJson(Map<String, dynamic> json) {
    return CarouselSlide(
      slideNumber: json['slideNumber'] as int? ?? 1,
      headline: json['headline'] as String? ?? '',
      subheadline: json['subheadline'] as String? ?? '',
      bulletPoints: (json['bulletPoints'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      visualPrompt: json['visualPrompt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'slideNumber': slideNumber,
    'headline': headline,
    'subheadline': subheadline,
    'bulletPoints': bulletPoints,
    'visualPrompt': visualPrompt,
  };
}

class LinkedInPost {
  final String hook;
  final String storyContext;
  final List<String> keyLessons;
  final String callToAction;
  final List<String> hashtags;

  const LinkedInPost({
    required this.hook,
    required this.storyContext,
    required this.keyLessons,
    required this.callToAction,
    required this.hashtags,
  });

  String get fullFormattedText {
    final buffer = StringBuffer();
    buffer.writeln(hook);
    buffer.writeln();
    buffer.writeln(storyContext);
    buffer.writeln();
    buffer.writeln('Here is the exact breakdown:');
    for (final lesson in keyLessons) {
      buffer.writeln('• $lesson');
    }
    buffer.writeln();
    buffer.writeln(callToAction);
    buffer.writeln();
    buffer.writeln(hashtags.join(' '));
    return buffer.toString().trim();
  }

  factory LinkedInPost.fromJson(Map<String, dynamic> json) {
    return LinkedInPost(
      hook: json['hook'] as String? ?? '',
      storyContext: json['storyContext'] as String? ?? '',
      keyLessons: (json['keyLessons'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      callToAction: json['callToAction'] as String? ?? '',
      hashtags: (json['hashtags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'hook': hook,
    'storyContext': storyContext,
    'keyLessons': keyLessons,
    'callToAction': callToAction,
    'hashtags': hashtags,
  };
}

class TwitterThread {
  final List<String> tweets;

  const TwitterThread({required this.tweets});

  String get fullFormattedThread {
    final buffer = StringBuffer();
    for (int i = 0; i < tweets.length; i++) {
      buffer.writeln('Tweet ${i + 1}/${tweets.length}:');
      buffer.writeln(tweets[i]);
      buffer.writeln('-----------------------------------');
    }
    return buffer.toString().trim();
  }

  factory TwitterThread.fromJson(Map<String, dynamic> json) {
    return TwitterThread(
      tweets: (json['tweets'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {'tweets': tweets};
}

class InstagramCarousel {
  final String caption;
  final List<CarouselSlide> slides;
  final List<String> hashtags;

  const InstagramCarousel({
    required this.caption,
    required this.slides,
    required this.hashtags,
  });

  String get fullFormattedPost {
    final buffer = StringBuffer();
    buffer.writeln(caption);
    buffer.writeln();
    buffer.writeln('--- SLIDE OUTLINE ---');
    for (final slide in slides) {
      buffer.writeln('[Slide ${slide.slideNumber}]: ${slide.headline}');
      if (slide.subheadline.isNotEmpty) buffer.writeln(slide.subheadline);
      for (final bp in slide.bulletPoints) {
        buffer.writeln('  - $bp');
      }
      buffer.writeln('  🎨 Visual Prompt: "${slide.visualPrompt}"');
      buffer.writeln();
    }
    buffer.writeln(hashtags.join(' '));
    return buffer.toString().trim();
  }

  factory InstagramCarousel.fromJson(Map<String, dynamic> json) {
    return InstagramCarousel(
      caption: json['caption'] as String? ?? '',
      slides: (json['slides'] as List<dynamic>?)
              ?.map((e) => CarouselSlide.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hashtags: (json['hashtags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'caption': caption,
    'slides': slides.map((e) => e.toJson()).toList(),
    'hashtags': hashtags,
  };
}

class NewsletterBlast {
  final List<String> subjectLineOptions;
  final String previewText;
  final String bodyMarkdown;
  final String callToAction;
  final String postScript;

  const NewsletterBlast({
    required this.subjectLineOptions,
    required this.previewText,
    required this.bodyMarkdown,
    required this.callToAction,
    required this.postScript,
  });

  String get fullFormattedNewsletter {
    final buffer = StringBuffer();
    buffer.writeln('SUBJECT LINES:');
    for (int i = 0; i < subjectLineOptions.length; i++) {
      buffer.writeln('Option ${i + 1}: ${subjectLineOptions[i]}');
    }
    buffer.writeln();
    buffer.writeln('PREVIEW TEXT: $previewText');
    buffer.writeln('-----------------------------------');
    buffer.writeln(bodyMarkdown);
    buffer.writeln();
    buffer.writeln('👉 $callToAction');
    buffer.writeln();
    buffer.writeln('P.S. $postScript');
    return buffer.toString().trim();
  }

  factory NewsletterBlast.fromJson(Map<String, dynamic> json) {
    return NewsletterBlast(
      subjectLineOptions:
          (json['subjectLineOptions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      previewText: json['previewText'] as String? ?? '',
      bodyMarkdown: json['bodyMarkdown'] as String? ?? '',
      callToAction: json['callToAction'] as String? ?? '',
      postScript: json['postScript'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'subjectLineOptions': subjectLineOptions,
    'previewText': previewText,
    'bodyMarkdown': bodyMarkdown,
    'callToAction': callToAction,
    'postScript': postScript,
  };
}
