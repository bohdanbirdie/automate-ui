import 'dart:convert';

class _AutomationZone {
  final bool onEnter;
  final bool onLeave;
  final String zoneId;
  _AutomationZone({
    this.onEnter,
    this.onLeave,
    this.zoneId,
  });

  _AutomationZone copyWith({
    bool onEnter,
    bool onLeave,
    String zoneId,
  }) {
    return _AutomationZone(
      onEnter: onEnter ?? this.onEnter,
      onLeave: onLeave ?? this.onLeave,
      zoneId: zoneId ?? this.zoneId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'onEnter': onEnter,
      'onLeave': onLeave,
      'zoneId': zoneId,
    };
  }

  static _AutomationZone fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return _AutomationZone(
      onEnter: map['onEnter'],
      onLeave: map['onLeave'],
      zoneId: map['zoneId'],
    );
  }

  String toJson() => json.encode(toMap());

  static _AutomationZone fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() =>
      '_AutomationZone onEnter: $onEnter, onLeave: $onLeave, zoneId: $zoneId';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is _AutomationZone &&
        o.onEnter == onEnter &&
        o.onLeave == onLeave &&
        o.zoneId == zoneId;
  }

  @override
  int get hashCode => onEnter.hashCode ^ onLeave.hashCode ^ zoneId.hashCode;
}

class _AutomationEvent {
  final int order;
  final String eventId;
  _AutomationEvent({
    this.order,
    this.eventId,
  });

  _AutomationEvent copyWith({
    int order,
    String eventId,
  }) {
    return _AutomationEvent(
      order: order ?? this.order,
      eventId: eventId ?? this.eventId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order': order,
      'eventId': eventId,
    };
  }

  static _AutomationEvent fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return _AutomationEvent(
      order: int.tryParse(map['order']),
      eventId: map['eventId'],
    );
  }

  String toJson() => json.encode(toMap());

  static _AutomationEvent fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() => '_AutomationEvent order: $order, eventId: $eventId';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is _AutomationEvent && o.order == order && o.eventId == eventId;
  }

  @override
  int get hashCode => order.hashCode ^ eventId.hashCode;
}

class Automation {
  final String id;
  final String created_at;
  final String updated_at;
  final String name;
  final String description;
  final List<_AutomationEvent> automationEvents;
  final List<_AutomationZone> automationZones;

  Automation({
    this.id,
    this.created_at,
    this.updated_at,
    this.name,
    this.description,
    this.automationEvents,
    this.automationZones,
  });

  Automation copyWith({
    String id,
    String created_at,
    String updated_at,
    String name,
    String description,
    List<_AutomationEvent> automationEvents,
    List<_AutomationZone> automationZones,
  }) {
    return Automation(
      id: id ?? this.id,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      name: name ?? this.name,
      description: description ?? this.description,
      automationEvents: automationEvents ?? this.automationEvents,
      automationZones: automationZones ?? this.automationZones,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': created_at,
      'updated_at': updated_at,
      'name': name,
      'description': description,
      'automationEvents':
          List<dynamic>.from(automationEvents.map((x) => x.toMap())),
      'automationZones':
          List<dynamic>.from(automationZones.map((x) => x.toMap())),
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
      automationEvents: List<_AutomationEvent>.from(
          map['automationEvents']?.map((x) => _AutomationEvent.fromMap(x))),
      automationZones: List<_AutomationZone>.from(
          map['automationZones']?.map((x) => _AutomationZone.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  static Automation fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Automation id: $id, created_at: $created_at, updated_at: $updated_at, name: $name, description: $description, automationEvents: $automationEvents, automationZones: $automationZones';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Automation &&
        o.id == id &&
        o.created_at == created_at &&
        o.updated_at == updated_at &&
        o.name == name &&
        o.description == description &&
        o.automationEvents == automationEvents &&
        o.automationZones == automationZones;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        created_at.hashCode ^
        updated_at.hashCode ^
        name.hashCode ^
        description.hashCode ^
        automationEvents.hashCode ^
        automationZones.hashCode;
  }
}
