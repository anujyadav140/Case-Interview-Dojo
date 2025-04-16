import 'dart:convert';
import 'dart:ui';
import 'package:bartleby/case_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:http/http.dart' as http;


class CaseInterview {
  final String name;
  final String source;
  final String? url;
  final String? description;

  CaseInterview({
    required this.name,
    required this.source,
    this.url,
    this.description,
  });

  factory CaseInterview.fromJson(Map<String, dynamic> json) {
    return CaseInterview(
      name: json['name'],
      source: json['source'],
      url: json['url'],
      description: json['description'],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<CaseInterview>> _casesFuture;

  @override
  void initState() {
    super.initState();
    _casesFuture = fetchCases();
  }

  Future<List<CaseInterview>> fetchCases() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/cases'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => CaseInterview.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load cases');
    }
  }

  // Show an alert dialog displaying the case description in a wider layout.
  Future<void> _showCaseDescriptionDialog(CaseInterview caseItem) async {
    final bool? shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(caseItem.name),
          content: SizedBox(
            width: 400, // Wider dialog width.
            child: SingleChildScrollView(
              child: Text(
                caseItem.description ?? 'No description available.',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          actions: [
            OutlineButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            PrimaryButton(
              child: const Text('Proceed'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldProceed == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CaseInterviewPage(caseInterview: caseItem),
        ),
      );
    }
  }

  // Show the search dialog with the Command widget.
  Future<void> _showSearchDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Case Interviews'),
          content: Command(
            builder: (context, query) async* {
              // Await the list of case interviews.
              final cases = await _casesFuture;
              // Filter the cases based on the search query.
              final filtered = cases.where((caseItem) {
                if (query == null || query.isEmpty) return true;
                return caseItem.name.toLowerCase().contains(query.toLowerCase());
              }).toList();

              // If there are results, yield a CommandCategory with the filtered items.
              if (filtered.isNotEmpty) {
                yield [
                  CommandCategory(
                    title: const Text('Case Interviews'),
                    children: filtered.map((caseItem) {
                      return CommandItem(
                        title: Text(caseItem.name),
                        trailing: Text(caseItem.source),
                        onTap: () {
                          // Close the search dialog.
                          Navigator.of(context).pop();
                          // Then show the case description alert dialog.
                          _showCaseDescriptionDialog(caseItem);
                        },
                      );
                    }).toList(),
                  ),
                ];
              } else {
                // If no matches, yield an empty list.
                yield [];
              }
            },
          ).sized(width: 300, height: 300),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      loadingProgressIndeterminate: false,
      headers: [
        AppBar(
          title: const Text('Case Interview Dojo'),
          subtitle: const Text('Practice & Perfect Case Interviews'),
          leading: [
            OutlineButton(
              onPressed: () {},
              density: ButtonDensity.icon,
              child: const Icon(Icons.menu),
            ),
          ],
          trailing: [
            // Updated search icon to trigger the search dialog.
            OutlineButton(
              onPressed: _showSearchDialog,
              density: ButtonDensity.icon,
              child: const Icon(Icons.search),
            ),
            OutlineButton(
              onPressed: () {},
              density: ButtonDensity.icon,
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const Divider(),
      ],
      child: Center(
        child: FutureBuilder<List<CaseInterview>>(
          future: _casesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final cases = snapshot.data!;
              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var caseItem in cases)
                            CardImage(
                              onPressed: () => _showCaseDescriptionDialog(caseItem),
                              image: Image.network(
                                'https://picsum.photos/200/300?random=${caseItem.name.hashCode}',
                                fit: BoxFit.cover,
                              ),
                              title: Text(caseItem.name),
                              subtitle: Text(caseItem.source),
                            ),
                        ],
                      ).gap(16),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
