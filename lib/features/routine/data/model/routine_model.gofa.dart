// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutineModel _$RoutineModelFromJson(Map<String, dynamic> json) => RoutineModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      routineTime: json['routineTime'] as String,
      routineFrequency: json['routineFrequency'] as String,
      routineExpired: json['routineExpired'] as bool,
      completed: json['completed'] as bool,
    );

Map<String, dynamic> _$RoutineModelToJson(RoutineModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'routineTime': instance.routineTime,
      'routineFrequency': instance.routineFrequency,
      'routineExpired': instance.routineExpired,
      'completed': instance.completed,
    };
