class Grade {
  int id; // Now non-nullable, it must be provided upon the creation of a Grade instance
  String sid; // Student ID
  String grade; // Letter grade

  // Adjust the constructor since id is now required
  Grade({required this.id, required this.sid, required this.grade});

  // Convert a Grade into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id, // id is now non-nullable
      'sid': sid,
      'grade': grade,
    };
  }

  // Extract a Grade object from a Map object
  static Grade fromMap(Map<String, dynamic> map) {
    return Grade(
      // Ensure proper type conversion, assuming the 'id' in the map is an int as expected
      id: map['id'],
      sid: map['sid'],
      grade: map['grade'],
    );
  }

  @override
  String toString() {
    // Now id is directly accessible since it's non-nullable
    return 'Grade{id: $id, sid: $sid, grade: $grade}';
  }
}
