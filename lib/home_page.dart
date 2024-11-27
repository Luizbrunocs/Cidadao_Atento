import 'package:flutter/material.dart';
import 'package:cidadao_atento_ac3/feedback.dart';
import 'package:cidadao_atento_ac3/user_profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:cidadao_atento_ac3/chamados_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("chamados");
  List<Calling> calls = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  /// Solicita permissões de câmera e galeria
  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.photos.request();
  }

  void _onDestinationSelected(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  Widget _buildBody() {
    switch (currentPageIndex) {
      case 0:
        return _buildHomePageWithBackground();
      case 1:
        return ChamadosPage(calls: calls);
      case 2:
        return const UserProfilePage(); // Página de perfil do usuário
      case 3:
        return const FeedbackPage(callId: 'id_do_chamado'); // Página para alterar senha
      default:
        return Container();
    }
  }

  Widget _buildHomePageWithBackground() {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/back.webp',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Início'),
          ),
          body: SingleChildScrollView(
            child: SizedBox(
              width: size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Olá, Bem-vindo ao Cidadão Atento!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black54,
                            offset: Offset(3.0, 3.0),
                          ),
                        ],),),),

                  const SizedBox(height: 350),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Para registrar uma nova ocorrência, clique no botão abaixo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black54,
                            offset: Offset(3.0, 3.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _showAddCallDialog,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      backgroundColor: Colors.amber,
                      textStyle: const TextStyle(fontSize: 22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Adicionar Chamado',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddCallDialog() async {
    final descriptionController = TextEditingController();
    final picker = ImagePicker();
    XFile? xFile;
    String base64Image = '';
    String callId = ''; // Gera um ID amigável

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Adicionar Chamado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  xFile = await picker.pickImage(source: ImageSource.camera);
                  if (xFile != null) {
                    File imageFile = File(xFile!.path);
                    base64Image = await _convertImageToBase64(imageFile);
                  }
                },
                child: const Text('Capturar Foto'),
              ),
              ElevatedButton(
                onPressed: () async {
                  xFile = await picker.pickImage(source: ImageSource.gallery);
                  if (xFile != null) {
                    File imageFile = File(xFile!.path);
                    base64Image = await _convertImageToBase64(imageFile);
                  }
                },
                child: const Text('Abrir Galeria'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );

    if (result == true && xFile != null && descriptionController.text.isNotEmpty) {
      callId = await _getNextCallId();
      final location = await _getCurrentLocation();

      setState(() {
        final newCall = Calling(
          id: callId,
          description: descriptionController.text,
          location: location,
          image: File(xFile!.path),
          imageBase64: base64Image,
        );

        calls.add(newCall);

        // Enviar dados para o Firebase
        dbRef.child(callId).set({
          'id': callId,
          'description': newCall.description,
          'location': newCall.location,
          'status': "Aguardando",
          'image': newCall.imageBase64,
        });
      });
      _showSnackBar('Seu chamado foi aberto com sucesso!');
    } else {
      if (xFile == null) {
        _showSnackBar('Selecione uma imagem para abrir o chamado!');
      } else if (descriptionController.text.isEmpty) {
        _showSnackBar('Adicione uma descrição para abrir o chamado!');
      } else {
        _showSnackBar('Erro ao abrir o chamado. Tente novamente!');
      }
    }
  }

  Future<String> _getNextCallId() async {
    // Referência ao contador do Firebase
    DatabaseReference counterRef = FirebaseDatabase.instance.ref('call_counter');

    // Obtendo o valor atual do contador
    final snapshot = await counterRef.get();
    int currentCounter = snapshot.exists ? snapshot.value as int : 0;

    // Incrementando o contador para o próximo número
    int nextCounter = currentCounter + 1;

    // Atualiza o contador no Firebase
    counterRef.set(nextCounter);

    // Gera o ID com prefixo + número sequencial
    return 'CHAMADO_${nextCounter.toString().padLeft(3, '0')}';

  }

  Future<String> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return "Serviço de localização desativado";
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return "Permissão de localização negada";
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return "Permissão de localização permanentemente negada";
    }

    Position position = await Geolocator.getCurrentPosition();
    return "${position.latitude}, ${position.longitude}";
  }
  // Função para converter a imagem em Base64
  Future<String> _convertImageToBase64(File image) async {
    List<int> imageBytes = await image.readAsBytes();
    return base64Encode(imageBytes); // Retorna a imagem em formato Base64
  }

  void _showSnackBar(String message) {
    // Exibe o SnackBar com o contexto garantido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onDestinationSelected,
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.important_devices),
            label: 'Chamados',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Cadastro',
          ),
          NavigationDestination(
            icon: Icon(Icons.feedback_outlined),
            label: 'Feedback',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}

class Calling {
  final String id;
  final String description;
  final String location;
  final File image;
  final String imageBase64;
  String status;

  Calling({
    required this.id,
    required this.description,
    required this.location,
    required this.image,
    required this.imageBase64,
    this.status = "Aguardando",
  });
}