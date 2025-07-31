import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tt_connect/models/post.dart';
import 'package:tt_connect/screens/login_screen.dart';
import 'package:tt_connect/services/auth_provider.dart';
import 'package:tt_connect/widgets/post_widget.dart';

void main() {
  group('Login Screen Tests', () {
    testWidgets('Should display login form', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: LoginScreen(),
          ),
        ),
      );

      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Should show validation errors for empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: LoginScreen(),
          ),
        ),
      );

      // Tap login button without entering credentials
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });
  });

  group('Post Widget Tests', () {
    testWidgets('Should display post content correctly', (WidgetTester tester) async {
      final testPost = Post(
        postId: '1',
        content: 'Test post content',
        createdAt: DateTime.now(),
        author: PostAuthor(
          firstName: 'John',
          lastName: 'Doe',
        ),
        likesCount: 5,
        commentsCount: 2,
        isLiked: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostWidget(
              post: testPost,
              onLikeToggle: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Test post content'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });
}