# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-08-11

### Added
- Aggregated JSON/YAML output across multiple AWS profiles. When using `--output=json` or `--output=yaml` with multiple profiles, a single unified document is emitted with a `profiles` array (one entry per profile) and a total `count`.
- New `version` command with aliases `-v`, `-V`, and `--version`. Supports text, JSON, and YAML outputs.

### Changed
- Removed the short alias `-v` from the global `--verbose` option to avoid conflict with the new version command.
- Refactored resource commands (ACM, Route53, Target Groups, Network Interfaces, Volumes) to support a "collect only" mode used for aggregated rendering.
- Extended `renderer` with `render_aggregated_response` to standardize multi-profile outputs.

### Documentation
- Updated README with installation steps, global options, and the aggregated output schema.

## [0.1.1] - 2024-12-03

### Added
- Search for private and public Route53 Records AWS resources. Before, it was only possible to search for only one.

## [0.1.0] - 2024-12-03

### Added
- Initial version of the project.
- Search for Target Groups AWS resources.
- Search for Network Interfaces AWS resources.
- Search for Route53 Zones AWS resources.
- Search for Route53 Records AWS resources.
- Search for Volumes AWS resources.
