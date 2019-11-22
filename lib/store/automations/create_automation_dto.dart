class _CreateAutomationZoneDto {
  final bool onEnter;
  final bool onLeave;
  final String zoneId;

  _CreateAutomationZoneDto({
    this.onEnter,
    this.onLeave,
    this.zoneId,
  });

  Map<String, dynamic> toMap() {
    return {
      'onEnter': onEnter,
      'onLeave': onLeave,
      'zoneId': zoneId,
    };
  }

  @override
  String toString() =>
      '_CreateAutomationZoneDto onEnter: $onEnter, onLeave: $onLeave, zoneId: $zoneId';
}

class _CreateAutomationEventDto {
  final int order;
  final String eventId;

  _CreateAutomationEventDto({
    this.order,
    this.eventId,
  });

  Map<String, dynamic> toMap() {
    return {
      'order': order,
      'eventId': eventId,
    };
  }

  @override
  String toString() =>
      '_CreateAutomationEventDto order: $order, eventId: $eventId';
}

class CreateAutomationDto {
  final String name;
  final String description;
  final List<_CreateAutomationZoneDto> zones;
  final List<_CreateAutomationEventDto> events;

  CreateAutomationDto._({
    this.name,
    this.description,
    this.zones,
    this.events,
  });

  factory CreateAutomationDto(
      {String name,
      String description,
      List<String> zonesIds,
      List<String> eventsIds,
      Map<String, dynamic> payload}) {
    return CreateAutomationDto._(
        name: name,
        description: description,
        zones: zonesIds.map((id) {
          return new _CreateAutomationZoneDto(
            zoneId: id,
            onEnter: payload[id].contains('onEnter'),
            onLeave: payload[id].contains('onLeave'),
          );
        }).toList(),
        events: eventsIds
            .asMap()
            .map((index, id) {
              return MapEntry(
                  index,
                  _CreateAutomationEventDto(
                    eventId: id,
                    order: index,
                  ));
            })
            .values
            .toList());
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'zones': List<dynamic>.from(zones.map((x) => x.toMap())),
      'events': List<dynamic>.from(events.map((x) => x.toMap())),
    };
  }

  @override
  String toString() {
    return 'CreateAutomationDto name: $name, description: $description, zones: $zones, events: $events';
  }
}
