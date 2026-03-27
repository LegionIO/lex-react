# Changelog

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
