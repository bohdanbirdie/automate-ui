import 'dart:convert';

class Event {
  final String id;
  final String created_at;
  final String updated_at;
  final String name;

  Event({
    this.id,
    this.created_at,
    this.updated_at,
    this.name,
  });

  Event copyWith({
    String id,
    String created_at,
    String updated_at,
    String name,
  }) {
    return Event(
      id: id ?? this.id,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': created_at,
      'updated_at': updated_at,
      'name': name,
    };
  }

  static Event fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return Event(
      id: map['id'],
      created_at: map['created_at'],
      updated_at: map['updated_at'],
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  static Event fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Event id: $id, created_at: $created_at, updated_at: $updated_at, name: $name';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
  
    return o is Event &&
      o.id == id &&
      o.created_at == created_at &&
      o.updated_at == updated_at &&
      o.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      created_at.hashCode ^
      updated_at.hashCode ^
      name.hashCode;
  }
}