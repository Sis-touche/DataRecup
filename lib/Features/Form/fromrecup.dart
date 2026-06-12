import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart'; // Requis pour l'emplacement Excel
import 'package:excel/excel.dart' hide Border;             // Requis pour la structure Excel
import '../../Dadabase/database_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Couleurs et design tokens (Aesthetics: Modern & Clean)
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  static const cyan = Color(0xFF00BCD4);
  static const cyanLight = Color(0xFFE0F7FA);
  static const cyanDark = Color(0xFF0097A7);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5E7EB);
  static const sectionBg = Color(0xFFF8FAFB);
  static const white = Colors.white;
}

// ─────────────────────────────────────────────────────────────────────────────
//  ÉCRAN PRINCIPAL DU FORMULAIRE
// ─────────────────────────────────────────────────────────────────────────────
class SurveyFormScreen extends StatefulWidget {
  const SurveyFormScreen({super.key});

  @override
  State<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends State<SurveyFormScreen> with TickerProviderStateMixin {
  int _currentStep = 1;
  final int _totalSteps = 6;

  late AnimationController _progressController;
  late AnimationController _pageController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isSaving = false;

  // Base du numéro de fiche (généré une seule fois au démarrage)
  late final String _baseFicheNo;

  // Données du formulaire – valeurs par défaut améliorées
  final Map<String, dynamic> _surveyData = {
    "date_remplissage": DateTime.now().toIso8601String(),
    "fiche_no": "", // Sera fusionné définitivement après le popup
    "age": null,
    "sexe": null,
    "matrimonial": null,
    "niveau_etude": null,
    "lieu_residence": null,
    "religion": null,
    "sources_revenu": <String>[],
    "vih_entendu": null,
    "transmission": <String, String?>{
      "Rapports sexuels non protégés": null,
      "Piqûres de moustiques": null,
      "Contact avec de la salive": null,
      "Transmission Mère-Enfant": null,
      "Échange de seringues usagées": null,
    },
    "prevention": <String>[],
    "perception_vih": null,
    "pratiques": <String, dynamic>{
      "rapports_sexuels": null,
      "preservatif": null,
      "depistage": null,
    },
    "attitudes": <String, String?>{
      "Q13": null,
      "Q14": null,
      "Q15": null,
      "Q16": null,
      "Q17": null,
      "Q18": null,
    },
    "statut_final": null,
  };

  bool get _isLastStep => _currentStep >= _totalSteps - 1;

  @override
  void initState() {
    super.initState();
    _baseFicheNo = "F-${DateTime.now().millisecondsSinceEpoch}";

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 1 / _totalSteps,
      end: 1 / _totalSteps,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeOut));
    _pageController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showIdentityPopup();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────────
  //  POPUP D'IDENTITÉ INITIALE (FUSION IDENTIFIANT)
  // ───────────────────────────────────────────────────────────────────────────
  void _showIdentityPopup() {
    final TextEditingController identityController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            final isInputValid = identityController.text.trim().isNotEmpty;

            return Dialog(
              backgroundColor: AppColors.white,
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cyanLight.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.cyanDark, size: 32),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Identité de l'Enquêteur",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Veuillez saisir votre nom, prénom ou trigramme pour l'associer à cette fiche.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Votre identification",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: identityController,
                        autofocus: true,
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                        textCapitalization: TextCapitalization.words,
                        onChanged: (value) {
                          setPopupState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: "Ex: ezra",
                          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          filled: true,
                          fillColor: AppColors.sectionBg,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isInputValid
                            ? () {
                          final String nameInput = identityController.text.trim().toLowerCase();
                          setState(() {
                            _surveyData["fiche_no"] = "$_baseFicheNo-$nameInput";
                          });
                          Navigator.pop(context);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            identityController.dispose();
                          });
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cyan,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: AppColors.border,
                          disabledForegroundColor: AppColors.textHint,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text("Créer et commencer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _animateToStep(int newStep) {
    _pageController.reset();
    final double target = newStep / _totalSteps;
    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: target,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));
    _progressController.forward(from: 0);
    setState(() => _currentStep = newStep);
    _pageController.forward();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      _animateToStep(_currentStep + 1);
    } else {
      _finaliserEnquete();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) _animateToStep(_currentStep - 1);
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1: return "Informations Générales";
      case 2: return "Identité du Répondant";
      case 3: return "Connaissances sur le VIH";
      case 4: return "Pratiques et Comportements";
      case 5: return "Attitudes de la Population";
      case 6: return "Statut Final";
      default: return "Enquête";
    }
  }

  Map<String, dynamic> _buildDBRecord() {
    final transmission = Map<String, String?>.from(_surveyData["transmission"] ?? {});
    final prevention = List<String>.from(_surveyData["prevention"] ?? []);
    final sources = List<String>.from(_surveyData["sources_revenu"] ?? []);
    final pratiques = Map<String, dynamic>.from(_surveyData["pratiques"] ?? {});
    final attitudes = Map<String, String?>.from(_surveyData["attitudes"] ?? {});

    String? t(String key) => transmission[key];
    bool p(String label) => prevention.contains(label);

    return {
      DBConstantes.colDateSaisie: _surveyData["date_remplissage"],
      DBConstantes.colFicheNumero: _surveyData["fiche_no"],
      DBConstantes.colAgeTranche: _surveyData["age"],
      DBConstantes.colSexe: _surveyData["sexe"],
      DBConstantes.colStatutMatrimonial: _surveyData["matrimonial"],
      DBConstantes.colNiveauEtude: _surveyData["niveau_etude"],
      DBConstantes.colResidence: _surveyData["lieu_residence"],
      DBConstantes.colReligion: _surveyData["religion"],
      DBConstantes.colSourceRevenu: sources.join(","),
      DBConstantes.colEntenduParlerVih: _surveyData["vih_entendu"],
      DBConstantes.colTransRapportsSexuels: t("Rapports sexuels non protégés"),
      DBConstantes.colTransMoustiques: t("Piqûres de moustiques"),
      DBConstantes.colTransSalive: t("Contact avec de la salive"),
      DBConstantes.colTransMereEnfant: t("Transmission Mère-Enfant"),
      DBConstantes.colTransVoieSanguine: t("Échange de seringues usagées"),
      DBConstantes.colPrevAbstinence: p("L'abstinence sexuelle") ? 1 : 0,
      DBConstantes.colPrevFideliteDepistage: p("Être fidèle à un seul partenaire") ? 1 : 0,
      DBConstantes.colPrevPreservatif: p("Utiliser correctement le préservatif") ? 1 : 0,
      DBConstantes.colPrevSpermicides: 0,
      DBConstantes.colPrevPilule: 0,
      DBConstantes.colPersonneSainePorteuse: _surveyData["perception_vih"],
      DBConstantes.colDejaRapportSexuel: pratiques["rapports_sexuels"],
      DBConstantes.colUtilisationPreservatif: pratiques["preservatif"],
      DBConstantes.colDepistage3Mois: pratiques["depistage"],
      DBConstantes.colAgePremierRapport: null,
      DBConstantes.colNombrePartenaires12Mois: null,
      DBConstantes.colObstacleAucun: 0,
      DBConstantes.colObstacleSensation: 0,
      DBConstantes.colObstacleCher: 0,
      DBConstantes.colObstacleHonte: 0,
      DBConstantes.colObstacleAutrePrecision: null,
      DBConstantes.colTatouagePiercing12Mois: null,
      DBConstantes.colConnaitStatutPartenaire: null,
      DBConstantes.colPretTestDepistage: attitudes["Q13"],
      DBConstantes.colPartagerToilettes: attitudes["Q14"],
      DBConstantes.colAmiAvecPvvih: attitudes["Q15"],
      DBConstantes.colTravaillerEtudierPvvih: attitudes["Q16"],
      DBConstantes.colRejetaParSociete: attitudes["Q17"],
      DBConstantes.colDepistageImportant: attitudes["Q18"],
      DBConstantes.colStatutSerologique: _surveyData["statut_final"],
    };
  }

  Future<void> _finaliserEnquete() async {
    setState(() => _isSaving = true);
    try {
      final record = _buildDBRecord();
      final int newId = await DatabaseHelper.instance.insererFiche(record);
      debugPrint("✅ Fiche enregistrée ID: $newId");
      if (!mounted) return;
      _showSuccessDialog(newId);
    } catch (e) {
      debugPrint("❌ Erreur: $e");
      if (!mounted) return;
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessDialog(int id) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.check_circle, color: AppColors.cyan, size: 28),
          SizedBox(width: 10),
          Text("Enquête terminée"),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Toutes les données ont été sauvegardées avec succès."),
            const SizedBox(height: 12),
            Text("Fiche N° $id", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.cyanDark)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SurveyFormScreen()),
              );
            },
            child: const Text("OK", style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.error_outline, color: Colors.red, size: 28),
          SizedBox(width: 10),
          Text("Erreur"),
        ]),
        content: Text("Impossible d'enregistrer la fiche.\n\nDétails: $message"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCustomSuccessDialog({required String titre, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.check_circle, color: AppColors.cyan, size: 28),
          const SizedBox(width: 10),
          Text(titre),
        ]),
        content: Text(message, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Génial", style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _exporterFichesVersExcel() async {
    setState(() => _isSaving = true);
    try {
      final List<Map<String, dynamic>> fiches = await DatabaseHelper.instance.obtenirToutesLesFiches();

      if (fiches.isEmpty) {
        if (!mounted) return;
        _showErrorDialog("Aucune fiche enregistrée à exporter.");
        return;
      }

      // 1. Construction du fichier Excel en mémoire
      var excel = Excel.createExcel();
      Sheet feuille = excel['Enquetes_VIH'];
      excel.delete('Sheet1');

      List<String> entetes = [
        "Numéro Fiche", "Date Saisie", "Tranche d'âge", "Sexe",
        "Statut Matrimonial", "Niveau d'étude", "Résidence", "Statut Final"
      ];
      feuille.appendRow(entetes.map((e) => TextCellValue(e)).toList());

      for (var fiche in fiches) {
        feuille.appendRow([
          TextCellValue(fiche[DBConstantes.colFicheNumero]?.toString() ?? ''),
          TextCellValue(fiche[DBConstantes.colDateSaisie]?.toString() ?? ''),
          TextCellValue(fiche[DBConstantes.colAgeTranche]?.toString() ?? ''),
          TextCellValue(fiche[DBConstantes.colSexe]?.toString() ?? ''),
          TextCellValue(fiche[DBConstantes.colStatutMatrimonial]?.toString() ?? ''),
          TextCellValue(fiche[DBConstantes.colNiveauEtude]?.toString() ?? ''),
          TextCellValue(fiche[DBConstantes.colResidence]?.toString() ?? ''),
          TextCellValue(fiche[DBConstantes.colStatutSerologique]?.toString() ?? ''),
        ]);
      }

      // 2. Encodage au format binaire (Bytes)
      final List<int>? bytesExcel = excel.encode(); // Utilisation de .encode() au lieu de .save() 
      if (bytesExcel == null) {
        _showErrorDialog("Échec de l'encodage du fichier Excel.");
        return;
      }

      final String dateStr = DateTime.now().toIso8601String().split('T')[0].replaceAll('-', '');
      final String nomFichierDefaut = "export_enquetes_$dateStr.xlsx";

      // 3. Appel de la boîte de dialogue en fournissant DIRECTEMENT les bytes
      String? pathSelectionne = await FilePicker.platform.saveFile(
        dialogTitle: 'Choisir l\'emplacement du fichier Excel',
        fileName: nomFichierDefaut,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        bytes: Uint8List.fromList(bytesExcel), // Injection cruciale des octets pour Android/iOS 
      );

      if (pathSelectionne == null) {
        if (mounted) setState(() => _isSaving = false);
        return; // L'utilisateur a annulé
      }

      if (!pathSelectionne.endsWith('.xlsx')) {
        pathSelectionne = '$pathSelectionne.xlsx';
      }

      // 4. Écriture finale de sécurité sur le stockage physique
      final File fichierPhysique = File(pathSelectionne);
      if (!await fichierPhysique.exists() || (await fichierPhysique.length()) == 0) {
        await fichierPhysique.writeAsBytes(bytesExcel);
      }

      if (!mounted) return;
      _showCustomSuccessDialog(
          titre: "Exportation réussie",
          message: "Le fichier Excel a été enregistré sous :\n${fichierPhysique.path}"
      );

    } catch (e) {
      debugPrint("❌ Erreur lors de l'exportation: $e");
      if (!mounted) return;
      _showErrorDialog("Échec de l'exportation.\nDétails: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    final double hPad = screenW > 600 ? screenW * 0.1 : 20.0;
    final double keyboardInsets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(hPad),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(hPad, 16, hPad, keyboardInsets + 16),
                    child: _buildCurrentStepContent(),
                  ),
                ),
              ),
            ),
            _buildBottomNav(hPad),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double hPad) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(hPad - 8, 8, hPad - 8, 0),
          child: Row(
            children: [
              if (_currentStep > 1)
                _IconBtn(icon: Icons.arrow_back_ios_new, onTap: _prevStep)
              else
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.cyanLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flash_on, color: AppColors.cyan, size: 20),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStepTitle(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                    ),
                    Text(
                      "Étape $_currentStep/$_totalSteps",
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Menu Options relié à l'exportation Excel
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
                onSelected: (value) {
                  if (value == 'export') _exporterFichesVersExcel();
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.ios_share, color: AppColors.cyan, size: 18),
                        SizedBox(width: 8),
                        Text('Exporter vers Excel', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (_, __) => LinearProgressIndicator(
            value: _progressAnimation.value,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
            minHeight: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(double hPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep == 1)
            TextButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text(
                'Retour',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            )
          else
            TextButton(
              onPressed: _prevStep,
              child: const Text(
                'Précédent',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
          const Spacer(),
          if (_isSaving)
            const CircularProgressIndicator(color: AppColors.cyan)
          else
            _CyanBtn(
              text: _isLastStep ? 'Finaliser' : 'Suivant',
              onTap: _nextStep,
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1: return _stepInformationsGenerales();
      case 2: return _stepIdentite();
      case 3: return _stepConnaissancesVIH();
      case 4: return _stepPratiquesComportements();
      case 5: return _stepAttitudesPopulation();
      case 6: return _stepStatutFinal();
      default: return const SizedBox.shrink();
    }
  }

  Widget _stepInformationsGenerales() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Paramètres de la fiche"),
        const SizedBox(height: 12),
        _buildReadOnlyField("Date de remplissage", _surveyData["date_remplissage"]),
        const SizedBox(height: 12),
        _buildReadOnlyField("Numéro de fiche unique", _surveyData["fiche_no"]),
      ],
    );
  }

  Widget _stepIdentite() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Profil sociodémographique"),
        const SizedBox(height: 16),
        _RadioList(
          title: "1. Tranche d'âge",
          options: const ["15-19 ans", "20-24 ans", "25-49 ans"],
          selectedValue: _surveyData["age"],
          onChanged: (val) => setState(() => _surveyData["age"] = val),
        ),
        _RadioList(
          title: "2. Sexe",
          options: const ["Masculin", "Féminin"],
          selectedValue: _surveyData["sexe"],
          onChanged: (val) => setState(() => _surveyData["sexe"] = val),
        ),
        _RadioList(
          title: "3. Statut matrimonial",
          options: const ["Célibataire", "Marié(e) / En couple", "Divorcé(e) / Veuf(ve)"],
          selectedValue: _surveyData["matrimonial"],
          onChanged: (val) => setState(() => _surveyData["matrimonial"] = val),
        ),
        _RadioList(
          title: "4. Niveau d'étude le plus élevé atteint",
          options: const ["Aucun niveau", "Primaire", "Secondaire", "Supérieur"],
          selectedValue: _surveyData["niveau_etude"],
          onChanged: (val) => setState(() => _surveyData["niveau_etude"] = val),
        ),
        _RadioList(
          title: "5. Lieu de résidence habituel",
          options: const ["Urbain", "Rural"],
          selectedValue: _surveyData["lieu_residence"],
          onChanged: (val) => setState(() => _surveyData["lieu_residence"] = val),
        ),
        _RadioList(
          title: "6. Religion",
          options: const ["Chrétienne", "Musulmane", "Traditionnelle", "Sans religion / Autre"],
          selectedValue: _surveyData["religion"],
          onChanged: (val) => setState(() => _surveyData["religion"] = val),
        ),
        _CheckList(
          title: "7. Quelles sont vos principales sources de revenu ? (Plusieurs choix)",
          options: const ["Agriculture / Élevage", "Commerce", "Emploi salarié", "Aide familiale / Allocations", "Pas de revenu"],
          selectedValues: List<String>.from(_surveyData["sources_revenu"]),
          onChanged: (updatedList) => setState(() => _surveyData["sources_revenu"] = updatedList),
        ),
      ],
    );
  }

  Widget _stepConnaissancesVIH() {
    final transmission = _surveyData["transmission"] as Map<String, String?>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Évaluation des connaissances"),
        const SizedBox(height: 16),
        _RadioList(
          title: "8. Avez-vous déjà entendu parler du VIH / Sida ?",
          options: const ["Oui", "Non"],
          selectedValue: _surveyData["vih_entendu"],
          onChanged: (val) => setState(() => _surveyData["vih_entendu"] = val),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text("9. Selon vous, le VIH peut-il se transmettre par :", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ),
        ...transmission.keys.map((key) {
          return _RadioList(
            title: "• $key",
            options: const ["Oui", "Non", "Ne sait pas"],
            selectedValue: transmission[key],
            onChanged: (val) => setState(() => transmission[key] = val),
          );
        }),
        _CheckList(
          title: "10. Comment peut-on se protéger du VIH ? (Plusieurs choix)",
          options: const ["L'abstinence sexuelle", "Être fidèle à un seul partenaire", "Utiliser correctement le préservatif", "Prendre des vitamines"],
          selectedValues: List<String>.from(_surveyData["prevention"]),
          onChanged: (updatedList) => setState(() => _surveyData["prevention"] = updatedList),
        ),
        _RadioList(
          title: "11. Une personne d'apparence saine peut-elle être porteuse du VIH ?",
          options: const ["Oui", "Non", "Ne sait pas"],
          selectedValue: _surveyData["perception_vih"],
          onChanged: (val) => setState(() => _surveyData["perception_vih"] = val),
        ),
      ],
    );
  }

  Widget _stepPratiquesComportements() {
    final pratiques = _surveyData["pratiques"] as Map<String, dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Comportements à risque et prévention"),
        const SizedBox(height: 16),
        _RadioList(
          title: "12. Avez-vous déjà eu des rapports sexuels ?",
          options: const ["Oui", "Non"],
          selectedValue: pratiques["rapports_sexuels"],
          onChanged: (val) => setState(() => pratiques["rapports_sexuels"] = val),
        ),
        _RadioList(
          title: "13. À quelle fréquence utilisez-vous le préservatif ?",
          options: const ["Toujours", "Parfois", "Jamais"],
          selectedValue: pratiques["preservatif"],
          onChanged: (val) => setState(() => pratiques["preservatif"] = val),
        ),
        _RadioList(
          title: "14. Avez-vous fait un test de dépistage du VIH au cours des 3 derniers mois ?",
          options: const ["Oui", "Non"],
          selectedValue: pratiques["depistage"],
          onChanged: (val) => setState(() => pratiques["depistage"] = val),
        ),
      ],
    );
  }

  Widget _stepAttitudesPopulation() {
    final attitudes = _surveyData["attitudes"] as Map<String, String?>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Stigmatisation et discrimination"),
        const SizedBox(height: 16),
        _AttitudeCard(
          questionCode: "Q13",
          label: "Êtes-vous prêt(e) à faire un test de dépistage ?",
          selectedValue: attitudes["Q13"],
          onChanged: (val) => setState(() => attitudes["Q13"] = val),
        ),
        _AttitudeCard(
          questionCode: "Q14",
          label: "Accepteriez-vous de partager les toilettes avec une PVVIH ?",
          selectedValue: attitudes["Q14"],
          onChanged: (val) => setState(() => attitudes["Q14"] = val),
        ),
        _AttitudeCard(
          questionCode: "Q15",
          label: "Resteriez-vous ami(e) avec quelqu'un si vous appreniez qu'il/elle est séropositif(ve) ?",
          selectedValue: attitudes["Q15"],
          onChanged: (val) => setState(() => attitudes["Q15"] = val),
        ),
        _AttitudeCard(
          questionCode: "Q16",
          label: "Pensez-vous qu'une PVVIH devrait avoir le droit de travailler ou d'étudier avec les autres ?",
          selectedValue: attitudes["Q16"],
          onChanged: (val) => setState(() => attitudes["Q16"] = val),
        ),
        _AttitudeCard(
          questionCode: "Q17",
          label: "Pensez-vous qu'une PVVIH est généralement rejetée par votre société ?",
          selectedValue: attitudes["Q17"],
          onChanged: (val) => setState(() => attitudes["Q17"] = val),
        ),
        _AttitudeCard(
          questionCode: "Q18",
          label: "Selon vous, est-il important d'en parler ouvertement en famille ?",
          selectedValue: attitudes["Q18"],
          onChanged: (val) => setState(() => attitudes["Q18"] = val),
        ),
      ],
    );
  }

  Widget _stepStatutFinal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Clôture du dossier médical"),
        const SizedBox(height: 16),
        _RadioList(
          title: "15. Quel est le statut sérologique final déclaré / enregistré ?",
          options: const ["Séronégatif (Négatif)", "Séropositif (Positif)", "Indéterminé"],
          selectedValue: _surveyData["statut_final"],
          onChanged: (val) => setState(() => _surveyData["statut_final"] = val),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.cyanDark));
  }

  Widget _buildReadOnlyField(String label, String? value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sectionBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value ?? '—', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  WIDGETS COMPOSANTS INTERNES COMPLETS (SOUS-JACENTS)
// ─────────────────────────────────────────────────────────────────────────────
class _AttitudeCard extends StatelessWidget {
  final String questionCode;
  final String label;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const _AttitudeCard({
    required this.questionCode,
    required this.label,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.textPrimary.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.cyanLight, borderRadius: BorderRadius.circular(6)),
                child: Text(questionCode, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.cyanDark)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: ["Oui", "Non", "Ne sait pas"].map((option) {
              final isSelected = selectedValue == option;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => onChanged(option),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.cyan : AppColors.sectionBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppColors.cyan : AppColors.border),
                      ),
                      child: Text(
                        option,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.white : AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RadioList extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const _RadioList({required this.title, required this.options, required this.selectedValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
        ),
        ...options.map((opt) {
          final isSelected = selectedValue == opt;
          return GestureDetector(
            onTap: () => onChanged(opt),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.cyanLight.withOpacity(0.4) : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppColors.cyan : AppColors.border, width: isSelected ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? AppColors.cyan : AppColors.textHint, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(opt, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _CheckList extends StatelessWidget {
  final String title;
  final List<String> options;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;

  const _CheckList({required this.title, required this.options, required this.selectedValues, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
        ),
        ...options.map((opt) {
          final isSelected = selectedValues.contains(opt);
          return GestureDetector(
            onTap: () {
              final updated = List<String>.from(selectedValues);
              isSelected ? updated.remove(opt) : updated.add(opt);
              onChanged(updated);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.cyanLight.withOpacity(0.4) : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppColors.cyan : AppColors.border, width: isSelected ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, color: isSelected ? AppColors.cyan : AppColors.textHint, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(opt, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}

class _CyanBtn extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _CyanBtn({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cyan,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}