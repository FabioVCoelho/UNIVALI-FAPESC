import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget CustomSearchableDropDown({
  required String label,
  required TextEditingController controller,
  // Note: We now take a simple List<String> for easier filtering.
  required List<String> items,
  required String? Function(String?) validator,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white, // Assuming a dark background
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          // 1. optionsBuilder: This is where the magic happens.
          // It's called every time the user types.
          optionsBuilder: (TextEditingValue textEditingValue) {
            // If the field is empty, show no options
            if (textEditingValue.text == '') {
              return const Iterable<String>.empty();
            }
            // Filter the list based on user input
            return items.where((String option) {
              return option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
            });
          },

          // 2. onSelected: This is called when the user taps an option.
          onSelected: (String selection) {
            // Update the controller with the selected value
            controller.text = selection;
          },

          // 3. fieldViewBuilder: This builds the actual text field.
          fieldViewBuilder: (
              BuildContext context,
              TextEditingController fieldController,
              FocusNode fieldFocusNode,
              VoidCallback onFieldSubmitted,
              ) {
            // We need to sync our controller with the field's controller
            // This is a common pattern for Autocomplete
            WidgetsBinding.instance.addPostFrameCallback((_) {
              fieldController.text = controller.text;
            });

            return TextFormField(
              controller: fieldController,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Digite para buscar...',
                hintStyle: const TextStyle(color: Colors.black54),
              ),
              // Use your original validator
              validator: validator,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            );
          },

          // Optional: Customize the appearance of the dropdown options
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: SizedBox(
                  // Constrain the height of the options list
                  height: 200.0,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return ListTile(
                        title: Text(option),
                        onTap: () {
                          onSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
