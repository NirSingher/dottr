# Dottr Open-Source Release Plan

Personal markdown journal app. Neo-brutalist UI. Flutter (macOS, iOS, Android).

---

## Phase 1 — Pre-launch (Repo Hygiene)

### Git Sync Implementation
Git sync is stubbed out. Must be functional before going public — it's a core promise.

- [ ] Implement Git clone/pull/push via local git binary or libgit2
- [ ] Handle auth (SSH key or token stored in flutter_secure_storage)
- [ ] Conflict resolution strategy (last-write-wins or user prompt)
- [ ] Test sync round-trip on macOS and Android

### Repo Cleanup
- [ ] Rename all `dottl` references to `dottr` (README, .iml files, comments, bundle IDs)
- [ ] Reset version to `0.1.0+1` in `pubspec.yaml`
- [ ] Harden `.gitignore` — ensure `build/`, `.dart_tool/`, `.env`, `*.jks`, `*.keystore`, IDE files excluded
- [ ] Remove `pubspec.lock` from tracking (or keep — decide and document)
- [ ] Clean up default Flutter boilerplate from README

### Security Audit
- [ ] Grep for hardcoded paths, API keys, credentials
- [ ] Verify `flutter_secure_storage` usage has no plaintext fallbacks
- [ ] Check no user data or journal content in repo
- [ ] Review Android `AndroidManifest.xml` and macOS entitlements for unnecessary permissions

### Community Files
- [ ] `LICENSE` — MIT
- [ ] `README.md` — rewrite with: what it is, screenshots, install instructions, build-from-source steps
- [ ] `CONTRIBUTING.md` — how to set up dev env, PR process, code style
- [ ] `CODE_OF_CONDUCT.md` — Contributor Covenant
- [ ] `SECURITY.md` — how to report vulnerabilities

### CI/CD (GitHub Actions)
- [ ] **Test + Analyze workflow**: `flutter test` + `flutter analyze` on push/PR
- [ ] **Release workflow**: build macOS `.app` (zipped) + Android universal `.apk` on tag push
- [ ] Badge in README for build status

---

## Phase 2 — Launch Day

- [ ] Make GitHub repo public
- [ ] Tag `v0.1.0` and create GitHub Release with:
  - macOS: `.zip` containing unsigned `.app`
  - Android: universal `.apk`
- [ ] Enable GitHub Discussions (General, Q&A, Ideas categories)
- [ ] Announce (channels TBD — consider HN Show, Reddit r/FlutterDev, Mastodon, X)

### Distribution Notes

| Platform | Method | Notes |
|----------|--------|-------|
| **macOS** | Unsigned `.app` in `.zip` via GitHub Releases | Users right-click → Open to bypass Gatekeeper |
| **Android** | Universal APK via GitHub Releases | Sideload; F-Droid as fast-follow |
| **iOS/iPadOS** | Build-from-source only | No Apple Developer Program currently |

---

## Phase 3 — Post-launch

### Distribution Expansion
- [ ] **F-Droid submission** — privacy-focused, builds from source, great fit for a local-first journal
- [ ] **Homebrew cask** — once macOS build is stable and download URL is predictable
- [ ] **Apple Developer Program** — future; enables TestFlight + App Store (paid, $99/yr)

### Community
- [ ] Label `good first issue` on 5-10 approachable tasks
- [ ] Publish a lightweight roadmap (GitHub Projects or `ROADMAP.md`)
- [ ] Set up issue templates (bug report, feature request)
- [ ] Review and merge first community PRs promptly to build momentum

---

## Open Decisions

| Decision | Options | Leaning |
|----------|---------|---------|
| `pubspec.lock` in repo? | Track (reproducible) vs. ignore (cleaner diffs) | Track it |
| Git sync auth method | SSH key vs. personal access token | Support both |
| Announcement channels | HN, Reddit, Mastodon, X | TBD |
| Conflict resolution | Last-write-wins vs. prompt user | Prompt user |

---

*Draft — edit before publishing*
