import 'dart:convert';

class CreateEventDto {
  final String name;
  CreateEventDto({
    this.name,
  });

  CreateEventDto copyWith({
    String name,
  }) {
    return CreateEventDto(
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  static CreateEventDto fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return CreateEventDto(
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  static CreateEventDto fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() => 'CreateEventDto name: $name';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is CreateEventDto && o.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
