class User {
  final int id;
  final String email;
  final String name;
  final double balance;
  final String? profilePic;
  final String? referralCode;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.balance,
    this.profilePic,
    this.referralCode,
    this.role = 'user',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      email: json['email'] ?? '',
      name: json['name'] ?? 'User',
      balance: double.parse((json['balance'] ?? 0).toString()),
      profilePic: json['profile_pic'],
      referralCode: json['referral_code'],
      role: json['role'] ?? 'user',
    );
  }
}

class Product {
  final int id;
  final String name;
  final String category;
  final String? description;
  final double price;
  final double? originalPrice;
  final String? image;
  final String? countries;
  final List<Map<String, dynamic>> colors;

  Product({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    required this.price,
    this.originalPrice,
    this.image,
    this.countries,
    this.colors = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'],
      price: double.parse((json['price'] ?? 0).toString()),
      originalPrice: json['original_price'] != null
          ? double.parse(json['original_price'].toString())
          : null,
      image: json['image'],
      countries: json['countries'],
      colors: (json['colors'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
    );
  }
}

class ProxyProduct {
  final int id;
  final String name;
  final String? description;
  final String category;
  final double price;
  final double? originalPrice;
  final String? duration;
  final String? features;

  ProxyProduct({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.price,
    this.originalPrice,
    this.duration,
    this.features,
  });

  factory ProxyProduct.fromJson(Map<String, dynamic> json) {
    return ProxyProduct(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'General',
      price: double.parse((json['price'] ?? 0).toString()),
      originalPrice: json['original_price'] != null
          ? double.parse(json['original_price'].toString())
          : null,
      duration: json['duration'],
      features: json['features'],
    );
  }
}

class Order {
  final int id;
  final String? orderNumber;
  final String? productName;
  final String category;
  final double price;
  final String status;
  final String? proxyCode;
  final String? createdAt;
  final String? fulfilledAt;

  Order({
    required this.id,
    this.orderNumber,
    this.productName,
    this.category = '',
    required this.price,
    required this.status,
    this.proxyCode,
    this.createdAt,
    this.fulfilledAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: int.parse(json['id'].toString()),
      orderNumber: json['order_number'],
      productName: json['product_name'] ?? json['name'],
      category: json['category'] ?? '',
      price: double.parse((json['price'] ?? json['total'] ?? 0).toString()),
      status: json['status'] ?? 'pending',
      proxyCode: json['proxy_code'],
      createdAt: json['created_at'],
      fulfilledAt: json['fulfilled_at'],
    );
  }
}

class Transaction {
  final int id;
  final String type;
  final double amount;
  final String? reference;
  final String? createdAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    this.reference,
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: int.parse(json['id'].toString()),
      type: json['type'] ?? '',
      amount: double.parse((json['amount'] ?? 0).toString()),
      reference: json['reference'],
      createdAt: json['created_at'],
    );
  }
}

class SmsService {
  final int id;
  final String service;
  final double price;
  final String countryName;
  final String? flag;
  final String? logo;

  SmsService({
    required this.id,
    required this.service,
    required this.price,
    required this.countryName,
    this.flag,
    this.logo,
  });

  factory SmsService.fromJson(Map<String, dynamic> json) {
    return SmsService(
      id: int.parse(json['id'].toString()),
      service: json['service'] ?? '',
      price: double.parse((json['price'] ?? 0).toString()),
      countryName: json['country_name'] ?? '',
      flag: json['flag'],
      logo: json['logo'],
    );
  }
}

class Notification {
  final int id;
  final String title;
  final String message;
  final String type;
  final String? link;
  final bool isRead;
  final String? createdAt;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.link,
    required this.isRead,
    this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      link: json['link'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'],
    );
  }
}
