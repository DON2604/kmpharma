import 'package:flutter/material.dart';

class CategoryFilterWidget extends StatelessWidget {
  final List<String> categories;
  final int selectedCategory;
  final Function(int) onCategorySelected;

  const CategoryFilterWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < categories.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text(categories[i]),
                selected: selectedCategory == i,
                selectedColor: Colors.blue.shade600,
                backgroundColor: Colors.grey.shade200,
                labelStyle: TextStyle(
                  color: selectedCategory == i ? Colors.white : Colors.black,
                ),
                onSelected: (bool selected) {
                  onCategorySelected(i);
                },
              ),
            ),
        ],
      ),
    );
  }
}
