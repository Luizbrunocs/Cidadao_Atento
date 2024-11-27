import 'package:cidadao_atento_ac3/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FeedbackPage extends StatefulWidget {
  final String callId; // Identificador inicial do chamado (opcional)

  const FeedbackPage({super.key, required this.callId});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("chamados");
  final TextEditingController feedbackController = TextEditingController();
  final TextEditingController idController = TextEditingController();

  void _submitFeedback() async {
    final feedback = feedbackController.text.trim();
    final callId = idController.text.trim();

    if (feedback.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, insira um feedback.")),
        );
      }
      return;
    }

    if (callId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, insira o ID do chamado.")),
        );
      }
      return;
    }

    try {
      // Verifica se o chamado existe no Firebase
      final snapshot = await dbRef.child(callId).get();
      if (!snapshot.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Chamado não encontrado. Verifique o ID.")),
          );
        }
        return;
      }

      // Envia o feedback para o chamado no banco de dados
      await dbRef.child(callId).update({
        "feedback": feedback,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Feedback enviado com sucesso!")),
        );

        // Após enviar o feedback com sucesso, navega de volta para a tela anterior
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationExample()),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao enviar feedback. Tente novamente.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building FeedbackPage...");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enviar Feedback"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Obrigado por usar nosso serviço!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Por favor, deixe seu feedback sobre o atendimento recebido.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: idController,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: "ID do Chamado",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Seu feedback",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                ),
                child: const Text("Enviar Feedback"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
