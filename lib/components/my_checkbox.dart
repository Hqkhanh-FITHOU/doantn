
import 'package:flutter/material.dart';

class MyCheckbox extends StatefulWidget {
  final String text;
  final bool isChecked;
  final ValueChanged<bool> onChanged;


  MyCheckbox({super.key, required this.text,required this.isChecked, required this.onChanged,});

  @override
  _MyCheckboxState createState() => _MyCheckboxState();
}

class _MyCheckboxState extends State<MyCheckbox> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    isChecked = widget.isChecked;
  }

  void _toggleCheckbox() {
    setState(() {
      isChecked = !isChecked;
    });
    widget.onChanged(isChecked);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _toggleCheckbox,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isChecked ? Colors.orange : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isChecked ? Colors.orange : Colors.grey,
                    width: 2
                  )
                ),
                child: isChecked ? const Icon(Icons.check, color: Colors.white,size: 16,) : null,
              )
            ],
          ),
        ),
        const SizedBox(width: 8,),
        Text(widget.text)
      ],
    );
  }
}