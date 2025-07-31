class ApiConfig {
  static const String _baseUrlDev = 'http://10.0.2.2:3000/api';
  static const String _baseUrlProd = 'https://your-domain.com/api';
  
  static const String _socketUrlDev = 'http://10.0.2.2:3000';
  static const String _socketUrlProd = 'https://your-domain.com';
  
  static String get baseUrl {
    return const bool.fromEnvironment('dart.vm.product') 
        ? _baseUrlProd 
        : _baseUrlDev;
  }
  
  static String get socketUrl {
    return const bool.fromEnvironment('dart.vm.product') 
        ? _socketUrlProd 
        : _socketUrlDev;
  }
}