import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../services/pdf_service.dart';
import '../controllers/cv_controller.dart';
import 'cv_preview_dialog.dart';

class CVFormView extends StatefulWidget {
  const CVFormView({super.key});

  @override
  State<CVFormView> createState() => _CVFormViewState();
}

class _CVFormViewState extends State<CVFormView> {
  final CVController _controller = Get.put(CVController());
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutQuart,
      );
    } else {
      _showPreviewDialog();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutQuart,
      );
    }
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      builder: (context) => GetBuilder<CVController>(
        builder: (controller) {
          return CVPreviewDialog(
            cv: controller.buildCVModel(),
            controller: controller,
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
      prefixIcon: Icon(icon, size: 22, color: Colors.blueAccent),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();
      setState(() {
        controller.text = '$month/$year';
      });
    }
  }

  Widget _buildStepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPersonalDetailsStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Personal Details',
            'Let\'s start with your contact information.',
          ),
          TextFormField(
            controller: _controller.nameController,
            style: GoogleFonts.inter(),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration('Full Name', Icons.person_outline),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controller.emailController,
            style: GoogleFonts.inter(),
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration('Email Address', Icons.email_outlined),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controller.phoneController,
            style: GoogleFonts.inter(),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration('Phone Number', Icons.phone_outlined),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controller.linkedinController,
            style: GoogleFonts.inter(),
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration('LinkedIn URL', Icons.link),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controller.portfolioController,
            style: GoogleFonts.inter(),
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              'Portfolio / Website URL',
              Icons.language,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controller.githubController,
            style: GoogleFonts.inter(),
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration('GitHub URL', Icons.code),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controller.twitterController,
            style: GoogleFonts.inter(),
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              'Twitter / X URL',
              Icons.alternate_email,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controller.cityStateController,
            style: GoogleFonts.inter(),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              'Location (City, State)',
              Icons.location_on_outlined,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controller.professionalTitleController,
            style: GoogleFonts.inter(),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: _inputDecoration(
              'Professional Title (e.g. Software Engineer)',
              Icons.work_outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Select Template',
            'Choose a layout that fits your industry. Live preview below.',
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _TemplateCard(
                  title: 'Classic',
                  subtitle: 'Harvard style. Best for finance & law.',
                  icon: Icons.account_balance,
                  isSelected:
                      _controller.currentTemplate == TemplateStyle.classic,
                  onTap: () => _controller.setTemplate(TemplateStyle.classic),
                  width: 200,
                ),
                const SizedBox(width: 16),
                _TemplateCard(
                  title: 'Modern',
                  subtitle: 'Two columns. Best for tech.',
                  icon: Icons.view_quilt,
                  isSelected:
                      _controller.currentTemplate == TemplateStyle.modern,
                  onTap: () => _controller.setTemplate(TemplateStyle.modern),
                  width: 200,
                ),
                const SizedBox(width: 16),
                _TemplateCard(
                  title: 'Minimalist',
                  subtitle: 'Clean & ATS-friendly.',
                  icon: Icons.format_align_left,
                  isSelected:
                      _controller.currentTemplate == TemplateStyle.minimalist,
                  onTap: () =>
                      _controller.setTemplate(TemplateStyle.minimalist),
                  width: 200,
                ),
                const SizedBox(width: 16),
                _TemplateCard(
                  title: 'Executive',
                  subtitle: 'Elegant & formal. For C-suite.',
                  icon: Icons.business_center,
                  isSelected:
                      _controller.currentTemplate == TemplateStyle.executive,
                  onTap: () => _controller.setTemplate(TemplateStyle.executive),
                  width: 200,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildColorPicker(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.psychology,
                  color: Colors.blueAccent,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Not sure which one to pick?',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Let AI read your summary and choose the best template.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _controller.isEnhancing
                      ? null
                      : () async {
                          try {
                            final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
                            await _controller.autoSuggestTemplate(apiKey);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'AI selected: ${_controller.currentTemplate.name}',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            // ignore
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _controller.isEnhancing
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Auto Select',
                          style: TextStyle(fontSize: 12),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 600, // Fixed height to ensure CV is visible and scrollable
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PdfPreview(
                build: (format) => PdfService().generateCVPdf(
                  _controller.buildCVModel(),
                  _controller.currentTemplate,
                  themeColor: PdfColor.fromInt(_controller.themeColor.value),
                ),
                allowSharing: false,
                allowPrinting: false,
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    final colors = [
      const Color(0xFF263238), // blueGrey900
      Colors.blue.shade800,
      Colors.indigo.shade800,
      Colors.teal.shade800,
      Colors.green.shade800,
      Colors.red.shade800,
      Colors.purple.shade800,
      Colors.brown.shade800,
      Colors.grey.shade900,
      Colors.black,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Color',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            final isSelected = _controller.themeColor.value == color.value;
            return GestureDetector(
              onTap: () => _controller.setThemeColor(color),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Colors.blueAccent
                        : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Executive Summary',
            'Write a brief overview of your career.',
          ),
          TextFormField(
            controller: _controller.summaryController,
            maxLines: 6,
            style: GoogleFonts.inter(fontSize: 15, height: 1.5),
            textCapitalization: TextCapitalization.sentences,
            decoration:
                _inputDecoration(
                  'Profile Summary (Draft)',
                  Icons.person,
                ).copyWith(
                  hintText:
                      'E.g., Software engineer with 5 years of experience...',
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent.shade100.withOpacity(
                  0.2,
                ),
                foregroundColor: Colors.deepPurpleAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _controller.isEnhancing
                  ? null
                  : () async {
                      try {
                        final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
                        await _controller.enhanceSummary(apiKey);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      }
                    },
              icon: _controller.isEnhancing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                'Rewrite professionally with AI',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Work Experience',
            'List your relevant professional history.',
          ),
          ..._controller.roles.asMap().entries.map((entry) {
            int idx = entry.key;
            RoleData role = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Role ${idx + 1}',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _controller.removeRole(idx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: role.titleController,
                      style: GoogleFonts.inter(),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration('Job Title', Icons.badge),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: role.companyController,
                      style: GoogleFonts.inter(),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration('Company', Icons.business),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: role.locationController,
                      style: GoogleFonts.inter(),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        'Location (City, State)',
                        Icons.location_on,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      final isCurrent = role.isCurrentRole.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: role.startDateController,
                                  readOnly: true,
                                  onTap: () => _selectDate(
                                    context,
                                    role.startDateController,
                                  ),
                                  style: GoogleFonts.inter(),
                                  decoration: _inputDecoration(
                                    'Start Date',
                                    Icons.calendar_today,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: role.endDateController,
                                  readOnly: true,
                                  enabled: !isCurrent,
                                  onTap: isCurrent
                                      ? null
                                      : () => _selectDate(
                                          context,
                                          role.endDateController,
                                        ),
                                  style: GoogleFonts.inter(),
                                  decoration:
                                      _inputDecoration(
                                        isCurrent ? 'Present' : 'End Date',
                                        Icons.event,
                                      ).copyWith(
                                        filled: isCurrent,
                                        fillColor: isCurrent
                                            ? Colors.grey.shade100
                                            : Colors.grey.shade50,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(
                              'I currently work here',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                            value: isCurrent,
                            onChanged: (val) {
                              if (val != null) {
                                role.isCurrentRole.value = val;
                                if (val) role.endDateController.clear();
                              }
                            },
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: role.bulletsController,
                      maxLines: 15,
                      style: GoogleFonts.inter(height: 1.5),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration(
                        'Bullet Points (One achievement per line)',
                        Icons.list_alt,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _controller.isEnhancing
                            ? null
                            : () async {
                                try {
                                  final apiKey =
                                      dotenv.env['GROQ_API_KEY'] ?? '';
                                  await _controller.autoSuggestBullets(
                                    apiKey,
                                    role,
                                  );
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              },
                        icon: const Icon(
                          Icons.auto_awesome,
                          color: Colors.deepPurple,
                        ),
                        label: Text(
                          'Generate Impactful Bullets with AI',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _controller.addRole,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blueAccent, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.blueAccent),
              label: Text(
                'Add Another Role',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Skills', 'List your core competencies.'),
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple.shade100),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.purple, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate Skills automatically',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AI will read your summary and extract your top skills.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _controller.isEnhancing
                      ? null
                      : () async {
                          try {
                            final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
                            await _controller.autoSuggestSkills(apiKey);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Generate'),
                ),
              ],
            ),
          ),
          TextFormField(
            controller: _controller.techSkillsController,
            style: GoogleFonts.inter(),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              'Technical Skills (Comma separated)',
              Icons.memory,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controller.toolsController,
            style: GoogleFonts.inter(),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              'Tools & Platforms (Comma separated)',
              Icons.build,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controller.softSkillsController,
            style: GoogleFonts.inter(),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: _inputDecoration(
              'Soft Skills (Comma separated)',
              Icons.groups,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Professional light gray
      appBar: AppBar(
        title: Text(
          'AI Resume Builder',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GetBuilder<CVController>(
        builder: (controller) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                children: [
                  // Custom Progress Indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16,
                    ),
                    child: Row(
                      children: List.generate(_totalSteps, (index) {
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            decoration: BoxDecoration(
                              color: index <= _currentStep
                                  ? Colors.blueAccent
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Page Content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable swipe to force using buttons
                      onPageChanged: (idx) =>
                          setState(() => _currentStep = idx),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: _buildPersonalDetailsStep(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: _buildSummaryStep(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: _buildExperienceStep(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: _buildSkillsStep(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: _buildTemplateStep(),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Navigation Bar
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          OutlinedButton(
                            onPressed: _prevStep,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              'Back',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          )
                        else
                          const SizedBox(), // Spacer

                        ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentStep == _totalSteps - 1
                                ? Colors.green
                                : Colors.black87,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentStep == _totalSteps - 1
                                ? 'Full Screen & Export'
                                : 'Next Step',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;

  const _TemplateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.blueAccent : Colors.grey.shade500,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isSelected ? Colors.blueAccent : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
