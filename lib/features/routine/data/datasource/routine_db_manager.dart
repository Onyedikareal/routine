import 'package:routine2/core/error/exceptions.dart';
import 'package:routine2/features/routine/data/model/routine_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:dartz/dartz.dart';
import 'package:routine2/features/routine/domain/entity/routine_entity.dart';

abstract class RoutineDbManager {
  Future<Routine> addRoutine(
      {required String title,
      required String description,
      required String routineTime,
      required String routineFrequency,
      required bool routineExpired,
      required bool completed});
  Future<bool> deleteRoutine({required int routineId});
  Future<bool> markRoutineDone({required int routineId, required bool marked});
  Future<bool> updateRoutine(
      {required int routineId,
      required String title,
      required bool routineExpired,
      required String description});
  Future<List<Routine>> fetchRoutines();
  Future<Routine> fetchRoutineWithID({required int routineID});
}

class RoutineDbManagerImpl implements RoutineDbManager {
  static final RoutineDbManagerImpl _dbHelper =
      RoutineDbManagerImpl._internal();
  String routineTable = "routineTable";
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colCompleted = "completed";
  String colExpired = "routineExpired";
  String colFrequency = "routineFrequency";
  String colDate = "routineTime";

  RoutineDbManagerImpl._internal();

  factory RoutineDbManagerImpl() {
    return _dbHelper;
  }

  static Database? _db;

  Future<Database> get db async {
    // _db!.execute("DROP TABLE IF EXISTS $routineTable");

    _db ??= await initializeDb();
    return _db as Database;
  }

  Future<Database> initializeDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = "${dir.path}schedule.db";

    var dbTodos = await openDatabase(path, version: 1, onCreate: _createDb);
    return dbTodos;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $routineTable($colId INTEGER PRIMARY KEY, $colTitle TEXT, "
        "$colDescription TEXT, $colCompleted INTEGER, $colDate TEXT, $colExpired TEXT, $colFrequency TEXT)");
  }

  @override
  Future<Routine> addRoutine(
      {required String title,
      required String description,
      required String routineTime,
      required String routineFrequency,
      required bool routineExpired,
      required bool completed}) async {
    Map<String, dynamic> insertValue = {
      colTitle: title,
      colDescription: description,
      colDate: routineTime.toString(),
      colFrequency: routineFrequency,
      colExpired: routineExpired.toString(),
      colCompleted: completed.toString()
    };
    
    Database db = await this.db;
    int insertID;
    try {
      insertID = await db.insert(routineTable, insertValue);
     
      Routine routine = RoutineModel(
          id: insertID,
          title: title,
          routineExpired: routineExpired,
          routineFrequency: routineFrequency,
          description: description,
          routineTime: routineTime,
          completed: completed);
      return routine;
    } catch (e) {
      throw DbException();
    }
  }

  @override
  Future<bool> deleteRoutine({required int routineId}) async {
    Database db = await this.db;
    int result;
    try {
      result =
          await db.rawDelete('DELETE FROM $routineTable WHERE $colId = $id');
      return result == 0; //result == 0 mean deleted
    } catch (e) {
      throw DbException();
    }
  }

  @override
  Future<List<Routine>> fetchRoutines() async {
    Database db = await this.db;
 
    try {
      List<Map<String, dynamic>> routineList = await db
          .rawQuery("SELECT * FROM $routineTable order by $colDate Desc");
      List<Routine> allRoutine = <Routine>[];
      for (Map<String, dynamic> routine in routineList) {
        if (DateTime.now().isAfter(DateTime.parse(routine[colDate]))) {
          Map<String, dynamic> modiefiedRoutine = {
            colTitle: routine[colTitle],
            colDescription: routine[colDescription],
            colDate: routine[colDate],
            colCompleted: routine[colCompleted] == 'true',
            colExpired: true,
            colId: routine[colId],
            colFrequency: routine[colFrequency]
          };
          allRoutine.add(RoutineModel.fromJson(modiefiedRoutine));
        }else{
          Map<String, dynamic> modiefiedRoutine = {
            colTitle: routine[colTitle],
            colDescription: routine[colDescription],
            colDate: routine[colDate],
            colCompleted: routine[colCompleted] == 'true',
            colExpired:false,
            colId: routine[colId],
            colFrequency: routine[colFrequency]
          };
          allRoutine.add(RoutineModel.fromJson(modiefiedRoutine));
        }
      }
      return allRoutine;
    } catch (e) {
      throw DbException();
    }
  }

  @override
  Future<Routine> fetchRoutineWithID({required int routineID}) async {
    Database db = await this.db;
    try {
      List<Map<String, dynamic>> routineList = await db
          .rawQuery("SELECT * FROM $routineTable WHERE $colId = $routineID");
      List<Routine> allRoutine = <Routine>[];

      for (Map<String, dynamic> routine in routineList) {
       
        Map<String, dynamic> modiefiedRoutine = {
          colTitle: routine[colTitle],
          colDescription: routine[colDescription],
          colDate: routine[colDate],
          colCompleted: routine[colCompleted] == 'true',
          colExpired: routine[colExpired] == 'true',
          colId: routine[colId],
          colFrequency: routine[colFrequency]
        };
        allRoutine.add(RoutineModel.fromJson(modiefiedRoutine));
      }
      return allRoutine[0];
    } catch (e) {
    
      throw DbException();
    }
  }

  @override
  Future<bool> markRoutineDone({required int routineId, required bool marked}) async {
    Database db = await this.db;
    Map<String, dynamic> updateValues = {
      colCompleted: marked.toString(),
    };
    try {
      await db.update(routineTable, updateValues,
          where: "$colId = ?", whereArgs: [routineId]);
      return true;
    } catch (e) {
      throw DbException();
    }
  }

  @override
  Future<bool> updateRoutine(
      {required int routineId,
      required String title,
      required bool routineExpired,
      required String description}) async {
    Database db = await this.db;
    Map<String, dynamic> updateValues = {
      colTitle: title,
      colDescription: description,
      colExpired: routineExpired
    };
    try {
      await db.update(routineTable, updateValues,
          where: "$colId = ?", whereArgs: [routineId]);
      return true;
    } catch (e) {
      throw DbException();
    }
  }
}
