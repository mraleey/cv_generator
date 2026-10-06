import 'package:pdf/widgets.dart' as pw;
void main() {
  pw.Partitions(children: [
    pw.Partition(
      flex: 1,
      child: pw.Text('test'),
    ),
    pw.Partition(
      flex: 2,
      child: pw.Text('test'),
    ),
  ]);
}
