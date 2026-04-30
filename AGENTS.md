# Thekr App - Agent Guidelines & Coding Standards

This document outlines the strict coding standards and design principles that MUST be followed by any AI agent or developer working on Thekr App.

## 1. Design System (Tokens First)
The project uses a unified Design System. **NEVER** use hardcoded values for colors, spacing, or borders.

### Colors
- **Usage:** Access via `context.colors`.
- **System:** `AppColors` (in `lib/core/theme/tokens/design_tokens.dart`).
- **Standard:** 
  - Use `primary` for main brand elements.
  - Use `secondary` for accents (Gold/Yellow).
  - Use `surface` for cards and components.
  - Use `background` for main page backgrounds.

### Spacing & Insets
- **Usage:** Access via `context.insets`.
- **Standard:**
  - `sm`: Small padding/margin (8.w)
  - `md`: Medium padding/margin (16.w)
  - `lg`: Large padding/margin (24.w)

### Corners (Radius)
- **Usage:** Access via `context.corners`.
- **Standard:**
  - `sm`: 4.r
  - `md`: 8.r
  - `lg`: 12.r
  - `xl`: 20.r

### Shadows
- **Usage:** Access via `context.shadows`.
- **Standard:** Use `low` or `medium` presets.

### Typography
- **Usage:** Access via `context.textStyles`.
- **System:** `TextTheme` (standard Flutter) configured via `AppTypography`.
- **Standard:** 
  - Use `context.textStyles.h1`, `h2`, `bodyMedium`, etc.
  - **Why?** It ensures the text responds to the active Theme (Light/Dark).
  - **Exception:** Use `AppTypography` directly ONLY when defining the theme or when a `BuildContext` is not available.

## 2. Architecture & File Structure
- **Modularization:** Each screen and widget MUST be in its own file.
- **Extensions:** Use `ThemeContextExtension` (in `lib/core/extensions/theme_extension.dart`) to access theme tokens.
- **Responsive UI:** Always use `.w`, `.h`, `.r`, and `.sp` from `flutter_screenutil`.

## 3. UI/UX Principles
- **Aesthetics:** Designs must be "Premium" (Glassmorphism, gradients, soft shadows).
- **Consistency:** Maintain the spiritual/Islamic aesthetic using existing assets like `AppAssets.around`.
- **Light/Dark Mode:** Always ensure components look great in both modes by relying on the `context.colors` tokens.

## 4. Prohibited Actions
- **NO** hardcoded hex colors (e.g., `Color(0xFF...)`).
- **NO** hardcoded `BorderRadius.circular(20)`. Use `context.corners.xl`.
- **NO** hardcoded `EdgeInsets.all(15)`. Use `EdgeInsets.all(context.insets.md)`.
- **NO** direct use of `Colors.white` or `Colors.black` unless specifically for overlays with alpha.

## 5. Data & Library Abstraction (New)
- **Library Decoupling**: NEVER use external libraries (like `adhan`) directly in UI widgets.
- **Models First**: Always use the `AppPrayerTimes` model to pass prayer data to widgets.
- **Enums Over Strings**: Use the `AppPrayer` enum for all prayer-related logic and display names.
- **Provider Centralization**: Asynchronous data (like prayer times) MUST be managed via Riverpod providers. Logic for "Next Prayer" calculation should reside in a provider, not in the widget's `build` method.

---
*Follow these rules strictly to maintain the integrity and quality of Thekr App.*
