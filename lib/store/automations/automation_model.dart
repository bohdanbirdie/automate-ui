import 'dart:convert';

class Automation {
  final String id;
  final String created_at;
  final String updated_at;
  final String name;
  final String description;

  Automation({
    this.id,
    this.created_at,
    this.updated_at,
    this.name,
    this.description,
  });

  Automation copyWith({
    String id,
    String created_at,
    String updated_at,
    String name,
    String description,
  }) {
    return Automation(
      id: id ?? this.id,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': created_at,
      'updated_at': updated_at,
      'name': name,
      'description': description,
    };
  }

  static Automation fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return Automation(
      id: map['id'],
      created_at: map['created_at'],
      updated_at: map['updated_at'],
      name: map['name'],
      description: map['description'],
    );
  }

  String toJson() => json.encode(toMap());

  static Automation fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Automation id: $id, created_at: $created_at, updated_at: $updated_at, name: $name, description: $description';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
  
    return o is Automation &&
      o.id == id &&
      o.created_at == created_at &&
      o.updated_at == updated_at &&
      o.name == name &&
      o.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      created_at.hashCode ^
      updated_at.hashCode ^
      name.hashCode ^
      description.hashCode;
  }
}