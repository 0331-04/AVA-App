import 'package:flutter/material.dart';
import '../../widgets/loading_overlay.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // TODO: Pre-fill these from real user data from auth service
  final _nameController    = TextEditingController(text: 'John Doe');
  final _phoneController   = TextEditingController(text: '+94 77 123 4567');
  final _addressController = TextEditingController(text: '45/A, Galle Road, Colombo 03');
  final _vehicleController = TextEditingController(text: 'Toyota Camry 2022');
  final _plateController   = TextEditingController(text: 'ABC-1234');
  final _colourController  = TextEditingController(text: 'Pearl White');
  final _engineController  = TextEditingController(text: '2.5L Hybrid');
  final _yearController    = TextEditingController(text: '2022');
  final _chassisController = TextEditingController(text: 'JTDBF3EH7C3012345');

  @override
  void dispose() {
    for (final c in [
      _nameController, _phoneController, _addressController,
      _vehicleController, _plateController, _colourController,
      _engineController, _yearController, _chassisController,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      LoadingOverlay.show(context, message: 'Saving your profile...');
      await Future.delayed(const Duration(seconds: 2)); // TODO: replace with real API call
      if (!mounted) return;
      LoadingOverlay.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _EditHeader(),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  children: [
                    _SectionCard(
                      title: 'Personal Information',
                      icon: Icons.person_outline,
                      children: [
                        _Field(label: 'Full Name', controller: _nameController,
                            icon: Icons.badge_outlined,
                            validator: (v) => v!.isEmpty ? 'Name is required' : null),
                        _Field(label: 'Phone', controller: _phoneController,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) => v!.isEmpty ? 'Phone is required' : null),
                        _Field(label: 'Address', controller: _addressController,
                            icon: Icons.location_on_outlined, maxLines: 2),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Vehicle Details',
                      icon: Icons.directions_car_outlined,
                      children: [
                        _Field(label: 'Vehicle Model', controller: _vehicleController,
                            icon: Icons.directions_car_outlined,
                            validator: (v) => v!.isEmpty ? 'Vehicle model is required' : null),
                        _Field(label: 'License Plate', controller: _plateController,
                            icon: Icons.confirmation_number_outlined,
                            validator: (v) => v!.isEmpty ? 'License plate is required' : null),
                        _Field(label: 'Colour', controller: _colourController,
                            icon: Icons.palette_outlined),
                        _Field(label: 'Engine', controller: _engineController,
                            icon: Icons.settings_outlined),
                        _Field(label: 'Year', controller: _yearController,
                            icon: Icons.event_outlined,
                            keyboardType: TextInputType.number),
                        _Field(label: 'Chassis No.', controller: _chassisController,
                            icon: Icons.tag),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004AAD),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.save_outlined,
                            color: Colors.white, size: 18),
                        label: const Text('Save Changes',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        width: double.infinity,
        height: 175,
        color: const Color(0xFF004AAD),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('AVA-Inspec',
                        style: TextStyle(color: Colors.white, fontSize: 20,
                            fontFamily: 'WorkSans', fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Edit Profile',
                    style: TextStyle(color: Colors.white, fontSize: 30,
                        fontFamily: 'WorkSans', fontWeight: FontWeight.w700,
                        shadows: [Shadow(offset: Offset(0, 4), blurRadius: 4,
                            color: Color(0x40000000))])),
                Text('Update your personal and vehicle info',
                    style: TextStyle(color: Colors.white.withOpacity(0.75),
                        fontSize: 13, fontFamily: 'WorkSans')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 45);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(_HeaderClipper old) => false;
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: const Color(0xFF004AAD), size: 18),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(fontSize: 14, fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700, color: Colors.black87)),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;

  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12,
              color: Colors.grey.shade600),
          prefixIcon: Icon(icon, color: const Color(0xFF004AAD), size: 18),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF004AAD), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          ),
        ),
      ),
    );
  }
}
