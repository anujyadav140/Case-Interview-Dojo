
import 'package:bartleby/components/sidebar.dart';
import 'package:bartleby/components/tree.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TabsExample1 extends StatefulWidget {
  const TabsExample1({super.key});

  @override
  State<TabsExample1> createState() => _TabsExample1State();
}

class _TabsExample1State extends State<TabsExample1> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
       final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Tabs(
          index: index,
          children: const [
            TabItem(child: Text('AI Agents')),
            TabItem(child: Text('Files')),
          ],
          onChanged: (int value) {
            setState(() {
              index = value;
            });
          },
        ),
        const Gap(8),
        IndexedStack(
          index: index,
          children: const [
           Tree(),
           Sidebar(),
          ],
        ).sized(height: screenHeight - 100),
      ],
    );
  }
}