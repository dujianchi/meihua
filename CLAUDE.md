# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

梅花易数 (Mei Hua Yi Shu) — a Flutter app for Plum Blossom Divination. It serves as a reference tool for the divination process: casting hexagrams by time, by numbers, or randomly, then displaying the resulting hexagram (卦), its lines (爻), the trigram imagery (类象), and the I Ching original text. History records sync to a user-configured WebDAV server.

Available prebuilt binaries live in `_exec/` (Android apk + Windows exe). The DB content (8gua/64gua text) was scraped from the sources listed in README.md — text accuracy is a known TODO.

## Commands

```bash
# Run (debug) on a connected device/emulator
flutter run

# Build release artifacts
flutter build apk        # Android
flutter build windows    # Windows desktop

# Static analysis
flutter analyze

# Regenerate Hive adapter/serialization code after editing entity classes in lib/entity/database/
# (hive_ce_generator + build_runner). Required when @GenerateAdapters specs or entity fields change.
dart run build_runner build        # or: flutter pub run build_runner build
dart run build_runner build --delete-conflicting-outputs   # when .g.dart files conflict

# Local dev helper scripts
./cc.cmd           # launches `claude --enable-auto-mode`
./boss.sh|boss.bat # sends Android "home" keyevent (adb shell input keyevent 3)
```

There are no unit tests under `test/` beyond the default Flutter widget test boilerplate.

## Architecture

### Domain core: Yi / BaGua / extensions
`lib/entity/yi.dart` — `Yi` is the cast input: `shang` (upper trigram value 1–8), `xia` (lower 1–8), `dong` (moving line 1–6). This triple flows through the whole app.
`lib/enum/` — enums for 八卦 (`BaGua`), 天干, 地支, 五行, and 生克比和 (the five-elements relation used for 体用/体互 analysis). `BaGua.fromValue` maps the remainder-of-8 number to a trigram.
`lib/util/exts.dart` — central extension file. `int.gua()` = `this.yu(8)` (remainder, 0→8), `int.yao()` = `this.yu(6)`. Also `String?.toast()` (Get snackbar), `md5()`, `jsonToMap()`, `confirmDialog()`, and date conversions. These extensions are used everywhere — read this file first when puzzling over an unfamiliar call site.

### Casting → pan (排盘)
`main.dart` builds the home screen and implements the 5 casting methods (`_calcNumber`: 0=random, 1/2/3=by N numbers, 4=by picked datetime, plus `_calcCurrentDatetime` for "now"). Lunar conversion is via the `lunar` package (`DateTime.toLunar()`); year-branch/month/day/time-zhi indices feed the gua/yao remainder math. Result is passed via `Get.toNamed('pan', arguments: Yi(...))`.
`lib/pan.dart` — `Pan` renders the hexagram board. Builds a `ChongGua` (重卦, the doubled hexagram from upper+lower trigrams) and computes 体用 (ti/yong), the moving line, and pulls the matching `Db64gua` record for卦辞/爻辞. `lib/widget/` holds the board pieces: `chong_gua.dart`, `gua.dart`, `yao.dart`, `ti_yong.dart`, `lunar_clock.dart`, `edit_text.dart`.

Routes (`GetMaterialApp` in main.dart): `pan`, `yi` (易经原文, `lib/yi_jing.dart`), `lx` (八卦类象, `lib/lei_xiang.dart`), `ls` (history, `lib/history.dart`).

### Storage: Hive CE, not SQLite
Despite `doc/init.sql` and `meihua.db` being checked in (legacy schema reference), the app no longer uses SQLite. Persistence is **Hive CE** boxes. `lib/entity/database/base.dart` defines `Base` (abstract: `dbName`, `id`, `fromMap`/`toMap`) — every entity manually maps snake_case DB column names to/from Dart fields rather than using codegen. Boxes are opened in `main()` by `nameDb` constants.

