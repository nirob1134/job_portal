import 'package:flutter/material.dart';
import 'package:job_portal/screens/admin/admin_dashboard.dart';
import 'package:job_portal/screens/admin/admin_home.dart';
import 'package:job_portal/screens/admin/admin_profile.dart';
import 'package:job_portal/screens/admin/job_application_screen.dart';
import 'package:job_portal/screens/admin/job_details_admin.dart';
import 'package:job_portal/screens/admin/post_job_screen.dart';
import 'package:job_portal/screens/auth/login_screen.dart';
import 'package:job_portal/screens/auth/registration_screen.dart';
import 'package:job_portal/screens/home/job_detail_screen.dart';
import 'package:job_portal/screens/home/user_dashboard.dart';
import 'package:job_portal/screens/splash/splash_screen.dart';
import 'package:job_portal/screens/home/home_screen.dart';
import '../models/job_model.dart';
import '../models/transport_model.dart';
import '../screens/admin/transport/admin_transport_screen.dart';
import '../screens/admin/transport/post_transport_screen.dart';
import '../screens/admin/transport/transport_details_screen.dart';
import '../screens/admin/transport/update_transport_screen.dart';
import '../screens/auth/role_gate.dart';
import '../screens/home/apply_transport_screen.dart';
import '../screens/home/transport_job_details_screen.dart';
import '../screens/home/transport_job_screen.dart';

class RouteHelper {
  static const String initial = '/';
  static const String login = '/login';
  static const String registration = '/registration';
  static const String adminDashboard = '/adminDashboard';
  static const String postJob = '/postJob';
  static const String adminJobDetails = '/adminJobDetails';
  static const String jobApplication = '/jobApplication';
  static const String userDashboard = '/userDashboard';
  static const String userJobDetails = '/userJobDetails';
  static const String home = '/home';
  static const String adminHome = '/adminHome';
  static const String adminProfile = '/adminProfile';
  static const String transportJobs = '/transportJobs';
  static const String transportJobDetails = '/transportJobDetails';
  static const String applyTransportJob = '/applyTransportJob';
  static const String adminTransportJobs = '/adminTransportJobs';
  static const String postTransportJob = '/postTransportJob';
  static const String updateTransportJob = '/updateTransportJob';
  static const String adminTransportDetails = '/adminTransportDetails';
  static const String roleGate = '/roleGate';

  static Map<String, WidgetBuilder> routes() {
    return {
      initial: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      registration: (context) => const RegistrationScreen(),
      adminDashboard: (context) => const AdminDashboard(),
      postJob: (context) => const PostJobScreen(),
      userDashboard: (context) => UserDashboard(),
      home: (context) => const HomeScreen(),
      adminHome: (context) => const AdminHome(),
      adminProfile: (context) => const AdminProfile(),
      transportJobs: (context) => const TransportJobScreen(),
      roleGate: (context) => const RoleGate(),



      transportJobDetails: (context) {
        final job =
        ModalRoute.of(context)!.settings.arguments as TransportModel;
        return TransportJobDetailsScreen(job: job);
      },

      applyTransportJob: (context) {
        final transport =
        ModalRoute.of(context)!.settings.arguments as TransportModel;

        return ApplyTransportScreen(
          jobId: transport.id,
          jobTitle: transport.title,
          route: transport.route,
        );
      },

      adminTransportJobs: (context) => const AdminTransportScreen(),

      postTransportJob: (context) => const PostTransportScreen(),

      updateTransportJob: (context) {
        final job =
        ModalRoute.of(context)!.settings.arguments as TransportModel;
        return UpdateTransportScreen(job: job);
      },

      adminTransportDetails: (context) {
        final job =
        ModalRoute.of(context)!.settings.arguments as TransportModel;
        return TransportDetailScreen(job: job);
      },

      userJobDetails: (context) {
        final job = ModalRoute.of(context)!.settings.arguments as JobModel;
        return JobDetailScreen(job: job);
      },

      adminJobDetails: (context) {
        final job = ModalRoute.of(context)!.settings.arguments as JobModel;
        return JobDetailsAdmin(job: job);
      },

      jobApplication: (context) {
        final jobId = ModalRoute.of(context)!.settings.arguments as String;
        return JobApplicationsScreen(jobId: jobId);
      },
    };
  }
}
