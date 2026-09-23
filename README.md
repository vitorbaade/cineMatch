# 🎬 CineMatch

App Flutter de catálogo e recomendação de filmes, com dados reais da API do
**TMDB**, tema escuro, layout **responsivo** (celular, tablet e desktop/web)
e biblioteca pessoal salva em **SQLite**.

---

## 📖 Como usar o app

### Início (Home)
- **Busca**: digite um título na barra de busca no topo — os resultados
  aparecem em tempo real, conforme você digita.
- **Filme do Dia**: banner em destaque no topo, escolhido automaticamente
  entre os filmes em alta. Toque em **Ver Detalhes** para saber mais, ou em
  **Match** para ir direto pro sorteio do CineMatch.
- **Gêneros**: os chips abaixo do filme do dia filtram o catálogo por gênero.
  Toque em "Todos" para voltar a ver tudo.
- **Em Alta** e **Melhores Avaliados**: catálogo carregado do TMDB. 

### Tela de Detalhes
Toque em qualquer pôster para abrir. Mostra sinopse, elenco, direção,
duração e nota. Dois botões de ação:
- **Adicionar à Minha Lista** — salva o filme na sua biblioteca pessoal.
Depois de adicionar à Minha Lista, aparece uma seção para você dar sua
**própria nota** (1 a 5 estrelas) e escrever um comentário — ao salvar, o
filme é automaticamente marcado como "Já Assisti".

### CineMatch (sorteio)
Escolha um ou mais gêneros favoritos (opcional) e toque em **Sortear
Filme** para receber uma recomendação aleatória do catálogo carregado.
Sem gênero selecionado, sorteia entre todos os filmes carregados.

### Minha Lista
Sua biblioteca pessoal, salva localmente. Duas abas:
- **Para Assistir** — filmes salvos que você ainda não avaliou.
- **Já Assisti** — filmes com nota e comentário salvos.

Toque no ícone de lixeira para remover um filme (pede confirmação antes).

---

## ▶️ Como rodar (setup do projeto)

