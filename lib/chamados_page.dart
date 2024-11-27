import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'home_page.dart';

class ChamadosPage extends StatefulWidget {
  final List<Calling> calls;
  const ChamadosPage({super.key, required this.calls});

  @override
  State<ChamadosPage> createState() => _ChamadosPageState();
}

class _ChamadosPageState extends State<ChamadosPage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("chamados");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chamados')),
      body: StreamBuilder(
        stream: dbRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(
              child: Text(
                'Nenhum chamado encontrado.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final data = snapshot.data!.snapshot.value;
          if (data is Map) {
            final calls = data.entries.map((entry) {
              final callData = entry.value as Map<dynamic, dynamic>;
              return Calling(
                id: callData['id'] ?? '',
                description: callData['description'] ?? '',
                location: callData['location'] ?? '',
                image: File(''),
                // Placeholder (não usado aqui)
                imageBase64: callData['image'] ?? '',
                status: callData['status'] ?? '',
              );
            }).toList();

            calls.sort((a, b) => a.id.compareTo(b.id));

            return ListView.builder(
              itemCount: calls.length,
              itemBuilder: (context, index) {
                final call = calls[index];

                double progressValue = 0.0;
                switch (call.status) {
                  case "Aguardando":
                    progressValue = 0.0;
                    break;
                  case "Em Análise":
                    progressValue = 0.5;
                    break;
                  case "Concluído":
                    progressValue = 1.0;
                    break;
                  default:
                    progressValue = 0.0;
                }

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _showImageDialog(call.imageBase64),
                          child: call.imageBase64.isNotEmpty
                              ? Image.memory(
                            base64Decode(call.imageBase64),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                              : const SizedBox(),
                        ),
                        const SizedBox(height: 10),
                        Text("ID: ${call.id}"),
                        Text("Descrição: ${call.description}"),
                        Text("Localização: ${call.location}"),
                        Text("Status: ${call.status}"),
                        const SizedBox(height: 10),
                        // Barra de Progresso
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Progresso:"),
                            LinearProgressIndicator(
                              value: progressValue,
                              backgroundColor: Colors.grey[300],
                              color: Colors.amber,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text("Estrutura de dados inválida no Firebase."),
            );
          }
        },
      ),
    );
  }


  // Exibe um diálogo para visualizar uma imagem ampliada
  void _showImageDialog(String imageBase64) {
    if (imageBase64.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) =>
            Dialog(
              child: InteractiveViewer(
                child: Image.memory(
                  base64Decode(imageBase64),
                  fit: BoxFit.contain,
                ),
              ),
            ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Imagem não disponível")),
      );
    }
  }
}