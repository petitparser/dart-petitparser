/// Whether the code is running in JavaScript.
const isJavaScript = identical(1, 1.0);

/// Whether the code is running in WASM.
const isWasm = bool.fromEnvironment('dart.tool.dart2wasm');

/// Compiler pragma to inline a function or method when possible.
const preferInline = isJavaScript
    ? preferInlineJs
    : isWasm
    ? preferInlineWasm
    : preferInlineVm;
const preferInlineJs = pragma('dart2js:prefer-inline');
const preferInlineVm = pragma('vm:prefer-inline');
const preferInlineWasm = pragma('wasm:prefer-inline');

/// Compiler pragma that removes all array bounds checks.
const noBoundsChecks = isJavaScript ? noBoundsChecksJs : noBoundsChecksVm;
const noBoundsChecksJs = pragma('dart2js:index-bounds:trust');
const noBoundsChecksVm = pragma('vm:unsafe:no-bounds-checks');
