import 'package:flutter/material.dart';
import 'package:risetechpreneur/data/models.dart';
import 'package:risetechpreneur/presentation/widgets/components.dart';

/// Home‑page section that surfaces a limited number of [BlogPost] items
/// with a "View All / Show Less" toggle.
class BlogSection extends StatefulWidget {
  final List<BlogPost> blogs;

  const BlogSection({super.key, required this.blogs});

  @override
  State<BlogSection> createState() => _BlogSectionState();
}

class _BlogSectionState extends State<BlogSection> {
  static const int _initialCount = 3;
  int _visibleCount = _initialCount;

  @override
  Widget build(BuildContext context) {
    final blogsToShow = widget.blogs.take(_visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Latest Blog News",
          subtitle:
              "Explore our blog for expert advice\n and actionable strategies.",
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: blogsToShow.map((blog) => BlogCard(blog: blog)).toList(),
          ),
        ),
        if (_visibleCount < widget.blogs.length ||
            _visibleCount > _initialCount)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_visibleCount < widget.blogs.length)
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
              if (_visibleCount < widget.blogs.length &&
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
      ],
    );
  }
}
