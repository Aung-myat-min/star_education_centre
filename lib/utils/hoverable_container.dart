import 'package:flutter/material.dart';
import 'package:star_education_centre/models/student.dart';
import 'package:star_education_centre/pages/student_detail_page.dart';

class HoverableContainer extends StatefulWidget {
  final Student student;

  const HoverableContainer({super.key, required this.student});

  @override
  _HoverableContainerState createState() => _HoverableContainerState();
}

class _HoverableContainerState extends State<HoverableContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * 0.4, // Responsive width
        ),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.white38 : Colors.white60,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 4,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    StudentDetailPage(student: widget.student),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 20,
                child: Icon(Icons.person, size: 30, color: Colors.white),
              ),
              const SizedBox(height: 10),
              FittedBox(
                child: Text(
                  '${widget.student.firstName} ${widget.student.lastName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.student.phone,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 14,
                child: _isHovered
                    ? const Text(
                        "Tap to view details",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                        ),
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
