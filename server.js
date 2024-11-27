const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 3000;

// Middleware para processar o corpo da requisição (JSON)
app.use(bodyParser.json({ limit: '50mb' })); // Ajuste o limite se necessário para grandes imagens

// Simulação de armazenamento de chamados em um arquivo JSON
const callsFilePath = path.join(__dirname, 'calls.json');

// Função para carregar os chamados
function loadCalls() {
  if (fs.existsSync(callsFilePath)) {
    const data = fs.readFileSync(callsFilePath);
    return JSON.parse(data);
  }
  return [];
}

// Função para salvar os chamados
function saveCalls(calls) {
  try {
    fs.writeFileSync(callsFilePath, JSON.stringify(calls, null, 2));
    console.log('Chamados salvos no arquivo com sucesso');
  } catch (error) {
    console.error('Erro ao salvar os chamados no arquivo:', error);
  }
}

// Endpoint para obter todos os chamados
app.get('/calls', (req, res) => {
  const calls = loadCalls();
  res.json(calls);
});

// Endpoint para adicionar um chamado
app.post('/calls', (req, res) => {
  const { description, location, image, status } = req.body;

  console.log('Dados recebidos:', {
    description,
    location,
    image,
    status
  });

  // Verifica se os dados estão corretos
  if (!description || !location || !image) {
    return res.status(400).json({ message: 'Dados incompletos' });
  }

  // Converte a imagem de base64 para arquivo
   const buffer = Buffer.from(image, 'base64');
   fs.writeFileSync('path_to_image.jpg', buffer);

  // Cria a pasta de uploads se não existir
  if (!fs.existsSync(path.join(__dirname, 'uploads'))) {
    fs.mkdirSync(path.join(__dirname, 'uploads'));
  }

  // Salva a imagem no disco
  fs.writeFileSync(imagePath, buffer);

  // Cria o novo chamado
  const newCall = { description, location, status };
  const data = JSON.parse(fs.readFileSync('calls.json', 'utf8'));
  data.push(newCall);

  // Salve o arquivo JSON
  fs.writeFileSync('calls.json', JSON.stringify(data, null, 2));

  // Carrega os chamados existentes, adiciona o novo e salva
  const calls = loadCalls();
  calls.push(newCall);
  saveCalls(calls);

  console.log('Chamado adicionado com sucesso:', newCall);

  // Retorna uma resposta de sucesso
  res.status(201).json({ message: 'Chamado adicionado com sucesso!' });
});

// Inicia o servidor
app.listen(port, () => {
  console.log('Servidor backend rodando em http://localhost:3000');
});
