import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  final Logger _logger = Logger();

  Dio get dio => _dio;

  // Initialize the service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing ApiService...');
      
      // Configure Dio
      _dio = Dio(BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: Duration(seconds: AppConfig.connectionTimeout),
        receiveTimeout: Duration(seconds: AppConfig.receiveTimeout),
        sendTimeout: Duration(seconds: AppConfig.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': '${AppConfig.appName}/${AppConfig.appVersion}',
        },
      ));

      // Add interceptors
      _dio.interceptors.add(LogInterceptor(
        request: AppConfig.enableLogging,
        requestHeader: AppConfig.enableLogging,
        requestBody: AppConfig.enableLogging,
        responseHeader: AppConfig.enableLogging,
        responseBody: AppConfig.enableLogging,
        error: true,
        logPrint: (object) {
          if (AppConfig.enableLogging) {
            _logger.d(object);
          }
        },
      ));

      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('API Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('API Response: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('API Error: ${error.requestOptions.path} - ${error.message}');
          return handler.next(error);
        },
      ));

      _logger.i('ApiService initialized successfully');
    } catch (e) {
      _logger.e('Error initializing ApiService: $e');
      throw Exception('Failed to initialize ApiService');
    }
  }

  // Set authentication token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _logger.d('Authentication token set');
  }

  // Remove authentication token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    _logger.d('Authentication token cleared');
  }

  // Generic GET request
  Future<T> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data!;
    } catch (e) {
      _handleError(e, endpoint);
      rethrow;
    }
  }

  // Generic POST request
  Future<T> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data!;
    } catch (e) {
      _handleError(e, endpoint);
      rethrow;
    }
  }

  // Generic PUT request
  Future<T> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data!;
    } catch (e) {
      _handleError(e, endpoint);
      rethrow;
    }
  }

  // Generic DELETE request
  Future<T> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data!;
    } catch (e) {
      _handleError(e, endpoint);
      rethrow;
    }
  }

  // Transaction API methods
  Future<TransactionDTO> createTransaction(TransactionDTO transaction) async {
    try {
      final response = await post<TransactionDTO>(
        AppConfig.transactionsEndpoint,
        data: transaction.toJson(),
      );
      return response;
    } catch (e) {
      _logger.e('Error creating transaction: $e');
      rethrow;
    }
  }

  Future<TransactionDTO> getTransactionById(int id) async {
    try {
      final response = await get<TransactionDTO>(
        '${AppConfig.transactionsEndpoint}/$id',
      );
      return response;
    } catch (e) {
      _logger.e('Error getting transaction by ID: $e');
      rethrow;
    }
  }

  Future<TransactionDTO> getTransactionByNumeroRecu(String numeroRecu) async {
    try {
      final response = await get<TransactionDTO>(
        '${AppConfig.transactionsEndpoint}/receipt/$numeroRecu',
      );
      return response;
    } catch (e) {
      _logger.e('Error getting transaction by receipt number: $e');
      rethrow;
    }
  }

  Future<List<TransactionDTO>> getTransactionsByAgent(int agentId) async {
    try {
      final response = await get<List<dynamic>>(
        '${AppConfig.transactionsEndpoint}/agent/$agentId',
      );
      return response.map((json) => TransactionDTO.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error getting transactions by agent: $e');
      rethrow;
    }
  }

  Future<List<TransactionDTO>> getTransactionsByAgentAndDateRange(
    int agentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await get<List<dynamic>>(
        '${AppConfig.transactionsEndpoint}/agent/$agentId/range',
        queryParameters: {
          'debut': startDate.toIso8601String(),
          'fin': endDate.toIso8601String(),
        },
      );
      return response.map((json) => TransactionDTO.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error getting transactions by date range: $e');
      rethrow;
    }
  }

  Future<TransactionDTO> updateTransactionStatus(int id, String status) async {
    try {
      final response = await put<TransactionDTO>(
        '${AppConfig.transactionsEndpoint}/$id/status',
        queryParameters: {'status': status},
      );
      return response;
    } catch (e) {
      _logger.e('Error updating transaction status: $e');
      rethrow;
    }
  }

  Future<TransactionDTO> synchronizeTransaction(int id) async {
    try {
      final response = await put<TransactionDTO>(
        '${AppConfig.transactionsEndpoint}/$id/sync',
      );
      return response;
    } catch (e) {
      _logger.e('Error synchronizing transaction: $e');
      rethrow;
    }
  }

  Future<List<TransactionDTO>> synchronizeAllOfflineTransactions() async {
    try {
      final response = await post<List<dynamic>>(
        '${AppConfig.transactionsEndpoint}/sync-all',
      );
      return response.map((json) => TransactionDTO.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error synchronizing all offline transactions: $e');
      rethrow;
    }
  }

  Future<int> countOfflineTransactions() async {
    try {
      final response = await get<int>(
        '${AppConfig.transactionsEndpoint}/offline/count',
      );
      return response;
    } catch (e) {
      _logger.e('Error counting offline transactions: $e');
      rethrow;
    }
  }

  Future<bool> verifyTransactionHash(int id, String hash) async {
    try {
      final response = await get<bool>(
        '${AppConfig.transactionsEndpoint}/$id/verify',
        queryParameters: {'hash': hash},
      );
      return response;
    } catch (e) {
      _logger.e('Error verifying transaction hash: $e');
      rethrow;
    }
  }

  // Contribuable API methods
  Future<ContribuableDto> createContribuable(ContribuableDto contribuable) async {
    try {
      final response = await post<ContribuableDto>(
        AppConfig.contribuablesEndpoint,
        data: contribuable.toJson(),
      );
      return response;
    } catch (e) {
      _logger.e('Error creating contribuable: $e');
      rethrow;
    }
  }

  Future<ContribuableDto> getContribuableById(int id) async {
    try {
      final response = await get<ContribuableDto>(
        '${AppConfig.contribuablesEndpoint}/$id',
      );
      return response;
    } catch (e) {
      _logger.e('Error getting contribuable by ID: $e');
      rethrow;
    }
  }

  Future<List<ContribuableDto>> getAllContribuables() async {
    try {
      final response = await get<List<dynamic>>(
        '${AppConfig.contribuablesEndpoint}/all',
      );
      return response.map((json) => ContribuableDto.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error getting all contribuables: $e');
      rethrow;
    }
  }

  Future<ContribuableDto> updateContribuable(int id, ContribuableDto contribuable) async {
    try {
      final response = await put<ContribuableDto>(
        '${AppConfig.contribuablesEndpoint}/$id',
        data: contribuable.toJson(),
      );
      return response;
    } catch (e) {
      _logger.e('Error updating contribuable: $e');
      rethrow;
    }
  }

  // Agent API methods
  Future<AgentsDto> createAgent(AgentsDto agent) async {
    try {
      final response = await post<AgentsDto>(
        AppConfig.agentsEndpoint,
        data: agent.toJson(),
      );
      return response;
    } catch (e) {
      _logger.e('Error creating agent: $e');
      rethrow;
    }
  }

  Future<AgentsDto> getAgentById(int id) async {
    try {
      final response = await get<AgentsDto>(
        '${AppConfig.agentsEndpoint}/$id',
      );
      return response;
    } catch (e) {
      _logger.e('Error getting agent by ID: $e');
      rethrow;
    }
  }

  Future<List<AgentsDto>> getAllAgents() async {
    try {
      final response = await get<List<dynamic>>(
        '${AppConfig.agentsEndpoint}/all',
      );
      return response.map((json) => AgentsDto.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error getting all agents: $e');
      rethrow;
    }
  }

  // Zone API methods
  Future<ZoneCollectDto> createZone(ZoneCollectDto zone) async {
    try {
      final response = await post<ZoneCollectDto>(
        AppConfig.zonesEndpoint,
        data: zone.toJson(),
      );
      return response;
    } catch (e) {
      _logger.e('Error creating zone: $e');
      rethrow;
    }
  }

  Future<ZoneCollectDto> getZoneById(int id) async {
    try {
      final response = await get<ZoneCollectDto>(
        '${AppConfig.zonesEndpoint}/$id',
      );
      return response;
    } catch (e) {
      _logger.e('Error getting zone by ID: $e');
      rethrow;
    }
  }

  Future<List<ZoneCollectDto>> getAllZones() async {
    try {
      final response = await get<List<dynamic>>(
        '${AppConfig.zonesEndpoint}/all',
      );
      return response.map((json) => ZoneCollectDto.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error getting all zones: $e');
      rethrow;
    }
  }

  // Taxe API methods
  Future<List<TaxeDto>> getAllTaxes() async {
    try {
      final response = await get<List<dynamic>>(
        '${AppConfig.taxesEndpoint}/all',
      );
      return response.map((json) => TaxeDto.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error getting all taxes: $e');
      rethrow;
    }
  }

  Future<TaxeDto> getTaxeById(int id) async {
    try {
      final response = await get<TaxeDto>(
        '${AppConfig.taxesEndpoint}/$id',
      );
      return response;
    } catch (e) {
      _logger.e('Error getting taxe by ID: $e');
      rethrow;
    }
  }

  // Cloture Caisse API methods
  Future<ClotureCaisseDTO> initierClotureCaisse(int agentId, DateTime dateCloture) async {
    try {
      final response = await post<ClotureCaisseDTO>(
        '${AppConfig.clotureCaisseEndpoint}/initier',
        queryParameters: {
          'agentId': agentId.toString(),
          'dateCloture': dateCloture.toIso8601String(),
        },
      );
      return response;
    } catch (e) {
      _logger.e('Error initiating cloture caisse: $e');
      rethrow;
    }
  }

  Future<ClotureCaisseDTO> getClotureCaisseById(int id) async {
    try {
      final response = await get<ClotureCaisseDTO>(
        '${AppConfig.clotureCaisseEndpoint}/$id',
      );
      return response;
    } catch (e) {
      _logger.e('Error getting cloture caisse by ID: $e');
      rethrow;
    }
  }

  Future<ClotureCaisseDTO> soumettreClotureCaisse(
    int clotureId,
    double montantDeclare,
    String? commentaireAgent,
  ) async {
    try {
      final response = await post<ClotureCaisseDTO>(
        '${AppConfig.clotureCaisseEndpoint}/$clotureId/soumettre',
        queryParameters: {
          'montantDeclare': montantDeclare.toString(),
          if (commentaireAgent != null) 'commentaireAgent': commentaireAgent,
        },
      );
      return response;
    } catch (e) {
      _logger.e('Error submitting cloture caisse: $e');
      rethrow;
    }
  }

  Future<ClotureCaisseDTO> validerClotureCaisse(
    int clotureId,
    int valideParId,
    String? commentaireTresor,
  ) async {
    try {
      final response = await post<ClotureCaisseDTO>(
        '${AppConfig.clotureCaisseEndpoint}/$clotureId/valider',
        queryParameters: {
          'valideParId': valideParId.toString(),
          if (commentaireTresor != null) 'commentaireTresor': commentaireTresor,
        },
      );
      return response;
    } catch (e) {
      _logger.e('Error validating cloture caisse: $e');
      rethrow;
    }
  }

  Future<ClotureCaisseDTO> rejeterClotureCaisse(
    int clotureId,
    int valideParId,
    String commentaireTresor,
  ) async {
    try {
      final response = await post<ClotureCaisseDTO>(
        '${AppConfig.clotureCaisseEndpoint}/$clotureId/rejeter',
        queryParameters: {
          'valideParId': valideParId.toString(),
          'commentaireTresor': commentaireTresor,
        },
      );
      return response;
    } catch (e) {
      _logger.e('Error rejecting cloture caisse: $e');
      rethrow;
    }
  }

  Future<ClotureCaisseDTO> confirmerDepotBanque(
    int clotureId,
    double montantDepose,
    String referenceDepot,
  ) async {
    try {
      final response = await post<ClotureCaisseDTO>(
        '${AppConfig.clotureCaisseEndpoint}/$clotureId/confirmer-depot',
        queryParameters: {
          'montantDepose': montantDepose.toString(),
          'referenceDepot': referenceDepot,
        },
      );
      return response;
    } catch (e) {
      _logger.e('Error confirming bank deposit: $e');
      rethrow;
    }
  }

  // Health check
  Future<bool> healthCheck() async {
    try {
      await get('/health');
      return true;
    } catch (e) {
      _logger.e('Health check failed: $e');
      return false;
    }
  }

  // Error handling
  void _handleError(dynamic error, String endpoint) {
    String message = AppConfig.serverError;
    
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = AppConfig.networkError;
          break;
        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 401) {
            message = AppConfig.authError;
          } else if (error.response?.statusCode == 404) {
            message = 'Ressource non trouvée';
          } else if (error.response?.statusCode == 500) {
            message = AppConfig.serverError;
          } else {
            message = error.response?.data?['message'] ?? AppConfig.serverError;
          }
          break;
        case DioExceptionType.cancel:
          message = 'Requête annulée';
          break;
        case DioExceptionType.connectionError:
          message = AppConfig.networkError;
          break;
        default:
          message = AppConfig.serverError;
      }
    }
    
    _logger.e('API Error on $endpoint: $message');
  }
}
