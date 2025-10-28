# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added
- Add basic security policy (`SECURITY.md`)
- Add Elixir `1.18` and `1.19` to CI

### Changed
- Updated dependencies:
  - Bumped `ecto` from 3.13.3 to 3.13.4
  - Bumped `recase` from 0.9.0 to 0.9.1
  - Bumped `ex_doc` from 0.38.4 to 0.39.1

## [0.1.1] - 2025-10-22

### Changed
- Updated dependencies:
  - Bumped `req` from 0.5.6 to 0.5.15
  - Bumped `polymorphic_embed` from 5.0.0 to 5.0.3
  - Bumped `typed_ecto_schema` from 0.4.1 to 0.4.3
  - Bumped `ecto` from 3.12.2 to 3.13.3
  - Bumped `dialyxir` from 1.4.3 to 1.4.6
  - Bumped `recase` from 0.8.1 to 0.9.0
  - Bumped `yaml_elixir` from 2.11.0 to 2.12.0
  - Bumped `ex_doc` from 0.34.2 to 0.38.4
  - Bumped `credo` from 1.7.7 to 1.7.13
  - Bumped `excoveralls` from 0.18.2 to 0.18.5

### Fixed
- Fixed type for `Positions.close_position/5`, `body` was incorrectly marked as `String.t()` in the spec; updated to `map()`
- Fixed streaming JSON decode errors caused by incomplete JSON chunks by implementing proper buffering logic

## [0.1.0] - 2025-10-18

### Changed
- Released to Hex.pm; updated `mix.exs`, `README.md` accordingly

## [0.0.21] - 2025-10-16

### Added
- Added `CHANGELOG.md`
- Added error handling and telemetry sections to `README.md`

### Changed
- **BREAKING** Changed `Connection.telemetry` to reference a new `Telemetry` struct, for enabling telemetry, using the default logger provided by `Req.Telemetry` and passing options to `Req.Telemetry`.
- **BREAKING** streaming functions without a bang (e.g. `price_stream`) now pass an ok/error tuple with the event to the specified handler function, whereas previously the unwrapped value was being sent

### Fixed
- Fixed transaction event schemas that were missing type specs
- **BREAKING** Fixed streaming transform behavior, previously calling a streaming function without a bang would still raise on a JSON decode error
    - Now the function will return an error tuple

---

## Version History Notes

### Contributing
When contributing to this project, please update this changelog with your changes following the format above. Each change should be categorized appropriately under Added, Changed, Deprecated, Removed, Fixed, or Security.
