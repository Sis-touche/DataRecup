import 'package:flutter/material.dart';
import 'package:recupdata/Dadabase/database_helper.dart';

class DeleteConfirmationScreen extends StatelessWidget {
  final int ficheId;
  final String ficheNumero;

  const DeleteConfirmationScreen({
    super.key,
    required this.ficheId,
    required this.ficheNumero,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text(
          'Confirmer la suppression',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 32),

              // ── Carte de confirmation ──────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: const Border(
                    top: BorderSide(color: Color(0xFFEF4444), width: 5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icône corbeille dans cercle rouge pâle
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF2F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFEF4444),
                        size: 38,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Supprimer la fiche ?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 16),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          height: 1.6,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Attention, cette action est irréversible. Toutes les données liées à la ',
                          ),
                          TextSpan(
                            text: 'Fiche N° $ficheNumero',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const TextSpan(
                            text: ' seront définitivement effacées de la base de données.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Bouton Supprimer définitivement
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          await DatabaseHelper.instance.supprimerFiche(ficheId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Fiche N° $ficheNumero supprimée avec succès.'),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                            Navigator.pop(context, true);
                          }
                        },
                        child: const Text(
                          'Supprimer définitivement',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Bouton Annuler
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Footer ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Connecté en tant que Responsable Administratif',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}