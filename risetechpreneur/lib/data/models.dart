class Course {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final double rating;
  final String duration;
  final double price;

  const Course({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.duration,
    required this.price,
  });
}

class Category {
  final String id;
  final String name;
  final String iconAsset; // Or generic icon data
  final int coursesCount;

  const Category({
    required this.id,
    required this.name,
    required this.iconAsset,
    required this.coursesCount,
  });
}

class Testimonial {
  final String id;
  final String userName;
  final String role;
  final String userImage;
  final String comment;
  final double rating;

  const Testimonial({
    required this.id,
    required this.userName,
    required this.role,
    required this.userImage,
    required this.comment,
    required this.rating,
  });
}

class BlogPost {
  final String id;
  final String title;
  final String date;
  final String imageUrl;

  const BlogPost({
    required this.id,
    required this.title,
    required this.date,
    required this.imageUrl,
  });
}
