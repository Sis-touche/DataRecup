import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recupdata/Core/utils/export_util.dart';
import 'package:recupdata/Features/Widgets/app_widgets.dart';
import '../../Dadabase/database_helper.dart'; // <-- VRAI export + BDD + Constantes

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  bool _isLoading = true;
  bool _isExporting = false;
  
  List<Map<String, dynamic>> _allRecords = []; 
  List<Map<String, dynamic>> _filteredRecords = []; 
  String? _filter; 

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  Future<void> _refreshList() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await DatabaseHelper.instance.obtenirToutesLesFiches();
      _allRecords = data;
      _applyFilter(); 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement: $e")),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilter() {
    setState(() {
      if (_filter == null || _filter == 'Tous') {
        _filteredRecords = List.from(_allRecords);
      } else {
        _filteredRecords = _allRecords.where((record) {
          final statut = record[DBConstantes.colStatutSerologique] ?? 'Non défini';
          return statut.toString().toLowerCase() == _filter!.toLowerCase();
        }).toList();
      }
      _isLoading = false;
    });
  }

  Future<void> _navigateToFormForEdit(int id) async {
    final result = await context.push('/form/edit/$id');
    if (result == true && mounted) {
      _refreshList(); 
    }
  }

  Future<void> _deleteRecord(int id, String ficheNo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        surfaceTintColor: Colors.transparent,
        title: const Text('Confirmer la Suppression'),
        content: Text('Voulez-vous vraiment supprimer la fiche N°$ficheNo ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.supprimerFiche(id);
      _refreshList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fiche N°$ficheNo supprimée.')),
        );
      }
    }
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    try {
      await exporterEtEventuellementVider(
        context,
        demanderVidage: true,
        onRefresh: () => _refreshList(), 
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

  void _onFilterChanged(String? newFilter) {
    setState(() {
      _filter = newFilter == 'Tous' ? null : newFilter;
    });
    _applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiches Remplies'),
        actions: [
          if (!_isLoading)
            _isExporting
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3, 
                        color: Theme.of(context).appBarTheme.iconTheme?.color ?? (isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.download_outlined),
                    onPressed: _exportData,
                    tooltip: 'Exporter les données (Excel)',
                  ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterBar(),
                Expanded(
                  child: _filteredRecords.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text(
                                'Aucune fiche à afficher.',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              if (_filter != null)
                                Text(
                                  'Filtre actif : $_filter',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredRecords.length,
                          itemBuilder: (context, index) {
                            final record = _filteredRecords[index];
                            final ficheNo = record[DBConstantes.colFicheNumero] ?? 'N/A';
                            final dateSaisie = record[DBConstantes.colDateSaisie] ?? 'Date inconnue';
                            final statut = record[DBConstantes.colStatutSerologique] ?? 'Non défini';

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: getStatutColor(statut).withOpacity(0.15),
                                  child: Icon(getStatutIcon(statut), color: getStatutColor(statut)),
                                ),
                                title: Text('Fiche N° $ficheNo', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Date: $dateSaisie'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Chip(
                                      label: Text(statut, style: const TextStyle(fontSize: 12)),
                                      backgroundColor: getStatutColor(statut).withOpacity(0.1),
                                      side: BorderSide.none,
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
                                      onPressed: () => _navigateToFormForEdit(record[DBConstantes.colId]),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () => _deleteRecord(record[DBConstantes.colId], ficheNo),
                                    ),
                                  ],
                                ),
                                onTap: () => _navigateToFormForEdit(record[DBConstantes.colId]),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/form/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Fiche'),
      ),
    );
  }

  Widget _buildFilterBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDarkMode ? Colors.grey[850] : Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Filtrer par statut:', style: TextStyle(fontWeight: FontWeight.w500)),
          DropdownButton<String>(
            value: _filter ?? 'Tous',
            underline: const SizedBox.shrink(),
            dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
            items: ['Tous', 'Réactif', 'Non réactif', 'Non défini']
                .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                .toList(),
            onChanged: _onFilterChanged,
          ),
        ],
      ),
    );
  }
}