import 'package:flutter/material.dart';

class LabeledDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selectedValue;
  final Function(String?) onChanged;

  const LabeledDropdown({
    Key? key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.selectedValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label displayed outside the dropdown
          SizedBox(
            width: 100, // Adjust width to align the label
            child: Text(
              label, // Label stays outside
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 20), // Space between label and dropdown

          // Dropdown field with selected value displayed inside
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 1.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedValue, // The selected value is shown here
                  icon: const Icon(Icons.arrow_drop_down),
                  isExpanded: true,
                  items: options.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged, // Calls the provided onChanged function
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}