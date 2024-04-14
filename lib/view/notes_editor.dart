import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/user_notes_model.dart';

class NotesEditor extends StatefulWidget {
  const NotesEditor({super.key, required this.userNotes});
  final UserNotes userNotes;
  @override
  State<NotesEditor> createState() => _NotesEditorState();
}

class _NotesEditorState extends State<NotesEditor> {
  final _formKey = GlobalKey<FormState>();
  final _userUid = FirebaseAuth.instance.currentUser!.uid;
  late final CollectionReference _userNotesReference;
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late bool _enableEditing;
  String? _documentId;
  bool _isSavingOperation = false;

  @override
  void initState() {
    super.initState();
    _userNotesReference =
        FirebaseFirestore.instance.collection('/flutnotes/$_userUid/usernotes');
    _titleController = TextEditingController(text: widget.userNotes.title);
    _noteController = TextEditingController(text: widget.userNotes.note);
    // if null, it indicates that user open a new note
    _documentId = widget.userNotes.docId;
    // When documentId is null, it means user is creating a new note
    _enableEditing = _documentId == null;
  }

  /// Check whether is there any unsaved changes
  Future<bool> _isSafeToDiscard() async {
    return !_enableEditing ||
        _noteController.text.isEmpty ||
        await showDialog(
          context: context,
          builder: (builder) {
            return AlertDialog(
              title: const Text('Discard changes?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Discard'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Continue editing'),
                ),
              ],
            );
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // capture back button trigger
      onWillPop: _isSafeToDiscard,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          readOnly: !_enableEditing,
                          controller: _titleController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) => value!.isEmpty
                              ? 'Title can\'t be left empty'
                              : null,
                          decoration: const InputDecoration(
                              border: InputBorder.none, hintText: 'Title'),
                          style: TextStyle(
                              fontSize: 21,
                              decoration: _enableEditing
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                              fontWeight: FontWeight.w100,
                              decorationStyle: TextDecorationStyle.dotted),
                        ),
                      ),
                      Builder(builder: (builder) {
                        if (_enableEditing) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  if (await _isSafeToDiscard()) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('Discard'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _isSavingOperation = true;
                                    });
                                    // if creating new doc, should add to databse
                                    // if editing existing document, should update
                                    // the database
                                    if (_documentId == null) {
                                      _userNotesReference.add({
                                        'title': _titleController.text,
                                        'note': _noteController.text,
                                        'modified': Timestamp.now(),
                                        'created': Timestamp.now(),
                                      }).then((value) {
                                        print('Notes ${value.id} created');
                                        setState(() {
                                          _documentId = value.id;
                                          _enableEditing = false;
                                          _isSavingOperation = false;
                                        });
                                      });
                                    } else {
                                      _userNotesReference
                                          .doc(_documentId)
                                          .update({
                                        'title': _titleController.text,
                                        'note': _noteController.text,
                                        'modified': Timestamp.now()
                                      }).then((value) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text('Saved (*/ω＼*)'),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: Colors.green,
                                        ));
                                        setState(() {
                                          _isSavingOperation = false;
                                          _enableEditing = false;
                                        });
                                      });
                                    }
                                  }
                                },
                                child: _isSavingOperation
                                    ? const SizedBox(
                                        height: 25,
                                        width: 25,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Save'),
                              ),
                            ],
                          );
                        } else {
                          return TextButton.icon(
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.green),
                              onPressed: () {
                                setState(() {
                                  _enableEditing = true;
                                });
                              },
                              icon: const Icon(Icons.lock_outline, size: 18),
                              label: const Text('Enable Editing'));
                        }
                      }),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        readOnly: !_enableEditing,
                        controller: _noteController,
                        maxLines: null, // no line limit
                        decoration: const InputDecoration(
                            hintText: 'Your notes here',
                            border: InputBorder.none),
                        textInputAction: TextInputAction.newline,
                        // onChanged: (text) {
                        //   setState(() {});
                        // },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
