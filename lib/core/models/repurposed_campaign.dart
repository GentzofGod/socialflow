import 'platform_output.dart';

class RepurposedCampaign {
  final String id;
  final String title;
  final String sourceText;
  final String tone;
  final String targetAudience;
  final String callToAction;
  final DateTime createdAt;
  final LinkedInPost linkedIn;
  final TwitterThread twitter;
  final InstagramCarousel instagram;
  final NewsletterBlast newsletter;

  const RepurposedCampaign({
    required this.id,
    required this.title,
    required this.sourceText,
    required this.tone,
    required this.targetAudience,
    required this.callToAction,
    required this.createdAt,
    required this.linkedIn,
    required this.twitter,
    required this.instagram,
    required this.newsletter,
  });

  factory RepurposedCampaign.fromJson(Map<String, dynamic> json) {
    return RepurposedCampaign(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'Untitled Campaign',
      sourceText: json['sourceText'] as String? ?? '',
      tone: json['tone'] as String? ?? 'Thought Leadership',
      targetAudience: json['targetAudience'] as String? ?? 'Creators & Founders',
      callToAction: json['callToAction'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      linkedIn: LinkedInPost.fromJson(json['linkedIn'] as Map<String, dynamic>),
      twitter: TwitterThread.fromJson(json['twitter'] as Map<String, dynamic>),
      instagram: InstagramCarousel.fromJson(json['instagram'] as Map<String, dynamic>),
      newsletter: NewsletterBlast.fromJson(json['newsletter'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'sourceText': sourceText,
    'tone': tone,
    'targetAudience': targetAudience,
    'callToAction': callToAction,
    'createdAt': createdAt.toIso8601String(),
    'linkedIn': linkedIn.toJson(),
    'twitter': twitter.toJson(),
    'instagram': instagram.toJson(),
    'newsletter': newsletter.toJson(),
  };

  String exportAllAsMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# $title - OmniFlow Repurposed Campaign');
    buffer.writeln('Generated on: ${createdAt.toLocal()}');
    buffer.writeln('Tone: $tone | Audience: $targetAudience');
    buffer.writeln('========================================\n');

    buffer.writeln('## 1. LinkedIn Thought Leadership Post\n');
    buffer.writeln(linkedIn.fullFormattedText);
    buffer.writeln('\n========================================\n');

    buffer.writeln('## 2. X (Twitter) 5-Tweet Thread\n');
    buffer.writeln(twitter.fullFormattedThread);
    buffer.writeln('\n========================================\n');

    buffer.writeln('## 3. Instagram Carousel & Slide Design Prompts\n');
    buffer.writeln(instagram.fullFormattedPost);
    buffer.writeln('\n========================================\n');

    buffer.writeln('## 4. Newsletter / Email Announcement\n');
    buffer.writeln(newsletter.fullFormattedNewsletter);

    return buffer.toString();
  }
}
