// lib/Features/Widgets/app_widgets.dart
import 'package:flutter/material.dart';

// ─── GESTION DES COULEURS DES STATUTS (ADAPTATIF) ────────────────────
Color getStatutColor(String statut) {
  switch (statut) {
    case 'Réactif':
      return Colors.redAccent;
    case 'Non réactif':
      return Colors.green;
    default:
      return Colors.blueGrey;
  }
}

// ─── GESTION DES ICÔNES DES STATUTS ──────────────────────────────────
IconData getStatutIcon(String statut) {
  switch (statut) {
    case 'Réactif':
      return Icons.warning_amber_rounded;
    case 'Non réactif':
      return Icons.check_circle_outline_rounded;
    default:
      return Icons.help_outline_rounded;
  }
}