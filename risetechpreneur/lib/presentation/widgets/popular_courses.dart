import 'package:flutter/material.dart';
import 'package:risetechpreneur/data/models.dart';
import 'package:risetechpreneur/presentation/widgets/components.dart';

class PopularCoursesSection extends StatefulWidget {
  final List<Course> courses;

  const PopularCoursesSection({super.key, required this.courses});

  @override
  State<PopularCoursesSection> createState() => _PopularCoursesSectionState();
}

class _PopularCoursesSectionState extends State<PopularCoursesSection> {
  bool showAll = false;
  static const int previewCount = 3;

  @override
  Widget build(BuildContext context) {
    final coursesToShow =
        showAll ? widget.courses : widget.courses.take(previewCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Popular Courses",
          subtitle: "Explore our highest rated content",
          onSeeAll: () {},
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

        if (widget.courses.length > previewCount)
          TextButton(
            onPressed: () {
              setState(() {
                showAll = !showAll;
              });
            },
            child: Text(
              showAll ? "Show Less" : "Show More",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
