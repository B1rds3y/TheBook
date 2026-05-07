# UI Tokens

This project uses a layered token model for UI styling.

## Layers
- `UiCore*` in `ui_tokens.dart`: primitive scales and shared constants.
- `UiSemanticColors` in `ui_tokens.dart`: role-based color semantics.
- `UiComponentTokens` in `ui_tokens.dart`: component-level sizing/motion/effects.

## Usage Rules
- In presentation code, prefer `Ui*` token references over raw literals for:
  - spacing/padding/margins
  - radii/sizes
  - typography sizes/weights where shared
  - animation durations/timing
  - effect values (opacity, blur, elevation)
- Keep `scoreboard_tokens.dart` as a compatibility facade while migration is in progress.
- Avoid introducing new ad-hoc UI constants inside feature widgets.

## Migration Notes
- New work should consume `ui_tokens.dart` first.
- Existing `Sb*` constants map progressively to `Ui*` tokens to preserve visual parity.
