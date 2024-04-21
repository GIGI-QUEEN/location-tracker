import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_firebase/components/custom_text_form_field.dart';
import 'package:tutorial_firebase/constants/routes_names.dart';
import 'package:tutorial_firebase/providers/authentication_provider.dart';
import 'package:tutorial_firebase/utils/utils.dart';
import 'package:tutorial_firebase/views/auth/shared/title.dart';
import 'package:tutorial_firebase/views/auth/shared/world_map.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //final authProvider = context.read<AuthenticationProvider>();
    final authProvider = Provider.of<AuthenticationProvider>(context);
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const WorldMap(),
                  const SizedBox(
                    height: 40,
                  ),
                  const PageTitle(title: 'Sign up'),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextFormField(
                    textEditingController: _emailController,
                    validator: signUpEmailValidator,
                    errorText: authProvider.emailErrorText,
                    hintText: 'email',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextFormField(
                    textEditingController: _passwordController,
                    validator: signUpPasswordValidator,
                    obscureText: true,
                    hintText: 'password',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      try {
                        if (await authProvider.submitSignUpForm(
                            _formKey, _emailController, _passwordController)) {
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(
                                context, authenticate);
                          }
                        }
                      } catch (e) {
                        throw Exception(e);
                      }
                    },
                    child: const Text('Get started'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already registered?'),
                      TextButton(
                          onPressed: () {
                            authProvider.clearErrorTexts();
                            Navigator.pushReplacementNamed(
                                context, authenticate);
                          },
                          child: const Text(
                            'Login',
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}