import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cv_model.dart';
import '../controllers/cv_controller.dart';

class PdfService {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;
  static pw.Font? _italicFont;
  static pw.Font? _serifRegular;
  static pw.Font? _serifBold;

  Future<void> _loadFonts() async {
    _regularFont ??= await PdfGoogleFonts.latoRegular();
    _boldFont ??= await PdfGoogleFonts.latoBold();
    _italicFont ??= await PdfGoogleFonts.latoItalic();
    _serifRegular ??= await PdfGoogleFonts.merriweatherRegular();
    _serifBold ??= await PdfGoogleFonts.merriweatherBold();
  }

  static String _cleanUrl(String url) {
    if (url.isEmpty) return '';
    var clean = url.split('?').first;
    clean = clean.replaceAll(RegExp(r'^https?://(www\.)?'), '');
    if (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    return clean;
  }

  static String _sanitizeText(String text) {
    if (text.isEmpty) return text;
    return text
        .replaceAll('‘', "'")
        .replaceAll('’', "'")
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('–', '-') // en-dash
        .replaceAll('—', '-') // em-dash
        .replaceAll('‑', '-') // non-breaking hyphen (U+2011)
        .replaceAll('…', '...');
  }

  static pw.Widget _buildSocialLink(
    String url,
    String platform,
    pw.TextStyle style,
  ) {
    if (url.isEmpty) return pw.SizedBox();

    var clean = _cleanUrl(url);
    String username = clean;
    var parts = clean.split('/');
    if (parts.length > 1 && parts.last.isNotEmpty) {
      username = parts.last;
    } else if (parts.length > 2 && parts[parts.length - 2] == 'in') {
      username = parts.last;
    }

    final destination = url.startsWith('http') ? url : 'https://$url';

    return pw.UrlLink(
      destination: destination,
      child: pw.Text('$platform: $username', style: style),
    );
  }

  static pw.Widget _buildContactRow(
    CVModel cv,
    pw.TextStyle style,
    String separator,
  ) {
    final widgets = <pw.Widget>[];

    void addWidget(pw.Widget w) {
      if (widgets.isNotEmpty) {
        widgets.add(pw.Text(separator, style: style));
      }
      widgets.add(w);
    }

    if (cv.email.isNotEmpty) {
      addWidget(
        pw.UrlLink(
          destination: 'mailto:${cv.email}',
          child: pw.Text(cv.email, style: style),
        ),
      );
    }
    if (cv.phone.isNotEmpty) {
      addWidget(
        pw.UrlLink(
          destination: 'tel:${cv.phone}',
          child: pw.Text(cv.phone, style: style),
        ),
      );
    }
    if (cv.cityState.isNotEmpty) {
      addWidget(pw.Text(cv.cityState, style: style));
    }
    if (cv.linkedin.isNotEmpty)
      addWidget(_buildSocialLink(cv.linkedin, 'LinkedIn', style));
    if (cv.portfolio.isNotEmpty)
      addWidget(_buildSocialLink(cv.portfolio, 'Portfolio', style));
    if (cv.github.isNotEmpty)
      addWidget(_buildSocialLink(cv.github, 'GitHub', style));
    if (cv.twitter.isNotEmpty)
      addWidget(_buildSocialLink(cv.twitter, 'Twitter', style));

    if (widgets.isEmpty) {
      return pw.Text(
        'email@domain.com $separator 555-555-5555 $separator City, State',
        style: style,
      );
    }

    return pw.Wrap(
      alignment: pw.WrapAlignment.center,
      crossAxisAlignment: pw.WrapCrossAlignment.center,
      children: widgets,
    );
  }

  Future<Uint8List> generateCVPdf(
    CVModel cv,
    TemplateStyle style, {
    PdfColor themeColor = PdfColors.blueGrey900,
  }) async {
    await _loadFonts();
    final pdf = pw.Document();

    final theme = pw.ThemeData.withFont(
      base: _regularFont,
      bold: _boldFont,
      italic: _italicFont,
    );

    final serifReg = _serifRegular!;
    final serifBld = _serifBold!;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40), // Professional 1-inch margins
        theme: theme,
        build: (pw.Context context) {
          switch (style) {
            case TemplateStyle.classic:
              return _buildHarvardClassic(cv, themeColor);
            case TemplateStyle.modern:
              return _buildModernTwoColumn(cv, themeColor);
            case TemplateStyle.minimalist:
              return _buildMinimalist(cv, themeColor);
            case TemplateStyle.executive:
              return _buildExecutive(cv, serifReg, serifBld, themeColor);
          }
        },
      ),
    );

    return pdf.save();
  }

  // --- HARVARD CLASSIC ---
  List<pw.Widget> _buildHarvardClassic(CVModel cv, PdfColor themeColor) {
    return [
      pw.Center(
        child: pw.Text(
          cv.name.isNotEmpty ? cv.name : 'YOUR NAME',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.SizedBox(height: 4),
      _buildContactRow(cv, const pw.TextStyle(fontSize: 10), '  |  '),
      pw.SizedBox(height: 12),

      _sectionHeaderClassic('SUMMARY'),
      pw.Text(
        _sanitizeText(cv.profileSummary),
        style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5),
      ),
      pw.SizedBox(height: 12),

      _sectionHeaderClassic('EXPERIENCE'),
      ...cv.roles.map((role) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  role.company,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  role.location,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  role.jobTitle,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                pw.Text(
                  '${role.startDate} - ${role.endDate}',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            ...role.bulletPoints.map(
              (bp) => pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('  •  ', style: const pw.TextStyle(fontSize: 10)),
                  pw.Expanded(
                    child: pw.Text(
                      _sanitizeText(bp),
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),
          ],
        );
      }),

      _sectionHeaderClassic('SKILLS'),
      pw.Text(
        "Technical: ${cv.skillsCategorized.technical.join(', ')}",
        style: const pw.TextStyle(fontSize: 10),
      ),
      pw.Text(
        "Tools: ${cv.skillsCategorized.toolsAndPlatforms.join(', ')}",
        style: const pw.TextStyle(fontSize: 10),
      ),
      pw.Text(
        "Soft Skills: ${cv.skillsCategorized.softSkills.join(', ')}",
        style: const pw.TextStyle(fontSize: 10),
      ),
    ];
  }

  pw.Widget _sectionHeaderClassic(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 2, bottom: 6),
          height: 1,
          color: PdfColors.black,
        ),
      ],
    );
  }

  // --- MODERN TWO COLUMN ---
  List<pw.Widget> _buildModernTwoColumn(CVModel cv, PdfColor themeColor) {
    final primaryColor = PdfColor.fromHex('#2B2B2B');
    final accentColor = themeColor; // User selected color

    return [
      pw.Partitions(
        children: [
          // Left Column
          pw.Partition(
            flex: 1,
            child: pw.Container(
              padding: const pw.EdgeInsets.only(right: 20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    cv.name.isNotEmpty ? cv.name.toUpperCase() : 'YOUR NAME',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  if (cv.professionalTitle.isNotEmpty)
                    pw.Text(
                      cv.professionalTitle,
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: accentColor,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    )
                  else
                    pw.Text(
                      'Professional Title',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: accentColor,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  pw.SizedBox(height: 20),

                  pw.Text(
                    'CONTACT',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  if (cv.email.isNotEmpty)
                    pw.UrlLink(
                      destination: 'mailto:${cv.email}',
                      child: pw.Text(
                        cv.email,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    )
                  else
                    pw.Text(
                      'email@example.com',
                      style: const pw.TextStyle(fontSize: 9),
                    ),

                  if (cv.phone.isNotEmpty)
                    pw.UrlLink(
                      destination: 'tel:${cv.phone}',
                      child: pw.Text(
                        cv.phone,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    )
                  else
                    pw.Text(
                      '(123) 456-7890',
                      style: const pw.TextStyle(fontSize: 9),
                    ),

                  if (cv.cityState.isNotEmpty)
                    pw.Text(
                      cv.cityState,
                      style: const pw.TextStyle(fontSize: 9),
                    )
                  else
                    pw.Text(
                      'City, Country',
                      style: const pw.TextStyle(fontSize: 9),
                    ),

                  if (cv.linkedin.isNotEmpty)
                    _buildSocialLink(
                      cv.linkedin,
                      'LinkedIn',
                      const pw.TextStyle(fontSize: 9),
                    ),
                  if (cv.portfolio.isNotEmpty)
                    _buildSocialLink(
                      cv.portfolio,
                      'Portfolio',
                      const pw.TextStyle(fontSize: 9),
                    ),
                  if (cv.github.isNotEmpty)
                    _buildSocialLink(
                      cv.github,
                      'GitHub',
                      const pw.TextStyle(fontSize: 9),
                    ),
                  if (cv.twitter.isNotEmpty)
                    _buildSocialLink(
                      cv.twitter,
                      'Twitter',
                      const pw.TextStyle(fontSize: 9),
                    ),
                  pw.SizedBox(height: 20),

                  pw.Text(
                    'SKILLS',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  ...cv.skillsCategorized.technical.map(
                    (s) => pw.Text(s, style: const pw.TextStyle(fontSize: 9)),
                  ),
                  ...cv.skillsCategorized.toolsAndPlatforms.map(
                    (s) => pw.Text(s, style: const pw.TextStyle(fontSize: 9)),
                  ),
                ],
              ),
            ),
          ),

          // Right Column
          pw.Partition(
            flex: 2,
            child: pw.Container(
              padding: const pw.EdgeInsets.only(left: 20),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  left: pw.BorderSide(color: PdfColors.grey300, width: 1),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'PROFILE',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    _sanitizeText(cv.profileSummary),
                    style: const pw.TextStyle(
                      fontSize: 10,
                      lineSpacing: 1.5,
                      color: PdfColors.grey800,
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  pw.Text(
                    'EXPERIENCE',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  ...cv.roles.map((role) {
                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          role.jobTitle,
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        pw.Text(
                          '${role.company} | ${role.startDate} - ${role.endDate}',
                          style: pw.TextStyle(fontSize: 9, color: accentColor),
                        ),
                        pw.SizedBox(height: 6),
                        ...role.bulletPoints.map(
                          (bp) => pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(
                                  top: 3,
                                  right: 6,
                                ),
                                child: pw.Container(
                                  width: 3,
                                  height: 3,
                                  decoration: pw.BoxDecoration(
                                    color: primaryColor,
                                    shape: pw.BoxShape.circle,
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  _sanitizeText(bp),
                                  style: const pw.TextStyle(
                                    fontSize: 9,
                                    color: PdfColors.grey800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 16),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    ];
  }

  // --- MINIMALIST ---
  List<pw.Widget> _buildMinimalist(CVModel cv, PdfColor themeColor) {
    return [
      pw.Text(
        cv.name.isNotEmpty ? cv.name : 'YOUR NAME',
        style: pw.TextStyle(
          fontSize: 28,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      pw.SizedBox(height: 4),
      _buildContactRow(
        cv,
        const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        '  •  ',
      ),
      pw.SizedBox(height: 24),

      pw.Text(
        _sanitizeText(cv.profileSummary),
        style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.6),
      ),
      pw.SizedBox(height: 24),

      pw.Text(
        'EXPERIENCE',
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 1.5,
          color: PdfColors.grey600,
        ),
      ),
      pw.SizedBox(height: 12),
      ...cv.roles.map((role) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    role.jobTitle,
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    role.company,
                    style: pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    '${role.startDate} - ${role.endDate}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              ...role.bulletPoints.map(
                (bp) => pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '—  ',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        _sanitizeText(bp),
                        style: const pw.TextStyle(
                          fontSize: 10,
                          lineSpacing: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),

      pw.SizedBox(height: 8),
      pw.Text(
        'SKILLS',
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 1.5,
          color: PdfColors.grey600,
        ),
      ),
      pw.SizedBox(height: 12),
      pw.Text(
        [
          ...cv.skillsCategorized.technical,
          ...cv.skillsCategorized.toolsAndPlatforms,
        ].join(' • '),
        style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5),
      ),
    ];
  }

  // --- EXECUTIVE ---
  List<pw.Widget> _buildExecutive(
    CVModel cv,
    pw.Font serifRegular,
    pw.Font serifBold,
    PdfColor themeColor,
  ) {
    return [
      pw.Center(
        child: pw.Text(
          cv.name.isNotEmpty ? cv.name : 'YOUR NAME',
          style: pw.TextStyle(
            font: serifBold,
            fontSize: 24,
            color: themeColor,
            letterSpacing: 1,
          ),
        ),
      ),
      pw.SizedBox(height: 6),
      _buildContactRow(
        cv,
        pw.TextStyle(
          font: serifRegular,
          fontSize: 10,
          color: PdfColors.blueGrey700,
        ),
        '  |  ',
      ),
      pw.SizedBox(height: 20),

      pw.Text(
        'EXECUTIVE PROFILE',
        style: pw.TextStyle(font: serifBold, fontSize: 12, color: themeColor),
      ),
      pw.Divider(color: PdfColors.blueGrey200, thickness: 1),
      pw.SizedBox(height: 4),
      pw.Text(
        _sanitizeText(cv.profileSummary),
        style: pw.TextStyle(
          font: serifRegular,
          fontSize: 10,
          lineSpacing: 1.6,
          color: PdfColors.grey900,
        ),
      ),
      pw.SizedBox(height: 20),

      pw.Text(
        'PROFESSIONAL EXPERIENCE',
        style: pw.TextStyle(font: serifBold, fontSize: 12, color: themeColor),
      ),
      pw.Divider(color: PdfColors.blueGrey200, thickness: 1),
      pw.SizedBox(height: 4),
      ...cv.roles.map((role) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    role.company,
                    style: pw.TextStyle(font: serifBold, fontSize: 11),
                  ),
                  pw.Text(
                    role.location,
                    style: pw.TextStyle(font: serifRegular, fontSize: 10),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    role.jobTitle,
                    style: pw.TextStyle(
                      font: serifRegular,
                      fontSize: 11,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                  pw.Text(
                    '${role.startDate} - ${role.endDate}',
                    style: pw.TextStyle(font: serifRegular, fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              ...role.bulletPoints.map(
                (bp) => pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '    •  ',
                      style: pw.TextStyle(font: serifRegular, fontSize: 10),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        _sanitizeText(bp),
                        style: pw.TextStyle(
                          font: serifRegular,
                          fontSize: 10,
                          lineSpacing: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),

      pw.Text(
        'CORE COMPETENCIES',
        style: pw.TextStyle(font: serifBold, fontSize: 12, color: themeColor),
      ),
      pw.Divider(color: PdfColors.blueGrey200, thickness: 1),
      pw.SizedBox(height: 4),
      pw.Text(
        [
          ...cv.skillsCategorized.technical,
          ...cv.skillsCategorized.softSkills,
        ].join('  |  '),
        style: pw.TextStyle(font: serifRegular, fontSize: 10, lineSpacing: 1.5),
      ),
    ];
  }

  Future<void> printOrSharePdf(CVModel cv, TemplateStyle style) async {
    final bytes = await generateCVPdf(cv, style);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }
}
