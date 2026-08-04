# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-08-03

> **Breaking:** the `req` requirement is raised from `~> 0.5.18` to `~> 0.7`
> (see Security below). Apps pinned to `req` 0.5.x/0.6.x must upgrade to `req`
> 0.7.x. This release also replaces the `req_telemetry` dependency with the
> maintained `req_tele` fork; the emitted telemetry events are unchanged
> (`[:req, :request, :pipeline | :adapter, ...]`).

### Security
- Bumped runtime HTTP-stack dependencies to resolve reported advisories: `req` 0.5.18 → 0.7.2 (CVE-2026-49755 HIGH, CVE-2026-49756 LOW), `mint` 1.9.0 → 1.9.3 (CVE-2026-56810 HIGH), and `hpax` 1.0.3 → 1.0.4 (CVE-2026-58226 HIGH). Moving to `req` 0.7 required replacing `req_telemetry` (unmaintained, pinned `req ~> 0.5.0`) with the API-compatible `req_tele` fork, which allows current `req` — so no dependency `override` is needed.
- Bumped transitive test-only dependencies to resolve reported advisories in the Cowboy stack (pulled in via `bypass`): `cowboy` 2.12.0 → 2.18.0, `cowlib` 2.13.0 → 2.19.0, `plug_cowboy` 2.7.1 → 2.9.0, `plug` 1.19.2 → 1.20.3, `ranch` 1.8.0 → 1.8.1. These are only used by the test suite and are not shipped in the published package. Two `cowlib` advisories (CVE-2026-43966, CVE-2026-43969) remain with no upstream fix and are ignored in the CI audit step.

### Changed
- **Minimum Elixir version is now 1.15** (was 1.14) and **minimum Erlang/OTP is now 25** (was 24). This follows the `req`/`finch` HTTP stack: `finch` 0.22 requires Elixir ~> 1.15 and uses an OTP 25+ `:ets` option.
- Added Elixir 1.20 to the CI test matrix (OTP 27+).
- Added a `mix hex.audit` security-advisory check to CI that fails the build on known advisories in the dependency tree.
- Updated dependencies:
  - Bumped `credo` from 1.7.18 to 1.7.19
  - Bumped `ecto` from 3.13.6 to 3.14.0
  - Bumped `ex_doc` from 0.40.2 to 0.40.3
  - Bumped `yaml_elixir` from 2.12.1 to 2.12.2

## [0.2.3] - 2026-05-20

### Fixed
- Fixed `OrderCancelTransaction` model, `replaced_by_order_id` is not always included in API response.

### Changed
- Updated dependencies:
  - Bumped `credo` from 1.7.16 to 1.7.18
  - Bumped `ecto` from 3.13.5 to 3.13.6
  - Bumped `ex_doc` from 0.40.1 to 0.40.2

## [0.2.2] - 2026-03-02

### Added
- Added integration tests for HTTP request construction across all generated API modules (Accounts, Orders, Trades, Positions, Pricing, Instruments, Transactions).
- Added missing tests for `StopLossOrderRequest`, `TransportError`, and `ValidationError` modules.

### Fixed
- Fixed flaky test `preprocess_data/2 does not log warnings for valid changesets` by checking for absence of warning messages instead of empty log output, preventing failures when info-level logs from Req are captured during parallel test execution.
- Fixed `Account` schema fields that were incorrectly marked as required: `last_margin_call_extension_time`, `margin_call_extension_count`, `margin_call_enter_time`, `resettabled_pl_time`

### Changed
- Updated dependencies:
  - Bumped `credo` from 1.7.14 to 1.7.16
  - Bumped `ex_doc` from 0.39.3 to 0.40.1
  - Bumped `polymorphic_embed` from 5.0.3 to 5.0.6
  - Bumped `req` from 0.5.16 to 0.5.17
  - Bumped `yaml_elixir` from 2.12.0 to 2.12.1

## [0.2.1] - 2025-12-17

### Fixed
- Fixed `BadMapError` when Cloudflare returns HTML error page with 200 status code instead of JSON. The SDK now properly returns `{:error, %ExOanda.DecodeError{}}` instead of raising `BadMapError` when the response body is HTML (string) instead of decoded JSON (map).

### Changed
- Updated dependencies:
  - Bumped `ecto` from 3.13.4 to 3.13.5
  - Bumped `dialyxir` from 1.4.6 to 1.4.7
  - Bumped `req` from 0.5.15 to 0.5.16
  - Bumped `credo` from 1.7.13 to 1.7.14
  - Bumped `ex_doc` from 0.39.2 to 0.39.3

## [0.2.0] - 2025-11-07

### Added
- Add basic security policy (`SECURITY.md`)
- Add Elixir `1.18` and `1.19` to CI
- Added type-specific order request schemas (`MarketOrderRequest`, `LimitOrderRequest`, `StopOrderRequest`, `MarketIfTouchedOrderRequest`, `TakeProfitOrderRequest`, `StopLossOrderRequest`, `GuaranteedStopLossOrderRequest`, `TrailingStopLossOrderRequest`) with type-specific defaults and validations

### Changed
- Updated dependencies:
  - Bumped `ecto` from 3.13.3 to 3.13.4
  - Bumped `recase` from 0.9.0 to 0.9.1
  - Bumped `ex_doc` from 0.38.4 to 0.39.1
- Updated `ecto` enums to align with API defaults:
  - `OrderRequest.time_in_force` default is now `:FOK`
  - `OrderRequest.position_fill` default is now `:DEFAULT`
  - `GuaranteedStopLossDetails.time_in_force` default is now `:GTC`
  - `StopLossDetails.time_in_force` default is now `:GTC`
  - `TakeProfitDetails.time_in_force` default is now `:GTC`
  - `TrailingStopLossDetails.time_in_force` default is now `:GTC`
- **BREAKING** `CreateOrder` now uses polymorphic embeds with separate schemas per order type. The `type` field must now be explicitly provided when creating orders; it no longer defaults to `:MARKET`. Each order type now has type-specific defaults for `time_in_force` (e.g., `MARKET` defaults to `FOK`, `LIMIT` defaults to `GTC`) and type-specific required field validations (e.g., `LIMIT` orders require `price`, `TRAILING_STOP_LOSS` orders require `distance` and `trade_id`)
- **BREAKING** `ReplaceOrder` now uses polymorphic embeds with separate schemas per order type, matching the `CreateOrder` implementation. The `type` field must now be explicitly provided when replacing orders. Each order type now has type-specific defaults for `time_in_force` and type-specific required field validations.

### Fixed
- Fixed `CreateOrder` and `ReplaceOrder` to return validation errors instead of raising when an invalid order type is provided. Non-bang functions now properly return `{:error, %ExOanda.ValidationError{}}` instead of raising exceptions.

### Removed
- Removed `OrderRequest` schema module as it has been superseded by type-specific order request schemas (`MarketOrderRequest`, `LimitOrderRequest`, etc.)

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
