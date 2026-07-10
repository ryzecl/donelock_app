import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import 'register_page.dart';



class LoginPage extends ConsumerStatefulWidget {

  const LoginPage({super.key});


  @override
  ConsumerState<LoginPage> createState() =>
      _LoginPageState();

}



class _LoginPageState
    extends ConsumerState<LoginPage> {


  final emailController =
      TextEditingController();


  final passwordController =
      TextEditingController();


  bool loading = false;



  Future<void> login() async {


    setState(() {
      loading = true;
    });


    try {


      await ref
          .read(authRepositoryProvider)
          .login(
            emailController.text.trim(),
            passwordController.text.trim(),
          );


    } catch(e){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content:
          Text(
            e.toString(),
          ),
        ),

      );


    }


    setState(() {

      loading = false;

    });


  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      body:

      Padding(

        padding:
        const EdgeInsets.all(24),


        child:

        Column(

          mainAxisAlignment:
          MainAxisAlignment.center,


          children: [


            const Text(

              "DoneLock",

              style:
              TextStyle(

                fontSize:32,

                fontWeight:
                FontWeight.bold,

              ),

            ),



            const SizedBox(
              height:40,
            ),



            TextField(

              controller:
              emailController,

              decoration:
              const InputDecoration(

                labelText:
                "Email",

              ),

            ),



            TextField(

              controller:
              passwordController,

              obscureText:true,

              decoration:
              const InputDecoration(

                labelText:
                "Password",

              ),

            ),



            const SizedBox(
              height:30,
            ),



            ElevatedButton(

              onPressed:
              loading
                  ? null
                  : login,


              child:

              loading

              ?

              const CircularProgressIndicator()

              :

              const Text(
                "Login",
              ),

            ),



            TextButton(

              onPressed: (){


                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                    const RegisterPage(),

                  ),

                );


              },


              child:
              const Text(
                "Create Account",
              ),

            )


          ],

        ),

      ),

    );

  }


}