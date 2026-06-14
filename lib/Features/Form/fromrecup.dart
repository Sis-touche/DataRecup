import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:uuid/uuid.dart';
import '../../Dadabase/database_helper.dart';

// ────────────────────────────────────────────────────────────────────
//  Couleurs et design tokens
// ────────────────────────────────────────────────────────────────────
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

// ────────────────────────────────────────────────────────────────────
//  ÉCRAN PRINCIPAL DU FORMULAIRE AVEC LAYOUT COLONNES
// ────────────────────────────────────────────────────────────────────
class SurveyFormScreen extends StatefulWidget {
  const SurveyFormScreen({super.key});

  @override
  State<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends State<SurveyFormScreen> with TickerProviderStateMixin {
  bool _isSaving = false;

  final Map<String, dynamic> _surveyData = {
    "date_remplissage": DateTime.now().toIso8601String(),
    "fiche_no": "",
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
      "Voie sanguine (transfusion)": null,
      "Contact avec de la salive": null,
      "Transmission Mère-Enfant": null,
      "Échange de seringues usagées": null,
    },
    "prevention": <String>[],
    "perception_vih": null,
    "age_premier_rapport": null,
    "nombre_partenaires": null,
    "pratiques": <String, dynamic>{
      "rapports_sexuels": null,
      "preservatif": null,
      "obstacles_preservatif": <String>[],
      "tatouage_piercing": null,
      "depistage": null,
      "connaît_statut_partenaire": null,
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

  @override
  void initState() {
    super.initState();
    final String uuidUnique = const Uuid().v4();
    _surveyData["fiche_no"] = "F-$uuidUnique";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showIdentityPopup();
    });
  }

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
                          setState(() {
                            _surveyData["fiche_no"] = "${_surveyData["fiche_no"]}-${identityController.text.trim().toLowerCase()}";
                          });
                          Navigator.pop(context);
                          identityController.dispose();
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

