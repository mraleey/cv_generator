import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/cv_model.dart';
import '../services/gemini_service.dart';

enum TemplateStyle { classic, modern, minimalist, executive }

class RoleData {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController bulletsController = TextEditingController();
  final TextEditingController techController = TextEditingController();
  final RxBool isCurrentRole = false.obs;

  void dispose() {
    titleController.dispose();
    companyController.dispose();
    locationController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    bulletsController.dispose();
    techController.dispose();
    isCurrentRole.close();
  }
}

class CVController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();
  final TextEditingController portfolioController = TextEditingController();
  final TextEditingController githubController = TextEditingController();
  final TextEditingController twitterController = TextEditingController();
  final TextEditingController cityStateController = TextEditingController();
  final TextEditingController professionalTitleController =
      TextEditingController();

  final TextEditingController summaryController = TextEditingController();
  final TextEditingController techSkillsController = TextEditingController();
  final TextEditingController toolsController = TextEditingController();
  final TextEditingController softSkillsController = TextEditingController();

  final List<RoleData> roles = [RoleData()];

  TemplateStyle currentTemplate = TemplateStyle.classic;
  Color themeColor = const Color(0xFF263238); // blueGrey900
  bool isEnhancing = false;

  void setThemeColor(Color color) {
    themeColor = color;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(update);
    emailController.addListener(update);
    phoneController.addListener(update);
    linkedinController.addListener(update);
    portfolioController.addListener(update);
    githubController.addListener(update);
    twitterController.addListener(update);
    cityStateController.addListener(update);
    professionalTitleController.addListener(update);

    summaryController.addListener(update);
    techSkillsController.addListener(update);
    toolsController.addListener(update);
    softSkillsController.addListener(update);
    _attachRoleListeners(roles.first);
  }

  void _attachRoleListeners(RoleData role) {
    role.titleController.addListener(update);
    role.companyController.addListener(update);
    role.locationController.addListener(update);
    role.startDateController.addListener(update);
    role.endDateController.addListener(update);
    role.bulletsController.addListener(update);
    role.techController.addListener(update);
    ever(role.isCurrentRole, (_) => update());
  }

  void addRole() {
    final role = RoleData();
    _attachRoleListeners(role);
    roles.add(role);
    update();
  }

  void removeRole(int index) {
    final role = roles.removeAt(index);
    role.dispose();
    update();
  }

  void setTemplate(TemplateStyle style) {
    currentTemplate = style;
    update();
  }

  Future<void> enhanceSummary(String apiKey) async {
    if (summaryController.text.trim().isEmpty) {
      throw Exception('Please enter a draft summary first.');
    }

    isEnhancing = true;
    update();

    try {
      final grok = GrokService(apiKey);
      final enhanced = await grok.enhanceSummary(summaryController.text);
      summaryController.text = enhanced;
    } finally {
      isEnhancing = false;
      update();
    }
  }

  Future<void> autoSuggestTemplate(String apiKey) async {
    isEnhancing = true;
    update();

    try {
      final cv = buildCVModel();
      final grok = GrokService(apiKey);
      final suggested = await grok.suggestTemplate(cv);
      setTemplate(suggested);
    } finally {
      isEnhancing = false;
      update();
    }
  }

  Future<void> autoSuggestBullets(String apiKey, RoleData role) async {
    if (role.titleController.text.trim().isEmpty) {
      throw Exception('Please enter a Job Title first.');
    }

    isEnhancing = true;
    update();

    try {
      final grok = GrokService(apiKey);
      final bullets = await grok.suggestJobBullets(
        role.titleController.text,
        role.companyController.text,
        techSkillsController.text,
        toolsController.text,
        softSkillsController.text,
      );
      if (bullets.isNotEmpty) {
        final current = role.bulletsController.text.trim();
        role.bulletsController.text = current.isEmpty
            ? bullets
            : '$current\n$bullets';
      }
    } finally {
      isEnhancing = false;
      update();
    }
  }

  Future<void> autoSuggestSkills(String apiKey) async {
    isEnhancing = true;
    update();

    try {
      final grok = GrokService(apiKey);
      final skills = await grok.suggestSkills(summaryController.text);
      if (skills.isNotEmpty) {
        techSkillsController.text = skills;
      }
    } finally {
      isEnhancing = false;
      update();
    }
  }

  CVModel buildCVModel() {
    return CVModel(
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      linkedin: linkedinController.text,
      portfolio: portfolioController.text,
      github: githubController.text,
      twitter: twitterController.text,
      cityState: cityStateController.text,
      professionalTitle: professionalTitleController.text,
      profileSummary: summaryController.text,
      roles: roles.map((r) {
        return Role(
          jobTitle: r.titleController.text,
          company: r.companyController.text,
          location: r.locationController.text,
          startDate: r.startDateController.text,
          endDate: r.isCurrentRole.value ? 'Present' : r.endDateController.text,
          bulletPoints: r.bulletsController.text
              .split('\n')
              .where((s) => s.trim().isNotEmpty)
              .toList(),
          technologiesUsed: r.techController.text
              .split(',')
              .map((e) => e.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
        );
      }).toList(),
      skillsCategorized: SkillsCategorized(
        technical: techSkillsController.text
            .split(',')
            .map((e) => e.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        toolsAndPlatforms: toolsController.text
            .split(',')
            .map((e) => e.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        softSkills: softSkillsController.text
            .split(',')
            .map((e) => e.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      ),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    linkedinController.dispose();
    portfolioController.dispose();
    githubController.dispose();
    twitterController.dispose();
    cityStateController.dispose();
    professionalTitleController.dispose();
    summaryController.dispose();
    techSkillsController.dispose();
    toolsController.dispose();
    softSkillsController.dispose();
    for (var r in roles) {
      r.dispose();
    }
    super.onClose();
  }
}
