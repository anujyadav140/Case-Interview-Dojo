import 'package:shadcn_flutter/shadcn_flutter.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int selected = 0;

  NavigationBarItem buildButton(String label, IconData icon) {
    return NavigationItem(
      label: Text(label),
      child: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the full screen height using MediaQuery
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight,
      width: 250,
      child: OutlinedContainer(
        child: NavigationSidebar(
          index: selected,
          onSelected: (index) {
            setState(() {
              selected = index;
            });
          },
          children: [
            const NavigationLabel(child: Text('Discovery')),
            buildButton('Listen Now', BootstrapIcons.playCircle),
            buildButton('Browse', BootstrapIcons.grid),
            buildButton('Radio', BootstrapIcons.broadcast),
            const NavigationGap(24),
            const NavigationDivider(),
            const NavigationLabel(child: Text('Library')),
            buildButton('Playlist', BootstrapIcons.musicNoteList),
            buildButton('Songs', BootstrapIcons.musicNote),
            buildButton('For You', BootstrapIcons.person),
            buildButton('Artists', BootstrapIcons.mic),
            buildButton('Albums', BootstrapIcons.record2),
            const NavigationGap(24),
            const NavigationDivider(),
            const NavigationLabel(child: Text('Playlists')),
            buildButton('Recently Added', BootstrapIcons.musicNoteList),
            buildButton('Recently Played', BootstrapIcons.musicNoteList),
            buildButton('Top Songs', BootstrapIcons.musicNoteList),
            buildButton('Top Albums', BootstrapIcons.musicNoteList),
            buildButton('Top Artists', BootstrapIcons.musicNoteList),
            buildButton('Logic Discography With Some Spice', BootstrapIcons.musicNoteList),
            buildButton('Bedtime Beats', BootstrapIcons.musicNoteList),
            buildButton('Feeling Happy', BootstrapIcons.musicNoteList),
            buildButton('I miss Y2K Pop', BootstrapIcons.musicNoteList),
            buildButton('Runtober', BootstrapIcons.musicNoteList),
          ],
        ),
      ),
    );
  }
}
