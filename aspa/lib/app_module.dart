import 'package:aspa/src/controllers/home_medico_controller.dart';
import 'package:aspa/src/controllers/signup_controller.dart';
import 'package:aspa/src/pages/exercise_history_page.dart';
import 'package:aspa/src/pages/favorites_page.dart';
import 'package:aspa/src/pages/game_selection_page.dart';
import 'package:aspa/src/pages/help_page.dart';
import 'package:aspa/src/pages/object_classification_game_page.dart';
import 'package:aspa/src/pages/privacy_policy_page.dart';
import 'package:aspa/src/pages/profile_page.dart';
import 'package:aspa/src/pages/settings_page.dart';
import 'package:aspa/src/pages/tracing_game_page.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'src/pages/splash_screen.dart';
import 'src/pages/landing_page.dart';
import 'src/pages/login_page.dart';
import 'src/pages/signup_page.dart';
import 'src/pages/home_page_paciente.dart';
import 'src/pages/home_page_medico.dart';
import 'src/pages/edit_profile_page.dart';
import 'src/pages/reminders_page.dart';
import 'src/pages/jardineiro_game_page.dart';
import 'src/controllers/login_controller.dart';
import 'src/controllers/home_paciente_controller.dart';
import 'src/controllers/profile_controller.dart';

class AppModule extends Module {
  @override
  void binds(i) {
    // tutorial em caso necessário, aqui registramos a lógica (Controllers)
    // Singleton: cria uma vez e usa sempre a mesma instância
    // Factory (vem por padrão) = cria uma nova instância toda vez

    i.addSingleton(LoginController.new);
    i.addSingleton(HomeController.new);
    i.addSingleton(ProfileController.new);
    i.addSingleton(HomeMedicoController.new);
    i.addSingleton(SignUpController.new);
  }

  @override
  void routes(r) {
    // TODAS AS ROTAS DEVEM SER CHAMADAS ASSIM, EX.: Modular.to.navigate('/profile'))
    r.child('/', child: (context) => const SplashScreen());
    r.child('/landing', child: (context) => const LandingPage());
    r.child('/login', child: (context) => const LoginPageWidget());
    r.child('/signup', child: (context) => const SignUpPageWidget());

    r.child('/home_paciente',
        child: (context) => Homepage(userId: r.args.data));
    r.child('/home_medico',
        child: (context) => HomePageMedico(
            userId: r.args.data['id'], userName: r.args.data['name']));

    r.child('/profile',
        child: (context) => ProfilePage(
            userId: r.args.data['id'], isMedico: r.args.data['isMedico']));
    r.child('/edit_profile', child: (context) => const EditProfilePage());

    r.child('/reminders', child: (context) => const RemindersPage());
    r.child('/game_jardineiro',
        child: (context) => JardineiroGamePage(userId: r.args.data));
    r.child('/game_tracing',
        child: (context) => TracingGamePage(userId: r.args.data as int));
    r.child('/game_classification',
        child: (context) =>
            ObjectClassificationGame(userId: r.args.data as int));

    r.child('/exercise_history',
        child: (context) => const ExerciseHistoryPage());
    r.child('/favorites', child: (context) => const FavoritesPage());
    r.child('/settings', child: (context) => const SettingsPage());
    r.child('/privacy_policy', child: (context) => const PrivacyPolicyPage());
    r.child('/help', child: (context) => const HelpPage());
    r.child('/game',
        child: (context) => GameSelectionPage(userId: r.args.data));
  }
}
