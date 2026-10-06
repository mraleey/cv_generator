class CVModel {
  final String name;
  final String email;
  final String phone;
  final String linkedin;
  final String portfolio;
  final String github;
  final String twitter;
  final String cityState;
  final String professionalTitle;
  final String profileSummary;
  final List<Role> roles;
  final SkillsCategorized skillsCategorized;

  CVModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.linkedin,
    required this.portfolio,
    required this.github,
    required this.twitter,
    required this.cityState,
    required this.professionalTitle,
    required this.profileSummary,
    required this.roles,
    required this.skillsCategorized,
  });

  factory CVModel.fromJson(Map<String, dynamic> json) {
    return CVModel(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      linkedin: json['linkedin'] as String? ?? '',
      portfolio: json['portfolio'] as String? ?? '',
      github: json['github'] as String? ?? '',
      twitter: json['twitter'] as String? ?? '',
      cityState: json['city_state'] as String? ?? '',
      professionalTitle: json['professional_title'] as String? ?? '',
      profileSummary: json['profile_summary'] as String? ?? '',
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => Role.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      skillsCategorized: SkillsCategorized.fromJson(
        json['skills_categorized'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'linkedin': linkedin,
      'portfolio': portfolio,
      'github': github,
      'twitter': twitter,
      'city_state': cityState,
      'professional_title': professionalTitle,
      'profile_summary': profileSummary,
      'roles': roles.map((e) => e.toJson()).toList(),
      'skills_categorized': skillsCategorized.toJson(),
    };
  }
}

class Role {
  final String jobTitle;
  final String company;
  final String location;
  final String startDate;
  final String endDate;
  final List<String> bulletPoints;
  final List<String> technologiesUsed;

  Role({
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.bulletPoints,
    required this.technologiesUsed,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      jobTitle: json['job_title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      bulletPoints:
          (json['bullet_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      technologiesUsed:
          (json['technologies_used'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_title': jobTitle,
      'company': company,
      'location': location,
      'start_date': startDate,
      'end_date': endDate,
      'bullet_points': bulletPoints,
      'technologies_used': technologiesUsed,
    };
  }
}

class SkillsCategorized {
  final List<String> technical;
  final List<String> toolsAndPlatforms;
  final List<String> softSkills;

  SkillsCategorized({
    required this.technical,
    required this.toolsAndPlatforms,
    required this.softSkills,
  });

  factory SkillsCategorized.fromJson(Map<String, dynamic> json) {
    return SkillsCategorized(
      technical:
          (json['technical'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      toolsAndPlatforms:
          (json['tools_and_platforms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      softSkills:
          (json['soft_skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'technical': technical,
      'tools_and_platforms': toolsAndPlatforms,
      'soft_skills': softSkills,
    };
  }
}
