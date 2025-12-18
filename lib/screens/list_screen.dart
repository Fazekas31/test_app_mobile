import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  // Variável que guarda a promessa da busca (Future)
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  // Função que vai no Supabase buscar os dados
  void _refreshList() {
    setState(() {
      _future = Supabase.instance.client
          .from('entries') // Nome da tabela
          .select()
          .order('created_at', ascending: false) // Mais recentes primeiro
          .limit(50); // Boa prática: não trazer o banco todo de uma vez
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Envios'),
        actions: [
          // Botão de atualizar manual
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshList,
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          // 1. Estado de Carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Estado de Erro
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar: ${snapshot.error}'),
            );
          }

          // 3. Estado de Lista Vazia ou Sucesso
          final data = snapshot.data;
          if (data == null || data.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum registro encontrado.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // 4. Renderizando a Lista
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = data[index];
              final createdAt = DateTime.parse(item['created_at']).toLocal();

              // Tenta formatar a data se tiver o pacote intl, senão usa toString simples
              // final dateString = DateFormat('dd/MM/yy HH:mm').format(createdAt);
              final dateString =
                  "${createdAt.day}/${createdAt.month} ${createdAt.hour}:${createdAt.minute}";

              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.location_on_outlined),
                ),
                title: Text(
                  item['title'] ?? 'Sem título',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['description'] ?? 'Sem descrição'),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${item['latitude']}, Long: ${item['longitude']}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.blueGrey),
                    ),
                  ],
                ),
                trailing: Text(
                  dateString,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  // Aqui você poderia abrir uma tela de Detalhes se quisesse
                },
              );
            },
          );
        },
      ),
    );
  }
}
