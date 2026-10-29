import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const NowStreamigsApp());
}

class NowStreamigsApp extends StatelessWidget {
  const NowStreamigsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nowstreamigs TV',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _serverController = TextEditingController(text: 'http://');
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _loginXtream() async {
    final server = _serverController.text.trim();
    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    if (server.isEmpty || user.isEmpty || pass.isEmpty) {
      setState(() => _errorMessage = 'Preencha todos os campos da API Xtream.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String normServer = server;
    if (normServer.endsWith('/')) {
      normServer = normServer.substring(0, normServer.length - 1);
    }

    final url = Uri.parse('$normServer/player_api.php?username=$user&password=$pass');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['user_info'] != null && data['user_info']['auth'] == 1) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(authData: {
                'serverUrl': normServer,
                'username': user,
                'password': pass,
              }),
            ),
          );
          return;
        }
      }
    } catch (_) {}

    setState(() {
      _isLoading = false;
      _errorMessage = 'Falha no login. Verifique os dados.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nowstreamigs TV 📺 - Entrar'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.tv_rounded, size: 80, color: Colors.deepOrange),
                const SizedBox(height: 10),
                const Text('Nowstreamigs TV', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                TextField(controller: _serverController, decoration: const InputDecoration(labelText: 'URL do Servidor', border: OutlineInputBorder())),
                const SizedBox(height: 15),
                TextField(controller: _userController, decoration: const InputDecoration(labelText: 'Usuário', border: OutlineInputBorder())),
                const SizedBox(height: 15),
                TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder())),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                    onPressed: _isLoading ? null : _loginXtream,
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Entrar', style: TextStyle(fontSize: 18)),
                  ),
                ),
                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Text(_errorMessage, style: const TextStyle(color: Colors.redAccent)),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final Map<String, dynamic> authData;
  const DashboardScreen({super.key, required this.authData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Painel - ${authData['username']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          )
        ],
      ),
      body: Center(
        child: const Text('Bem-vindo ao Nowstreamigs TV!', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