Você precisa do SDK do Flutter instalado (https://flutter.dev).

```bash
# 1. Crie um projeto Flutter vazio com o mesmo nome
flutter create cinematch
cd cinematch

# 2. Substitua a pasta lib/ e o pubspec.yaml pelos arquivos deste pacote.
#    Copie também web/index.html e web/manifest.json por cima dos gerados.

# 3. Baixe as dependências
flutter pub get
```

### 3.1 Configure sua chave da API do TMDB (obrigatório)

1. Crie uma conta gratuita em https://www.themoviedb.org/signup
2. Vá em **Configurações → API → Create** (peça uma chave "Developer",
   escolha "API Key (v3 auth)" — **não** o "API Read Access Token", que é
   um token bem mais longo e não funciona aqui)
3. Abra `lib/config/tmdb_config.dart` e cole sua chave em `apiKey`:

```dart
static const String apiKey = 'SUA_CHAVE_AQUI';
```

⚠️ Cuidado com "substituir tudo": se o seu editor trocar *todas* as
ocorrências do texto `YOUR_TMDB_API_KEY_HERE`, ele também vai estragar a
linha `isConfigured` logo abaixo, que precisa continuar comparando com o
texto do placeholder, e não com a sua chave. O arquivo final deve ficar
assim:

```dart
static const String apiKey = 'SUA_CHAVE_AQUI';
...
static bool get isConfigured => apiKey.isNotEmpty && apiKey != 'YOUR_TMDB_API_KEY_HERE';
```

Sem a chave, o app compila e roda normalmente, mas a Home mostra um aviso
pedindo pra configurar em vez do catálogo.

### 3.2 Se for rodar na Web, rode este comando uma única vez

O app usa `sqflite` tanto no celular quanto na Web — na Web ele roda sobre
IndexedDB via `sqflite_common_ffi_web`, que precisa de dois arquivos
binários dentro de `web/`:

```bash
dart run sqflite_common_ffi_web:setup
```

Isso cria `web/sqlite3.wasm` e `web/sqflite_sw.js`. Só precisa rodar de novo
se atualizar a versão do pacote no `pubspec.yaml`.

### 3.3 Rodar

```bash
flutter run -d chrome --web-port=5000 #Web (USE A MESMA PORTA PARA TESTAR O BANCO DE DADOS) 
flutter run -d android    #Celular
```

### 3.4 Depois de qualquer alteração no código

Pare o servidor completamente (Ctrl+C no terminal) antes de rodar de novo,
em vez de confiar só no hot reload — principalmente no Flutter Web, que
guarda cache agressivo de build e de service worker no navegador. Se uma
mudança não aparecer mesmo depois de reiniciar, rode `flutter clean` e
depois `flutter pub get` antes de rodar de novo.

---

## 🧱 Estrutura do projeto

```
lib/
├── main.dart                       # MaterialApp, rotas nomeadas, MultiProvider,
│                                    # configuração do factory do SQLite
├── config/tmdb_config.dart         # Chave e URLs da API do TMDB
├── theme/app_theme.dart            # Dark Theme (#121212), tipografia
├── models/
│   ├── movie.dart                   # Classe Movie — parseia o JSON do TMDB
│   ├── genre.dart                   # Par {id, name} de gênero do TMDB
│   └── saved_movie.dart             # Linha da tabela SQLite `saved_movies`
├── database/
│   ├── database_helper.dart         # Singleton + SQL puro (CRUD das duas tabelas)
│   └── database_factory_config.dart # Ativa o SQLite também na Web
├── services/
│   └── tmdb_service.dart            # "TmdbApiService" — chamadas HTTP reais
├── providers/
│   ├── movie_provider.dart          # Estado da Home (tendências, busca, gêneros)
│   ├── my_list_provider.dart        # Estado da Minha Lista (CRUD no SQLite)
│   └── roulette_provider.dart       # Estado do CineMatch (sorteio por gênero)
├── screens/
│   ├── home_screen.dart             # RF01, RF08 — banner, busca, chips, listas
│   ├── details_screen.dart          # RF02, RF03, RF05 — detalhes e avaliação
│   ├── my_list_screen.dart          # RF04, RF06 — biblioteca pessoal, abas
│   └── roulette_screen.dart         # RF07 — CineMatch (sorteio)
└── widgets/
    ├── responsive/
    │   ├── breakpoints.dart          # Larguras de referência (700 / 1100px)
    │   └── adaptive_scaffold.dart    # BottomNavigationBar (celular) ou
    │                                 # NavigationRail (tablet/desktop)
    ├── movie_card.dart                # Card de pôster (usado em toda parte)
    ├── movie_grid.dart                # Carrossel (celular) ou grade (tablet/desktop)
    ├── genre_chip.dart, rating_stars.dart, section_header.dart
```

## 🗺️ Rotas nomeadas

| Rota         | Tela                                        |
|--------------|---------------------------------------------|
| `/`          | Home                                        |
| `/details`   | Detalhes (recebe um `Movie` como argumento) |
| `/my-list`   | Minha Lista                                 |
| `/roulette`  | CineMatch (sorteio)                         |

## 📱💻 Responsividade

- **< 700px** (celular): `AppBar` + conteúdo + `BottomNavigationBar`; listas
  de filmes viram **carrosséis horizontais**.
- **700–1099px** (tablet): `NavigationRail` compacto à esquerda; listas em
  grade.
- **≥ 1100px** (desktop / janela larga no navegador): `NavigationRail`
  estendido, banner "Filme do Dia" em formato panorâmico e tela de
  detalhes em duas colunas (pôster fixo + informações).

## 🗄️ Banco de dados (SQLite)

Duas tabelas, mesmo padrão (`DatabaseHelper` singleton + SQL puro):

```sql
CREATE TABLE saved_movies (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tmdbId INTEGER NOT NULL UNIQUE,
  title TEXT NOT NULL,
  overview TEXT NOT NULL DEFAULT '',
  posterPath TEXT NOT NULL DEFAULT '',
  releaseDate TEXT NOT NULL DEFAULT '',
  voteAverage REAL NOT NULL DEFAULT 0,
  genres TEXT NOT NULL DEFAULT '',
  director TEXT NOT NULL DEFAULT '',
  cast TEXT NOT NULL DEFAULT '',
  durationMinutes INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'Para Assistir',
  userRating REAL,
  userComment TEXT NOT NULL DEFAULT '',
  dateAdded TEXT NOT NULL
);

```

- `tmdbId UNIQUE` garante que o mesmo filme não é duplicado; salvar de novo
  faz um *upsert* (`ConflictAlgorithm.replace`).
- Como o catálogo em si vem da API (não fica salvo no banco), guardamos um
  **snapshot** dos dados do filme no momento em que ele é salvo/destacado —
  assim "Minha Lista" contina funcionando offline, sem
  precisar reconsultar o TMDB.

## 🌐 Sobre a busca de filmes no TMDB

`TmdbService._getPaged` busca várias páginas do catálogo para "Em Alta" e 
"Melhores Avaliados" — o CineMatch sorteia dentro da união dessas duas listas.
Se uma página falhar no meio do caminho (rede instável, limite de requisições),
a busca para ali e mostra o que já conseguiu, em vez de dar erro e não mostrar nada.

## ✅ Requisitos atendidos

- RF01 Listar Tendências — carrosséis/grades "Em Alta" / "Melhores Avaliados" (TMDB)
- RF02 Exibir Detalhes — rota `/details`, com sinopse/elenco/direção/duração completos
- RF03 Adicionar à Lista — botão na tela de detalhes, grava no SQLite
- RF04 Listar Itens Salvos — tela "Minha Lista", funciona offline
- RF05 Avaliar Título — estrelas (1-5) + comentário, exige status "Já Assisti"
- RF06 Remover da Lista — com diálogo de confirmação
- RF07 Sorteio Rápido — tela CineMatch, com filtro por gêneros favoritos
- RF08 Pesquisar Títulos — busca em tempo real via `/search/movie` do TMDB
