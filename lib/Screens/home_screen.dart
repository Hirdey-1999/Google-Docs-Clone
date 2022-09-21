import 'package:docs_clone/color.dart';
import 'package:docs_clone/common/widgets/loader.dart';
import 'package:docs_clone/models/document_model.dart';
import 'package:docs_clone/models/error_models.dart';
import 'package:docs_clone/repository/auth_repository.dart';
import 'package:docs_clone/repository/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class homeScreen extends ConsumerWidget {
  const homeScreen({Key? key}) : super(key: key);

  void signedOut(WidgetRef ref) {
    ref.read(AuthRepositoryProvider).siqnedOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(BuildContext context, WidgetRef ref) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    final errorModel =
        await ref.read(documentRepositoryProvider).createDocument(token);

    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackbar.showSnackBar(
        SnackBar(
          content: Text('${errorModel.error!}'),
        ),
      );
    }
  }

void navigateToDocument (BuildContext context, String documentId){
  Routemaster.of(context).push('/document/$documentId');
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kwhitecolor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => createDocument(context, ref),
            icon: const Icon(
              Icons.add,
              color: kblackcolor,
            ),
            hoverColor: Colors.blueGrey[300],
          ),
          SizedBox(
            width: 50,
          ),
          IconButton(
              onPressed: () => signedOut(ref),
              icon: const Icon(
                Icons.logout_sharp,
                color: kredcolor,
              ),
              hoverColor: kblackcolor),
        ],
      ),
      body: FutureBuilder<errorModel?>(
        future: ref
            .watch(documentRepositoryProvider).getDocument(ref.watch(userProvider)!.token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          return InkWell(
            onTap: () {},
            child: Center(
              child: Container(
                width: 600,
                margin: const EdgeInsets.only(top: 10),
                child: ListView.builder(
                  itemCount: snapshot.data!.data.length,
                  itemBuilder: (context, index) {
                    documentModel documentmodel = snapshot.data!.data[index];
                    return InkWell(
                      onTap: () => navigateToDocument(context, documentmodel.id),
                      child: Center(
                        child: SizedBox(
                          height:50,
                          width: 600,
                          child: Card(
                            child: Center(
                              child: Text(
                                documentmodel.title,
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
