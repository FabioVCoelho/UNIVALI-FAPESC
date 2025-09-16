import 'package:flutter/foundation.dart';

/// Simple in-memory translation service for static texts and role metadata.
///
/// - Supports Portuguese (pt) and English (en) initially.
/// - Keys use UPPER_SNAKE_CASE for app strings and RBAC role IDs as-is.
/// - Role helpers: roleLabel(roleId) and roleDescription(roleId).
/// - Language selection can be wired to a user profile setting (see TODOs).
class TranslationService {
  static String _current = 'pt'; // default language

  /// Public getter for the current language code.
  static String get currentLanguage => _current;

  /// Set the current language (e.g., 'pt' or 'en'). Falls back to 'pt'.
  static void setLanguage(String code) {
    if (_bundles.containsKey(code)) {
      _current = code;
    } else {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[TranslationService] Unsupported language: $code. Falling back to pt');
      }
      _current = 'pt';
    }
  }

  /// Translate a generic key (UI strings, messages, etc.).
  static String t(String key) {
    final map = _bundles[_current] ?? const {};
    return map[key] ?? key; // fallback to key if not found
  }

  /// Human-readable label for a role.
  static String roleLabel(String roleId) {
    final map = _roleLabels[_current] ?? const {};
    return map[roleId] ?? roleId;
  }

  /// Description for a role.
  static String roleDescription(String roleId) {
    final map = _roleDescriptions[_current] ?? const {};
    return map[roleId] ?? roleId;
  }

  // ==================== LANGUAGE BUNDLES ====================

  /// Generic UI strings per language.
  static final Map<String, Map<String, String>> _bundles = {
    'pt': {
      // Auth / Login
      'LOGIN': 'Login',
      'EMAIL': 'Email',
      'PASSWORD': 'Senha',
      'SIGN_UP': 'Cadastrar-se',
      'CONTINUE_AS_GUEST': 'Entrar sem login',
      'LOGIN_SUCCESS': 'Login feito com sucesso!',
      'LOGIN_ERROR': 'Ocorreu um erro',
      'GUEST_SUCCESS': 'Entrou como convidado',
      'GUEST_ERROR': 'Falha ao entrar como convidado',

      // Home / Services
      'SERVICES': 'Serviços',
      'REGISTER_PLANT': 'Registrar Planta',
      'CONSULT_PLANT': 'Consultar Planta',
      'EXPORT_PDF': 'Exportar PDF',
      'CUSTOM_CHART': 'Gráfico Personalizado',
      'CREDITS': 'Créditos',
      'RESOLVE_CONFLICTS': 'Resolver Conflitos',
      'ADD_FIELD': 'Adicionar Campo',
      'USERS_AND_PERMISSIONS': 'Usuários & Permissões',

      // Misc
      'PLANTS_REGISTERED': 'Plantas Registradas',
      'ACCESS_DENIED_EXPORT': 'Acesso negado: você não possui permissão para exportar.',
      // Filters
      'FILTER': 'Filtrar',
      'FILTER_TITLE': 'Filtrar',
      'APPLY': 'Aplicar',
      'CLEAR_FILTERS': 'Limpar filtros',
    },
    'en': {
      // Auth / Login
      'LOGIN': 'Login',
      'EMAIL': 'Email',
      'PASSWORD': 'Password',
      'SIGN_UP': 'Sign Up',
      'CONTINUE_AS_GUEST': 'Continue as guest',
      'LOGIN_SUCCESS': 'Logged in successfully!',
      'LOGIN_ERROR': 'An error occurred',
      'GUEST_SUCCESS': 'Signed in as guest',
      'GUEST_ERROR': 'Failed to sign in as guest',

      // Home / Services
      'SERVICES': 'Services',
      'REGISTER_PLANT': 'Register Plant',
      'CONSULT_PLANT': 'Consult Plant',
      'EXPORT_PDF': 'Export PDF',
      'CUSTOM_CHART': 'Custom Chart',
      'CREDITS': 'Credits',
      'RESOLVE_CONFLICTS': 'Resolve Conflicts',
      'ADD_FIELD': 'Add Field',
      'USERS_AND_PERMISSIONS': 'Users & Permissions',

      // Misc
      'PLANTS_REGISTERED': 'Plants Registered',
      'ACCESS_DENIED_EXPORT': 'Access denied: you do not have permission to export.',
      // Filters
      'FILTER': 'Filter',
      'FILTER_TITLE': 'Filter',
      'APPLY': 'Apply',
      'CLEAR_FILTERS': 'Clear filters',
    },
  };

  /// Role labels per language (keys are RBAC role IDs from rbac_service.dart)
  static final Map<String, Map<String, String>> _roleLabels = {
    'pt': {
      'VIEW_GRAPH': 'Visualizar Gráfico',
      'APPROVE_MERGE_CONTENT': 'Resolver Conflitos',
      'EXPORT_PDF': 'Exportar PDF',
      'VIEW_PLANTS': 'Consultar Planta',
      'REGISTER_PLANTS': 'Registrar Planta',
      'VIEW_CREDITS': 'Créditos',
      'ADD_NEW_FIELDS': 'Adicionar Campo',
      'LIST_USER': 'Listar Usuários',
      'UPDATE_USER': 'Atualizar Usuário',
      'REMOVE_USER': 'Remover Usuário',
      'ADD_USER': 'Adicionar Usuário',
      'ADD_PLANT': 'Adicionar Planta',
      'SEARCH_PLANT': 'Pesquisar Planta',
      'DELETE_PLANT': 'Excluir Planta',
    },
    'en': {
      'VIEW_GRAPH': 'View Graph',
      'APPROVE_MERGE_CONTENT': 'Resolve Conflicts',
      'EXPORT_PDF': 'Export PDF',
      'VIEW_PLANTS': 'View Plants',
      'REGISTER_PLANTS': 'Register Plants',
      'VIEW_CREDITS': 'View Credits',
      'ADD_NEW_FIELDS': 'Add New Fields',
      'LIST_USER': 'List Users',
      'UPDATE_USER': 'Update User',
      'REMOVE_USER': 'Remove User',
      'ADD_USER': 'Add User',
      'ADD_PLANT': 'Add Plant',
      'SEARCH_PLANT': 'Search Plant',
      'DELETE_PLANT': 'Delete Plant',
    },
  };

  /// Role descriptions per language.
  static final Map<String, Map<String, String>> _roleDescriptions = {
    'pt': {
      'VIEW_GRAPH': 'Permite a visualização do gráfico na tela inicial',
      'APPROVE_MERGE_CONTENT': 'Permissão para resolver conflitos de plantas quando uma é atualizada offline e outra online.',
      'EXPORT_PDF': 'Permite exportar relatórios em PDF na Home.',
      'VIEW_PLANTS': 'Acessa a página de consulta de plantas.',
      'REGISTER_PLANTS': 'Acessa a página de registro de plantas.',
      'VIEW_CREDITS': 'Acessa a página de créditos (pública).',
      'ADD_NEW_FIELDS': 'Acessa a página de Adicionar Campo.',
      'LIST_USER': 'Permite visualizar lista de usuários e permissões.',
      'UPDATE_USER': 'Permite atualizar as permissões dos usuários.',
      'REMOVE_USER': 'Permite remover um usuário e seus papéis associados.',
      'ADD_USER': 'Permite adicionar um novo usuário.',
      'ADD_PLANT': 'Acesso macro para adicionar plantas.',
      'SEARCH_PLANT': 'Acesso macro para pesquisar plantas.',
      'DELETE_PLANT': 'Permite excluir plantas na página de consulta.',
    },
    'en': {
      'VIEW_GRAPH': 'Allows viewing the graph on the home screen.',
      'APPROVE_MERGE_CONTENT': 'Permission to resolve plant conflicts when one is updated offline and another online.',
      'EXPORT_PDF': 'Allows exporting PDF reports on Home.',
      'VIEW_PLANTS': 'Access plant consultation page.',
      'REGISTER_PLANTS': 'Access plant registration page.',
      'VIEW_CREDITS': 'Access credits page (public).',
      'ADD_NEW_FIELDS': 'Access Add Field page.',
      'LIST_USER': 'Allows viewing users and permissions.',
      'UPDATE_USER': 'Allows updating user permissions.',
      'REMOVE_USER': 'Allows removing a user and associated roles.',
      'ADD_USER': 'Allows adding a new user.',
      'ADD_PLANT': 'Macro access to add plants.',
      'SEARCH_PLANT': 'Macro access to search plants.',
      'DELETE_PLANT': 'Allows deleting plants in the consultation page.',
    },
  };
}
