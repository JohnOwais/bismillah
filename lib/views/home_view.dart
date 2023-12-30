// ignore_for_file: use_build_context_synchronously

import 'package:bismillah/views/login_view.dart';
import 'package:bismillah/views/password_view.dart';
import 'package:bismillah/views/prifile_view.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key, required this.name, required this.phone, this.pass});

  final String name;
  final String phone;
  final String? pass;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedValue = '1';
  final postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.pass != null) {
        await Future<void>.delayed(const Duration(seconds: 1));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Your password is:  ${widget.pass}",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          backgroundColor: Colors.green,
        ));
      }
    });
  }

  Future<bool?> _showLogoutConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.name;
    final String phoneNumber = widget.phone;
    final Query query =
        FirebaseDatabase.instance.ref('Posts').child(phoneNumber);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(name: name, phone: phoneNumber)),
            ((route) => false)),
        Fluttertoast.showToast(
            msg: "Reloading...",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0)
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Welcome $name",
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          backgroundColor: Colors.green,
          iconTheme: const IconThemeData(color: Colors.white),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color.fromARGB(30, 0, 0, 0),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onSelected: (String value) async {
                if (value == '1') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ProfileView(phone: phoneNumber)));
                } else if (value == '2') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PasswordView(phone: phoneNumber)));
                } else {
                  bool confirmLogout =
                      await _showLogoutConfirmationDialog() as bool;
                  if (confirmLogout) {
                    Fluttertoast.showToast(
                        msg: "Logged Out",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginView()),
                        ((route) => false));
                  } else {
                    Fluttertoast.showToast(
                        msg: "Cancelled",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                }
                setState(() {
                  selectedValue = value;
                });
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: '1',
                  child: Row(
                    children: [
                      Icon(Icons.account_circle, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Edit Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: '2',
                  child: Row(
                    children: [
                      Icon(Icons.lock, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Change Password'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: '3',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Expanded(
                    child: FirebaseAnimatedList(
                      query: query,
                      itemBuilder: (context, snapshot, animation, index) {
                        Map<dynamic, dynamic> posts =
                            snapshot.value as Map<dynamic, dynamic>;
                        String postId = snapshot.key as String;
                        String postText = posts['post'];
                        return GestureDetector(
                          onLongPress: () {
                            showOptionsDialog(widget.phone, postId, postText);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Card(
                              elevation: 5,
                              color: const Color.fromARGB(255, 200, 255, 200),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(postText,
                                    style:
                                        const TextStyle(color: Colors.black)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Post(phone: phoneNumber, controller: postController);
              },
            );
          },
          label: const Text(
            'Post',
            style: TextStyle(color: Colors.white),
          ),
          icon: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  Future<void> showOptionsDialog(String phone, String postId, String postText) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Options(phone: phone, postId: postId, postText: postText);
        });
  }
}

class Options extends StatelessWidget {
  const Options(
      {super.key,
      required this.phone,
      required this.postId,
      required this.postText});

  final String phone;
  final String postId;
  final String postText;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SingleChildScrollView(
          child: SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: postText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                            "                    Copy                    ",
                            style: TextStyle(fontSize: 17)),
                      )),
                  SizedBox(height: 0.1, child: Container(color: Colors.black)),
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return UpdatePost(
                                phone: phone,
                                postText: postText,
                                postId: postId);
                          },
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                            "                    Edit                    ",
                            style: TextStyle(fontSize: 17)),
                      )),
                  SizedBox(height: 0.1, child: Container(color: Colors.black)),
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showDeleteConfirmationDialog(context, phone, postId);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                            "                    Delete                    ",
                            style: TextStyle(fontSize: 17)),
                      ))
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> showDeleteConfirmationDialog(
      BuildContext context, phone, String postId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Post"),
          content: const Text("Sure to delete this post?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseDatabase.instance
                    .ref('Posts')
                    .child(phone)
                    .child(postId)
                    .remove();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      "Post Deleted",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.red));
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

class UpdatePost extends StatefulWidget {
  const UpdatePost(
      {super.key,
      required this.phone,
      required this.postText,
      required this.postId});

  final String postId;
  final String postText;
  final String phone;

  @override
  State<UpdatePost> createState() => _UpdatePostState();
}

class _UpdatePostState extends State<UpdatePost> {
  final controller = TextEditingController();
  bool isValid = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller.text = widget.postText;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            InputText(
              controller: controller,
              valid: isValid,
            ),
            const SizedBox(
              height: 5,
            ),
            PostButton(
                phone: widget.phone,
                textController: controller,
                isLoading: isLoading,
                updateLoading: (bool loading) {
                  setState(() {
                    isLoading = loading;
                  });
                },
                updateValidity: (bool validity) {
                  setState(() {
                    isValid = validity;
                  });
                },
                update: true,
                postId: widget.postId)
          ]),
        ),
      ),
    );
  }
}

class Post extends StatefulWidget {
  const Post({super.key, required this.phone, required this.controller});

  final String phone;
  final TextEditingController controller;

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  bool isValid = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            InputText(controller: widget.controller, valid: isValid),
            const SizedBox(
              height: 5,
            ),
            PostButton(
              phone: widget.phone,
              textController: widget.controller,
              isLoading: isLoading,
              updateLoading: (bool loading) {
                setState(() {
                  isLoading = loading;
                });
              },
              updateValidity: (bool validity) {
                setState(() {
                  isValid = validity;
                });
              },
              update: false,
            )
          ]),
        ),
      ),
    );
  }
}

class PostButton extends StatelessWidget {
  const PostButton(
      {super.key,
      required this.phone,
      required this.textController,
      required this.isLoading,
      required this.updateLoading,
      required this.updateValidity,
      required this.update,
      this.postId});

  final String phone;
  final TextEditingController textController;
  final bool isLoading;
  final Function(bool) updateLoading;
  final Function(bool) updateValidity;
  final bool update;
  final String? postId;

  @override
  Widget build(BuildContext context) {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref('Posts');
    return ElevatedButton(
      onPressed: () async {
        updateValidity(true);
        textController.text = textController.text.trim();
        if (textController.text.length < 10) {
          updateValidity(false);
        } else {
          updateLoading(true);
          Map<String, String> post = {'post': textController.text};
          if (update) {
            await databaseReference.child(phone).child(postId!).update(post);
            Fluttertoast.showToast(
                msg: "Successfully Updated",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
          } else {
            await databaseReference.child(phone).push().set(post);
            Fluttertoast.showToast(
                msg: "Successfully Posted",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
          }
          textController.text = "";
          updateLoading(false);
          Navigator.pop(context);
        }
      },
      style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.green),
      child: isLoading
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : Text(
              update ? "Update" : "Post",
              style: const TextStyle(color: Colors.white),
            ),
    );
  }
}

class InputText extends StatelessWidget {
  const InputText({
    super.key,
    required this.controller,
    required this.valid,
  });

  final TextEditingController controller;
  final bool valid;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.multiline,
      minLines: 3,
      maxLines: 5,
      maxLength: 200,
      decoration: InputDecoration(
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green)),
          hintText: 'Type something...',
          errorText: valid ? null : "Can't be less than 10 characters"),
    );
  }
}