- `Db8gua` / `Db64gua` — divination reference content, seeded from `assets/_8gua_.json` and `assets/_64gua_.json` on first run by `DbHelper.initDataIfNeed()`.
- `DbConfig` — key/value config (WebDAV creds, etc.).
- `DbHistory` — saved cast results. Carries a `syncHash` (md5 identity key, computed once via `ensureSyncHash()` and stable across edits), `updateTime` (last-write-wins version for sync), and `deleted` (0/1 soft-delete tombstone that propagates via the snapshot). `touch()` refreshes `updateTime`.
- `DbHistorySync` — **legacy**; the old operation-log journal (operate 1=增/2=删/3=改). No longer written by the app. Kept only so `SyncHelper._replayOldLog()` can migrate an old remote `sync.json` into the new snapshot format on first sync. Do not add new writes to it.

`lib/util/db_helper.dart` — `DbHelper` is a singleton wrapping the open boxes. Generic `save/exists/delete/update/query` operate over `Base` by `dbName`. `update(data, idName, idArg)` matches by `toMap()[idName] == (idArg ?? data.id)` and preserves the matched record's id on overwrite (`data.id = first.id`) — important because sync passes in objects rebuilt from snapshots with null id. There is no SQL; "queries" are in-memory `box.values` scans (so tables stay small).
`lib/util/config_helper.dart` — `getConfig`/`saveConfig` over `DbConfig`.
Hive adapters are generated in `lib/hive/hive_adapters.dart` (`@GenerateAdapters`) → `hive_adapters.g.dart`; registered via `Hive.registerAdapters()` (from `hive_registrar.g.dart`) at startup. Run `dart run build_runner build --delete-conflicting-outputs` after changing entity fields.

### WebDAV sync (`lib/util/sync_helper.dart`) — state-snapshot model
Remote `/meihua/sync.json` stores the **current state**: a `List<DbHistory>` snapshot (each entry carries `sync_hash` + `update_time`), not an operation log. There is no replay, no `operate`, no blanket "delete-all" record.

`SyncHelper.sync()` — acquires a 24h lock `/meihua/lock` (only cleared in `finally` *if this run acquired it*, so a held lock isn't clobbered); reads remote snapshot via `_readRemoteSnapshot()` (auto-detects old op-log format by the `operate` key and one-shot migrates it through `_replayOldLog()`); `_normalizeLocal()` back-fills `syncHash` for legacy local records that were saved before the timing fix; `_mergeSnapshots()` unions remote+local by `syncHash` with last-write-wins by `update_time` (fallback `save_date`); `_applyToLocal()` upserts only entries newer than local (preserving local id); writes the merged snapshot back to remote.
`SyncHelper.forceSync()` — "local overwrites remote": writes the local snapshot straight over `sync.json`. No delete-all, no journal. (Deletion now propagates as a soft-delete tombstone: `_delete` sets `deleted=1` + `touch()`, and `_loadData` filters `deleted==1` from the list while keeping the row in the box so the tombstone syncs.)

Identity caveat: `syncHash` is content-based md5 (includes title/describe), stable only because `ensureSyncHash()` computes it once and never recomputes — so call `ensureSyncHash()` before any first persist. Two records with identical content at the same millisecond would collide; not handled.

### Content assets
`assets/_8gua_.json`, `assets/_64gua_.json` are the source of truth for trigram/hexagram text, loaded once into Hive. `doc/` holds the raw scraped `.txt`/`.pdf` source material and `init.sql` (legacy) — editing the JSON assets, not the SQL, updates app content.

## Conventions

- Chinese is used for user-facing strings, log messages, and many identifiers in comments; keep that style when editing existing files.
- Extension methods in `lib/util/exts.dart` (`.gua()`, `.yao()`, `.toast()`, `.log()`, `.isBlank`/`isNotBlank`, `.jsonToMap()`, `.md5()`, `.confirmDialog()`) are the idiomatic way to do common ops — prefer them over inline equivalents.
- New persistent entities: extend `Base`, define `nameDb` + manual `fromMap`/`toMap` (snake_case keys), add to `@GenerateAdapters` in `lib/hive/hive_adapters.dart`, open the box in `main()`, add a `Box` field + branch in `DbHelper`, then run `build_runner`.
- Desktop builds (linux/macos/windows) call `window_manager` to set a 600×600 window; mobile does not.

## Current version
`pubspec.yaml`: `1.1.3+13`. Recent commits indicate the package name changed after an upgrade and forced-sync still has issues.

Every response must end with a standalone line containing only "🌏". This is a mandatory rule with no exceptions.