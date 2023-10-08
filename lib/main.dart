import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rx_prescription/component/medicine_card.dart';
import 'package:rx_prescription/component/medicine_input.dart';
import 'types/medicine.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Doctor Prescription App',
      home: PrescriptionForm(),
    );
  }
}

class PrescriptionForm extends StatefulWidget {
  const PrescriptionForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PrescriptionFormState createState() => _PrescriptionFormState();
}

class _PrescriptionFormState extends State<PrescriptionForm> {
  FormGroup form = FormGroup({
    'name': FormControl<String>(),
    // 'age': FormControl<int>(),
    // 'gender': FormControl<String>(value: 'Male'),
  });

  List<Medicine> medicines = [];

  void addToForm(Medicine medicineData) {
    List<Medicine> data = medicines;
    data.add(medicineData);
    setState(() {
      medicines = data;
    });
  }

  String getFormattedDate() {
    DateTime now = DateTime.now();
    String day = now.day.toString().padLeft(2, '0');
    String month = now.month.toString().padLeft(2, '0');
    String year = now.year.toString();
    String formattedDate = '$day/$month/$year';
    return formattedDate;
  }

  void printPrescription() async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    const fontSize = 13.0;
    const fontColor = "000000";
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);

    final header = pw.MemoryImage(
      (await rootBundle.load('assets/images/header_2.png'))
          .buffer
          .asUint8List(),
    );

    final rxIcon = pw.MemoryImage(
        (await rootBundle.load('assets/images/rxIcon.png'))
            .buffer
            .asUint8List());

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(8),
        build: (pw.Context context) {
          return pw.Container(
            child: pw.Column(children: [
              pw.Container(
                  child: pw.Image(header),
                  padding: const pw.EdgeInsets.only(bottom: 4)),
              // Border line below header
              // pw.Container(
              //     decoration: pw.BoxDecoration(
              //         border:
              //             pw.Border.all(color: PdfColor.fromHex("000000")))),
              pw.Container(
                  child: pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                                "Patient Name: ${form.control('name').value ?? '-'}",
                                style: pw.TextStyle(
                                    fontSize: fontSize,
                                    color: PdfColor.fromHex(fontColor))),
                            pw.Text(
                              getFormattedDate(),
                              style: pw.TextStyle(
                                  fontSize: fontSize,
                                  color: PdfColor.fromHex(fontColor)),
                            )
                            // pw.Text(
                            //     "${form.control("gender").value ?? ''} ${form.control("age").value != null ? '- ${form.control("age").value} years' : ''}",
                            //     style: const pw.TextStyle(fontSize: fontSize))
                          ]))),
              // Border line below header
              pw.Container(
                  margin: const pw.EdgeInsets.fromLTRB(16, 0, 16, 0),
                  decoration: pw.BoxDecoration(
                      border:
                          pw.Border.all(color: PdfColor.fromHex("000000")))),
              pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Container(
                            child: pw.Image(rxIcon, height: 20, width: 20),
                            padding: const pw.EdgeInsets.only(top: 12)),
                      ])),
              for (var medicine in medicines)
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.fromLTRB(28, 8, 26, 4),
                          child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Expanded(
                                    child: pw.Text(
                                        "${medicine.type}. ${medicine.name}",
                                        style: pw.TextStyle(
                                            fontSize: fontSize,
                                            color: PdfColor.fromHex(fontColor)),
                                        softWrap: true),
                                    flex: 8),
                                pw.Expanded(
                                    child: pw.Text(
                                        "(${medicine.quantity.toString()})",
                                        textAlign: pw.TextAlign.right,
                                        style: pw.TextStyle(
                                            fontSize: fontSize,
                                            color:
                                                PdfColor.fromHex(fontColor))),
                                    flex: 1)
                              ])),
                      pw.Padding(
                          padding: const pw.EdgeInsets.fromLTRB(30, 0, 20, 8),
                          child: pw.Text(formatMedicineFrequency(medicine),
                              softWrap: true,
                              style: pw.TextStyle(
                                  fontSize: fontSize - 2,
                                  color: PdfColor.fromHex(fontColor)))
                          // )
                          )
                    ]),
              pw.Container(
                  // decoration: pw.BoxDecoration(color: PdfColor.fromHex("#ddd")),
                  width: 1000,
                  padding: pw.EdgeInsets.fromLTRB(
                      0,
                      (45.0 *
                          ((7 - medicines.length) > 0
                              ? 7 - medicines.length
                              : 1)),
                      20,
                      0),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("Dr. Vikram N. Jain",
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                                fontSize: fontSize,
                                color: PdfColor.fromHex(fontColor))),
                        pw.Text("Reg. 2001/07/2514",
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                                fontSize: fontSize - 4,
                                color: PdfColor.fromHex(fontColor)))
                      ]))
            ]),
          );
        }));

    final directory = await getExternalStorageDirectory();
    final filePath = '${directory?.path}/patient_info.pdf';
    final file = File(filePath);
    final abctext = await file.writeAsBytes(await pdf.save());

    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();
    final storage = statuses[Permission.storage];
    final manageExternalStorage = statuses[Permission.manageExternalStorage];

    if (storage!.isGranted || manageExternalStorage!.isGranted) {
      await OpenFile.open(filePath);
    } else {
      const snackBar = SnackBar(
        content: Text("Unable to open file, please contact developer"),
        // duration: Duration(seconds: 5),
        // action: SnackBarAction(
        //   label: 'Undo',
        //   onPressed: () {
        //     // Some code to undo the change.
        //   },
        // ),
      );
      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void updateMedicineState(Medicine medicineData, int index) {
    List<Medicine> data = medicines;
    data[index] = medicineData;
    setState(() {
      medicines = data;
    });
  }

  void deleteMedicineData(int index) {
    List<Medicine> data = medicines;
    data.removeAt(index);
    setState(() {
      medicines = data;
    });
  }

  void resetForm() {
    form.reset();
    // form.control('gender').value = 'Male';
    setState(() {
      medicines = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Prescription'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: resetForm)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: ReactiveForm(
          formGroup: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Name'),
              ReactiveTextField(
                formControlName: 'name',
                decoration: const InputDecoration(
                  hintText: "Patient's name",
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           const Text('Gender'),
              //           ReactiveDropdownField<String>(
              //             formControlName: 'gender',
              //             items: const [
              //               DropdownMenuItem<String>(
              //                 value: 'Male',
              //                 child: Text('Male'),
              //               ),
              //               DropdownMenuItem<String>(
              //                 value: 'Female',
              //                 child: Text('Female'),
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ),
              //     const SizedBox(
              //       width: 16.0,
              //     ),
              //     Expanded(
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           const Text('Age'),
              //           ReactiveTextField(
              //             keyboardType: TextInputType.number,
              //             formControlName: 'age',
              //             decoration: const InputDecoration(
              //               hintText: "Patient's age",
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: const MedicineInput()),
                  ).then((value) => addToForm(value));
                },
                icon: const Icon(
                  Icons.add,
                  size: 24.0,
                ),
                label: const Text('Add Medicine'),
              ),
              if (medicines.isNotEmpty)
                ListView.builder(
                    itemBuilder: (context, index) {
                      return MedicineCard(
                          medicine: medicines[index],
                          index: index,
                          updateMedicine: updateMedicineState,
                          deleteMedicine: deleteMedicineData);
                    },
                    shrinkWrap: true,
                    itemCount: medicines.length),
            ],
          ),
        )),
      ),
      floatingActionButton: medicines.isNotEmpty
          ? FloatingActionButton(
              onPressed: printPrescription,
              child: const Icon(Icons.print),
            )
          : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
