import 'package:flutter/material.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'The Single Best Password Manager Ever'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final websiteController = TextEditingController();

  String username = "";
  String password = "";
  String website = "";

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_updateUsername);
    passwordController.addListener(_updatePassword);
    websiteController.addListener(_updateWebsite);
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  _updateUsername() {
    setState(() {
      username = usernameController.text;
    });
  }

  _updatePassword() {
    setState(() {
      password = passwordController.text;
    });
  }

  _updateWebsite() {
    setState(() {
      website = websiteController.text;
    });
  }

  void _saveNewPassword(String username, String password, String website) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (username.isNotEmpty && password.isNotEmpty && website.isNotEmpty) {
      Process.run('pwdm', ['-w', website, username, password]).then((value) =>
          value.stderr.toString().isNotEmpty
              ? ScaffoldMessenger.of(context)
                  .showSnackBar(snackbar(value.stderr))
              : null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          snackbar('Supply a username, password, and domain name!'));
    }
  }

  void _deletePassword(String username, String website) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (username.isNotEmpty && website.isNotEmpty) {
      Process.run('pwdm', ['-d', website, username]).then((value) => value
              .stderr
              .toString()
              .isNotEmpty
          ? ScaffoldMessenger.of(context).showSnackBar(snackbar(value.stderr))
          : null);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(snackbar('Supply a username, and domain name!'));
    }
  }

  void _updateDbPassword(String username, String password, String website) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (username.isNotEmpty && password.isNotEmpty && website.isNotEmpty) {
      Process.run('pwdm', ['-c', website, username, password]).then((value) =>
          value.stderr.toString().isNotEmpty
              ? ScaffoldMessenger.of(context)
                  .showSnackBar(snackbar(value.stderr))
              : null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          snackbar('Supply a username, password, and domain name!'));
    }
  }

  void _readPassword(String username, String website) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (username.isNotEmpty && website.isNotEmpty) {
      Process.run('pwdm', ['-r', website, username]).then((value) => value
              .stderr
              .toString()
              .isNotEmpty
          ? ScaffoldMessenger.of(context)
              .showSnackBar(snackbar("Record not found! \n" + value.stderr))
          : ScaffoldMessenger.of(context).showSnackBar(snackbar(value.stdout)));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(snackbar('Supply a username, and domain name!'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            inputField(usernameController, 'Username',
                const Icon(Icons.account_circle)),
            inputField(passwordController, 'Password', const Icon(Icons.lock)),
            inputField(websiteController, 'Website', const Icon(Icons.web)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      _saveNewPassword(username, password, website),
                  child: const Text('Save New Password'),
                ),
                ElevatedButton(
                  onPressed: () => _deletePassword(username, website),
                  child: const Text('Delete Password'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _updateDbPassword(username, password, website),
                  child: const Text('Update Password'),
                ),
                ElevatedButton(
                  onPressed: () => _readPassword(username, website),
                  child: const Text('Read Password'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

Widget inputField(TextEditingController controller, String hint, Icon ikon) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(300, 20, 300, 20),
    child: TextField(
      cursorColor: Colors.blue,
      controller: controller,
      style: const TextStyle(color: Colors.blue),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.blue),
        icon: ikon,
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue)),
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
            borderSide: BorderSide(color: Colors.white)),
      ),
    ),
  );
}

SnackBar snackbar(txt) {
  return SnackBar(
    duration: const Duration(seconds: 10),
    content: Row(
      children: [
        const Icon(Icons.error_outline),
        const SizedBox(width: 30),
        Flexible(child: Text(txt)),
      ],
    ),
  );
}
