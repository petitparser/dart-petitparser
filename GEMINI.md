# Development Charter

## General Instructions

- When generating new Dart code, strictly follow the style conventions defined in [Effective Dart](https://dart.dev/effective-dart).
- Systematically prefer using `const` constructors and literals whenever possible to optimize runtime performance.

## Comments, Documentation and Examples
  
- Use triple-slash (`///`) doc comments for all public members.
- Use square brackets (`[Name]`) to link to other members within doc comments. Use markdown sparingly.
- Start with a concise, single-sentence summary. If more detail is required, follow with a blank line and a deeper explanation (e.g., edge cases, parameters, error handling, ...).
- Include code examples for non-trivial public APIs. Ensure examples are well-formatted, accurate, and relevant. Verify that examples compile and produce the advertised output.

## Coding Style and Conventions

### Naming

- File names must use snake-case (e.g., `recipe_card.dart`).
- Class names, enums, and extensions must use upper camel-case (e.g., `RecipeCard`).
- Private class members, variables, and functions (visible only within the file) must be prefixed with an underscore `_`.

### Imports

- Adhere to the `directives_ordering` linter rule: `dart:` imports first, then `package:` imports, then relative imports.
- Within `lib/`, prefer relative imports (e.g., `import 'src/utils.dart';`) over package imports.

### Code Quality

- The code must be free of linter warnings (run `dart analyze` and `dart fix --apply`).
- The code must be auto-formatted (run `dart format .`).
- Embrace strict **null safety**. Avoid using the non-null assertion operator (`!`) unless you can prove adherence to a loop invariant or similar logical guarantee that the compiler cannot infer.

## Logic and Patterns

### Asynchrony

- Prefer `async` / `await` syntax over chaining `Future.then`, `Future.catchError`, etc., for better readability.
- Always return `Future<void>` instead of `void` for asynchronous functions (unless it's an event handler where `void` is required).

### Error Handling

- Throw specific exceptions (e.g., `ArgumentError`, `StateError`, `FormatException`) rather than generic `Exception` strings.
- Catch specific exceptions. Avoid generic `catch (e)` unless you are logging the error or rethrowing it.

## Architecture

- Keep the root `lib/` directory clean. It should primarily contain the public API exports.
- Place implementation details in `lib/src/`. Users of the package should not import files from `lib/src/` directly.
- Avoid introducing new external dependencies in `pubspec.yaml` unless absolutely necessary and no alternative exists in the SDK. If required, justify the addition to the user.

## Testing

- All new code must be accompanied by unit tests in the `test/` folder.
- Structure the tests following the same folder structure as the code under test (e.g., `lib/src/foo/bar.dart` -> `test/foo/bar_test.dart`).
- Use `expect` with literal values or matchers to assert the expected behavior (e.g., `expect(result, 'expected')`, `expect(list, isEmpty)`).
- Group tests by functionality using `group('description', () { ... })`. Avoid declaring a single top-level group in a file.
