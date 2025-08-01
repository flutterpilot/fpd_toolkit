---
title: Quality Checklist
description: This rule provides a final quality checklist for Flutter and Dart projects, based on official examples. The checklist covers all critical aspects of development, including architecture, code quality, UI/UX, performance, testing, security, multiplatform compatibility, and maintenance, to ensure a professional and robust final product.
alwaysApply: false
globs:
  - '**/pubspec.yaml'
  - '**/lib/**'
  - '**/*.md'
  - '**/test/**'
---
# Quality Checklist 

## Final Quality Checklist

### Architecture
- [ ] Clean Architecture implemented
- [ ] Clear separation of responsibilities
- [ ] Dependency injection configured
- [ ] Appropriate design patterns

### Code
- [ ] Naming conventions followed
- [ ] Complete documentation (dartdoc)
- [ ] Robust error handling
- [ ] Logging implemented

### UI/UX
- [ ] Material 3 Design System
- [ ] Responsive design
- [ ] Smooth animations
- [ ] Accessibility considered

### Performance
- [ ] Widgets optimized with const
- [ ] Virtualized lists
- [ ] Optimized images
- [ ] Memory leaks checked

### Testing
- [ ] >90% code coverage
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Golden tests

### Security
- [ ] Secure storage
- [ ] Input validation
- [ ] Certificate pinning
- [ ] Sensitive data protected

### Multiplatform
- [ ] Platform-specific code isolated
- [ ] Adaptive widgets
- [ ] Navigation 2.0
- [ ] Responsive for desktop

### Maintenance
- [ ] Code generation configured
- [ ] CI/CD pipeline
- [ ] Documentation updated
- [ ] Semantic versioning