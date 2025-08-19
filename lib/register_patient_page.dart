import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPatientPage extends StatefulWidget {
  const RegisterPatientPage({super.key});

  @override
  State<RegisterPatientPage> createState() => _RegisterPatientPageState();
}

class _RegisterPatientPageState extends State<RegisterPatientPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _gender;
  bool isLoading = false;
  bool showPasswordHint = false;

  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(() {
      setState(() {
        showPasswordHint = _passwordFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Patient'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Patient Registration Form',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(_nameController, 'Full Name', Icons.person),
              _buildTextField(
                _emailController,
                'Email Address',
                Icons.email,
                inputType: TextInputType.emailAddress,
              ),
              _buildTextField(
                _phoneController,
                'Phone Number',
                Icons.phone,
                inputType: TextInputType.phone,
              ),
              _buildTextField(
                _ageController,
                'Age',
                Icons.cake,
                inputType: TextInputType.number,
              ),
              _buildGenderField(),
              _buildPasswordField(
                _passwordController,
                'Password',
                focusNode: _passwordFocusNode,
              ),
              _buildPasswordField(
                _confirmPasswordController,
                'Confirm Password',
              ),

              if (showPasswordHint) _buildPasswordRequirements(),

              const SizedBox(height: 25),
              isLoading
                  ? const CircularProgressIndicator(color: Colors.teal)
                  : ElevatedButton(
                      onPressed: _registerPatient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
  TextEditingController controller,
  String label,
  IconData icon, {
  TextInputType inputType = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15.0),
    child: TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }

        // Phone number validation
        if (label == 'Phone Number') {
          final RegExp phoneReg = RegExp(r'^03[0-9]{9}$');
          if (!phoneReg.hasMatch(value)) {
            return 'Enter a valid 11-digit number like 03XXXXXXXXX';
          }
        }

        // Age validation
        if (label == 'Age') {
          final age = int.tryParse(value);
          if (age == null || age <= 0 || age > 120) {
            return 'Enter a valid age (1–120)';
          }
        }

        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
  );
}

  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: _gender,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.transgender),
          labelText: 'Gender',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
        items: ['Male', 'Female', 'Other'].map((gender) {
          return DropdownMenuItem(value: gender, child: Text(gender));
        }).toList(),
        onChanged: (value) => setState(() => _gender = value),
        validator: (value) => value == null ? 'Please select gender' : null,
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label, {
    FocusNode? focusNode,
  }) {
    bool isPasswordField = label == 'Password';
    bool isConfirmPasswordField = label == 'Confirm Password';
    bool obscureText = isPasswordField
        ? _obscurePassword
        : _obscureConfirmPassword;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        validator: (value) {
          if (isConfirmPasswordField && value != _passwordController.text) {
            return 'Passwords do not match';
          }
          if (isPasswordField) {
            if (value == null || value.isEmpty) return 'Password is required';
            if (value.length < 8) return 'Minimum 8 characters';
            if (!RegExp(r'[A-Z]').hasMatch(value)) {
              return 'Include at least 1 uppercase letter';
            }
            if (!RegExp(r'[a-z]').hasMatch(value)) {
              return 'Include at least 1 lowercase letter';
            }
            if (!RegExp(r'[0-9]').hasMatch(value)) {
              return 'Include at least 1 number';
            }
            if (!RegExp(r'[!@#\$&*~%^()]').hasMatch(value)) {
              return 'Include at least 1 special character';
            }
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          suffixIcon: IconButton(
            icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                if (isPasswordField) {
                  _obscurePassword = !_obscurePassword;
                } else if (isConfirmPasswordField) {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                }
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Text(
          'Password must be at least 8 characters.\nInclude uppercase, lowercase, number & special character.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ),
    );
  }

  Future<void> _registerPatient() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(credential.user!.uid)
          .set({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
            'age': _ageController.text.trim(),
            'gender': _gender,
            'uid': credential.user!.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Patient registered successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      if (e.code == 'email-already-in-use') {
        message = 'Email already in use';
      } else if (e.code == 'weak-password') {
        message = 'Weak password';
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Error'),
          content: Text('Something went wrong. Please try again later.'),
          actions: [TextButton(onPressed: null, child: Text('OK'))],
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
