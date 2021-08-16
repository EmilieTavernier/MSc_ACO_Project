import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Custom text fields definition for user input parameters
class CustomTextField extends StatelessWidget{
  CustomTextField({
    Key? key,
    required this.width,
    required this.controller,
    required this.regex,
    required this.max,
    this.min = 0,
    this.labelOut = '',
    this.labelIn = '',
    this.onChanged,
  }) : super(key: key);

  final String labelOut;
  final String labelIn;
  final double width;
  final TextEditingController controller;
  final RegExp regex;
  final double max;
  final double min;
  void Function(String)? onChanged;

  //bool _alertOpen = false;

  @override
  Widget build(BuildContext context) {
    var betweenSpace = 20.0;
    if( labelOut == '' ) betweenSpace = 0.0;

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(labelOut),
          SizedBox(width: betweenSpace),
          SizedBox(
            height: 30,
            width: width,
            child: TextFormField(
              controller: controller,
              validator: (value) { 
                // To check if input is valid.
                // return ''; (= empty error message) means it is not valid (input field will be highlighted in red)
                if (value == null || value.isEmpty) {
                  return '';
                }
                else if ( labelOut.contains('Job') ){
                  RegExp pattern = RegExp(r'^(\([0-9],[0-9]\);)*(\([0-9],[0-9]\))$');
                  // match (1,2);(4,3) ...
                  // don't match (1,2);(4,3); nor (1,2)(4,3)
                  final match = pattern.firstMatch(value);
                  final matchedText = match?.group(0);
                  if(matchedText != value){
                    return '';
                  }
                  if(matchedText != null && matchedText.split(';').length > 9){
                    return '';
                  }
                }
                else if ( value.contains(RegExp(r'^\..*')) ||        // if start with a '.'
                          value.contains(RegExp(r'.*\.$')) ||        // or ends with a '.'
                          value.contains(RegExp(r'.*\..*\..*')) ){  // or has more than 1 '.' ...
                  // return an empty error string (invalid input)
                  return '';
                }
                else if ( double.parse(value) > max ){
                  if(max >= 1)
                    controller.text = max.toInt().toString();
                  else
                    controller.text = max.toString();
                  return '';
                }
                else if ( double.parse(value) < min ){
                  controller.text = min.toString();
                  return '';
                }
                return null; // Input is valid
              },
              inputFormatters: [
                //LengthLimitingTextInputFormatter(3),
                FilteringTextInputFormatter.allow(regex),
              ],
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(10.0),
                border: OutlineInputBorder(),
                labelText: labelIn,

                errorBorder: OutlineInputBorder( // If input is not valid, field borders turn red
                  borderSide: BorderSide(color: Colors.red),
                ),
                errorStyle: TextStyle(height: 0), // No error message display (no room for this)
              ),

              onChanged: onChanged,
            ),
          ),
        ]
    );
  }
}
