---
title: Enforce English for Code and Documentation
descripcion: This rule requires that all source code, technical documentation, comments, identifiers, commit messages, and user-facing texts be generated exclusively in English, regardless of the original language of the user's prompt. It aims to ensure the universality and maintainability of the project by prohibiting the use of any other language in any generated output.
alwaysApply: true
globs:
  - '**/*.dart'
  - '**/*.md'
  - '**/*.yaml'
  - '**/*.json'
---
# Enforce English for Code and Documentation

## Description

This rule mandates that all generated output related to source code and technical documentation must be in **English**. This applies universally, regardless of the language used by the user in their prompt.

### Core Mandates:
1.  **Code and Identifiers**: All variable names, function names, class names, module names, and other code identifiers must be in English.
2.  **Comments**: All code comments, whether inline or block-level, must be written in clear and concise English.
3.  **Documentation**: All generated documentation files, such as `README.md`, `DEVELOPMENT.md`, `ARCHITECTURE.md`, `CHANGELOG.md`, and API docs, must be in English.
4.  **Commit Messages**: All git commit messages must be written in English, following conventional commit standards where applicable.
5.  **User-Facing Strings**: Default user-facing strings embedded in the code should be in English. If internationalization (i18n) is required, the base/default language must be English.

### Behavior:
- If the user provides a prompt in Spanish, French, German, or any other language, you must **translate the user's intent** and generate all resulting code, comments, and documentation in **English**.
- Do not replicate non-English terms from the prompt in the code. Instead, find the appropriate English equivalent.
- This rule serves as a strict guideline to maintain a universally understandable and maintainable codebase.

### Example Scenario:
- **User Prompt (Spanish)**: "Crea una función que calcule el total del carrito de compras. Añade una variable llamada 'precio_final'."
- **Correct AI Action**: Generate the following code:
  ```dart
  // Calculates the total price of the shopping cart.
  double calculateCartTotal() {
    // ... logic ...
    double finalPrice = 0.0; 
    // ... more logic ...
    return finalPrice;
  }
  ```
- **Incorrect AI Action**:
  ```dart
  // Calcula el total del carrito.
  double calcularTotalCarrito() {
    double precio_final = 0.0;
    return precio_final;
  }
  ```
