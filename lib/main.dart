import 'dart:io';

import 'package:flutter/material.dart';
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
  _PrescriptionFormState createState() => _PrescriptionFormState();
}

class _PrescriptionFormState extends State<PrescriptionForm> {
  FormGroup form = FormGroup({
    'name': FormControl<String>(),
    'age': FormControl<int>(),
    'gender': FormControl<String>(value: 'Male'),
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

    const fontSize = 16.0;
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Container(
            child: pw.Column(children: [
              pw.Row(children: [
                pw.Text("Rx", style: const pw.TextStyle(fontSize: fontSize)),
                pw.Text(getFormattedDate(),
                    style: const pw.TextStyle(fontSize: fontSize)),
              ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween),
              pw.Container(
                  decoration: pw.BoxDecoration(
                      border:
                          pw.Border.all(color: PdfColor.fromHex("000000")))),
              pw.Container(
                  // decoration: pw.BoxDecoration(
                  //     // border: pw.Border.symmetric(horizontal: pw.BorderSide(color: PdfColor.fromHex("000000"))),

                  //   ),

                  child: pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(0, 8, 0, 16),
                      child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("Name: ${form.control('name').value}",
                                style: const pw.TextStyle(fontSize: fontSize)),
                            pw.Text(
                                "${form.control("gender").value} - ${form.control("age").value} years",
                                style: const pw.TextStyle(fontSize: fontSize))
                          ]))),
              for (var medicine in medicines)
                pw.Column(children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(medicine.frequency![0].details),
                            pw.Expanded(
                                child: pw.Text(
                                    "${medicine.type}. ${medicine.name}",
                                    style:
                                        const pw.TextStyle(fontSize: fontSize),
                                    softWrap: true),
                                flex: 8),
                            pw.Expanded(
                                child: pw.Text("(${medicine.quantity.toString()})",
                                textAlign: pw.TextAlign.right,
                                    style:
                                        const pw.TextStyle(fontSize: fontSize))
                                      ,
                                flex: 1)
                          ]))
                ])
            ]),
          );
        }));

    final directory = await getExternalStorageDirectory();
    final filePath = '${directory?.path}/patient_info.pdf';
    final file = File(filePath);
    final abctext = await file.writeAsBytes(await pdf.save());

    if (await Permission.manageExternalStorage.request().isGranted) {
      await OpenFile.open(filePath);
    } else {
      print("Permission denied");
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
    form.control('gender').value = 'Male';
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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gender'),
                        ReactiveDropdownField<String>(
                          formControlName: 'gender',
                          items: const [
                            DropdownMenuItem<String>(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Age'),
                        ReactiveTextField(
                          keyboardType: TextInputType.number,
                          formControlName: 'age',
                          decoration: const InputDecoration(
                            hintText: "Patient's age",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
              // if (medicine.isNotEmpty)
              IconButton(
                  onPressed: printPrescription, icon: Icon(Icons.download)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
