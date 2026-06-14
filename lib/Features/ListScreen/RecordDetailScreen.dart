import 'package:flutter/material.dart';
import 'package:recupdata/Dadabase/database_helper.dart';
import 'package:recupdata/Features/ListScreen/DeleteConfirmationScreen.dart';

class RecordDetailScreen extends StatelessWidget {
  final int ficheId;

  const RecordDetailScreen({super.key, required this.ficheId});

  Future<Map<String, dynamic>?> _loadFiche() =>
      DatabaseHelper.instance.obtenirFicheParId(ficheId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        // 1. On augmente la hauteur de l'appBar pour accueillir confortablement les 2 lignes
        toolbarHeight: 70,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: FutureBuilder<Map<String, dynamic>?>(
          future: _loadFiche(),
          builder: (context, snapshot) {
            final num = snapshot.data?[DBConstantes.colFicheNumero] ?? '...';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'DÉTAIL DU DOSSIER',
                  style: TextStyle(
                    color: Color(0xFF22D3EE), // Ton cyan moderne
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fiche N° $num',
                  maxLines: 2, // 2. On autorise le retour à la ligne
                  overflow: TextOverflow.visible, // Plus de blocage !
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // Légèrement plus petit pour que le bloc reste élégant
                    height: 1.2, // Ajuste l'espacement entre les deux lignes si ça coupe
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadFiche(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF22D3EE)),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('Une erreur est survenue lors du chargement.'),
            );
          }

          final data = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ── En-tête statut ──────────────────────────
                    _StatutHeader(data: data),
                    const SizedBox(height: 16),

                    // ── I. Identité ─────────────────────────────
                    _SectionCard(
                      title: 'I. IDENTITÉ',
                      icon: Icons.person_outline,
                      iconColor: Colors.deepPurple,
                      accentColor: Colors.deepPurple,
                      borderColor: Colors.deepPurple.shade200,
                      rows: [
                        _DataRow('Tranche d\'âge', data[DBConstantes.colAgeTranche]),
                        _DataRow('Sexe', data[DBConstantes.colSexe]),
                        _DataRow('Statut matrimonial', data[DBConstantes.colStatutMatrimonial]),
                        _DataRow('Niveau d\'étude', data[DBConstantes.colNiveauEtude]),
                        _DataRow('Résidence', data[DBConstantes.colResidence]),
                        _DataRow('Religion', data[DBConstantes.colReligion]),
                        _DataRow('Source de revenu', data[DBConstantes.colSourceRevenu]),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── II. Connaissances ───────────────────────
                    _SectionCard(
                      title: 'II. CONNAISSANCES SUR LE VIH',
                      icon: Icons.menu_book_outlined,
                      iconColor: Colors.blue,
                      accentColor: Colors.blue,
                      rows: [
                        _DataRow('Entendu parler du VIH', data[DBConstantes.colEntenduParlerVih]),
                        _DataRow('Transmission par rapports sexuels', data[DBConstantes.colTransRapportsSexuels]),
                        _DataRow('Transmission par voie sanguine', data[DBConstantes.colTransVoieSanguine]),
                        _DataRow('Transmission par moustiques', data[DBConstantes.colTransMoustiques]),
                        _DataRow('Transmission par salive', data[DBConstantes.colTransSalive]),
                        _DataRow('Transmission mère-enfant', data[DBConstantes.colTransMereEnfant]),
                        _DataRow('Personne saine peut être porteuse', data[DBConstantes.colPersonneSainePorteuse]),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── III. Pratiques ──────────────────────────
                    _SectionCard(
                      title: 'III. PRATIQUES',
                      icon: Icons.monitor_heart_outlined,
                      iconColor: const Color(0xFF10B981),
                      accentColor: const Color(0xFF10B981),
                      rows: [
                        _DataRow('Prévention — Abstinence', _intToOuiNon(data[DBConstantes.colPrevAbstinence])),
                        _DataRow('Prévention — Spermicides', _intToOuiNon(data[DBConstantes.colPrevSpermicides])),
                        _DataRow('Prévention — Fidélité/Dépistage', _intToOuiNon(data[DBConstantes.colPrevFideliteDepistage])),
                        _DataRow('Prévention — Pilule', _intToOuiNon(data[DBConstantes.colPrevPilule])),
                        _DataRow('Prévention — Préservatif', _intToOuiNon(data[DBConstantes.colPrevPreservatif])),
                        _DataRow('Déjà eu un rapport sexuel', data[DBConstantes.colDejaRapportSexuel]),
                        _DataRow('Âge du premier rapport', data[DBConstantes.colAgePremierRapport]?.toString()),
                        _DataRow('Nb partenaires (12 mois)', data[DBConstantes.colNombrePartenaires12Mois]?.toString()),
                        _DataRow('Utilisation du préservatif', data[DBConstantes.colUtilisationPreservatif]),
                        _DataRow('Obstacle — Aucun', _intToOuiNon(data[DBConstantes.colObstacleAucun])),
                        _DataRow('Obstacle — Sensation diminuée', _intToOuiNon(data[DBConstantes.colObstacleSensation])),
                        _DataRow('Obstacle — Trop cher', _intToOuiNon(data[DBConstantes.colObstacleCher])),
                        _DataRow('Obstacle — Honte', _intToOuiNon(data[DBConstantes.colObstacleHonte])),
                        _DataRow('Obstacle — Autre', data[DBConstantes.colObstacleAutrePrecision]),
                        _DataRow('Tatouage/Piercing (12 mois)', data[DBConstantes.colTatouagePiercing12Mois]),
                        _DataRow('Dépistage (3 derniers mois)', data[DBConstantes.colDepistage3Mois]),
                        _DataRow('Connaît statut partenaire', data[DBConstantes.colConnaitStatutPartenaire]),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── IV. Attitudes ───────────────────────────
                    _SectionCard(
                      title: 'IV. ATTITUDES',
                      icon: Icons.favorite_outline,
                      iconColor: Colors.pinkAccent,
                      accentColor: Colors.pinkAccent,
                      rows: [
                        _DataRow('Prêt pour un test de dépistage', data[DBConstantes.colPretTestDepistage]),
                        _DataRow('Partager toilettes avec PVVIH', data[DBConstantes.colPartagerToilettes]),
                        _DataRow('Ami avec une PVVIH', data[DBConstantes.colAmiAvecPvvih]),
                        _DataRow('Travailler/Étudier avec PVVIH', data[DBConstantes.colTravaillerEtudierPvvih]),
                        _DataRow('Rejeté par la société', data[DBConstantes.colRejetaParSociete]),
                        _DataRow('Dépistage important', data[DBConstantes.colDepistageImportant]),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── V. Statut sérologique ───────────────────
                    _SectionCard(
                      title: 'V. STATUT SÉROLOGIQUE',
                      icon: Icons.science_outlined,
                      iconColor: Colors.teal,
                      accentColor: Colors.teal,
                      rows: [
                        _DataRow('Statut sérologique', data[DBConstantes.colStatutSerologique]),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // ── Barre d'actions bas ─────────────────────────
              _BottomActionBar(
                context: context,
                ficheId: ficheId,
                data: data,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Convertit 0/1 en "Non"/"Oui" pour l'affichage
  String _intToOuiNon(dynamic value) {
    if (value == null) return '—';
    if (value is int) return value == 1 ? 'Oui' : 'Non';
    return value.toString();
  }
}

// ── Statut Header ─────────────────────────────────────────────────────────────
class _StatutHeader extends StatelessWidget {
  final Map<String, dynamic> data;
  const _StatutHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. L'Expanded force la colonne à utiliser uniquement l'espace disponible restant
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FICHE N°',
                    style: TextStyle(
                      color: Color(0xFF0891B2),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data[DBConstantes.colFicheNumero] ?? '—',
                    // 2. On autorise le texte à s'étaler sur plusieurs lignes si nécessaire
                    maxLines: 3,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20, // Légèrement réduit à 20 pour un rendu plus équilibré sur 2 lignes
                      color: Colors.black87,
                      height: 1.2, // Ajuste l'espacement vertical entre les lignes
                    ),
                  ),
                ],
              ),
            ),
            // 3. Un petit espace de sécurité pour que le texte ne colle pas au badge
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF22D3EE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Enregistré',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
          const SizedBox(height: 14),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DATE DE SAISIE',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data[DBConstantes.colDateSaisie] ?? '—',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SEXE / ÂGE',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${data[DBConstantes.colSexe] ?? '—'} / ${data[DBConstantes.colAgeTranche] ?? '—'}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color accentColor;
  final Color? borderColor;
  final List<Widget> rows;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.accentColor,
    this.borderColor,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? Colors.grey.shade200,
          width: borderColor != null ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 4),
          ...rows,
        ],
      ),
    );
  }
}

// ── Data Row ──────────────────────────────────────────────────────────────────
class _DataRow extends StatelessWidget {
  final String label;
  final String? value;

  const _DataRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    // N'affiche pas la ligne si la valeur est nulle ou vide
    final display = (value == null || value!.trim().isEmpty) ? null : value!.trim();
    if (display == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 3,
            child: Text(
              display,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Barre d'actions bas ───────────────────────────────────────────────────────
class _BottomActionBar extends StatelessWidget {
  final BuildContext context;
  final int ficheId;
  final Map<String, dynamic> data;

  const _BottomActionBar({
    required this.context,
    required this.ficheId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.edit_outlined, color: Colors.black87, size: 18),
              label: const Text(
                'Éditer',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              icon: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
              label: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeleteConfirmationScreen(
                      ficheId: ficheId,
                      ficheNumero: data[DBConstantes.colFicheNumero] ?? 'Inconnu',
                    ),
                  ),
                ).then((hasDeleted) {
                  if (hasDeleted == true) Navigator.pop(context, true);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}