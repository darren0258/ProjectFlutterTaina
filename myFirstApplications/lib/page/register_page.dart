import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../service/auth_service.dart';
import 'all_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  Map? _userData;
  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool circular = false;
  String name = "";
  bool changeButton = false;

  final _formKey = GlobalKey<FormState>();
  TextEditingController consumerData = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  moveToHome(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        changeButton = true;
      });
      await Future.delayed(const Duration(seconds: 1));
      await Navigator.pushNamed(context, AllPage.homeRoute);
      setState(() {
        changeButton = false;
      });
    }
  }

  moveToRegisterPage(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        changeButton = false;
      });
      await Future.delayed(const Duration(seconds: 1));
      await Navigator.pushNamed(context, AllPage.registerRoute);
      setState(() {
        changeButton = false;
      });
    }
  }

  moveToLoginPage(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        changeButton = true;
      });
      await Future.delayed(const Duration(seconds: 1));
      await Navigator.pushNamed(context, AllPage.registerRoute);
      setState(() {
        changeButton = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.greenAccent,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.symmetric()),
              sizeBoxButton(150, 0),
              GestureDetector(child: Image.asset("assets/images/2.jpeg")),
              const Padding(padding: EdgeInsets.symmetric()),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sizeBoxButton(40, 0),
                    const Center(
                        child: Text(
                      "TAINA",
                      style: TextStyle(fontSize: 60, color: Colors.black),
                    )),
                    sizeBoxButton(20, 0),

                    buttonItem(
                        "assets/images/Google-icon.png",
                        "เข้าสู่ระบบด้วย Google",
                        25,
                        Colors.white,
                        Colors.black),
                    sizeBoxButton(20, 20),
                    buildSigInFacebook(),
                    // sizeBoxButton(20, 0),
                    // const Center(
                    //     child: Text(
                    //   "หรือ",
                    //   style: TextStyle(fontSize: 30, color: Colors.white54),
                    // )),
                    // sizeBoxButton(20, 0),
                    // textItem("อีเมล ...", _emailController, false),
                    // sizeBoxButton(20, 0),
                    // textItem("รหัสผ่าน ...", _pwdController, true),
                    // sizeBoxButton(35, 0),
                    // colorButton(),
                    // sizeBoxButton(20, 0),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     const Text(
                    //       "ถ้ายังไม่มีรหัสผ่านต้องการจะสมัครไหม? ",
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //     InkWell(
                    //       onTap: () {
                    //         Navigator.pushAndRemoveUntil(
                    //             context,
                    //             MaterialPageRoute(
                    //                 builder: (build) => const RegisterPage()),
                    //             (route) => false);
                    //       },
                    //       child: const Text(
                    //         "สมัคร",
                    //         style: TextStyle(
                    //           color: Colors.greenAccent,
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(
                    //   height: 5,
                    // ),
                    // const Center(
                    //   child: Text(
                    //     "ลืมรหัสผ่าน?",
                    //     style: TextStyle(
                    //       color: Colors.greenAccent,
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container buildSigInFacebook() => Container(
        width: MediaQuery.of(context).size.width - 70,
        height: 60,
        margin: EdgeInsets.only(top: 8),
        child: SignInButton(
          Buttons.Facebook,
          onPressed: () async {
            final result = await FacebookAuth.i
                .login(permissions: ["public_profile", "email"]);
            if (result.status == LoginStatus.success) {
              final requestData = await FacebookAuth.i.getUserData(
                fields: "email, name",
              );
              setState(() {
                _userData = requestData;
                Navigator.pushNamed(context, AllPage.homeRoute);
              });
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );

  Container buildSignInGoogle() => Container(
      margin: EdgeInsets.only(top: 8),
      child: SignInButton(Buttons.Google, onPressed: () {
        processSignInWithGoogle();
      },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          )));

  Future<Null> processSignInWithGoogle() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );

    await Firebase.initializeApp().then((value) async {
      await _googleSignIn.signIn().then((value) {
        print('Login With gmail Success');
        Navigator.pushNamed(context, AllPage.homeRoute);
      });
    });
  }

  Widget colorBlackGround(Color colors) {
    return Scaffold(
      backgroundColor: colors,
    );
  }

  Widget sizeBoxButton(double sizeBoxButtonHeight, double sizeBoxButtonWidth) {
    return SizedBox(
      height: sizeBoxButtonHeight,
      width: sizeBoxButtonWidth,
    );
  }

  Widget colorButton() {
    return InkWell(
      onTap: () async {
        setState(() {
          circular = true;
        });
        try {
          firebase_auth.UserCredential userCredential =
              await firebaseAuth.createUserWithEmailAndPassword(
                  email: _emailController.text, password: _pwdController.text);
          if (_emailController.text != "" && _pwdController.text != "") {
            Navigator.pushNamed(context, AllPage.homeRoute);
          }
          if (kDebugMode) {
            print(userCredential.user?.email);
          }
          setState(() {
            circular = false;
          });
        } catch (e) {
          setState(() {
            circular = false;
          });
          final snackBar = SnackBar(content: Text(e.toString()));
          // ScaffoldMessenger.of(context).showSnackBar(snackBar);
          if (_emailController.text != "" && _pwdController.text != "") {
            Navigator.pushNamed(context, AllPage.homeRoute);
          }
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width - 70,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [
            Color(0xfffd746c),
            Color(0xffff9068),
            Color(0xfffd746c),
          ]),
        ),
        child: Center(
          child: circular
              ? const CircularProgressIndicator()
              : const Text(
                  "เข้าสู่ระบบ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _pwdController.text.trim(),
    );
  }

  Widget buttonItem(String imagePath, String buttonName, double size,
      Color colorButton, Color textColor) {
    return GestureDetector(
      onTap: () async {
        processSignInWithGoogle();
        signIn();
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 60,
        height: 60,
        child: Card(
          color: colorButton,
          elevation: 8,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(
                width: 1,
                color: Colors.white,
              )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: size,
                width: size,
              ),
              sizeBoxButton(0, 15),
              Text(
                buttonName,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              sizeBoxButton(0, 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget textItem(
      String labelText, TextEditingController controller, bool obscureText) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 70,
      height: 55,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 17,
          color: Colors.white,
        ),
        decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(
              fontSize: 17,
              color: Colors.white,
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  width: 1.5,
                  color: Colors.amber,
                )),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  width: 1,
                  color: Colors.grey,
                ))),
      ),
    );
  }

  login() {
    return Consumer<GoogleSignInController>(builder: (context, model, child) {
      if (model.googleAccount != null) {
        Navigator.pushNamed(context, AllPage.homeRoute);
        return const SizedBox();
      } else {
        return loginControls(context);
      }
    });
  }

  loginUI() {
    return Consumer<GoogleSignInController>(builder: (context, model, child) {
      if (model.googleAccount != null) {
        return Center(
          child: loggedInUI(model),
        );
      } else {
        return loginControls(context);
      }
    });
  }

  loggedInUI(GoogleSignInController model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage:
              Image.network(model.googleAccount!.photoUrl ?? '').image,
          radius: 80,
        ),
        Text(model.googleAccount!.displayName ?? ''),
        Text(model.googleAccount!.email),
        ActionChip(
            label: const Text("LogOut"),
            onPressed: () {
              Provider.of<GoogleSignInController>(context, listen: false)
                  .logOut();
            })
      ],
    );
  }

  loginControls(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            child: Image.asset(
              "assets/images/Google-icon.png",
              width: 50,
            ),
            onTap: () {
              Provider.of<GoogleSignInController>(context, listen: false)
                  .login();
            },
          ),
          Image.asset(
            "assets/images/login.jpg",
            width: 50,
          )
        ],
      ),
    );
  }
}

class Google extends StatefulWidget {
  const Google({Key? key}) : super(key: key);

  @override
  _GooglePage createState() => _GooglePage();
}

class _GooglePage extends State<Google> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loginUI(),
    );
  }

  loginUI() {
    return Consumer<GoogleSignInController>(builder: (context, model, child) {
      if (model.googleAccount != null) {
        return Center(
          child: loggedInUI(model),
        );
      } else {
        return loginControls(context);
      }
    });
  }

  loggedInUI(GoogleSignInController model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage:
              Image.network(model.googleAccount!.photoUrl ?? '').image,
          radius: 80,
        ),
        Text(model.googleAccount!.displayName ?? ''),
        Text(model.googleAccount!.email),
        ActionChip(
            label: const Text("LogOut"),
            onPressed: () {
              Provider.of<GoogleSignInController>(context, listen: false)
                  .logOut();
            })
      ],
    );
  }

  loginControls(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            child: Image.asset(
              "assets/images/Google-icon.png",
              width: 50,
            ),
            onTap: () {
              Provider.of<GoogleSignInController>(context, listen: false)
                  .login();
            },
          ),
          Image.asset(
            "assets/images/login.jpg",
            width: 50,
          )
        ],
      ),
    );
  }
}
