import 'package:flutter/material.dart';
import 'package:risetechpreneur/data/models.dart';
import 'package:risetechpreneur/presentation/widgets/components.dart';

/// Home‑page section that highlights a curated list of popular courses
/// with lazy "View All / Show Less" pagination.
class PopularCoursesSection extends StatefulWidget {
  final List<Course> courses;

  const PopularCoursesSection({super.key, required this.courses});

  @override
  State<PopularCoursesSection> createState() => _PopularCoursesSectionState();
}

class _PopularCoursesSectionState extends State<PopularCoursesSection> {
  int _visibleCount = 3;

  @override
  Widget build(BuildContext context) {
    final coursesToShow = widget.courses.take(_visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Popular Courses",
          subtitle:
              "Explore our diverse range of tech courses\ndesigned to equip you with the skills and knowledge",
        ),

        ListView.builder(
          padding: const EdgeInsets.only(left: 24, right: 8),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: coursesToShow.length,
          itemBuilder:
              (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CourseCard(course: coursesToShow[index]),
              ),
        ),

        if (_visibleCount < widget.courses.length || _visibleCount > 3)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_visibleCount < widget.courses.length)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _visibleCount += 3;
                    });
                  },
                  child: const Text(
                    "View All",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              if (_visibleCount < widget.courses.length && _visibleCount > 3)
                const SizedBox(width: 16),
              if (_visibleCount > 3)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _visibleCount = 3;
                    });
                  },
                  child: const Text(
                    "Show Less",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
