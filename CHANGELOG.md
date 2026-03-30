# Changelog

## [0.1.3] - 2026-03-30

### Changed
- update to rubocop-legion 0.1.7, resolve all offenses

## [0.1.2] - 2026-03-29

### Changed
- Migrate logging calls to `log.*` via `Helpers::Lex` tagged logger; fallback to `Legion::Logging` when helper is unavailable

## [0.1.1] - 2026-03-26

### Changed
- fix remote_invocable? to use class method for local dispatch

## [0.1.0] - 2026-03-24

### Added
- Initial release: rule engine, event matcher, reaction dispatcher, loop breaker
- Wildcard event subscription via Legion::Events
- YAML-based configurable reaction rules via Legion::Settings
- Synapse autonomy level gating (OBSERVE/FILTER/TRANSFORM/AUTONOMOUS)
- Loop prevention with configurable depth limit and cooldown window