  Map<String, dynamic> _buildDBRecord() {
    final transmission = Map<String, String?>.from(_surveyData["transmission"] ?? {});
    final prevention = List<String>.from(_surveyData["prevention"] ?? []);
    final sources = List<String>.from(_surveyData["sources_revenu"] ?? []);
    final pratiques = Map<String, dynamic>.from(_surveyData["pratiques"] ?? {});
    final obstacles = List<String>.from(pratiques["obstacles_preservatif"] ?? []);
    final attitudes = Map<String, String?>.from(_surveyData["attitudes"] ?? {});

    String? t(String key) => transmission[key];
    bool p(String label) => prevention.contains(label);
    bool o(String label) => obstacles.contains(label);

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
      DBConstantes.colPrevSpermicides: p("L'utilisation de spermicides") ? 1 : 0,
      DBConstantes.colPrevPilule: p("La pilule contraceptive") ? 1 : 0,
      DBConstantes.colPersonneSainePorteuse: _surveyData["perception_vih"],
      DBConstantes.colDejaRapportSexuel: pratiques["rapports_sexuels"],
      DBConstantes.colAgePremierRapport: _surveyData["age_premier_rapport"],
      DBConstantes.colNombrePartenaires12Mois: _surveyData["nombre_partenaires"],
      DBConstantes.colUtilisationPreservatif: pratiques["preservatif"],
      DBConstantes.colObstacleAucun: o("Aucun") ? 1 : 0,
      DBConstantes.colObstacleSensation: o("Diminue la sensation") ? 1 : 0,
      DBConstantes.colObstacleCher: o("Coûte cher") ? 1 : 0,
      DBConstantes.colObstacleHonte: o("Honte à l'achat") ? 1 : 0,
      DBConstantes.colObstacleAutrePrecision: null,
      DBConstantes.colTatouagePiercing12Mois: pratiques["tatouage_piercing"],
      DBConstantes.colDepistage3Mois: pratiques["depistage"],
      DBConstantes.colConnaitStatutPartenaire: pratiques["connaît_statut_partenaire"],
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

      final List<int>? bytesExcel = excel.encode();
      if (bytesExcel == null) {
        _showErrorDialog("Échec de l'encodage du fichier Excel.");
        return;
      }

      final String dateStr = DateTime.now().toIso8601String().split('T')[0].replaceAll('-', '');
      final String nomFichierDefaut = "export_enquetes_$dateStr.xlsx";

      String? pathSelectionne = await FilePicker.platform.saveFile(
        dialogTitle: 'Choisir l\'emplacement du fichier Excel',
        fileName: nomFichierDefaut,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        bytes: Uint8List.fromList(bytesExcel),
      );

      if (pathSelectionne == null) {
        if (mounted) setState(() => _isSaving = false);
        return;
      }

      if (!pathSelectionne.endsWith('.xlsx')) {
        pathSelectionne = '$pathSelectionne.xlsx';
      }

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;
    final columnCount = isLargeScreen ? 3 : (screenWidth > 600 ? 2 : 1);
    final hPad = screenWidth > 600 ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(hPad),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
                child: _buildFormContent(columnCount),
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
                    const Text(
                      "Enquête VIH-SIDA",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                    ),
                    Text(
                      _surveyData["fiche_no"] ?? "",
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad - 8),
          child: const LinearProgressIndicator(
            value: 0.5,
            backgroundColor: Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyan),
            minHeight: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent(int columnCount) {
    return Column(
      children: [
        _buildFormSection(columnCount),
      ],
    );
  }

  Widget _buildFormSection(int columnCount) {
    final transmission = _surveyData["transmission"] as Map<String, String?>;
    final pratiques = _surveyData["pratiques"] as Map<String, dynamic>;
    final attitudes = _surveyData["attitudes"] as Map<String, String?>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ═══════════════════════════════════════════════════════════
        //  SECTION 1 : INFORMATIONS GÉNÉRALES
        // ═══════════════════════════════════════════════════════════
        _buildSectionTitle("📋 Informations Générales"),
        const SizedBox(height: 12),
        _buildReadOnlyFields(),
        const SizedBox(height: 24),

        // ═══════════════════════════════════════════════════════════
        //  SECTION 2 : PROFIL SOCIODÉMOGRAPHIQUE
        // ═══════════════════════════════════════════════════════════
        _buildSectionTitle("👤 Profil Sociodémographique"),
        const SizedBox(height: 12),
        _buildGridFields(
          columnCount: columnCount,
          fields: [
            _buildFieldWidget(
              "Tranche d'âge",
              _RadioList(
                title: "",
                options: const ["15-19 ans", "20-24 ans", "25-49 ans"],
                selectedValue: _surveyData["age"],
                onChanged: (val) => setState(() => _surveyData["age"] = val),
              ),
            ),
            _buildFieldWidget(
              "Sexe",
              _RadioList(
                title: "",
                options: const ["Masculin", "Féminin"],
                selectedValue: _surveyData["sexe"],
                onChanged: (val) => setState(() => _surveyData["sexe"] = val),
              ),
            ),
            _buildFieldWidget(
              "Statut matrimonial",
              _RadioList(
                title: "",
                options: const ["Célibataire", "Marié(e) / En couple", "Divorcé(e) / Veuf(ve)"],
                selectedValue: _surveyData["matrimonial"],
                onChanged: (val) => setState(() => _surveyData["matrimonial"] = val),
              ),
            ),
            _buildFieldWidget(
              "Niveau d'étude",
              _RadioList(
                title: "",
                options: const ["Aucun niveau", "Primaire", "Secondaire", "Supérieur"],
                selectedValue: _surveyData["niveau_etude"],
                onChanged: (val) => setState(() => _surveyData["niveau_etude"] = val),
              ),
            ),
            _buildFieldWidget(
              "Lieu de résidence",
              _RadioList(
                title: "",
                options: const ["Urbain", "Rural"],
                selectedValue: _surveyData["lieu_residence"],
                onChanged: (val) => setState(() => _surveyData["lieu_residence"] = val),
              ),
            ),
            _buildFieldWidget(
              "Religion",
              _RadioList(
                title: "",
                options: const ["Chrétienne", "Musulmane", "Traditionnelle", "Sans religion"],
                selectedValue: _surveyData["religion"],
                onChanged: (val) => setState(() => _surveyData["religion"] = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCheckListField(
          "Sources de revenu (sélectionner plusieurs)",
          const ["Agriculture / Élevage", "Commerce", "Emploi salarié", "Aide familiale", "Pas de revenu"],
          List<String>.from(_surveyData["sources_revenu"]),
          (updatedList) => setState(() => _surveyData["sources_revenu"] = updatedList),
        ),
        const SizedBox(height: 24),

        // ═══════════════════════════════════════════════════════════
        //  SECTION 3 : CONNAISSANCES SUR LE VIH
        // ═══════════════════════════════════════════════════════════
        _buildSectionTitle("🧠 Connaissances sur le VIH-SIDA"),
        const SizedBox(height: 12),
        _buildFieldWidget(
          "Avez-vous déjà entendu parler du VIH/SIDA ?",
          _RadioList(
            title: "",
            options: const ["Oui", "Non"],
            selectedValue: _surveyData["vih_entendu"],
            onChanged: (val) => setState(() => _surveyData["vih_entendu"] = val),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text("Le VIH peut-il se transmettre par :", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13)),
        ),
        _buildGridFields(
          columnCount: 2,
          fields: transmission.keys.map((key) {
            return _buildFieldWidget(
              key,
              _RadioList(
                title: "",
                options: const ["Oui", "Non", "Ne sait pas"],
                selectedValue: transmission[key],
                onChanged: (val) => setState(() => transmission[key] = val),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildCheckListField(
          "Comment se protéger du VIH ?",
          const ["L'abstinence sexuelle", "Être fidèle à un seul partenaire", "Utiliser correctement le préservatif", "La pilule contraceptive", "L'utilisation de spermicides"],
          List<String>.from(_surveyData["prevention"]),
          (updatedList) => setState(() => _surveyData["prevention"] = updatedList),
        ),
        const SizedBox(height: 16),
        _buildFieldWidget(
          "Une personne d'apparence saine peut-elle porter le VIH ?",
          _RadioList(
            title: "",
            options: const ["Oui", "Non", "Ne sait pas"],
            selectedValue: _surveyData["perception_vih"],
            onChanged: (val) => setState(() => _surveyData["perception_vih"] = val),
          ),
        ),
        const SizedBox(height: 24),

        // ═══════════════════════════════════════════════════════════
        //  SECTION 4 : PRATIQUES ET COMPORTEMENTS
        // ═══════════════════════════════════════════════════════════
        _buildSectionTitle("⚠️ Pratiques et Comportements"),
        const SizedBox(height: 12),
        _buildGridFields(
          columnCount: columnCount,
          fields: [
            _buildFieldWidget(
              "Avez-vous eu des rapports sexuels ?",
              _RadioList(
                title: "",
                options: const ["Oui", "Non"],
                selectedValue: pratiques["rapports_sexuels"],
                onChanged: (val) => setState(() => pratiques["rapports_sexuels"] = val),
              ),
            ),
            if (pratiques["rapports_sexuels"] == "Oui")
              _buildFieldWidget(
                "Âge du premier rapport",
                _buildTextFieldInt(
                  value: _surveyData["age_premier_rapport"],
                  onChanged: (val) => setState(() => _surveyData["age_premier_rapport"] = val),
                ),
              ),
            if (pratiques["rapports_sexuels"] == "Oui")
              _buildFieldWidget(
                "Nombre de partenaires (12 mois)",
                _RadioList(
                  title: "",
                  options: const ["Aucun", "Un seul", "2 à 3", "Plus de 3"],
                  selectedValue: _surveyData["nombre_partenaires"],
                  onChanged: (val) => setState(() => _surveyData["nombre_partenaires"] = val),
                ),
              ),
            _buildFieldWidget(
              "Utilisation du préservatif",
              _RadioList(
                title: "",
                options: const ["Toujours", "Parfois", "Jamais"],
                selectedValue: pratiques["preservatif"],
                onChanged: (val) => setState(() => pratiques["preservatif"] = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCheckListField(
          "Obstacles à l'utilisation du préservatif",
          const ["Aucun", "Diminue la sensation", "Coûte cher", "Honte à l'achat"],
          List<String>.from(pratiques["obstacles_preservatif"]),
          (updatedList) => setState(() => pratiques["obstacles_preservatif"] = updatedList),
        ),
        const SizedBox(height: 16),
        _buildGridFields(
          columnCount: columnCount,
          fields: [
            _buildFieldWidget(
              "Tatouages/Piercings (12 mois)",
              _RadioList(
                title: "",
                options: const ["Oui", "Non"],
                selectedValue: pratiques["tatouage_piercing"],
                onChanged: (val) => setState(() => pratiques["tatouage_piercing"] = val),
              ),
            ),
            _buildFieldWidget(
              "Dépistage (3 derniers mois)",
              _RadioList(
                title: "",
                options: const ["Oui", "Non"],
                selectedValue: pratiques["depistage"],
                onChanged: (val) => setState(() => pratiques["depistage"] = val),
              ),
            ),
            _buildFieldWidget(
              "Connaissez-vous le statut du partenaire ?",
              _RadioList(
                title: "",
                options: const ["Oui", "Non"],
                selectedValue: pratiques["connaît_statut_partenaire"],
                onChanged: (val) => setState(() => pratiques["connaît_statut_partenaire"] = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ═══════════════════════════════════════════════════════════
        //  SECTION 5 : ATTITUDES ET STIGMATISATION
        // ═══════════════════════════════════════════════════════════
        _buildSectionTitle("💭 Attitudes et Stigmatisation"),
        const SizedBox(height: 12),
        _buildAttitudeCards(attitudes),
        const SizedBox(height: 24),

        // ═══════════════════════════════════════════════════════════
        //  SECTION 6 : STATUT SÉROLOGIQUE FINAL
        // ═══════════════════════════════════════════════════════════
        _buildSectionTitle("🔬 Statut Sérologique Final"),
        const SizedBox(height: 12),
        _buildFieldWidget(
          "Résultat du test",
          _RadioList(
            title: "",
            options: const ["Séronégatif", "Séropositif", "Indéterminé"],
            selectedValue: _surveyData["statut_final"],
            onChanged: (val) => setState(() => _surveyData["statut_final"] = val),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cyanDark),
    );
  }

  Widget _buildReadOnlyFields() {
    return Column(
      children: [
        _buildReadOnlyField("Date de remplissage", _surveyData["date_remplissage"]),
        const SizedBox(height: 12),
        _buildReadOnlyField("Numéro de fiche", _surveyData["fiche_no"]),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String? value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sectionBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value ?? '—', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildGridFields({required int columnCount, required List<Widget> fields}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          crossAxisCount: columnCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: fields,
        );
      },
    );
  }

  Widget _buildFieldWidget(String label, Widget child) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sectionBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildCheckListField(String title, List<String> options, List<String> selectedValues, Function(List<String>) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sectionBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          _CheckList(
            title: "",
            options: options,
            selectedValues: selectedValues,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldInt({required String? value, required Function(String) onChanged}) {
    return TextFormField(
      initialValue: value,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        hintText: "Ex: 16",
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildAttitudeCards(Map<String, String?> attitudes) {
    return Column(
      children: [
        _AttitudeCard(
          label: "Êtes-vous prêt(e) à faire un test de dépistage ?",
          selectedValue: attitudes["Q13"],
          onChanged: (val) => setState(() => attitudes["Q13"] = val),
        ),
        _AttitudeCard(
          label: "Accepteriez-vous de partager les toilettes avec une PVVIH ?",
          selectedValue: attitudes["Q14"],
          onChanged: (val) => setState(() => attitudes["Q14"] = val),
        ),
        _AttitudeCard(
          label: "Resteriez-vous ami(e) avec une personne séropositive ?",
          selectedValue: attitudes["Q15"],
          onChanged: (val) => setState(() => attitudes["Q15"] = val),
        ),
        _AttitudeCard(
          label: "Une PVVIH devrait-elle avoir le droit de travailler/étudier ?",
          selectedValue: attitudes["Q16"],
          onChanged: (val) => setState(() => attitudes["Q16"] = val),
        ),
        _AttitudeCard(
          label: "Une PVVIH est-elle généralement rejetée par la société ?",
          selectedValue: attitudes["Q17"],
          onChanged: (val) => setState(() => attitudes["Q17"] = val),
        ),
        _AttitudeCard(
          label: "Est-il important d'en parler ouvertement en famille ?",
          selectedValue: attitudes["Q18"],
          onChanged: (val) => setState(() => attitudes["Q18"] = val),
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
          TextButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          if (_isSaving)
            const CircularProgressIndicator(color: AppColors.cyan)
          else
            _CyanBtn(
              text: 'Finaliser',
              onTap: _finaliserEnquete,
            ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────
//  WIDGETS COMPOSANTS
// ────────────────────────────────────────────────────────────────────

class _AttitudeCard extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const _AttitudeCard({
    required this.label,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3)),
          const SizedBox(height: 10),
          Row(
            children: ["Oui", "Non", "Ne sait pas"].map((option) {
              final isSelected = selectedValue == option;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => onChanged(option),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.cyan : AppColors.sectionBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? AppColors.cyan : AppColors.border),
                      ),
                      child: Text(
                        option,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.white : AppColors.textSecondary),
                      ),
                    ),
                  ),
                );
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

  const _RadioList({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((option) {
        return GestureDetector(
          onTap: () => onChanged(option),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Radio<String>(
                  value: option,
                  groupValue: selectedValue,
                  onChanged: onChanged,
                  activeColor: AppColors.cyan,
                ),
                Expanded(
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CheckList extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;

  const _CheckList({
    required this.title,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
  });

  @override
  State<_CheckList> createState() => _CheckListState();
}

class _CheckListState extends State<_CheckList> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.options.map((option) {
        final isChecked = _selected.contains(option);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isChecked) {
                _selected.remove(option);
              } else {
                _selected.add(option);
              }
            });
            widget.onChanged(_selected);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (_) {
                    setState(() {
                      if (isChecked) {
                        _selected.remove(option);
                      } else {
                        _selected.add(option);
                      }
                    });
                    widget.onChanged(_selected);
                  },
                  activeColor: AppColors.cyan,
                ),
                Expanded(
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.cyanLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.cyan, size: 20),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}
