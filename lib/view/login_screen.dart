import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section

              SizedBox(height: 20),
              Text(
                'MEDREC',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Your Digital Medical Records',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),
              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      value: _selectedRole,
                      onChanged: (value) =>
                          setState(() => _selectedRole = value),
                      items: [
                        'Doctor',
                        'Patient',
                        'Admin',
                      ]
                          .map((role) => DropdownMenuItem<String>(
                                value: role.toLowerCase(),
                                child: Text(role),
                              ))
                          .toList(),
                      validator: (value) {
                        if (value == null) {
                          return "Role is required";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Login', style: TextStyle(fontSize: 18)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await _auth.signInWithEmailAndPassword(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                      // Get the user's role from Firestore
                      final userDoc = await _firestore
                          .collection('users')
                          .doc(_auth.currentUser!.uid)
                          .get();
                      final userRole = userDoc.data()?['role'];

                      // Navigate to the corresponding screen based on the user's role
                      if (userRole == 'patient') {
                        Navigator.pushReplacementNamed(context, '/home');
                      } else if (userRole == 'doctor') {
                        Navigator.pushReplacementNamed(context, '/doctor');
                      } else if (userRole == 'admin') {
                        Navigator.pushReplacementNamed(context, '/admin');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Invalid role')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid email or password')),
                      );
                    }
                  }
                },
              ),
              SizedBox(height: 10),

              SizedBox(height: 10),
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              //     backgroundColor: Colors.grey[300],
              //     foregroundColor: Colors.blue[700],
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              //   child: Text('Sign up', style: TextStyle(fontSize: 18)),
              //   onPressed: () {
              //     // Navigate to signup screen
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => SignupScreen()),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: validator,
    );
  }
}
