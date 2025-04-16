import 'dart:convert';
// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:bartleby/components/search_content.dart';

class CarouselSlides extends StatefulWidget {
  const CarouselSlides({super.key});

  @override
  State<CarouselSlides> createState() => _CarouselSlidesState();
}

class _CarouselSlidesState extends State<CarouselSlides> {
  final CarouselController controller = CarouselController();
  List<Movie> movies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNowPlaying();
  }

  Future<void> fetchNowPlaying() async {
    final url = Uri.parse('https://api.themoviedb.org/3/movie/now_playing');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiNzZlMTU0NGZjMjA4YWJhNmRlNDU3NGRiNGU3ZTVjMiIsIm5iZiI6MTc0NDU2ODA5Mi41OTM5OTk5LCJzdWIiOiI2N2ZiZmYxY2VjMjJiYTNiNDlkOTU3ZDQiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.vfHA8VxB4l-0lI_fvOqFv9ocRRK9kkZM8J8Vi5H4vTA',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List results = jsonData['results'];
      final parsedMovies = results.map((e) => Movie.fromJson(e)).toList();

      setState(() {
        movies = parsedMovies;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (movies.isEmpty) {
      return const Center(child: Text("No movies found"));
    }

    return SizedBox(
      width: 800,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 400,
            child: Carousel(
              alignment: CarouselAlignment.center,
              controller: controller,
              itemCount: movies.length,
              itemBuilder: (context, index) {
                return SearchContent(index: index, movie: movies[index]);
              },
              transition: CarouselTransition.sliding(gap: 20),
              duration: const Duration(hours: 1),
              autoplayReverse: false,
              draggable: true,
              autoplaySpeed: const Duration(hours: 1),
            ),
          ),
          const Gap(8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CarouselDotIndicator(itemCount: movies.length, controller: controller),
              const Spacer(),
              OutlineButton(
                shape: ButtonShape.circle,
                onPressed: () {
                  controller.animatePrevious(const Duration(milliseconds: 500));
                },
                child: const Icon(Icons.arrow_back),
              ),
              const Gap(8),
              OutlineButton(
                shape: ButtonShape.circle,
                onPressed: () {
                  controller.animateNext(const Duration(milliseconds: 500));
                },
                child: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
