import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _future = Supabase.instance.client
          .from('entries')
          .select()
          .order('created_at', ascending: false)
          .limit(50);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Envios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshList,
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final data = snapshot.data;
          if (data == null || data.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum registro encontrado.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = data[index];
              final createdAt = DateTime.parse(item['created_at']).toLocal();

              final dateString =
                  DateFormat('dd/MM/yyyy HH:mm').format(createdAt);

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
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
