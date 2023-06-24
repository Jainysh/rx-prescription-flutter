import 'package:flutter/material.dart';
import 'package:rx_prescription/component/medicine_input.dart';
import 'package:rx_prescription/types/medicine.dart';

class MedicineCard extends StatelessWidget {
  const MedicineCard(
      {super.key,
      required this.medicine,
      required this.index,
      required this.updateMedicine,
      required this.deleteMedicine});
  final Medicine medicine;
  final Function(Medicine, int) updateMedicine;
  final Function(int) deleteMedicine;
  final int index;

  @override
  Widget build(BuildContext context) {
    String result = '';
    for (var frequencyData in medicine.frequency ?? []) {
      result += '${frequencyData.quantity} ${frequencyData.details} |';
    }

    void updateMedicineData() {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return MedicineInput(medicineData: medicine);
        },
      ).then((value) => updateMedicine(value, index));
    }

    void deleteMedicineChild() {
      deleteMedicine(index);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 0, 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Text('${medicine.type}. ${medicine.name}')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Qty ${medicine.quantity.toString()}'),
                      const SizedBox(width: 8),
                      // Text('Duration ${medicine.duration} days'),
                    ],
                  ),
                  if (result.isNotEmpty) const SizedBox(height: 16),
                  if (result.isNotEmpty) Text(result, softWrap: true)
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                    onPressed: deleteMedicineChild,
                    icon: const Icon(Icons.close)),
                IconButton(
                    onPressed: updateMedicineData,
                    icon: const Icon(Icons.edit)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
