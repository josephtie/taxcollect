import '../config/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class TransactionScreen extends StatefulWidget {
  final ContribuableForm? contribuable;
  
  const TransactionScreen({super.key, this.contribuable});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Logger _logger = Logger();
  
  bool _isLoading = false;
  List<TransactionDTO> _transactions = [];
  List<TaxeDto> _availableTaxes = [];
  TaxeDto? _selectedTaxe;
  String? _selectedPaymentMethod;
  DateTime? _selectedDate;
  
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTaxes();
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contribuable != null 
          ? 'Transaction - ${widget.contribuable!.fullName}'
          : 'Nouvelle Transaction'),
        backgroundColor: AppTheme.goldColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.add), text: 'Nouveau'),
            Tab(icon: Icon(Icons.list), text: 'Historique'),
            Tab(icon: Icon(Icons.analytics), text: 'Statistiques'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewTransactionTab(),
          _buildHistoryTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildNewTransactionTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contribuable info
          if (widget.contribuable != null) ...[
            Container(
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                color: AppTheme.goldColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppTheme.goldColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: AppTheme.goldColor, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.contribuable!.fullName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldColor,
                          ),
                        ),
                        if (widget.contribuable!.telephone != null)
                          Text(
                            widget.contribuable!.telephone!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],
          
          // Taxe selection
            Text(
              'Sélectionner une Taxe',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<TaxeDto>(
              value: _selectedTaxe,
              decoration: const InputDecoration(
                hintText: 'Sélectionner une taxe',
                prefixIcon: Icon(Icons.receipt_long),
              ),
              items: _availableTaxes.map((taxe) {
                return DropdownMenuItem(
                  value: taxe,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(taxe.libelle ?? 'Taxe inconnue'),
                      SizedBox(width: 8.h),
                      Text(
                        '${taxe.montant?.toStringAsFixed(2) ?? '0.00'} FCFA',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTaxe = value;
                  if (value != null) {
                    _amountController.text = value.montant?.toString() ?? '';
                  }
                });
              },
            ),
            
            SizedBox(height: 16.h),
            
            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Montant (FCFA)',
                hintText: 'Entrez le montant',
                prefixIcon: Icon(Icons.money),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Montant invalide';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16.h),
            
            // Payment method
            Text(
              'Méthode de Paiement',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: const InputDecoration(
                hintText: 'Sélectionner une méthode',
                prefixIcon: Icon(Icons.payment),
              ),
              items: const [
                DropdownMenuItem(value: 'ESPECE', child: Text('Espèce')),
                DropdownMenuItem(value: 'MOBILE_MONEY', child: Text('Mobile Money')),
                DropdownMenuItem(value: 'QR_CODE', child: Text('QR Code')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
            ),
            
            SizedBox(height: 16.h),
            
            // Date
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date de Transaction',
                hintText: 'Sélectionner une date',
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ),
              controller: TextEditingController(
                text: _selectedDate != null 
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : '',
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitTransaction,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  backgroundColor: AppTheme.goldColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Créer Transaction'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        // Search bar
        Container(
          padding: EdgeInsets.all(16.h),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher une transaction...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _clearSearch();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        
        // Transactions list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64.sp,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Aucune transaction trouvée',
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.h),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        return TransactionCard(
                          transaction: transaction,
                          onTap: () => _viewTransaction(transaction),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    if (_transactions.isEmpty) {
      return const Center(
        child: Text('Aucune donnée statistique disponible'),
      );
    }

    final totalAmount = _calculateTotalAmount(_transactions);
    final paymentDistribution = _calculatePaymentMethodsDistribution();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques des Transactions',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          
          // Total amount card
          _buildStatCard(
            'Montant Total',
            '${totalAmount.toStringAsFixed(0)} FCFA',
            Icons.money,
            Colors.green,
          ),
          
          SizedBox(height: 16.h),
          
          // Transaction count
          _buildStatCard(
            'Nombre de Transactions',
            '${_transactions.length}',
            Icons.receipt_long,
            AppTheme.goldColor,
          ),
          
          SizedBox(height: 24.h),
          
          Text(
            'Répartition par Méthode de Paiement',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Payment methods distribution
          ...paymentDistribution.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Icon(
                    _getPaymentMethodIcon(entry.key),
                    color: _getPaymentMethodColor(entry.key),
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: entry.value / _transactions.length,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getPaymentMethodColor(entry.key),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '${entry.value}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadTaxes() async {
    try {
      final apiService = ApiService();
      _availableTaxes = await apiService.getAllTaxes();
      _logger.i('Loaded ${_availableTaxes.length} taxes');
    } catch (e) {
      _logger.e('Error loading taxes: $e');
      // Fallback for development
      _availableTaxes = [
        TaxeDto(
          id: 1,
          nom: 'Taxe Marchande',
          description: 'Taxe pour les commerçants',
          taux: 5000.0,
        ),
        TaxeDto(
          id: 2,
          nom: 'Taxe Transport',
          description: 'Taxe pour les transporteurs',
          taux: 3000.0,
        ),
      ];
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final authService = Provider.of<AuthService>(context, listen: false);
      
      _transactions = await apiService.getTransactionsByAgent(
        int.tryParse(authService.currentUser?.id ?? '0') ?? 0,
      );
      
      // Sort by creation date (most recent first)
      _transactions.sort((a, b) {
        if (a.dateCreation == null && b.dateCreation == null) return 0;
        if (a.dateCreation == null) return 1;
        if (b.dateCreation == null) return -1;
        return b.dateCreation!.compareTo(a.dateCreation!);
      });
      
    } catch (e) {
      _logger.e('Error loading transactions: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitTransaction() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final transaction = TransactionDTO(
        numeroRecu: '', // Will be generated by backend
        montant: double.parse(_amountController.text),
        dateCreation: _selectedDate ?? DateTime.now(),
        statut: TransactionStatus.validee,
        modePaiement: ModePaiement.values.firstWhere(
          (mode) => mode.code == _selectedPaymentMethod,
          orElse: () => ModePaiement.espece,
        ),
        agentId: int.tryParse(authService.currentUser?.id ?? '0') ?? 0,
        contribuableId: widget.contribuable?.id ?? 0,
        contribuableNom: widget.contribuable?.fullName,
        zoneId: 1, // Default zone
        offline: false,
      );

      final createdTransaction = await apiService.createTransaction(transaction);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction ${createdTransaction.numeroRecu} créée'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form and reload
        _clearForm();
        _loadTransactions();
        _tabController.animateTo(1); // Switch to history tab
      }
    } catch (e) {
      _logger.e('Error creating transaction: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateForm() {
    if (_selectedTaxe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une taxe')),
      );
      return false;
    }
    
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une méthode de paiement')),
      );
      return false;
    }
    
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant')),
      );
      return false;
    }
    
    return true;
  }

  void _clearForm() {
    setState(() {
      _selectedTaxe = null;
      _selectedPaymentMethod = null;
      _selectedDate = null;
      _amountController.clear();
      _referenceController.clear();
    });
  }

  void _onSearchChanged(String query) {
    // Implement search logic
  }

  void _clearSearch() {
    // Implement clear search logic
  }

  void _viewTransaction(TransactionDTO transaction) {
    // Implement transaction details view
  }

  double _calculateTotalAmount(List<TransactionDTO> transactions) {
    return transactions.fold(0.0, (sum, transaction) => sum + transaction.montant);
  }

  Map<String, int> _calculatePaymentMethodsDistribution() {
    final distribution = <String, int>{};
    for (final transaction in _transactions) {
      final method = transaction.modePaiement.label;
      distribution[method] = (distribution[method] ?? 0) + 1;
    }
    return distribution;
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'ESPECE':
        return Icons.money;
      case 'MOBILE_MONEY':
        return Icons.phone_android;
      case 'QR_CODE':
        return Icons.qr_code;
      default:
        return Icons.payment;
    }
  }

  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case 'ESPECE':
        return Colors.green;
      case 'MOBILE_MONEY':
        return Colors.orange;
      case 'QR_CODE':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
