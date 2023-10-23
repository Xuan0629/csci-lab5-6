import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'grade.dart'; // Import the Grade class
import 'grade_form.dart'; // We will create this next
// import your database helper class
import 'grades_model.dart';

class ListGrades extends StatefulWidget {
  final String title;

  const ListGrades({Key? key, required this.title}) : super(key: key);
  @override
  _ListGradesState createState() => _ListGradesState();
}

class _ListGradesState extends State<ListGrades> {
  List<Grade> testGrades = []; // Placeholder for grade list
  int? _selectedIndex;

  // Placeholder data for grades
  // final List<Grade> _gradesList = [
  //   // Adding some sample grades
  //   Grade(id: 1, sid: '100000001', grade: 'A'),
  //   Grade(id: 2, sid: '100000002', grade: 'B'),
  //   Grade(id: 3, sid: '100000003', grade: 'C'),
  //   // Add more samples as needed
  // ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // remembering the selection
    });
  }
  // Fetch grades from the database
  void _getGrades() async {
    var fetchedGrades = await GradesModel.instance.getAllGrades();
    if (kDebugMode) {
      print("Fetched grades: $fetchedGrades");
    }  // <-- Add this line for debugging
    setState(() {
      testGrades = fetchedGrades;
    });
  }


  @override
  void initState() {
    super.initState();
    _getGrades(); // Fetch the grades when the widget is initialized.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Triggering data fetch when the dependencies of this State object change.
    // This is called immediately after initState, and also when the widget is rebuilt with different dependencies.
    _getGrades();
  }

  // Navigate to GradeForm and wait for a result to add a grade
  void _addGrade() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GradeForm()),
    ).then((newGrade) {
      if (newGrade != null && newGrade is Grade) {
        GradesModel.instance.insertGrade(newGrade).then((_) {
          // Fetch the grades again from the database after a new grade is added.
          // This ensures the list on the homepage is updated and displays the newly added item.
          _getGrades();
        });
      }
    });
  }

  // Modify the selected grade
  void _editGrade() async {
    if (_selectedIndex != null) {
      // Get the selected grade
      var selectedGrade = testGrades[_selectedIndex!];
      if (kDebugMode) {
        print('Editing grade: $selectedGrade');
      }  // Debug: print the selected grade

      // Navigate to the GradeForm page and wait for the edited grade
      var editedGrade = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GradeForm(grade: selectedGrade)), // Send the selected grade for editing
      );
      if (kDebugMode) {
        print('Received edited grade: $editedGrade');
      }  // Debug: print the edited grade

      if (editedGrade != null) {
        setState(() {
          testGrades[_selectedIndex!] = editedGrade as Grade; // Cast the editedGrade to a Grade object and update the list
        });
        await GradesModel.instance.updateGrade(editedGrade); // Update the grade in the database
        _getGrades(); // Refresh the list after editing
      }
    }
  }



  // Delete the selected grade
  void _deleteGrade() async {
    if (_selectedIndex != null) {
      // Get the id of the grade to remove.
      var idToRemove = testGrades[_selectedIndex!].id;

      // Perform the deletion from the database. This is an async operation.
      await GradesModel.instance.deleteGradeById(idToRemove);

      // Now, call _getGrades to refresh the list from the database.
      _getGrades();

      // After the async operation is done and the list is updated, then call setState
      setState(() {
        // Reset the selected index to null since we've deleted the item.
        _selectedIndex = null;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editGrade,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteGrade,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: testGrades.length, // Use testGrades list here
        itemBuilder: (context, index) {
          var grade = testGrades[index]; // Get grade from testGrades
          return GestureDetector(
            onTap: () => _onItemTapped(index),
            child: Container(
              decoration: BoxDecoration(
                color: _selectedIndex == index ? Colors.blue[100] : null,
              ),
              child: ListTile(
                title: Text(grade.sid),
                subtitle: Text(grade.grade),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGrade,
        tooltip: 'Add Grade',
        child: const Icon(Icons.add),
      ),
    );
  }
}
