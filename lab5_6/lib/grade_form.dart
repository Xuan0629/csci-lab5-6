import 'package:flutter/material.dart';
import 'grade.dart';
import 'main.dart'; // Import the Grade class

class GradeForm extends StatefulWidget {
  final Grade? grade; // If you're editing a grade, this is the grade to edit. Otherwise, it's null.

  const GradeForm({Key? key, this.grade}) : super(key: key); // Fixed constructor call

  @override
  _GradeFormState createState() => _GradeFormState();
}

class _GradeFormState extends State<GradeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _sidController;
  late TextEditingController _gradeController;

  @override
  void initState() {
    super.initState();
    _sidController = TextEditingController(text: widget.grade?.sid);
    _gradeController = TextEditingController(text: widget.grade?.grade);
  }

  void _saveGrade() {
    if (_formKey.currentState!.validate()) {
      Grade newOrEditedGrade;

      if (widget.grade == null) {
        // We are adding a new grade, not editing an existing one
        newOrEditedGrade = Grade(
          sid: _sidController.text,
          grade: _gradeController.text,
          id: UniqueIdGenerator.nextId, // Using the unique ID generator
        );
      } else {
        // We are editing an existing grade, so we use the existing grade's ID
        newOrEditedGrade = Grade(
          sid: _sidController.text,
          grade: _gradeController.text,
          id: widget.grade!.id,
        );
      }

      Navigator.pop(context, newOrEditedGrade); // Pops the current route off the navigator and returns the new or edited grade
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.grade == null ? 'Add Grade' : 'Edit Grade'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _sidController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a student ID';
                } else if (!RegExp(r'^[0-9]{9}$').hasMatch(value)) { // Checking if the input is exactly 9 digits
                  return 'Please enter a valid 9-digit student ID';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _gradeController,
              decoration: const InputDecoration(
                labelText: 'Grade',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the grade';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: _saveGrade,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _sidController.dispose();
    _gradeController.dispose();
    super.dispose();
  }
}
