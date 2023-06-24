import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rx_prescription/types/medicine.dart';

class MedicineInput extends StatefulWidget {
  const MedicineInput({super.key, this.medicineData});

  final Medicine? medicineData;

  @override
  State<MedicineInput> createState() => _MedicineInputState();
}

class _MedicineInputState extends State<MedicineInput> {
  final FormGroup form = FormGroup({
    'type':
        FormControl<String>(validators: [Validators.required], value: 'Tab'),
    'name': FormControl<String>(validators: [Validators.required]),
    // 'duration': FormControl<int>(validators: [Validators.required]),
    'quantity': FormControl<int>(validators: [Validators.required]),
    'frequency': FormArray([])
  });

  Medicine? medicineData;

  @override
  void initState() {
    super.initState();
    medicineData = widget.medicineData;
    if (medicineData != null) {
      form.patchValue({
        'type': medicineData!.type,
        'name': medicineData!.name,
        // 'duration': medicineData!.duration,
        'quantity': medicineData!.quantity
      });

      final frequencyControl = form.control('frequency') as FormArray;
      for (var frequencyData in medicineData!.frequency ?? []) {
        final frequencyGroup = FormGroup({
          'details': FormControl<String>(value: frequencyData.details),
          'quantity': FormControl<int>(value: frequencyData.quantity),
        });
        frequencyControl.add(frequencyGroup);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ReactiveForm(
        formGroup: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Type'),
                      ReactiveDropdownField<String>(
                        formControlName: 'type',
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'Tab',
                            child: Text('Tab'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Cap',
                            child: Text('Cap'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Name of Medicine'),
                      ReactiveTextField(
                        formControlName: 'name',
                        decoration: const InputDecoration(
                          hintText: 'Enter name of medicine',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Quantity'),
                      ReactiveTextField(
                        keyboardType: TextInputType.number,
                        formControlName: 'quantity',
                        decoration: const InputDecoration(
                          hintText: 'Total medicines',
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(width: 16.0),
                // Expanded(
                //     child: Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     const Text('Duration (in days)'),
                //     ReactiveTextField(
                //       formControlName: 'duration',
                //       keyboardType: TextInputType.number,
                //       decoration: const InputDecoration(
                //         hintText: 'Enter days',
                //       ),
                //     ),
                //   ],
                // ))
              ],
            ),
            const SizedBox(height: 16.0),
            ListView.builder(
                shrinkWrap: true,
                itemCount: form.control('frequency').value.length,
                itemBuilder: (context, index) {
                  final frequencyControl =
                      form.control('frequency.$index') as FormGroup;
                  final detailsControl =
                      frequencyControl.control('details') as FormControl;
                  final quantityControl =
                      frequencyControl.control('quantity') as FormControl;
                  final dosageNames = [
                    'Sakali', //'सकाळी नाष्टा नंतर',
                    'Ratri', //'रात्री',
                    // 'सकाळी',
                    'Sandhyakali' // ,'संध्याकाळी जेवणानंतर'
                  ];
                  List<DropdownMenuItem<dynamic>> dosageDropdown = [];
                  for (var dosage in dosageNames) {
                    dosageDropdown.add(DropdownMenuItem<String>(
                      value: dosage,
                      child: Text(dosage),
                    ));
                  }
                  return Card(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              flex: 6,
                              child: Autocomplete<String>(
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text == '') {
                                    return dosageNames;
                                  }
                                  detailsControl.value = textEditingValue.text;
                                  return dosageNames.where((String option) {
                                    return option.toLowerCase().contains(
                                        textEditingValue.text.toLowerCase());
                                  });
                                },
                                onSelected: (String selection) {
                                  detailsControl.value = selection;
                                },
                              )),
                          const SizedBox(width: 16.0),
                          Expanded(
                              flex: 3,
                              child: ReactiveTextField(
                                  formControl: quantityControl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Quantity',
                                  ))),
                          IconButton(
                            onPressed: () {
                              final formArray =
                                  form.control('frequency') as FormArray;
                              formArray.removeAt(index);
                              setState(() {});
                            },
                            icon: const Icon(Icons.cancel),
                          ),
                        ]),
                  ));
                }),
            ElevatedButton(
                onPressed: () {
                  final formArray = form.control('frequency') as FormArray;
                  formArray.add(FormGroup({
                    'details': FormControl<String>(),
                    'quantity': FormControl<int>(),
                  }));
                  setState(() {});
                },
                child: Text(form.control('frequency').value.length > 0
                    ? 'Add more'
                    : 'Add Dosage Information')),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (form.valid) {
                      final List<Frequency> frequencyValue = [];
                      for (var val in form.control("frequency").value) {
                        final Frequency listItem = Frequency(
                            details: val['details'],
                            quantity: val['quantity'] ?? 0);
                        frequencyValue.add(listItem);
                      }

                      Medicine medicine = Medicine(
                          form.control("type").value,
                          form.control("name").value,
                          // form.control("duration").value ?? 0,
                          form.control("quantity").value ?? 0,
                          frequencyValue);
                      Navigator.of(context).pop(medicine);
                    } else {
                      print("else called");
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDosageFormGroup(FormArray formArray, int index) {
  final dosageFormGroup = formArray.control(index.toString()) as FormGroup;
  return Row(
    children: [
      Expanded(
        child: ReactiveTextField(
          formControlName: 'name',
          decoration: const InputDecoration(labelText: 'Dosage Name'),
        ),
      ),
      const SizedBox(width: 8.0),
      Expanded(
        child: ReactiveTextField(
          formControlName: 'quantity',
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Dosage Quantity'),
        ),
      ),
      const SizedBox(width: 8.0),
      IconButton(
        icon: const Icon(Icons.remove),
        onPressed: () {
          formArray.removeAt(index);
        },
      ),
    ],
  );
}
