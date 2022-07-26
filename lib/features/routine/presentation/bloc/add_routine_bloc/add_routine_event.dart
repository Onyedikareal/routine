part of 'add_routine_bloc.dart';

abstract class AddRoutineEvent extends Equatable {
  const AddRoutineEvent();

  @override
  List<Object> get props => [];
}

class AddNewRoutineEvent extends AddRoutineEvent {
  final String title;
  final String description;
  final String routineTime;
  final bool routineExpired;
  final String routineFrequency;
  final bool completed;
  const AddNewRoutineEvent({required this.title, required this.description, required this.completed, required this.routineTime, required this.routineExpired, required this.routineFrequency});

  @override
  List<Object> get props => [title, description, routineTime, completed];
}
