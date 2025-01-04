/// Tests if the code is targeting JavaScript.
const isJavaScript = identical(1, 1.0);

// Request a function to be inlined.
const inline = isJavaScript ? inlineJs : inlineVm;
const inlineJs = pragma('dart2js:tryInline');
const inlineVm = pragma('vm:prefer-inline');

// Removes all array bounds checks.
const noBoundsChecks = isJavaScript ? noBoundsChecksJs : noBoundsChecksVm;
const noBoundsChecksJs = pragma('dart2js:index-bounds:trust');
const noBoundsChecksVm = pragma('vm:unsafe:no-bounds-checks');
