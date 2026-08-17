# Graph Report - cafeflow  (2026-08-17)

## Corpus Check
- 98 files · ~36,149 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 622 nodes · 698 edges · 59 communities (50 shown, 9 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 7 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `258b820b`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 46|Community 46]]
- [[_COMMUNITY_Community 47|Community 47]]
- [[_COMMUNITY_Community 48|Community 48]]
- [[_COMMUNITY_Community 49|Community 49]]
- [[_COMMUNITY_Community 50|Community 50]]
- [[_COMMUNITY_Community 51|Community 51]]
- [[_COMMUNITY_Community 52|Community 52]]
- [[_COMMUNITY_Community 53|Community 53]]
- [[_COMMUNITY_Community 54|Community 54]]
- [[_COMMUNITY_Community 55|Community 55]]
- [[_COMMUNITY_Community 56|Community 56]]
- [[_COMMUNITY_Community 57|Community 57]]
- [[_COMMUNITY_Community 58|Community 58]]

## God Nodes (most connected - your core abstractions)
1. `EncodableValue` - 14 edges
2. `WriteValue()` - 10 edges
3. `Create()` - 10 edges
4. `MessageHandler()` - 10 edges
5. `WndProc()` - 9 edges
6. `ProcessExternalWindowMessage()` - 7 edges
7. `HandleTopLevelWindowProc()` - 7 edges
8. `ReadValue()` - 7 edges
9. `HWND` - 7 edges
10. `WindowClassRegistrar` - 7 edges

## Surprising Connections (you probably didn't know these)
- `ResizeChannel()` --calls--> `EncodableValue`  [INFERRED]
  windows/flutter/ephemeral/cpp_client_wrapper/core_implementations.cc → windows/flutter/ephemeral/cpp_client_wrapper/standard_codec.cc
- `SetChannelWarnsOnOverflow()` --calls--> `EncodableValue`  [INFERRED]
  windows/flutter/ephemeral/cpp_client_wrapper/core_implementations.cc → windows/flutter/ephemeral/cpp_client_wrapper/standard_codec.cc
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `OnCreate()` --calls--> `RegisterPlugins()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/flutter/generated_plugin_registrant.cc
- `OnCreate()` --calls--> `GetClientArea()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/runner/win32_window.cpp

## Communities (59 total, 9 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.08
Nodes (34): RegisterPlugins(), PluginRegistry, Point, RECT, OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable() (+26 more)

### Community 1 - "Community 1"
Cohesion: 0.22
Nodes (6): flutter(), flutter(), flutter(), namespace, namespace, namespace

### Community 2 - "Community 2"
Cohesion: 0.18
Nodes (28): ByteStreamReader, ByteStreamWriter, DecodeAndProcessResponseEnvelopeInternal(), DecodeMessageInternal(), DecodeMethodCallInternal(), EncodedTypeForValue(), EncodeErrorEnvelopeInternal(), EncodeMessageInternal() (+20 more)

### Community 3 - "Community 3"
Cohesion: 0.06
Nodes (25): AddPlugin(), ClearPlugins(), GetInstance(), OnRegistrarDestroyed(), PluginRegistrar(), flutter(), flutter(), flutter() (+17 more)

### Community 4 - "Community 4"
Cohesion: 0.09
Nodes (19): class, _In_, _In_opt_, MessageHandler(), wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16() (+11 more)

### Community 5 - "Community 5"
Cohesion: 0.11
Nodes (21): BinaryMessageHandler, BinaryMessenger, BinaryReply, BinaryMessengerImpl(), ForwardToHandler(), RegisterTexture(), ReplyManager(), ResizeChannel() (+13 more)

### Community 6 - "Community 6"
Cohesion: 0.15
Nodes (11): FlutterViewController(), HandleTopLevelWindowProc(), view_id(), FlutterViewId, DartProject, HWND, LPARAM, LRESULT (+3 more)

### Community 7 - "Community 7"
Cohesion: 0.10
Nodes (19): FlutterEngine(), GetRegistrarForPlugin(), ProcessExternalWindowMessage(), ProcessMessages(), RelinquishEngine(), SetNextFrameCallback(), ShutDown(), FlutterDesktopEngineRef (+11 more)

### Community 8 - "Community 8"
Cohesion: 0.14
Nodes (10): flutter(), flutter(), flutter(), flutter(), flutter(), namespace, namespace, namespace (+2 more)

### Community 9 - "Community 9"
Cohesion: 0.09
Nodes (21): ../../features/analitik/presentation/analitik_page.dart, ../../features/autentikasi/domain/auth_state.dart, ../../features/autentikasi/presentation/login_page.dart, ../../features/dashboard/presentation/dashboard_page.dart, ../../features/kafe/presentation/pilih_kafe_page.dart, ../../features/meja/presentation/meja_page.dart, ../../features/pelanggan/presentation/pelanggan_page.dart, ../../features/pengaturan/presentation/pengaturan_page.dart (+13 more)

