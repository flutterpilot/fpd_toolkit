---
title: Final Checklist
description: This rule offers a final checklist for publishing a Dart or Flutter package. It ensures quality by covering all essential steps, including package preparation, comprehensive documentation, code quality verification, publishing readiness on pub.dev, and long-term maintenance planning.
alwaysApply: false
globs:
  - '**/pubspec.yaml'
  - '**/README.md'
  - '**/CHANGELOG.md'
  - '**/lib/**'
  - '**/test/**'
---
# Final Checklist

Before publishing your package, verify:

## 📋 Preparation
- [ ] Unique and descriptive package name
- [ ] Clear and concise description
- [ ] Correct semantic version
- [ ] Appropriate OSI license

## 📄 Documentation
- [ ] Complete README.md with examples
- [ ] Updated CHANGELOG.md
- [ ] API documentation (dartdoc)
- [ ] Functional example/ folder

## 🧪 Quality
- [ ] Unit tests (>80% coverage)
- [ ] Widget tests
- [ ] Integration tests
- [ ] No errors in static analysis
- [ ] Consistent code formatting

## 🚀 Publishing
- [ ] Successful `dart pub publish --dry-run`
- [ ] Verification with pana (130+ points)
- [ ] CI/CD configured
- [ ] Public Git repository

## 🔄 Maintenance
- [ ] Update plan
- [ ] Issue monitoring
- [ ] Contribution documentation
- [ ] Future roadmap