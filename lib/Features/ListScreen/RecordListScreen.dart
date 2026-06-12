import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recupdata/Dadabase/database_helper.dart';
import 'package:recupdata/Features/Form/fromrecup.dart';
import 'package:recupdata/Features/ListScreen/RecordDetailScreen.dart' hide DBConstantes, DatabaseHelper, exporterEtEventuellementVider;
class RecordListScreen extends StatefulWidget {
  const RecordListScreen({Key? key}) : super(key: key);

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  late Future<List<Map<String, dynamic>>> _recordsFuture;
  int _currentIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allFiches = [];
  List<Map<String, dynamic>> _filteredFiches = [];
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _refreshList();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFiches = _allFiches;
      } else {
        _filteredFiches = _allFiches.where((fiche) {
          final numero = (fiche[DBConstantes.colFicheNumero] ?? '').toString().toLowerCase();
          final date = (fiche[DBConstantes.colDateSaisie] ?? '').toString().toLowerCase();
          return numero.contains(query) || date.contains(query);
        }).toList();
      }
    });
  }

  void _refreshList() {
    setState(() {
      _recordsFuture = DatabaseHelper.instance.obtenirToutesLesFiches().then((data) {
        _allFiches = data;
        _filteredFiches = data;
        return data;
      });
    });
  }

  // Nouvelle méthode d'export utilisant la fonction utilitaire corrigée
  // Nouvelle méthode d'export utilisant la fonction utilitaire corrigée
  Future<void> _exportData() async {
    // Les permissions de stockage ne sont plus requises grâce au FilePicker moderne,
    // on peut directement lancer l'exportation sécurisée.
    setState(() => _isExporting = true);

    try {
      await exporterEtEventuellementVider(
        context,
        demanderVidage: true,
        onRefresh: () => _refreshList(), // Rafraîchit la liste automatiquement si la base est vidée
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur export : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double hPad = screenWidth > 600 ? 32.0 : 16.0;

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
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2C),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
          ),
        ),
        title: const Text(
          'Enregistrements',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // Bouton d'exportation Excel mis à jour
          IconButton(
            icon: _isExporting
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.upload_file_outlined),
            onPressed: _isExporting ? null : _exportData,
            tooltip: 'Exporter en Excel et vider la base',
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _recordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF22C55E)),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barre de recherche
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Rechercher par Fiche N° ou date',
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                              prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Icon(Icons.tune, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),

                // En-tête
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_filteredFiches.length} DOSSIERS RÉCENTS',
                        style: const TextStyle(
                          color: Color(0xFF5A6A85),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          fontSize: 12,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Tout voir',
                          style: TextStyle(color: Color(0xFF22C55E), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                // Liste
                Expanded(
                  child: _filteredFiches.isEmpty
                      ? const Center(
                    child: Text(
                      'Aucun enregistrement trouvé.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
                    itemCount: _filteredFiches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final fiche = _filteredFiches[index];
                      final id = fiche[DBConstantes.colId] ?? 0;
                      final numeroFiche = fiche[DBConstantes.colFicheNumero] ?? 'Inconnu';
                      final dateSaisie = fiche[DBConstantes.colDateSaisie] ?? '--/--/----';
                      final sexe = fiche[DBConstantes.colSexe] ?? 'N/A';
                      final age = fiche[DBConstantes.colAgeTranche] ?? 'N/A';

                      return _FicheCard(
                        id: id,
                        numeroFiche: numeroFiche,
                        dateSaisie: dateSaisie,
                        sexe: sexe,
                        age: age,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecordDetailScreen(ficheId: id),
                            ),
                          );
                          if (result == true) _refreshList();
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SurveyFormScreen()),
          ).then((_) => _refreshList());
        },
        backgroundColor: const Color(0xFF38BDF8),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// ── Widget carte fiche (inchangé) ──────────────────────────────────────────
class _FicheCard extends StatelessWidget {
  final int id;
  final String numeroFiche;
  final String dateSaisie;
  final String sexe;
  final String age;
  final VoidCallback onTap;

  const _FicheCard({
    required this.id,
    required this.numeroFiche,
    required this.dateSaisie,
    required this.sexe,
    required this.age,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AJOUT DE EXPANDED : Empêche le numéro de fiche long de faire déborder le composant
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FICHE N°',
                          style: TextStyle(
                            color: Color(0xFF22D3EE),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          numeroFiche,
                          // Sécurité anti-overflow : réduit la police ou tronque si le nom est extrêmement long
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16, // Légère réduction à 16 pour une meilleure tolérance responsive
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12), // Espace de sécurité entre le numéro et la date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        dateSaisie,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Complété',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(height: 1, color: Colors.grey.shade200),
              ),
              Row(
                children: [
                  Expanded(child: _InfoCell(label: 'ÂGE', value: '$age ans')),
                  const SizedBox(width: 8),
                  Expanded(child: _InfoCell(label: 'SEXE', value: sexe)),
                  const SizedBox(width: 8),
                  // Nettoyage des SizedBox inutiles pour garder une structure propre
                  const Row(
                    children: [
                      Text(
                        'Voir',
                        style: TextStyle(
                          color: Color(0xFF22D3EE),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Color(0xFF22D3EE), size: 18),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _InfoCell({
    required this.label,
    required this.value,
    this.valueColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: valueColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}