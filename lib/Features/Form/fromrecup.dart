import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:uuid/uuid.dart';
import '../../Dadabase/database_helper.dart';

// ────────────────────────────────────────────────────────────────────
//  Couleurs et design tokens adaptatifs
// ────────────────────────────────────────────────────────────────────
class AppColors {
  static const cyan = Color(0xFF00BCD4);
  static const cyanLight = Color(0xFFE0F7FA);
  static const cyanDark = Color(0xFF0097A7);
  
  // Couleurs de secours si le thème ne suffit pas
  static const textPrimaryLight = Color(0xFF111827);
  static const textSecondaryLight = Color(0xFF6B7280);
  
  // Remplacements pour les fonds de cartes adaptatifs
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.grey[900]! 
        : Colors.white;
  }
}

// ────────────────────────────────────────────────────────────────────
//  ÉCRAN PRINCIPAL DU FORMULAIRE
// ────────────────────────────────────────────────────────────────────
class SurveyFormScreen extends StatefulWidget {
  final int? ficheId;
  const SurveyFormScreen({super.key, this.ficheId});

  @override
  State<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends State<SurveyFormScreen> {
  bool get _isEditMode => widget.ficheId != null;
  bool _isLoading = true;
  bool _isSaving = false;

  final _sexeAutreController = TextEditingController();
  final _statutMatrimonialAutreController = TextEditingController();
  final _residenceAutreController = TextEditingController();
  final _religionAutreController = TextEditingController();
  final _sourceRevenuAutreController = TextEditingController();
  final _agePremierRapportController = TextEditingController();
  final _obstaclesAutreController = TextEditingController();

  final Map<String, dynamic> _surveyData = {
    "date_remplissage": DateTime.now().toIso8601String(),
    "fiche_no": "",
    "age": null,
    "sexe": null,
    "statut_matrimonial": null,
    "niveau_etude": null,
    "residence": null,
    "religion": null,
    "source_principale_revenu": null,
    "entendu_parler_vih": null,
    "transmission": {
      "Rapports sexuels non protégés": null,
      "Voie sanguine": null,
      "Piqûres de moustiques": null,
      "Salive": null,
      "De la mère à l’enfant": null,
    },
    "prevention": <String>[],
    "personne_saine_porteuse": null,
    "deja_rapport_sexuel": null,
    "age_premier_rapport": null,
    "nombre_partenaires_12_mois": null,
    "utilise_preservatif": null,
    "obstacles_preservatif": <String>[],
    "tatouage_scarification_piercing_12_mois": null,
    "depistage_3_mois": null,
    "connait_etat_serologique_partenaire": null,
    "pret_test_depistage": null,
    "partager_toilettes": null,
    "ami_avec_pvvih": null,
    "travailler_etudier_avec_pvvih": null,
    "rejetee_par_societe": null,
    "depistage_important": null,
    "statut_serologique": null,
  };

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadExistingData();
    } else {
      _surveyData["fiche_no"] = const Uuid().v4();
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _sexeAutreController.dispose();
    _statutMatrimonialAutreController.dispose();
    _residenceAutreController.dispose();
    _religionAutreController.dispose();
    _sourceRevenuAutreController.dispose();
    _agePremierRapportController.dispose();
    _obstaclesAutreController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    setState(() => _isLoading = true);
    final dbData = await DatabaseHelper.instance.obtenirFicheParId(widget.ficheId!);
    if (dbData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Fiche non trouvée."),
          backgroundColor: Colors.red,
        ));
        Navigator.pop(context);
      }
      return;
    }

    final uiData = _reverseMapData(dbData);
    _surveyData.addAll(uiData);
    
    _sexeAutreController.text = uiData['sexe_autre'] ?? '';
    _statutMatrimonialAutreController.text = uiData['statut_matrimonial_autre'] ?? '';
    _residenceAutreController.text = uiData['residence_autre'] ?? '';
    _religionAutreController.text = uiData['religion_autre'] ?? '';
    _sourceRevenuAutreController.text = uiData['source_principale_revenu_autre'] ?? '';
    _agePremierRapportController.text = uiData['age_premier_rapport']?.toString() ?? '';
    _obstaclesAutreController.text = uiData['obstacles_preservatif_autre'] ?? '';

    setState(() => _isLoading = false);
  }

  Map<String, dynamic> _reverseMapData(Map<String, dynamic> dbData) {
    final uiData = <String, dynamic>{};

    void extractValueAndOther(String uiKey, String uiOtherKey, List<String> standardOptions, String? dbValue) {
      if (dbValue == null || dbValue.isEmpty) {
        uiData[uiKey] = null;
        uiData[uiOtherKey] = '';
      } else if (standardOptions.contains(dbValue)) {
        uiData[uiKey] = dbValue;
        uiData[uiOtherKey] = '';
      } else {
        uiData[uiKey] = 'Autre';
        uiData[uiOtherKey] = dbValue;
      }
    }

    uiData['fiche_no'] = dbData[DBConstantes.colFicheNumero];
    uiData['date_remplissage'] = dbData[DBConstantes.colDateSaisie];
    uiData['age'] = dbData[DBConstantes.colAgeTranche];
    extractValueAndOther('sexe', 'sexe_autre', ['M', 'F'], dbData[DBConstantes.colSexe]);
    extractValueAndOther('statut_matrimonial', 'statut_matrimonial_autre', ['Célibataire', 'En couple', 'Marié(e)'], dbData[DBConstantes.colStatutMatrimonial]);
    uiData['niveau_etude'] = dbData[DBConstantes.colNiveauEtude];
    extractValueAndOther('residence', 'residence_autre', ['Campus universitaire', 'Famille', 'Location'], dbData[DBConstantes.colResidence]);
    extractValueAndOther('religion', 'religion_autre', ['Chrétienne', 'Musulmane', 'Traditionnelle', 'Sans religion'], dbData[DBConstantes.colReligion]);
    extractValueAndOther('source_principale_revenu', 'source_principale_revenu_autre', ['Parents / famille', 'Travail personnel', 'Bourse'], dbData[DBConstantes.colSourceRevenu]);

    uiData['entendu_parler_vih'] = dbData[DBConstantes.colEntenduParlerVih];
    uiData['transmission'] = {
      "Rapports sexuels non protégés": dbData[DBConstantes.colTransRapportsSexuels],
      "Voie sanguine": dbData[DBConstantes.colTransVoieSanguine],
      "Piqûres de moustiques": dbData[DBConstantes.colTransMoustiques],
      "Salive": dbData[DBConstantes.colTransSalive],
      "De la mère à l’enfant": dbData[DBConstantes.colTransMereEnfant],
    };

    final prevention = <String>[];
    if (dbData[DBConstantes.colPrevAbstinence] == 1) prevention.add("L’abstinence");
    if (dbData[DBConstantes.colPrevSpermicides] == 1) prevention.add("L’utilisation de spermicides");
    if (dbData[DBConstantes.colPrevFideliteDepistage] == 1) prevention.add("La fidélité et dépistage de couple");
    if (dbData[DBConstantes.colPrevPilule] == 1) prevention.add("La pilule contraceptive");
    if (dbData[DBConstantes.colPrevPreservatif] == 1) prevention.add("Le préservatif");
    uiData['prevention'] = prevention;
    uiData['personne_saine_porteuse'] = dbData[DBConstantes.colPersonneSainePorteuse];

    uiData['deja_rapport_sexuel'] = dbData[DBConstantes.colDejaRapportSexuel];
    uiData['age_premier_rapport'] = dbData[DBConstantes.colAgePremierRapport];
    uiData['nombre_partenaires_12_mois'] = dbData[DBConstantes.colNombrePartenaires12Mois];
    uiData['utilise_preservatif'] = dbData[DBConstantes.colUtilisationPreservatif];
    
    final obstacles = <String>[];
    if (dbData[DBConstantes.colObstacleAucun] == 1) obstacles.add("Aucun");
    if (dbData[DBConstantes.colObstacleSensation] == 1) obstacles.add("Diminue la sensation");
    if (dbData[DBConstantes.colObstacleCher] == 1) obstacles.add("Coûte cher");
    if (dbData[DBConstantes.colObstacleHonte] == 1) obstacles.add("Honte à l’achat");
    if (dbData[DBConstantes.colObstacleAutrePrecision] != null && (dbData[DBConstantes.colObstacleAutrePrecision] as String).isNotEmpty) {
      obstacles.add("Autres à préciser");
    }
    uiData['obstacles_preservatif'] = obstacles;
    uiData['obstacles_preservatif_autre'] = dbData[DBConstantes.colObstacleAutrePrecision] ?? "";
    
    uiData['tatouage_scarification_piercing_12_mois'] = dbData[DBConstantes.colTatouagePiercing12Mois];
    uiData['depistage_3_mois'] = dbData[DBConstantes.colDepistage3Mois];
    uiData['connait_etat_serologique_partenaire'] = dbData[DBConstantes.colConnaitStatutPartenaire];
    
    uiData['pret_test_depistage'] = dbData[DBConstantes.colPretTestDepistage];
    uiData['partager_toilettes'] = dbData[DBConstantes.colPartagerToilettes];
    uiData['ami_avec_pvvih'] = dbData[DBConstantes.colAmiAvecPvvih];
    uiData['travailler_etudier_avec_pvvih'] = dbData[DBConstantes.colTravaillerEtudierPvvih];
    uiData['rejetee_par_societe'] = dbData[DBConstantes.colRejetaParSociete];
    uiData['depistage_important'] = dbData[DBConstantes.colDepistageImportant];
    
    uiData['statut_serologique'] = dbData[DBConstantes.colStatutSerologique];

    return uiData;
  }
  
  Map<String, dynamic> _buildDBRecord() {
    String? getAutreValue(String? mainValue, TextEditingController autreController) {
      return mainValue == "Autre" ? autreController.text : mainValue;
    }

    final transmission = _surveyData["transmission"] as Map<String, dynamic>;
    final prevention = _surveyData["prevention"] as List<String>;
    final obstacles = _surveyData["obstacles_preservatif"] as List<String>;

    return {
      DBConstantes.colDateSaisie: _surveyData["date_remplissage"],
      DBConstantes.colFicheNumero: _surveyData["fiche_no"],
      DBConstantes.colAgeTranche: _surveyData["age"],
      DBConstantes.colSexe: getAutreValue(_surveyData["sexe"], _sexeAutreController),
      DBConstantes.colStatutMatrimonial: getAutreValue(_surveyData["statut_matrimonial"], _statutMatrimonialAutreController),
      DBConstantes.colNiveauEtude: _surveyData["niveau_etude"],
      DBConstantes.colResidence: getAutreValue(_surveyData["residence"], _residenceAutreController),
      DBConstantes.colReligion: getAutreValue(_surveyData["religion"], _religionAutreController),
      DBConstantes.colSourceRevenu: getAutreValue(_surveyData["source_principale_revenu"], _sourceRevenuAutreController),
      DBConstantes.colEntenduParlerVih: _surveyData["entendu_parler_vih"],
      DBConstantes.colTransRapportsSexuels: transmission["Rapports sexuels non protégés"],
      DBConstantes.colTransVoieSanguine: transmission["Voie sanguine"],
      DBConstantes.colTransMoustiques: transmission["Piqûres de moustiques"],
      DBConstantes.colTransSalive: transmission["Salive"],
      DBConstantes.colTransMereEnfant: transmission["De la mère à l’enfant"],
      DBConstantes.colPrevAbstinence: prevention.contains("L’abstinence") ? 1 : 0,
      DBConstantes.colPrevSpermicides: prevention.contains("L’utilisation de spermicides") ? 1 : 0,
      DBConstantes.colPrevFideliteDepistage: prevention.contains("La fidélité et dépistage de couple") ? 1 : 0,
      DBConstantes.colPrevPilule: prevention.contains("La pilule contraceptive") ? 1 : 0,
      DBConstantes.colPrevPreservatif: prevention.contains("Le préservatif") ? 1 : 0,
      DBConstantes.colPersonneSainePorteuse: _surveyData["personne_saine_porteuse"],
      DBConstantes.colDejaRapportSexuel: _surveyData["deja_rapport_sexuel"],
      DBConstantes.colAgePremierRapport: int.tryParse(_agePremierRapportController.text),
      DBConstantes.colNombrePartenaires12Mois: _surveyData["nombre_partenaires_12_mois"],
      DBConstantes.colUtilisationPreservatif: _surveyData["utilise_preservatif"],
      DBConstantes.colObstacleAucun: obstacles.contains("Aucun") ? 1 : 0,
      DBConstantes.colObstacleSensation: obstacles.contains("Diminue la sensation") ? 1 : 0,
      DBConstantes.colObstacleCher: obstacles.contains("Coûte cher") ? 1 : 0,
      DBConstantes.colObstacleHonte: obstacles.contains("Honte à l’achat") ? 1 : 0,
      DBConstantes.colObstacleAutrePrecision: obstacles.contains("Autres à préciser") ? _obstaclesAutreController.text : null,
      DBConstantes.colTatouagePiercing12Mois: _surveyData["tatouage_scarification_piercing_12_mois"],
      DBConstantes.colDepistage3Mois: _surveyData["depistage_3_mois"],
      DBConstantes.colConnaitStatutPartenaire: _surveyData["connait_etat_serologique_partenaire"],
      DBConstantes.colPretTestDepistage: _surveyData["pret_test_depistage"],
      DBConstantes.colPartagerToilettes: _surveyData["partager_toilettes"],
      DBConstantes.colAmiAvecPvvih: _surveyData["ami_avec_pvvih"],
      DBConstantes.colTravaillerEtudierPvvih: _surveyData["travailler_etudier_avec_pvvih"],
      DBConstantes.colRejetaParSociete: _surveyData["rejetee_par_societe"],
      DBConstantes.colDepistageImportant: _surveyData["depistage_important"],
      DBConstantes.colStatutSerologique: _surveyData["statut_serologique"],
    };
  }

  Future<void> _finaliserEnquete() async {
    setState(() => _isSaving = true);
    try {
      final record = _buildDBRecord();
      if (_isEditMode) {
        await DatabaseHelper.instance.modifierFiche(widget.ficheId!, record);
      } else {
        await DatabaseHelper.instance.insererFiche(record);
      }
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.toString());
    } finally { // <--- Corrigé ici (avec deux 'l')
      if (mounted) setState(() => _isSaving = false);
    }
  }
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.check_circle, color: AppColors.cyan, size: 28),
          const SizedBox(width: 10),
          Text(_isEditMode ? "Enquête Modifiée" : "Enquête Sauvegardée"),
        ]),
        content: Text(_isEditMode
            ? "La fiche N° ${_surveyData['fiche_no']} a été mise à jour avec succès."
            : "La fiche N° ${_surveyData['fiche_no']} a été enregistrée avec succès."),
        actions: [
          if (_isEditMode)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
              child: const Text("Retour au Détail", style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold)),
            )
          else ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/dashboard');
              },
              child: const Text("Retour au Dashboard", style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                 Navigator.pop(context);
                 Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SurveyFormScreen()),
                );
              },
              child: const Text("Nouvelle Fiche", style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold)),
            ),
          ]
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.error_outline, color: Colors.red, size: 28),
          const SizedBox(width: 10),
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

  @override
  Widget build(BuildContext context) {
    // Suppression du fond blanc forcé pour laisser le ThemeProvider gérer l'arrière-plan
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode ? "Modifier l'Enquête" : "Questionnaire", 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 4),
            Text(
              "Fiche N°: ${_surveyData['fiche_no']}", 
              style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _isEditMode ? Navigator.pop(context) : context.go('/dashboard'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.cyan))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildSectionTitle("I- Identité"),
                   _buildRadioGroup("1- Age", ["16-20 ans", "21-25 ans", "26-30 ans", "+30 ans"], "age"),
                   _buildRadioGroupWithOther("2- Sexe", ["M", "F"], "sexe", _sexeAutreController),
                   _buildRadioGroupWithOther("3- Statut matrimonial", ["Célibataire", "En couple", "Marié(e)"], "statut_matrimonial", _statutMatrimonialAutreController),
                   _buildRadioGroup("4- Niveau d’Etude", ["1ère cycle", "2ème cycle", "3ème cycle"], "niveau_etude"),
                   _buildRadioGroupWithOther("5- Résidence", ["Campus universitaire", "Famille", "Location"], "residence", _residenceAutreController),
                   _buildRadioGroupWithOther("6- Religion", ["Chrétienne", "Musulmane", "Traditionnelle", "Sans religion"], "religion", _religionAutreController),
                   _buildRadioGroupWithOther("7- Source principale de revenu", ["Parents / famille", "Travail personnel", "Bourse"], "source_principale_revenu", _sourceRevenuAutreController),

                   _buildSectionTitle("II- Connaissances"),
                   _buildRadioGroup("1- Avez-vous déjà entendu parler du VIH/SIDA", ["OUI", "NON"], "entendu_parler_vih"),
                   
                   const Padding(
                     padding: EdgeInsets.symmetric(vertical: 8.0),
                     child: Text("2- Selon vous, Le VIH se transmet par :", style: TextStyle(fontWeight: FontWeight.w500)),
                   ),
                   _buildTransmissionRadioGroup("Rapports sexuels non protégés"),
                   _buildTransmissionRadioGroup("Voie sanguine"),
                   _buildTransmissionRadioGroup("Piqûres de moustiques"),
                   _buildTransmissionRadioGroup("Salive"),
                   _buildTransmissionRadioGroup("De la mère à l’enfant"),

                   _buildCheckboxGroup("3- Quels sont les moyens de prévention du VIH", ["L’abstinence", "L’utilisation de spermicides", "La fidélité et dépistage de couple", "La pilule contraceptive", "Le préservatif"], "prevention"),
                   _buildRadioGroup("4- Une personne apparemment en bonne santé peut-elle être porteuse du VIH ?", ["Oui", "Non", "Ne sait pas"], "personne_saine_porteuse"),

                   _buildSectionTitle("III- Pratiques"),
                   _buildRadioGroup("5- Avez-vous déjà eu un rapport sexuel ?", ["Oui", "Non"], "deja_rapport_sexuel"),
                  if (_surveyData["deja_rapport_sexuel"] == "Oui")
                     _buildTextField("6- Si oui, âge du premier rapport sexuel", _agePremierRapportController, isNumeric: true),
                   _buildRadioGroup("7- Nombre de partenaires sexuels au cours des 12 derniers mois", ["Aucun", "Un seul", "2 à 3", "+ de 3"], "nombre_partenaires_12_mois"),
                   _buildRadioGroup("8- Utilisez-vous le préservatif ?", ["Toujours", "Parfois", "Jamais"], "utilise_preservatif"),
                   _buildCheckboxGroupWithOther("9- Selon vous quels sont les obstacles à l’utilisation du préservatif ?", ["Aucun", "Diminue la sensation", "Coûte cher", "Honte à l’achat"], "obstacles_preservatif", _obstaclesAutreController),
                   _buildRadioGroup("10- Avez-vous fait soit des tatouages, soit des scarifications ou un piercing ces 12 derniers mois ?", ["Oui", "Non"], "tatouage_scarification_piercing_12_mois"),
                   _buildRadioGroup("11- Avez-vous fait le dépistage pendant ces 3 derniers mois ?", ["Oui", "Non"], "depistage_3_mois"),
                   _buildRadioGroup("12- Connaissez-vous l’état sérologique de votre partenaire ?", ["Oui", "Non"], "connait_etat_serologique_partenaire"),

                   _buildSectionTitle("IV- Attitudes"),
                   _buildRadioGroup("13- Seriez-vous prêt(e) à effectuer une test de dépistage du VIH ?", ["Oui", "Non"], "pret_test_depistage"),
                   _buildRadioGroup("14- Accepteriez-vous de partager des toilettes avec une personne vivant avec le VIH/SIDA ?", ["Oui", "Non"], "partager_toilettes"),
                   _buildRadioGroup("15- Accepteriez-vous d’être ami(e) avec une personne vivant avec le VIH ?", ["Oui", "Non"], "ami_avec_pvvih"),
                   _buildRadioGroup("16- Accepteriez-vous de travailler ou d’étudier avec une personne vivant avec le VIH/SIDA ?", ["Oui", "Non"], "travailler_etudier_avec_pvvih"),
                   _buildRadioGroup("17- Une personne vivant avec le VIH doit-elle être rejetée par la société ?", ["Oui", "Non"], "rejetee_par_societe"),
                   _buildRadioGroup("18- Pensez-vous que le dépistage du VIH is important ?", ["Oui", "Non", "Ne sait pas"], "depistage_important"),

                   _buildSectionTitle("V- Status sérologique"),
                   _buildRadioGroup("Réactif/Non réactif", ["Réactif", "Non réactif"], "statut_serologique"),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isSaving || _isLoading ? null : _finaliserEnquete,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cyan,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isSaving
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : Text(_isEditMode ? "Mettre à Jour la Fiche" : "Enregistrer la Fiche", style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.cyanDark)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Card(
      color: AppColors.getCardColor(context),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                hintText: isNumeric ? "Âge" : "Préciser...",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioGroup(String title, List<String> options, String dataKey) {
    return Card(
      color: AppColors.getCardColor(context),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            ...options.map((option) => RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _surveyData[dataKey],
                  onChanged: (String? value) {
                    setState(() {
                      _surveyData[dataKey] = value;
                    });
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTransmissionRadioGroup(String mode) {
    return Card(
      color: AppColors.getCardColor(context),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mode, style: const TextStyle(fontWeight: FontWeight.w500)),
            ...['OUI', 'NON', 'Ne sait pas'].map((option) => RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _surveyData['transmission'][mode],
                  onChanged: (String? value) {
                    setState(() {
                      final newTransmission = Map<String, String?>.from(_surveyData['transmission']);
                      newTransmission[mode] = value;
                       _surveyData['transmission'] = newTransmission;
                    });
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioGroupWithOther(String title, List<String> options, String dataKey, TextEditingController otherController) {
    List<String> allOptions = [...options, 'Autre'];
    
    return Card(
      color: AppColors.getCardColor(context),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            ...allOptions.map((option) => RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _surveyData[dataKey],
                  onChanged: (String? value) {
                    setState(() {
                      _surveyData[dataKey] = value;
                    });
                  },
                )),
            if (_surveyData[dataKey] == 'Autre')
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                child: TextField(
                  controller: otherController,
                  decoration: const InputDecoration(
                    labelText: "Autre, à préciser",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxGroup(String title, List<String> options, String dataKey) {
    return Card(
      color: AppColors.getCardColor(context),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            ...options.map((option) {
              return CheckboxListTile(
                title: Text(option),
                value: (_surveyData[dataKey] as List<String>).contains(option),
                onChanged: (bool? checked) {
                  setState(() {
                    if (checked == true) {
                      (_surveyData[dataKey] as List<String>).add(option);
                    } else {
                      (_surveyData[dataKey] as List<String>).remove(option);
                    }
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCheckboxGroupWithOther(String title, List<String> options, String dataKey, TextEditingController otherController) {
    List<String> allOptions = [...options, 'Autres à préciser'];
    
    return Card(
      color: AppColors.getCardColor(context),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            ...allOptions.map((option) {
              return CheckboxListTile(
                title: Text(option),
                value: (_surveyData[dataKey] as List<String>).contains(option),
                onChanged: (bool? checked) {
                  setState(() {
                    if (checked == true) {
                      (_surveyData[dataKey] as List<String>).add(option);
                    } else {
                      (_surveyData[dataKey] as List<String>).remove(option);
                    }
                  });
                },
              );
            }).toList(),
            if ((_surveyData[dataKey] as List<String>).contains('Autres à préciser'))
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                child: TextField(
                  controller: otherController,
                  decoration: const InputDecoration(
                    labelText: "Autres, à préciser",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}