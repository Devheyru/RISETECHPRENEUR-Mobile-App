import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';

// Mock Data Generators - simulating API responses
final coursesProvider = Provider<List<Course>>((ref) {
  return [
    const Course(
      id: '1',
      title: 'UI/UX Design Masterclass',
      category: 'Design',
      imageUrl:
          'https://images.unsplash.com/photo-1586717791821-3f44a5638d48?auto=format&fit=crop&w=500&q=60',
      rating: 4.8,
      duration: '10h 30m',
      price: 89.99,
    ),
    const Course(
      id: '2',
      title: 'Flutter Development Bootcamp',
      category: 'Development',
      imageUrl:
          'https://images.unsplash.com/photo-1555099962-4199c345e5dd?auto=format&fit=crop&w=500&q=60',
      rating: 4.9,
      duration: '42h 00m',
      price: 129.99,
    ),
    const Course(
      id: '3',
      title: 'Digital Marketing Zero to Hero',
      category: 'Marketing',
      imageUrl:
          'https://images.unsplash.com/photo-1557838923-2985c318be48?auto=format&fit=crop&w=500&q=60',
      rating: 4.7,
      duration: '8h 15m',
      price: 49.99,
    ),
  ];
});

final categoriesProvider = Provider<List<Category>>((ref) {
  return [
    const Category(id: '1', name: 'Design', iconAsset: '🎨', coursesCount: 120),
    const Category(id: '2', name: 'Coding', iconAsset: '💻', coursesCount: 250),
    const Category(
      id: '3',
      name: 'Marketing',
      iconAsset: '📢',
      coursesCount: 80,
    ),
    const Category(
      id: '4',
      name: 'Business',
      iconAsset: '💼',
      coursesCount: 100,
    ),
  ];
});

final testimonialsProvider = Provider<List<Testimonial>>((ref) {
  return [
    const Testimonial(
      id: '1',
      userName: 'Sarah Jenkins',
      role: 'Product Designer',
      userImage: 'https://randomuser.me/api/portraits/women/44.jpg',
      comment:
          "This platform completely changed my career path. The UI course was fantastic!",
      rating: 5.0,
    ),
    const Testimonial(
      id: '2',
      userName: 'Mike Ross',
      role: 'Flutter Dev',
      userImage: 'https://randomuser.me/api/portraits/men/32.jpg',
      comment:
          "The best investment I've made for my skills. Highly recommended.",
      rating: 4.8,
    ),
  ];
});
// Add this to the end of the file
final blogsProvider = Provider<List<BlogPost>>((ref) {
  return [
    const BlogPost(
      id: '1',
      title: 'How to master UI/UX Design in 2024',
      date: 'Nov 20, 2023 • 5 min read',
      imageUrl:
          'https://rise-techpreneur.havanacademy.com/assets/img/blog/blog-post-1.webp',
    ),
    const BlogPost(
      id: '2',
      title: 'The Future of Flutter Development',
      date: 'Nov 18, 2023 • 8 min read',
      imageUrl:
          'https://rise-techpreneur.havanacademy.com/assets/img/blog/blog-post-2.webp',
    ),
    const BlogPost(
      id: '3',
      title: 'SEO Strategies for Startups',
      date: 'Nov 15, 2023 • 4 min read',
      imageUrl:
          'https://rise-techpreneur.havanacademy.com/assets/img/blog/blog-post-3.webp',
    ),
  ];
});
