import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class MultiselectDropdown extends StatefulWidget {
  const MultiselectDropdown({super.key});

  @override
  State<MultiselectDropdown> createState() => _MultiselectDropdownState();
}

class _MultiselectDropdownState extends State<MultiselectDropdown> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormBuilderState>();
    List<String> _selectedOptions = [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Multi Select Dropdown'),
        centerTitle: true,
      ),
      body: FormBuilder(
        key: _formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // Multi-Options Selections
              FormBuilderFilterChip(
                name: 'multi_select_Options',
                decoration: InputDecoration(
                  labelText: 'Select multiple options',
                ),
                options: [
                  FormBuilderChipOption(value: 'Select 1'),
                  FormBuilderChipOption(value: 'Select 2'),
                  FormBuilderChipOption(value: 'Select 3'),
                ],
                initialValue: [],
                padding: EdgeInsets.all(2),
                labelStyle: TextStyle(color: Colors.black),
                spacing: 15,
                selectedColor: Colors.green,
                selectedShadowColor: Colors.white,
                showCheckmark: true,
                backgroundColor: Colors.grey[400],
                alignment: WrapAlignment.start,
                checkmarkColor: Colors.blue,
                disabledColor: Colors.grey,
                enabled: true,
                onChanged: (value) {
                  debugPrint('Selected values: $value');
                },
              ),

              // Multi-CheckBox
              FormBuilderCheckboxGroup<String>(
                name: 'multi_select_checkBox',
                decoration: InputDecoration(
                  labelText: 'Select multiple checkbox options',
                  counterText: 'Select any 1',
                  counterStyle: TextStyle(color: Colors.red),
                  errorStyle: TextStyle(color: Colors.redAccent),
                  suffixText: 'Choose any 1',
                ),
                options: [
                  FormBuilderFieldOption(value: '1', child: Text('Option A',style: TextStyle(color: Colors.black),),),
                  FormBuilderFieldOption(value: '2', child: Text('Option B',style: TextStyle(color: Colors.black),),),
                  FormBuilderFieldOption(value: '3', child: Text('Option C',style: TextStyle(color: Colors.black),),),
                ],
                initialValue: [],
                enabled: true,
                wrapSpacing: 15,
                checkColor: Colors.white,
                activeColor: Colors.deepOrange,
                onChanged: (value) {
                  debugPrint('Selected values: $value');
                },
              ),

              // Multi-Option-Selected Dropdown

            ],
          ),
        ),
      ),
    );
  }
}
