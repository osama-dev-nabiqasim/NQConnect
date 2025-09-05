class DummyDB {
  // Dummy users with roles + departments
  static final users = [
    // --- HR Department ---
    {
      "employeeId": "emp_hr_1",
      "password": "12345",
      "role": "employee",
      "name": "Ali",
      "department": "HR",
    },
    {
      "employeeId": "emp_hr_2",
      "password": "12345",
      "role": "employee",
      "name": "Sara",
      "department": "HR",
    },
    {
      "employeeId": "mgr_hr",
      "password": "12345",
      "role": "manager",
      "name": "Taha",
      "department": "HR",
    },

    // --- Finance Department ---
    {
      "employeeId": "emp_fin_1",
      "password": "12345",
      "role": "employee",
      "name": "Bilal",
      "department": "Finance",
    },
    {
      "employeeId": "emp_fin_2",
      "password": "12345",
      "role": "employee",
      "name": "Ayesha",
      "department": "Finance",
    },
    {
      "employeeId": "mgr_fin",
      "password": "12345",
      "role": "manager",
      "name": "Hassan",
      "department": "Finance",
    },

    // --- IT Department ---
    {
      "employeeId": "emp_it_1",
      "password": "12345",
      "role": "employee",
      "name": "Zain",
      "department": "IT",
    },
    {
      "employeeId": "emp_it_2",
      "password": "12345",
      "role": "employee",
      "name": "Hina",
      "department": "IT",
    },
    {
      "employeeId": "mgr_it",
      "password": "12345",
      "role": "manager",
      "name": "Omar",
      "department": "IT",
    },

    // --- Admin (All Departments Access) ---
    {
      "employeeId": "admin",
      "password": "12345",
      "role": "admin",
      "name": "Admin Qasim",
      "department": "All",
    },
  ];
}
