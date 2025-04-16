import 'package:shadcn_flutter/shadcn_flutter.dart';

class Tree extends StatefulWidget {
  const Tree({super.key});

  @override
  State<Tree> createState() => _TreeState();
}

class _TreeState extends State<Tree> {
  bool expandIcon = true;
  bool recursiveSelection = true;
  List<TreeNode<String>> treeItems = [
    TreeItem(
      data: 'Apple',
      expanded: true,
      children: [
        TreeItem(data: 'Red Apple', children: [
          TreeItem(data: 'Red Apple 1'),
          TreeItem(data: 'Red Apple 2'),
        ]),
        TreeItem(data: 'Green Apple'),
      ],
    ),
    TreeItem(
      data: 'Banana',
      children: [
        TreeItem(data: 'Yellow Banana'),
        TreeItem(data: 'Green Banana', children: [
          TreeItem(data: 'Green Banana 1'),
          TreeItem(data: 'Green Banana 2'),
          TreeItem(data: 'Green Banana 3'),
        ]),
      ],
    ),
    TreeItem(
      data: 'Cherry',
      children: [
        TreeItem(data: 'Red Cherry'),
        TreeItem(data: 'Green Cherry', expanded: false, selected: false),
      ],
    ),
    TreeItem(
      data: 'Date',
    ),
    // Tree Root acts as a parent node with no data,
    // it will flatten the children into the parent node
    TreeRoot(
      children: [
        TreeItem(
          data: 'Elderberry',
          children: [
            TreeItem(data: 'Black Elderberry'),
            TreeItem(data: 'Red Elderberry'),
          ],
        ),
        TreeItem(
          data: 'Fig',
          children: [
            TreeItem(data: 'Green Fig'),
            TreeItem(data: 'Purple Fig'),
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedContainer(
          child: SizedBox(
            height: 300,
            width: 250,
            child: TreeView(
              expandIcon: expandIcon,
              shrinkWrap: true,
              recursiveSelection: recursiveSelection,
              nodes: treeItems,
              branchLine: BranchLine.line,
              onSelectionChanged: TreeView.defaultSelectionHandler(
                treeItems,
                (value) {
                  setState(() {
                    treeItems = value;
                  });
                },
              ),
              builder: (context, node) {
                return TreeItemView(
                  onPressed: () {},
                  trailing: node.leaf
                      ? Container(
                          width: 16,
                          height: 16,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        )
                      : null,
                  leading: node.leaf
                      ? const Icon(BootstrapIcons.fileImage)
                      : Icon(node.expanded
                          ? BootstrapIcons.folder2Open
                          : BootstrapIcons.folder2),
                  onExpand: TreeView.defaultItemExpandHandler(treeItems, node,
                      (value) {
                    setState(() {
                      treeItems = value;
                    });
                  }),
                  child: Text(node.data),
                );
              },
            ),
          ),
        ),
        const Gap(16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              onPressed: () {
                setState(() {
                  treeItems = treeItems.expandAll();
                });
              },
              child: const Text('Expand All'),
            ),
            const Gap(8),
            PrimaryButton(
              onPressed: () {
                setState(() {
                  treeItems = treeItems.collapseAll();
                });
              },
              child: const Text('Collapse All'),
            ),
          ],
        ),
      ],
    );
  }
}