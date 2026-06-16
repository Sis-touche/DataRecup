import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart'; // Import crucial pour choisir l'emplacement
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// ============================================================================
// CONSTANTES
// ============================================================================
class DBConstantes {
  static const String tableReponses = 'reponses_questionnaire';
  static const String colId = 'id';
  static const String colDateSaisie = 'date_saisie';
  static const String colFicheNumero = 'fiche_numero';
  static const String colAgeTranche = 'age_tranche';
  static const String colSexe = 'sexe';
  static const String colStatutMatrimonial = 'statut_matrimonial';
  static const String colNiveauEtude = 'niveau_etude';
  static const String colResidence = 'residence';
  static const String colReligion = 'religion';
  static const String colSourceRevenu = 'source_revenu';
  static const String colEntenduParlerVih = 'entendu_parler_vih';
  static const String colTransRapportsSexuels = 'trans_rapports_sexuels';
  static const String colTransVoieSanguine = 'trans_voie_sanguine';
  static const String colTransMoustiques = 'trans_moustiques';
  static const String colTransSalive = 'trans_salive';
  static const String colTransMereEnfant = 'trans_mere_enfant';
  static const String colPrevAbstinence = 'prev_abstinence';
  static const String colPrevSpermicides = 'prev_spermicides';
  static const String colPrevFideliteDepistage = 'prev_fidelite_depistage';
  static const String colPrevPilule = 'prev_pilule';
  static const String colPrevPreservatif = 'prev_preservatif';
  static const String colPersonneSainePorteuse = 'personne_saine_porteuse';
  static const String colDejaRapportSexuel = 'deja_rapport_sexuel';
  static const String colAgePremierRapport = 'age_premier_rapport';
  static const String colNombrePartenaires12Mois = 'nombre_partenaires_12_mois';
  static const String colUtilisationPreservatif = 'utilisation_preservatif';
  static const String colObstacleAucun = 'obstacle_aucun';
  static const String colObstacleSensation = 'obstacle_sensation';
  static const String colObstacleCher = 'obstacle_cher';
  static const String colObstacleHonte = 'obstacle_honte';
  static const String colObstacleAutrePrecision = 'obstacle_autre_precision';
  static const String colTatouagePiercing12Mois = 'tatouage_piercing_12_mois';
  static const String colDepistage3Mois = 'depistage_3_mois';
  static const String colConnaitStatutPartenaire = 'connait_statut_partenaire';
  static const String colPretTestDepistage = 'pret_test_depistage';
  static const String colPartagerToilettes = 'partager_toilettes';
  static const String colAmiAvecPvvih = 'ami_avec_pvvih';
  static const String colTravaillerEtudierPvvih = 'travailler_etudier_pvvih';
  static const String colRejetaParSociete = 'rejeta_par_societe';
  static const String colDepistageImportant = 'depistage_important';
  static const String colStatutSerologique = 'statut_serologique';
}

// ============================================================================
// HELPERS DE CONVERSION
// ============================================================================
int boolToInt(dynamic value) {
  if (value == null) return 0;
  if (value is bool) return value ? 1 : 0;
  if (value is int) return value;
  if (value is String) return value.toLowerCase() == 'oui' ? 1 : 0;
  return 0;
}

bool intToBool(int? value) => value == 1;
String intToOuiNon(int? value) => (value == 1) ? 'Oui' : 'Non';

