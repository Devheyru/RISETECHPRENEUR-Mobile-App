import 'package:flutter/material.dart';
import 'package:risetechpreneur/data/models.dart';
import 'package:risetechpreneur/presentation/widgets/components.dart';

/// Home‑page section that shows a subset of categories in a grid with
/// "View All / Show Less" controls.
class CategorySection extends StatefulWidget {
  final List<Category> categories;

  const CategorySection({super.key, required this.categories});

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  static const int _initialCount = 6;
  int _visibleCount = _initialCount; // Show 6 categories initially (3 rows)

  @override
  Widget build(BuildContext context) {
    final categoriesToShow = widget.categories.take(_visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Course Categories",
          subtitle:
              "Every category is a step toward becoming a\nsuccessful techpreneur.",
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categoriesToShow.length,
            itemBuilder:
                (context, index) =>
                    CategoryItem(category: categoriesToShow[index]),
          ),
        ),
        if (_visibleCount < widget.categories.length ||
            _visibleCount > _initialCount)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_visibleCount < widget.categories.length)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _visibleCount += 4; // Load 4 more
                      });
                    },
                    child: const Text(
                      "View All",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                if (_visibleCount < widget.categories.length &&
                    _visibleCount > _initialCount)
                  const SizedBox(width: 16),
                if (_visibleCount > _initialCount)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _visibleCount = _initialCount;
                      });
                    },
                    child: const Text(
                      "Show Less",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
