import 'dart:async';

import 'package:aspa/api_service.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class ChatPage extends StatefulWidget {
  final int meuId;
  final int amigoId;
  final String nomeAmigo;

  const ChatPage(
      {super.key,
      required this.meuId,
      required this.amigoId,
      required this.nomeAmigo});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _api = ApiService();
  late WebSocketChannel channel;
  StreamSubscription? _assinaturaWebSocket;
  List<dynamic> _mensagens = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
    _conectarWebSocket();
  }

  void _carregarHistorico() async {
    final historico = await _api.getHistoricoChat(widget.meuId, widget.amigoId);

    setState(() {
      _mensagens = historico.map((m) {
        return {
          "texto": m['mensagem'],
          "isMe": m['remetente_id'] == widget.meuId
        };
      }).toList();
      _isLoading = false;
    });
  }

  void _conectarWebSocket() {
    channel = WebSocketChannel.connect(
      // usar o IP correto aqui msm logica do api service
      Uri.parse('https://kylah-savouriest-superserviceably.ngrok-free.dev'),
    );

    _assinaturaWebSocket = channel.stream.listen((message) {
      // impede o flutter de tentar atualizar a tela se ela já fechou
      if (!mounted) return;

      final dados = jsonDecode(message);
      if (dados['remetente_id'].toString() == widget.amigoId.toString()) {
        setState(() {
          _mensagens.add({"texto": dados['mensagem'], "isMe": false});
        });
      }
    }, onError: (error) {
      // ! Adicionar proteção de erro
    }, cancelOnError: true // para de ouvir se der erro grave
        );
  }

  void _enviarMensagem() {
    if (_controller.text.isNotEmpty) {
      // envia pro Server
      channel.sink.add(jsonEncode(
          {"destinatario_id": widget.amigoId, "mensagem": _controller.text}));

      // add na tela localmente
      setState(() {
        _mensagens.add({"texto": _controller.text, "isMe": true});
      });
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _assinaturaWebSocket?.cancel();

    channel.sink.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: Text(widget.nomeAmigo.isNotEmpty
                  ? widget.nomeAmigo[0].toUpperCase()
                  : "?"),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.nomeAmigo,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(
                    child:
                        CircularProgressIndicator(color: colorScheme.primary))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    itemCount: _mensagens.length,
                    itemBuilder: (context, index) {
                      final msg = _mensagens[index];
                      final isMe = msg['isMe'];

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: isMe
                                  ? const Radius.circular(20)
                                  : Radius.zero,
                              bottomRight: isMe
                                  ? Radius.zero
                                  : const Radius.circular(20),
                            ),
                          ),
                          child: Text(
                            msg['texto'],
                            style: textTheme.bodyMedium?.copyWith(
                              color: isMe
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 5,
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: textTheme.bodyLarge
                          ?.copyWith(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: "Digite uma mensagem...",
                        hintStyle: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.outline),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _enviarMensagem,
                  borderRadius: BorderRadius.circular(50),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: colorScheme.primary,
                    child: Icon(Icons.send_rounded,
                        color: colorScheme.onPrimary, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
