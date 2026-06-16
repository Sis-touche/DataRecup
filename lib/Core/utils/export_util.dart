// lib/Core/utils/export_util.dart
import 'dart:io';
import 'dart:typed_data'; // Requis pour Uint8List
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:recupdata/Dadabase/database_helper.dart';

/// VRAIE fonction d'exportation DIRECTE corrigée pour Android & iOS
Future<void> exporterEtEventuellementVider(
  BuildContext context, {
  bool demanderVidage = true,
  VoidCallback? onRefresh,
}) async {
  final dbHelper = DatabaseHelper.instance;

  // 1. Vérifie s'il y a des fiches en BDD
  final fiches = await dbHelper.obtenirToutesLesFiches();
  if (fiches.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune fiche à exporter.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    return;
  }

  // 2. Récupérer d'abord le fichier temporaire généré par le DatabaseHelper
  final tempFile = await dbHelper.exporterVersExcelSansPartage();
  if (tempFile == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la génération du fichier Excel.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    return;
  }

  try {
    // 3. CRUCIAL : Lire les octets (bytes) du fichier Excel généré
    final Uint8List fileBytes = await tempFile.readAsBytes();

    // 4. Préparer le nom du fichier par défaut
    final String dateStr = DateTime.now().toIso8601String().split('T')[0].replaceAll('-', '');
    final String nomFichierDefaut = "export_enquetes_$dateStr.xlsx";

    // 5. Demander à l'utilisateur OÙ enregistrer en lui passant DIRECTEMENT les bytes
    // C'est le paramètre 'bytes: fileBytes' qui règle l'erreur sur Android/iOS !
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Choisir l\'emplacement de sauvegarde',
      fileName: nomFichierDefaut,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      bytes: fileBytes, // <-- CORRECTION ICI
    );

    // Si l'utilisateur clique sur "Annuler"
    if (outputFile == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exportation annulée.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // 6. Succès de l'enregistrement
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Fichier enregistré avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de l\'enregistrement : $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    return;
  }

  // 7. Propose de vider la base de données (Inchangé)
  if (demanderVidage && context.mounted) {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Vider la base ?'),
        content: const Text('Voulez-vous supprimer toutes les fiches de l\'application après cet export ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Oui', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await dbHelper.viderToutesLesFiches();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Base de données vidée avec succès.'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    }
  }

  if (onRefresh != null) onRefresh();
}