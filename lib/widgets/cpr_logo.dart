import 'package:material_ui/material_ui.dart';

class CprLogo extends StatelessWidget {
  const CprLogo({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF67E6D1), Color(0xFF157F85)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43D6BD).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'CPR',
        style: TextStyle(
          color: const Color(0xFF071817),
          fontSize: size * 0.29,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
      ),
    );
  }
}
