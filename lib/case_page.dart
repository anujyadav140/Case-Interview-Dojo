import 'dart:convert';
import 'package:flutter/material.dart' as material; // Aliased for Colors
import 'package:http/http.dart' as http;
import 'package:bartleby/chat.dart';
import 'package:bartleby/home.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class CaseInterviewPage extends StatefulWidget {
  final CaseInterview caseInterview;

  const CaseInterviewPage({super.key, required this.caseInterview});

  @override
  State<CaseInterviewPage> createState() => _CaseInterviewPageState();
}

class _CaseInterviewPageState extends State<CaseInterviewPage> {
  String? _initialAiMessage;
  String? _responseId;
  bool _isLoadingInitialMessage = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchInitialAiMessage();
  }

  Future<void> _fetchInitialAiMessage() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/chat/initiate_chat'), // Corrected path
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'case_id': widget.caseInterview.id}),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        setState(() {
          _initialAiMessage = decodedResponse['ai_message'];
          _responseId = decodedResponse['response_id'];
          _isLoadingInitialMessage = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load initial message. Status code: ${response.statusCode}';
          _isLoadingInitialMessage = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching initial message: $e';
        _isLoadingInitialMessage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define fixed divider width: left padding (8) + divider (1) + right padding (8)
    const dividerWidth = 17.0;

    return Scaffold(
      headers: [
        AppBar(
          title: Text(widget.caseInterview.name),
          leading: [
            OutlineButton(
              onPressed: () {
                Navigator.pop(context);
              },
              density: ButtonDensity.icon,
              child: const Icon(Icons.arrow_back),
            ),
          ],
        ),
        const Divider(),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: OutlinedContainer(
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              // Left Pane: occupies 70% of the available width
              Expanded(
                flex: 7,
                child: Document(numberOfSteps: 3), // Assuming Document is defined elsewhere
              ),
              // Divider Pane: fixed width with a vertical divider.
              Container(
                width: dividerWidth,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(width: 8),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: material.Colors.grey,
                    ),
                    material.SizedBox(width: 8),
                  ],
                ),
              ),
              // Right Pane: occupies 30% of the available width
              Expanded(
                flex: 3,
                child: Container(
                  color: material.Colors.grey[200], // Consider theming
                  child: Center(
                    child: _isLoadingInitialMessage
                        ? const material.CircularProgressIndicator() // Assuming shadcn_flutter has its own or use material explicitly
                        : _errorMessage != null
                            ? Text('Error: $_errorMessage', style: TextStyle(color: material.Colors.red))
                            : ChatPage(
                                onSpeechResult: (value) {
                                  // Handle speech result if needed
                                },
                                initialAiMessage: _initialAiMessage,
                                initialResponseId: _responseId,
                              ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A dynamic horizontal stepper widget where each step is a Quill document.
class Document extends StatefulWidget {
  /// Number of dynamic steps in the stepper.
  final int numberOfSteps;

  const Document({super.key, this.numberOfSteps = 3});

  @override
  State<Document> createState() => _DocumentState();
}

class _DocumentState extends State<Document> {
  final StepperController controller = StepperController();
  late List<QuillController> _quillControllers;

  @override
  void initState() {
    super.initState();
    // Initialize a separate QuillController for each step.
    _quillControllers =
        List.generate(widget.numberOfSteps, (_) => QuillController.basic());
  }

  @override
  void dispose() {
    for (final ctrl in _quillControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate 70% of the screen height dynamically for the editor.
    final screenHeight = MediaQuery.of(context).size.height;
    return Stepper(
      controller: controller,
      direction: Axis.horizontal,
      steps: List.generate(widget.numberOfSteps, (index) {
        return Step(
          title: Text('Question ${index + 1}'),
          contentBuilder: (context) {
            return StepContainer(
                actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 20.0),
                  child: Column(
                  children: [
                    Row(
                    children: [
                      if (index > 0)
                      SecondaryButton(
                        child: const Text('Prev'),
                        onPressed: () {
                        controller.previousStep();
                        },
                      ),
                      const SizedBox(width: 10),
                      if (index < widget.numberOfSteps - 1)
                      PrimaryButton(
                        child: const Text('Next'),
                        onPressed: () {
                        controller.nextStep();
                        },
                      )
                      else
                      PrimaryButton(
                        child: const Text('Finish'),
                        onPressed: () {
                        controller.nextStep();
                        },
                      ),
                    ],
                    ),
                  ],
                  ),
                ),
                ],
              child: Column(
                children: [
                  QuillSimpleToolbar(
                    controller: _quillControllers[index],
                    config: QuillSimpleToolbarConfig(
                      buttonOptions: QuillSimpleToolbarButtonOptions(
                        base: QuillToolbarBaseButtonOptions(
                          iconTheme: QuillIconTheme(
                            iconButtonSelectedData:  IconButtonData(
                              color: Colors.black,
                            ),
                          )
                        )
                      ),
                      showAlignmentButtons: false,
                      showBackgroundColorButton: false,
                      showHeaderStyle: false,
                      showUndo: true,
                      showRedo: true,
                      showSubscript: false,
                      showSuperscript: false,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.60,
                    child: QuillEditor.basic(
                      controller: _quillControllers[index],
                      config: const QuillEditorConfig(

                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
