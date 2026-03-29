import 'package:flutter/material.dart';
import '../models/category.dart';
import '../utils/constants.dart';

class CategoryPicker extends StatelessWidget {
  final Category selectedCategory;
  final ValueChanged<Category> onSelected;
  // ↑ ValueChanged<T> = a function that takes T and returns void
  //   Like (category: Category) => void in TypeScript

  const CategoryPicker({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // ↑ Horizontal scroll like Instagram stories
        itemCount: Category.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = Category.values[index];
          final isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () => onSelected(category),
            child: AnimatedContainer(
              // ↑ AnimatedContainer smoothly transitions
              //   between selected/unselected states
              duration: const Duration(milliseconds: 200),
              width: 64,
              decoration: BoxDecoration(
                color: isSelected
                    ? category.color
                    : category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(
                  color: isSelected ? category.color : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category.icon,
                    color: isSelected ? Colors.white : category.color,
                    size: AppSizes.iconM,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.label,
                    style: TextStyle(
                      fontSize: 9,
                      color: isSelected ? Colors.white : category.color,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
