import 'dart:async';
import 'dart:html';

import 'package:docs_clone/color.dart';
import 'package:docs_clone/common/widgets/loader.dart';
import 'package:docs_clone/models/document_model.dart';
import 'package:docs_clone/models/error_models.dart';
import 'package:docs_clone/repository/auth_repository.dart';
import 'package:docs_clone/repository/document_repository.dart';
import 'package:docs_clone/repository/socket_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class documentScreen extends ConsumerStatefulWidget {
  final String id;
  const documentScreen({Key? key, required this.id}) : super(key: key);

  @override
  ConsumerState<documentScreen> createState() => _documentScreenState();
}

class _documentScreenState extends ConsumerState<documentScreen> {
  TextEditingController titleController =
      TextEditingController(text: 'Untitled Document');
  quill.QuillController? _controller;
  errorModel? Modelerror;
  SocketRepository socketRepository = SocketRepository();
  @override
  void initState() {
    super.initState();
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();
    socketRepository.changeListener((data) {
      _controller!.compose(
          quill.Delta.fromJson(data['delta']),
          _controller?.selection ?? const TextSelection.collapsed(offset: 0),
          quill.ChangeSource.REMOTE);
    });
    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepository.autoSave(<String, dynamic>{
        'delta': _controller!.document.toDelta(),
        'room': widget.id,
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  void fetchDocumentData() async {
    Modelerror = await ref
        .read(documentRepositoryProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);
    print(Modelerror!.data);
    if (Modelerror!.data != null) {
      titleController.text = (Modelerror!.data as documentModel).title;
      _controller = quill.QuillController(
          document: Modelerror!.data.content.isEmpty
              ? quill.Document()
              : quill.Document.fromDelta(
                  quill.Delta.fromJson(Modelerror!.data.content),
                ),
          selection: const TextSelection.collapsed(offset: 0));
      setState(() {});
    }
    _controller!.document.changes.listen((event) {
      if (event.item3 == quill.ChangeSource.LOCAL) {
        Map<String, dynamic> map = {
          'delta': event.item2,
          'room': widget.id,
        };
        socketRepository.typing(map);
      }
    });
  }

  void updateTitle(WidgetRef ref, String title) {
    ref.read(documentRepositoryProvider).updateDocument(
          token: ref.read(userProvider)!.token,
          id: widget.id,
          title: title,
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Scaffold(body: const Loader());
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kwhitecolor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
              icon: Image.asset(
                'assets/images/docs-logo.png',
              ),
              onPressed: () {
                Routemaster.of(context).replace('/');
              },
              color: Colors.white),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(
                        text: 'http://localhost:3000/#/document/${widget.id}'))
                    .then(
                  ((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link Copied'),
                      ),
                    );
                    ;
                  }),
                );
              },
              icon: Icon(
                Icons.lock,
                size: 16,
              ),
              label: Text(
                "Share",
              ),
              style: ElevatedButton.styleFrom(primary: kbluecolor),
            ),
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: 180,
            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kbluecolor, width: 1.5),
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                contentPadding: EdgeInsets.only(
                  left: 10.0,
                ),
              ),
              onSubmitted: ((value) => updateTitle(ref, value)),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: kgreycolor, width: 0.1),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(children: [
          SizedBox(
            height: 10,
          ),
          quill.QuillToolbar.basic(
            controller: _controller!,
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Container(
              width: 850,
              margin: EdgeInsets.all(10.0),
              child: Card(
                color: kwhitecolor,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: quill.QuillEditor.basic(
                      controller: _controller!, readOnly: false),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