// ============================================================================
// DATABASE HELPER
// ============================================================================
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mon_application.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DBConstantes.tableReponses} (
        ${DBConstantes.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DBConstantes.colDateSaisie} TEXT,
        ${DBConstantes.colFicheNumero} TEXT,
        ${DBConstantes.colAgeTranche} TEXT,
        ${DBConstantes.colSexe} TEXT,
        ${DBConstantes.colStatutMatrimonial} TEXT,
        ${DBConstantes.colNiveauEtude} TEXT,
        ${DBConstantes.colResidence} TEXT,
        ${DBConstantes.colReligion} TEXT,
        ${DBConstantes.colSourceRevenu} TEXT,
        ${DBConstantes.colEntenduParlerVih} TEXT,
        ${DBConstantes.colTransRapportsSexuels} TEXT,
        ${DBConstantes.colTransVoieSanguine} TEXT,
        ${DBConstantes.colTransMoustiques} TEXT,
        ${DBConstantes.colTransSalive} TEXT,
        ${DBConstantes.colTransMereEnfant} TEXT,
        ${DBConstantes.colPrevAbstinence} INTEGER,
        ${DBConstantes.colPrevSpermicides} INTEGER,
        ${DBConstantes.colPrevFideliteDepistage} INTEGER,
        ${DBConstantes.colPrevPilule} INTEGER,
        ${DBConstantes.colPrevPreservatif} INTEGER,
        ${DBConstantes.colPersonneSainePorteuse} TEXT,
        ${DBConstantes.colDejaRapportSexuel} TEXT,
        ${DBConstantes.colAgePremierRapport} INTEGER,
        ${DBConstantes.colNombrePartenaires12Mois} TEXT,
        ${DBConstantes.colUtilisationPreservatif} TEXT,
        ${DBConstantes.colObstacleAucun} INTEGER,
        ${DBConstantes.colObstacleSensation} INTEGER,
        ${DBConstantes.colObstacleCher} INTEGER,
        ${DBConstantes.colObstacleHonte} INTEGER,
        ${DBConstantes.colObstacleAutrePrecision} TEXT,
        ${DBConstantes.colTatouagePiercing12Mois} TEXT,
        ${DBConstantes.colDepistage3Mois} TEXT,
        ${DBConstantes.colConnaitStatutPartenaire} TEXT,
        ${DBConstantes.colPretTestDepistage} TEXT,
        ${DBConstantes.colPartagerToilettes} TEXT,
        ${DBConstantes.colAmiAvecPvvih} TEXT,
        ${DBConstantes.colTravaillerEtudierPvvih} TEXT,
        ${DBConstantes.colRejetaParSociete} TEXT,
        ${DBConstantes.colDepistageImportant} TEXT,
        ${DBConstantes.colStatutSerologique} TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute(
          'ALTER TABLE ${DBConstantes.tableReponses} ADD COLUMN synchronise INTEGER DEFAULT 0',
        );
      } catch (e) {
        debugPrint('Erreur migration : $e');
      }
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }

  // ============================================================================
  // OPERATIONS CRUD
  // ============================================================================
  Future<int> insererFiche(Map<String, dynamic> donneesFiche) async {
    final db = await instance.database;
    try {
      return await db.insert(
        DBConstantes.tableReponses,
        _normaliserDonnees(donneesFiche),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      debugPrint('Erreur insererFiche : $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> obtenirToutesLesFiches() async {
    final db = await instance.database;
    try {
      return await db.query(
        DBConstantes.tableReponses,
        orderBy: '${DBConstantes.colId} DESC',
      );
    } catch (e) {
      debugPrint('Erreur obtenirToutesLesFiches : $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> obtenirFicheParId(int id) async {
    final db = await instance.database;
    try {
      final result = await db.query(
        DBConstantes.tableReponses,
        where: '${DBConstantes.colId} = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      debugPrint('Erreur obtenirFicheParId : $e');
      rethrow;
    }
  }

  Future<int> modifierFiche(int id, Map<String, dynamic> nouvellesDonnees) async {
    final db = await instance.database;
    try {
      return await db.update(
        DBConstantes.tableReponses,
        _normaliserDonnees(nouvellesDonnees),
        where: '${DBConstantes.colId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Erreur modifierFiche : $e');
      rethrow;
    }
  }

  Future<int> supprimerFiche(int id) async {
    final db = await instance.database;
    try {
      return await db.delete(
        DBConstantes.tableReponses,
        where: '${DBConstantes.colId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Erreur supprimerFiche : $e');
      rethrow;
    }
  }

  Future<int> viderToutesLesFiches() async {
    final db = await instance.database;
    try {
      return await db.delete(DBConstantes.tableReponses);
    } catch (e) {
      debugPrint('Erreur viderToutesLesFiches : $e');
      rethrow;
    }
  }

  // ============================================================================
  // GENERATION EXCEL ET EN-TÊTES
  // ============================================================================
  static const List<String> _headers = [
    DBConstantes.colId,
    DBConstantes.colDateSaisie,
    DBConstantes.colFicheNumero,
    DBConstantes.colAgeTranche,
    DBConstantes.colSexe,
    DBConstantes.colStatutMatrimonial,
    DBConstantes.colNiveauEtude,
    DBConstantes.colResidence,
    DBConstantes.colReligion,
    DBConstantes.colSourceRevenu,
    DBConstantes.colEntenduParlerVih,
    DBConstantes.colTransRapportsSexuels,
    DBConstantes.colTransVoieSanguine,
    DBConstantes.colTransMoustiques,
    DBConstantes.colTransSalive,
    DBConstantes.colTransMereEnfant,
    DBConstantes.colPrevAbstinence,
    DBConstantes.colPrevSpermicides,
    DBConstantes.colPrevFideliteDepistage,
    DBConstantes.colPrevPilule,
    DBConstantes.colPrevPreservatif,
    DBConstantes.colPersonneSainePorteuse,
    DBConstantes.colDejaRapportSexuel,
    DBConstantes.colAgePremierRapport,
    DBConstantes.colNombrePartenaires12Mois,
    DBConstantes.colUtilisationPreservatif,
    DBConstantes.colObstacleAucun,
    DBConstantes.colObstacleSensation,
    DBConstantes.colObstacleCher,
    DBConstantes.colObstacleHonte,
    DBConstantes.colObstacleAutrePrecision,
    DBConstantes.colTatouagePiercing12Mois,
    DBConstantes.colDepistage3Mois,
    DBConstantes.colConnaitStatutPartenaire,
    DBConstantes.colPretTestDepistage,
    DBConstantes.colPartagerToilettes,
    DBConstantes.colAmiAvecPvvih,
    DBConstantes.colTravaillerEtudierPvvih,
    DBConstantes.colRejetaParSociete,
    DBConstantes.colDepistageImportant,
    DBConstantes.colStatutSerologique,
  ];

  Excel _construireExcel(List<Map<String, dynamic>> fiches) {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Fiches_VIH'];

    sheetObject.appendRow(_headers.map((h) => TextCellValue(h)).toList());

    for (var fiche in fiches) {
      List<CellValue> row = [];
      for (var header in _headers) {
        dynamic value = fiche[header];
        if (value == null) {
          row.add(TextCellValue(''));
        } else if (value is int) {
          if (header == DBConstantes.colPrevAbstinence ||
              header == DBConstantes.colPrevSpermicides ||
              header == DBConstantes.colPrevFideliteDepistage ||
              header == DBConstantes.colPrevPilule ||
              header == DBConstantes.colPrevPreservatif ||
              header == DBConstantes.colObstacleAucun ||
              header == DBConstantes.colObstacleSensation ||
              header == DBConstantes.colObstacleCher ||
              header == DBConstantes.colObstacleHonte) {
            row.add(TextCellValue(intToOuiNon(value)));
          } else {
            row.add(IntCellValue(value));
          }
        } else if (value is double) {
          row.add(DoubleCellValue(value));
        } else if (value is bool) {
          row.add(BoolCellValue(value));
        } else {
          row.add(TextCellValue(value.toString()));
        }
      }
      sheetObject.appendRow(row);
    }
    return excel;
  }

  // ============================================================================
  // EXPORT AVEC MENU DE PARTAGE (OPTIONNEL)
  // ============================================================================
  Future<File?> exporterVersExcel() async {
    final fiches = await obtenirToutesLesFiches();
    if (fiches.isEmpty) return null;

    final excel = _construireExcel(fiches);
    final bytes = excel.encode();
    if (bytes == null) return null;

    final directory = await getTemporaryDirectory();
    final filePath =
        '${directory.path}/export_fiches_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> partagerFichier(File file, {String texte = 'Export des données VIH'}) async {
    await Share.shareXFiles([XFile(file.path)], text: texte);
  }

  // ============================================================================
// EXPORT AVEC CHOIX DU DOSSIER — Compatible Android / iOS / Desktop
// ============================================================================
  Future<File?> exporterVersExcelSansPartage() async {
    final fiches = await obtenirToutesLesFiches();
    if (fiches.isEmpty) return null;

    final excel = _construireExcel(fiches);
    final List<int>? bytes = excel.encode();

    // Garde-fou : encode() a retourné null
    if (bytes == null || bytes.isEmpty) {
      debugPrint('❌ Encodage Excel échoué');
      return null;
    }

    final String dateStr = DateTime.now()
        .toIso8601String()
        .split('T')[0]
        .replaceAll('-', '');
    final String nomFichier = "export_enquetes_$dateStr.xlsx";

    if (Platform.isAndroid) {
      return await _exportAndroid(Uint8List.fromList(bytes), nomFichier);
    } else if (Platform.isIOS) {
      return await _exportIOS(Uint8List.fromList(bytes), nomFichier);
    }
    return null; 
    // else {
    //   return await _exportDesktop(Uint8List.fromList(bytes), nomFichier);
    // }
  }

// ── Android : stratégie selon version SDK ──────────────────────────────────
  Future<File?> _exportAndroid(Uint8List bytes, String nomFichier) async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final int sdk = androidInfo.version.sdkInt;

    if (sdk >= 29) {
      // Android 10+ (API 29+) : Scoped Storage
      // → On écrit dans le cache, on partage ensuite
      // getDirectoryPath() retourne un URI SAF non compatible avec File()
      return await _ecrireDansCacheEtPartager(bytes, nomFichier);

    } else if (sdk >= 23) {
      // Android 6–9 : permission WRITE_EXTERNAL_STORAGE requise au runtime
      final status = await Permission.storage.request();
      if (status.isGranted) {
        return await _ecrireDansDownloads(bytes, nomFichier);
      } else if (status.isPermanentlyDenied) {
        // L'utilisateur a coché "Ne plus demander"
        await openAppSettings();
        return null;
      } else {
        debugPrint('Permission stockage refusée');
        return null;
      }

    } else {
      // Android < 6 : permission déclarée dans le manifest suffit
      return await _ecrireDansDownloads(bytes, nomFichier);
    }
  }

// ── iOS ────────────────────────────────────────────────────────────────────
  Future<File?> _exportIOS(Uint8List bytes, String nomFichier) async {
    // iOS : pas d'accès libre au système de fichiers
    // → cache + partage natif (AirDrop, Fichiers, Mail, etc.)
    return await _ecrireDansCacheEtPartager(bytes, nomFichier);
  }

// ── Desktop ────────────────────────────────────────────────────────────────
  // Future<File?> _exportDesktop(Uint8List bytes, String nomFichier) async {
  //   String? path = await FilePicker.platform.saveFile(
  //     dialogTitle: 'Enregistrer le fichier Excel',
  //     fileName: nomFichier,
  //     type: FileType.custom,
  //     allowedExtensions: ['xlsx'],
  //   );
  //   if (!path.endsWith('.xlsx')) path = '$path.xlsx';

  //   final file = File(path);
  //   await file.writeAsBytes(bytes);
  //   return file;
  // }

// ── Écriture dans /Downloads (Android 6-9) ─────────────────────────────────
  Future<File?> _ecrireDansDownloads(Uint8List bytes, String nomFichier) async {
    try {
      Directory? dir;

      final downloads = Directory('/storage/emulated/0/Download');
      if (await downloads.exists()) {
        dir = downloads;
      } else {
        dir = await getExternalStorageDirectory();
      }
      dir ??= await getApplicationDocumentsDirectory();

      // Crée le dossier s'il n'existe pas
      if (!await dir.exists()) await dir.create(recursive: true);

      final file = File('${dir.path}/$nomFichier');
      await file.writeAsBytes(bytes);
      debugPrint('✅ Écrit dans Downloads : ${file.path}');
      return file;
    } catch (e) {
      debugPrint('❌ Erreur écriture Downloads : $e');
      return null;
    }
  }

// ── Écriture dans le cache + partage (Android 10+ et iOS) ──────────────────
  Future<File?> _ecrireDansCacheEtPartager(
      Uint8List bytes, String nomFichier) async {
    try {
      // getTemporaryDirectory() est TOUJOURS accessible, sans aucune permission
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$nomFichier');
      await file.writeAsBytes(bytes);
      debugPrint('✅ Écrit dans cache : ${file.path}');
      return file;
    } catch (e) {
      debugPrint('❌ Erreur écriture cache : $e');
      return null;
    }
  }

// ── Fallback : sauvegarde dans /Downloads (Android ancien) ───────────────
  Future<File?> _sauvegarderDansDownloads(List<int> bytes, String nomFichier) async {
    try {
      Directory? dir;

      // Essaie le vrai dossier Downloads public
      final downloadsPath = Directory('/storage/emulated/0/Download');
      if (await downloadsPath.exists()) {
        dir = downloadsPath;
      } else {
        // Fallback sur le stockage externe de l'app
        dir = await getExternalStorageDirectory();
      }

      dir ??= await getApplicationDocumentsDirectory();

      final file = File('${dir.path}/$nomFichier');
      await file.writeAsBytes(bytes);
      debugPrint('✅ Sauvegardé (Downloads fallback) : ${file.path}');
      return file;
    } catch (e) {
      debugPrint('❌ Erreur fallback Downloads : $e');
      return null;
    }
  }

// ── Fallback : dossier Documents de l'app (iOS) ──────────────────────────
  Future<File?> _sauvegarderDansDocuments(List<int> bytes, String nomFichier) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$nomFichier');
      await file.writeAsBytes(bytes);
      debugPrint('✅ Sauvegardé (Documents iOS) : ${file.path}');
      return file;
    } catch (e) {
      debugPrint('❌ Erreur Documents iOS : $e');
      return null;
    }
  }

  // ============================================================================
  // UTILITAIRES PRIVÉS
  // ============================================================================
  Map<String, dynamic> _normaliserDonnees(Map<String, dynamic> data) {
    final Map<String, dynamic> result = Map.from(data);
    final colonnesBool = [
      DBConstantes.colPrevAbstinence,
      DBConstantes.colPrevSpermicides,
      DBConstantes.colPrevFideliteDepistage,
      DBConstantes.colPrevPilule,
      DBConstantes.colPrevPreservatif,
      DBConstantes.colObstacleAucun,
      DBConstantes.colObstacleSensation,
      DBConstantes.colObstacleCher,
      DBConstantes.colObstacleHonte,
    ];
    for (var col in colonnesBool) {
      if (result.containsKey(col)) {
        result[col] = boolToInt(result[col]);
      }
    }
    return result;
  }
}

