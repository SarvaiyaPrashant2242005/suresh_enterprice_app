class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://suresh-enterprice-app.onrender.com';
  
  // Static files
  static const String uploads = 'uploads';
  
  // Categories
  static const String categories = 'api/categories';
    
  // Products
  static const String products = 'api/products';
  
  // Customers
  static const String customers = 'api/customers';
  
  // GST Masters
  static const String gstMasters = 'api/gstMasters';
  
  // Company Profiles
  static const String companyProfiles = 'api/companyProfiles';
  
  // Invoices
  static const String invoices = 'api/invoices';
  static String invoicesByCompany(String id) => 'api/invoices/company/$id';
  static String invoicesByUser(String userId) => 'api/invoices/user/$userId';
  
  // Users
  static const String users = 'api/users';
  static const String adminLogin = 'api/users/admin-login';
  static const String userLogin = 'api/users/login';
  static const String logout = 'api/users/logout';
}