# Flutter WebSocket Chat App

Um aplicativo de chat em tempo real desenvolvido com Flutter utilizando WebSocket, com suporte para mensagens de texto e imagens.

## 📸 Imagem

<img width="1000" alt="image" src="https://github.com/user-attachments/assets/6dbde1ab-8daa-4be2-b266-d190472cd231" />

## ✨ Funcionalidades

- **Chat em Tempo Real**  
  Comunicação instantânea via conexão WebSocket persistente

- **Suporte a Imagens**  
  Envio e recebimento de imagens com preview

- **Gerenciamento de Usuários**  
  - Geração automática de ID único
  - Nickname personalizável
  - Identificação visual dos participantes

- **Interface Moderna**  
  - Layout responsivo
  - Bubbles de mensagem estilizadas
  - Indicadores de status

## 🛠️ Tecnologias

**Frontend (Flutter)**:
- `flutter_chat_ui` - Componentes de UI para chat
- `web_socket_channel` - Conexão WebSocket
- `image_picker` - Seleção de imagens da galeria

**Backend (Python)**:
- `websockets` - Implementação do servidor WebSocket
- `asyncio` - Para operações assíncronas

## 🚀 Como Executar

### Pré-requisitos
- Flutter 3.0+
- Python 3.7+
- Dart SDK

### Instalação

1. **Servidor WebSocket**:
```bash
python server.py

```

## 🚀 Executando o Aplicativo Flutter

Para iniciar o aplicativo, execute os seguintes comandos:

```bash
flutter pub get
flutter run -d chrome
```

## 📁 Estrutura do Projeto
```
chat_app/
├── lib/
│ ├── main.dart # Ponto de entrada
│ ├── chat_page.dart # Tela do chat
│ └── contacts_page.dart # Tela de login
├── server.py # Servidor WebSocket
└── pubspec.yaml # Dependências Flutter
```


## 🔧 Configuração

### Alterar Endereço do WebSocket

```dart
// Em chat_page.dart
Uri.parse('ws://seu_endereco:porta')
```

