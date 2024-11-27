import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key}); // Adicionado parâmetro 'key'

  @override
  UserProfilePageState createState() => UserProfilePageState(); // Classe pública
}

class UserProfilePageState extends State<UserProfilePage> {
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _novasenhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  void _initializeUserData() {
    // Simulando dados de um usuário
    _nameController.text = 'João da Silva';
    _cpfController.text = '123.456.789-00';
    _emailController.text = 'joao.silva@example.com';
    _phoneController.text = '(11) 91234-5678';
    _novasenhaController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro do Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField(_nameController, 'Nome'),
            const SizedBox(height: 16.0),
            _buildTextField(_cpfController, 'CPF'),
            const SizedBox(height: 16.0),
            _buildTextField(_emailController, 'E-mail'),
            const SizedBox(height: 16.0),
            _buildTextField(_phoneController, 'Telefone'),
            const SizedBox(height: 16.0),
            _buildTextField(_novasenhaController, 'Digite a nova senha'),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _saveUserData,
              child: const Text('Salvar Dados'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _saveUserData() {
    // Lógica para salvar ou atualizar os dados do usuário
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados salvos com sucesso!')),
    );
  }
}