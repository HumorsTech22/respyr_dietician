import 'package:google_sign_in/google_sign_in.dart';

Future<GoogleSignInAccount?>  handleGoogleSignIn() async {
  try {
    final signIn = GoogleSignIn.instance;
    await signIn.initialize();
    final user = await signIn.authenticate();
    return user;
    } catch (e) {
    return null;
  }
}


Future<GoogleSignInAccount?>  signOut() async {
  try {
    final signIn = GoogleSignIn.instance;
    await signIn.signOut();
    final user = await signIn.authenticate();
    return user;
  } catch (e) {
    return null;
  }
}