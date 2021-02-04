import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataBaseTable extends StatelessWidget {
  final List<String> headers;
  final List<Map<String, dynamic>> data;
  final String table;

  const DataBaseTable({Key key, this.headers, this.data, this.table}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: DataTable(
              columns: _buildHeaders(context), rows: _buildRows(context)),
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  List<DataColumn> _buildHeaders(context) {
    return headers
        .map<DataColumn>((e) => DataColumn(label: Text('$e',style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),)))
        .toList();
  }

  List<DataRow> _buildRows(context) {
    if (data == null) {
      return [];
    }
    return data
        .map((el) => DataRow(

            cells: headers
                .map<DataCell>((e) => DataCell(Container(
                      child: Text('${el[e]}',style: TextStyle(fontWeight: e==headers.first?FontWeight.bold:null),),
                      constraints: BoxConstraints(maxWidth: 200),
                    )))
                .toList()))
        .toList();
  }
}
