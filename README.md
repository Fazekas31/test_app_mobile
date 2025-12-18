# 📱 Projeto Teste - Dev Mobile Pleno (Vistoria com Geolocalização)

Este projeto é uma aplicação mobile desenvolvida em **Flutter** que permite a criação de registros de vistoria integrados ao **Supabase**. O principal diferencial técnico é a captura precisa de geolocalização (Latitude/Longitude) no momento exato do envio do formulário, garantindo a integridade do dado.

## 🚀 Funcionalidades

- **Formulário de Vistoria:** Cadastro de título e descrição.
- **Geolocalização Ativa:** Captura automática de coordenadas GPS e precisão no momento do envio.
- **Integração Backend:** Persistência de dados em tempo real no Supabase (PostgreSQL).
- **Histórico:** Visualização dos últimos registros enviados, ordenados cronologicamente.
- **Tratamento de Erros:** Feedback visual para falta de internet, GPS desligado ou permissões negadas.

## 🛠️ Tech Stack & Decisões Técnicas

- **Framework:** Flutter (Dart)
- **Backend:** Supabase (Database + API)
- **Gerenciamento de Estado:** `setState` (Escolhido pela simplicidade do escopo; para projetos maiores, utilizaria BLoC ou Riverpod).
- **Pacotes Principais:**
  - `supabase_flutter`: Conexão nativa com o backend.
  - `geolocator`: Padrão da indústria para acesso ao hardware de GPS.
  - `permission_handler`: Melhor UX para solicitação de permissões em runtime.
  - `flutter_dotenv`: Segurança para não expor chaves de API no controle de versão.

### Arquitetura
O projeto segue uma estrutura baseada em recursos (Features) e separação de serviços:

```text
lib/
├── screens/            # Camada de UI (Telas)
│   ├── form_screen.dart
│   └── list_screen.dart
├── services/           # Regras de Negócio e Hardware
│   └── location_service.dart
├── main.dart           # Inicialização e Injeção de Dependências
└── .env                # Variáveis de ambiente (GitIgnored)