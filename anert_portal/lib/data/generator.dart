import 'package:anert_portal/data/field_names.dart';
import 'package:firebase/firebase.dart';
import 'package:excel/excel.dart';

Future<List<int>?> generator(String dataset) async {
  // Queries data
  final db = database();
  final ref = db.ref(dataset);
  final data = (await ref.once('value')).snapshot;

  // Prepares .xlsl
  final excel = Excel.createExcel();
  final sheet = excel['Sheet1'];
  final dataScheme = dataset == "EvSite" ? evData : inspectionData;

  // Writes Data
  sheet.appendRow(dataScheme.values.toList());
  data.forEach((rowData) {
    List row;
    if (rowData.child("suitable").val() == "no") {
      row = [
        rowData.child("uid").val(),
        rowData.child("building_name").val(),
        "No"
      ];
    } else {
      row = [];
      for (var element in dataScheme.keys) {
        row.add(rowData.child(element).val());
      }
    }
    List replaced = [];
    for (var ele in row) {
      if (replacements.containsKey(ele)) {
        replaced.add(replacements[ele]);
      } else {
        replaced.add(ele);
      }
    }
    sheet.appendRow(replaced);
  });

  return excel.encode();
}
