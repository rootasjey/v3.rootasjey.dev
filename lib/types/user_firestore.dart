import 'package:rootasjey/types/user_pp.dart';
import 'package:rootasjey/types/user_stats.dart';
import 'package:rootasjey/utils/date_helper.dart';
import 'urls.dart';

class UserFirestore {
  final DateTime? createdAt;
  final String email;
  final String id;
  String job;
  final String lang;
  String location;
  final String name;
  final String nameLowerCase;
  final UserPP pp;
  final String pricing;
  final String role;
  final UserStats? stats;
  String summary;
  final DateTime? updatedAt;
  Urls urls;

  UserFirestore({
    this.createdAt,
    this.email = 'anonymous@rootasjey.dev',
    required this.id,
    this.job = 'Ghosting',
    this.lang = 'en',
    this.location = 'Nowhere',
    this.name = 'Anonymous',
    this.nameLowerCase = 'anonymous',
    required this.pp,
    this.pricing = 'free',
    this.role = 'user',
    this.stats,
    this.summary = 'An anonymous user ghosting decent people.',
    this.updatedAt,
    required this.urls,
  });

  factory UserFirestore.empty() {
    return UserFirestore(
      createdAt: DateTime.now(),
      email: 'anonymous@rootasjey.dev',
      id: '',
      job: 'Ghosting',
      lang: 'en',
      location: 'Nowhere',
      name: 'Anonymous',
      nameLowerCase: 'anonymous',
      pp: UserPP.empty(),
      pricing: 'free',
      role: 'user',
      summary: 'An anonymous user ghosting decent people.',
      stats: UserStats.empty(),
      updatedAt: DateTime.now(),
      urls: Urls.empty(),
    );
  }

  factory UserFirestore.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return UserFirestore.empty();
    }

    return UserFirestore(
      createdAt: DateHelper.fromFirestore(data['createdAt']),
      email: data['email'] ?? '',
      id: data['id'] ?? '',
      job: data['job'] ?? 'Ghosting',
      lang: data['lang'] ?? 'en',
      location: data['location'] ?? 'Nowhere',
      name: data['name'] ?? 'Anonymous',
      nameLowerCase: data['nameLowerCase'] ?? 'anonymous',
      pp: UserPP.fromJSON(data['pp']),
      pricing: data['pricing'] ?? 'free',
      role: data['role'] ?? 'user',
      stats: UserStats.fromJSON(data['stats']),
      summary: data['summary'] ?? 'An anonymous user ghosting decent people.',
      updatedAt: DateHelper.fromFirestore(data['updatedAt']),
      urls: Urls.fromJSON(data['urls']),
    );
  }

  Map<String, dynamic> toJSON({bool withAllFields = false}) {
    Map<String, dynamic> data = Map();

    if (withAllFields) {
      data['email'] = email;
      data['name'] = name;
      data['nameLowerCase'] = nameLowerCase;
    }

    data['job'] = job;
    data['lang'] = lang;
    data['location'] = location;
    data['pp'] = pp.toJSON();
    data['pricing'] = pricing;
    data['role'] = role;
    data['summary'] = summary;
    data['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
    data['urls'] = urls.toJSON();

    return data;
  }
}
