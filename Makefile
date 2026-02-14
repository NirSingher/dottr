ENV_FILE ?= .env
RELEASE_ENV = .env.release

# --- Dev (uses your local .env) ---

run:
	flutter run --dart-define-from-file=$(ENV_FILE)

build-debug:
	flutter build macos --debug --dart-define-from-file=$(ENV_FILE)

# --- Release (always uses empty .env.release) ---

build-macos:
	flutter build macos --release --dart-define-from-file=$(RELEASE_ENV)

build-ios:
	flutter build ios --release --dart-define-from-file=$(RELEASE_ENV)

build-android:
	flutter build appbundle --release --dart-define-from-file=$(RELEASE_ENV)

# --- Utilities ---

clean:
	flutter clean

.PHONY: run build-debug build-macos build-ios build-android clean
