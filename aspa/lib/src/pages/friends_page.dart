import 'package:flutter/material.dart';
import '../../api_service.dart';
import 'chat_page.dart';

class FriendsPage extends StatefulWidget {
  final int userId;
  const FriendsPage({super.key, required this.userId});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _amigos = [];
  List<dynamic> _pendentes = [];
  List<dynamic> _buscaResultado = [];
  // ignore: unused_field
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregarTudo();
  }

  void _carregarTudo() async {
    setState(() => _isLoading = true);
    final amigos = await _api.getMeusAmigos(widget.userId);
    final pendentes = await _api.getPedidosPendentes(widget.userId);
    setState(() {
      _amigos = amigos;
      _pendentes = pendentes;
      _isLoading = false;
    });
  }

  void _buscarPessoas() async {
    if (_searchController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final resultado =
        await _api.buscarUsuarios(_searchController.text, widget.userId);
    setState(() {
      _buscaResultado = resultado;
      _isLoading = false;
    });
  }

  void _enviarPedido(int idDestino) async {
    final sucesso = await _api.solicitarAmizade(widget.userId, idDestino);

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Pedido enviado!")));
      _searchController.clear();
      setState(() => _buscaResultado = []);
    }
  }

  void _responderPedido(int idAmizade, bool aceitar) async {
    await _api.responderAmizade(idAmizade, aceitar);
    _carregarTudo(); // reccarregando p att lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Amigos e Chat"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Amigos"),
            Tab(text: "Solicitações (${_pendentes.length})"),
            Tab(text: "Adicionar"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListaAmigos(),
          _buildListaPendentes(),
          _buildTelaBusca(),
        ],
      ),
    );
  }

  Widget _buildListaAmigos() {
    if (_amigos.isEmpty) {
      return Center(child: Text("Você ainda não tem amigos."));
    }

    return ListView.builder(
      itemCount: _amigos.length,
      itemBuilder: (context, index) {
        final amigo = _amigos[index];
        return ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text(amigo['nome']),
          subtitle: Text(amigo['email']),
          trailing: Icon(Icons.chat_bubble_outline, color: Colors.blue),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatPage(
                        meuId: widget.userId,
                        amigoId: amigo['id_usuario'],
                        nomeAmigo: amigo['nome'])));
          },
        );
      },
    );
  }

  Widget _buildListaPendentes() {
    if (_pendentes.isEmpty) {
      return Center(child: Text("Nenhuma solicitação pendente."));
    }

    return ListView.builder(
      itemCount: _pendentes.length,
      itemBuilder: (context, index) {
        final req = _pendentes[index];
        return Card(
          margin: EdgeInsets.all(8),
          child: ListTile(
            title: Text(req['nome']),
            subtitle: Text("Quer ser seu amigo"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () => _responderPedido(req['id_amizade'], true),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => _responderPedido(req['id_amizade'], false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTelaBusca() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Digite nome ou email",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(icon: Icon(Icons.search), onPressed: _buscarPessoas)
            ],
          ),
        ),
        Expanded(
          child: _buscaResultado.isEmpty
              ? Center(child: Text("Pesquise alguém para adicionar"))
              : ListView.builder(
                  itemCount: _buscaResultado.length,
                  itemBuilder: (context, index) {
                    final user = _buscaResultado[index];
                    return ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person_add)),
                      title: Text(user['nome']),
                      subtitle: Text(user['email']),
                      trailing: ElevatedButton(
                        child: Text("Adicionar"),
                        onPressed: () => _enviarPedido(user['id']),
                      ),
                    );
                  },
                ),
        )
      ],
    );
  }
}