### Community 10 - "Community 10"
Cohesion: 0.12
Nodes (16): ../../features/autentikasi/presentation/user_profile_provider.dart, ../../features/autentikasi/presentation/auth_provider.dart, ../../features/kafe/presentation/active_cafe_provider.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:go_router/go_router.dart, AppResponsiveLayout, build (+8 more)

### Community 11 - "Community 11"
Cohesion: 0.20
Nodes (8): flutter(), flutter(), flutter(), flutter(), namespace, namespace, namespace, namespace

### Community 12 - "Community 12"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 13 - "Community 13"
Cohesion: 0.15
Nodes (12): app/routes/app_router.dart, app/theme/app_theme.dart, core/config/supabase_config.dart, build, CafeFlowApp, core/config/supabase_config.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart (+4 more)

### Community 14 - "Community 14"
Cohesion: 0.08
Nodes (25): ../../../core/utils/currency_formatter.dart, dashboard_provider.dart, ../../kafe/presentation/active_cafe_provider.dart, ../../meja/domain/meja_model.dart, package:cafeflow/core/utils/currency_formatter.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:intl/intl.dart (+17 more)

### Community 15 - "Community 15"
Cohesion: 0.29
Nodes (6): package:flutter/material.dart, AnalitikPage, build, Padding, SizedBox, Text

### Community 16 - "Community 16"
Cohesion: 0.14
Nodes (13): auth_provider.dart, ../domain/auth_state.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:go_router/go_router.dart, lupa_password_dialog.dart, build, dispose (+5 more)

### Community 17 - "Community 17"
Cohesion: 0.08
Nodes (23): dialogs/lihat_qr_meja_dialog.dart, dialogs/tambah_edit_meja_dialog.dart, ../domain/meja_model.dart, ../../kafe/presentation/active_cafe_provider.dart, meja_provider.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, build (+15 more)

### Community 18 - "Community 18"
Cohesion: 0.29
Nodes (6): package:flutter/material.dart, build, Padding, PelangganPage, SizedBox, Text

### Community 19 - "Community 19"
Cohesion: 0.29
Nodes (6): package:flutter/material.dart, build, Padding, PengaturanPage, SizedBox, Text

### Community 20 - "Community 20"
Cohesion: 0.29
Nodes (6): package:flutter/material.dart, build, Padding, PesananPage, SizedBox, Text

### Community 21 - "Community 21"
Cohesion: 0.29
Nodes (6): package:flutter/material.dart, build, Padding, ProdukPage, SizedBox, Text

### Community 22 - "Community 22"
Cohesion: 0.29
Nodes (6): package:flutter/material.dart, build, Padding, SesiMejaPage, SizedBox, Text

### Community 23 - "Community 23"
Cohesion: 0.33
Nodes (5): package:flutter/material.dart, package:google_fonts/google_fonts.dart, AppTheme, TextStyle, ThemeData

### Community 24 - "Community 24"
Cohesion: 0.25
Nodes (7): StateError, SupabaseConfig, package:flutter/foundation.dart, package:supabase_flutter/supabase_flutter.dart, package:flutter_dotenv/flutter_dotenv.dart, package:flutter/foundation.dart, package:supabase_flutter/supabase_flutter.dart

### Community 25 - "Community 25"
Cohesion: 0.33
Nodes (5): package:flutter/material.dart, build, KafePage, Padding, SizedBox

### Community 26 - "Community 26"
Cohesion: 0.33
Nodes (5): package:cafeflow/main.dart, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_test/flutter_test.dart, main, ProviderScope

### Community 27 - "Community 27"
Cohesion: 0.33
Nodes (5): package:intl/intl.dart, package:intl/intl.dart, CurrencyFormatter, formatRupiah, formatRupiahRingkas

### Community 30 - "Community 30"
Cohesion: 0.40
Nodes (4): package:cafeflow/core/utils/currency_formatter.dart, package:cafeflow/core/utils/currency_formatter.dart, package:flutter_test/flutter_test.dart, main

### Community 38 - "Community 38"
Cohesion: 0.12
Nodes (15): active_cafe_provider.dart, ../../autentikasi/presentation/auth_provider.dart, ../domain/cafe_model.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:go_router/go_router.dart, build, _CafeTile (+7 more)

### Community 39 - "Community 39"
Cohesion: 0.17
Nodes (11): ../data/auth_repository.dart, ../../kafe/presentation/active_cafe_provider.dart, ../../../core/config/supabase_config.dart, ../domain/auth_state.dart, ../../kafe/presentation/active_cafe_provider.dart, package:flutter_riverpod/flutter_riverpod.dart, AuthNotifier, AuthRepository (+3 more)

