# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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