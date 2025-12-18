import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'services/location_service.dart';
import 'screens/list_screen.dart'; // <--- IMPORTANTE: Certifique-se que este arquivo existe

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Carrega variáveis de ambiente com tratamento de erro
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Erro ao carregar .env: $e");
    // O app continuará, mas vai falhar na verificação abaixo se não carregar
  }

  // 2. Verificação de Segurança (Evita o Crash "Null check operator")
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseKey == null) {
    // Se faltar chave, rodamos um App de Erro para avisar você na tela
    runApp(const ErrorApp(
        message:
            "Faltou configurar o arquivo .env com SUPABASE_URL e SUPABASE_ANON_KEY"));
    return;
  }

  // 3. Inicializa Supabase (agora seguro)
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

// App simples apenas para mostrar erro de configuração se houver
class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(message,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                    textAlign: TextAlign.center))),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teste Dev Mobile',
      debugShowCheckedModeBanner: false, // Remove a tarja "Debug"
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const FormScreen(),
    );
  }
}

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationService = LocationService();

  bool _isLoading = false;

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Capturar Geolocalização (Requisito Obrigatório)
      final Position position = await _locationService.getCurrentLocation();

      // 2. Montar Payload conforme tabela do Supabase
      final data = {
        'title': _titleController.text,
        'description': _descController.text,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy_m': position.accuracy,
        'device_timestamp': DateTime.now().toIso8601String(),
        'location_source': 'gps',
      };

      // 3. Enviar para o Supabase
      await supabase.from('entries').insert(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registro enviado com sucesso!'),
              backgroundColor: Colors.green),
        );
        _titleController.clear();
        _descController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Vistoria'),
        actions: [
          // --- NOVO: Botão para ir à tela de lista ---
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: "Ver Histórico",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                    labelText: 'Título da Vistoria',
                    border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                    labelText: 'Descrição / Observações',
                    border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _submitData,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send),
                  label: Text(_isLoading
                      ? 'Enviando e Localizando...'
                      : 'Gravar com Localização'),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "A localização será capturada automaticamente ao enviar.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              )
            ],
          ),
        ),
      ),
    );
  }
}