### Community 40 - "Community 40"
Cohesion: 0.22
Nodes (8): AuthRepository, _parseAuthException, UserProfile, ../../kafe/domain/cafe_model.dart, ../../../core/config/supabase_config.dart, ../domain/user_profile.dart, package:flutter/foundation.dart, package:supabase_flutter/supabase_flutter.dart

### Community 41 - "Community 41"
Cohesion: 0.22
Nodes (8): ../../autentikasi/presentation/auth_provider.dart, ../domain/cafe_model.dart, package:flutter_riverpod/flutter_riverpod.dart, ActiveCafeNotifier, ActiveCafeState, clearActiveCafe, copyWith, selectCafe

### Community 42 - "Community 42"
Cohesion: 0.33
Nodes (5): auth_provider.dart, ../domain/user_profile.dart, package:flutter_riverpod/flutter_riverpod.dart, clearProfile, UserProfileNotifier

### Community 43 - "Community 43"
Cohesion: 0.40
Nodes (4): package:cafeflow/features/autentikasi/domain/user_profile.dart, package:cafeflow/features/kafe/domain/cafe_model.dart, package:flutter_test/flutter_test.dart, main

### Community 44 - "Community 44"
Cohesion: 0.50
Nodes (3): AuthState, copyWith, package:supabase_flutter/supabase_flutter.dart

### Community 47 - "Community 47"
Cohesion: 0.13
Nodes (14): build, _copyToken, Dialog, initState, LihatQrMejaDialog, _LihatQrMejaDialogState, SizedBox, SnackBar (+6 more)

### Community 48 - "Community 48"
Cohesion: 0.14
Nodes (13): dart:async, ../../kafe/presentation/active_cafe_provider.dart, ../../meja/domain/meja_model.dart, package:flutter_riverpod/flutter_riverpod.dart, ../../sesi_meja/domain/sesi_meja_model.dart, ../../meja/data/meja_repository.dart, ../../meja/presentation/meja_provider.dart, copyWith (+5 more)

### Community 49 - "Community 49"
Cohesion: 0.15
Nodes (12): build, Dialog, dispose, initState, SizedBox, SnackBar, TambahEditMejaDialog, _TambahEditMejaDialogState (+4 more)

### Community 50 - "Community 50"
Cohesion: 0.20
Nodes (8): flutter(), DecodeAndProcessResponseEnvelope(), flutter(), flutter(), namespace, MethodResult, namespace, namespace

### Community 51 - "Community 51"
Cohesion: 0.25
Nodes (7): ../data/meja_repository.dart, ../domain/meja_model.dart, ../../kafe/presentation/active_cafe_provider.dart, package:flutter_riverpod/flutter_riverpod.dart, loadMeja, MejaListNotifier, MejaRepository

### Community 52 - "Community 52"
Cohesion: 0.29
Nodes (6): MejaRepository, ../../../core/config/supabase_config.dart, ../domain/meja_model.dart, package:flutter/foundation.dart, package:supabase_flutter/supabase_flutter.dart, ../../sesi_meja/domain/sesi_meja_model.dart

### Community 53 - "Community 53"
Cohesion: 0.29
Nodes (4): flutter(), SetMethodCallHandler(), MethodCallHandler, namespace

### Community 54 - "Community 54"
Cohesion: 0.29
Nodes (6): package:cafeflow/features/dashboard/presentation/dashboard_provider.dart, package:cafeflow/features/meja/domain/meja_model.dart, package:cafeflow/features/sesi_meja/domain/sesi_meja_model.dart, package:flutter_test/flutter_test.dart, main, MejaModel

### Community 55 - "Community 55"
Cohesion: 0.33
Nodes (4): flutter(), flutter(), namespace, namespace

### Community 56 - "Community 56"
Cohesion: 0.33
Nodes (4): flutter(), flutter(), namespace, namespace

## Knowledge Gaps
- **391 isolated node(s):** `CafeFlowApp`, `main`, `initializeDateFormatting`, `ProviderScope`, `build` (+386 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `EncodableValue` connect `Community 2` to `Community 5`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `EncodableValue` (e.g. with `ResizeChannel()` and `SetChannelWarnsOnOverflow()`) actually correct?**
  _`EncodableValue` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `CafeFlowApp`, `main`, `initializeDateFormatting` to the rest of the system?**
  _391 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.08130081300813008 - nodes in this community are weakly interconnected._
- **Should `Community 3` be split into smaller, more focused modules?**
  _Cohesion score 0.06306306306306306 - nodes in this community are weakly interconnected._
- **Should `Community 4` be split into smaller, more focused modules?**
  _Cohesion score 0.08923076923076922 - nodes in this community are weakly interconnected._
- **Should `Community 5` be split into smaller, more focused modules?**
  _Cohesion score 0.10507246376811594 - nodes in this community are weakly interconnected._