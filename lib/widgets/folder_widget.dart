import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class FolderWidget extends StatelessWidget {
  const FolderWidget({super.key, required this.path, required this.size});
  final String path;
  final double size;
  @override
  Widget build(BuildContext context) {
    final name = p.basename(path);
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: ShapeDecoration(
            color: const Color(0xFF272727),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(33),
            ),
          ),
          child: Icon(Icons.folder),
        ),
        Positioned(
          left: size * 0.076,
          top: size * 0.135,
          child: Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.085,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 0,
            ),
          ),
        ),
      ],
    );
  }
}
