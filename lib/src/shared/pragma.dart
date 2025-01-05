// Tests if the code is targeting JavaScript.
const isJavaScript = identical(1, 1.0);

// Request a function to be inlined.
const preferInline = isJavaScript ? preferInlineJs : preferInlineVm;
const preferInlineJs = pragma('dart2js:prefer-inline');
const preferInlineVm = pragma('vm:prefer-inline');

// Removes all array bounds checks.
const noBoundsChecks = isJavaScript ? noBoundsChecksJs : noBoundsChecksVm;
const noBoundsChecksVm = pragma('vm:unsafe:no-bounds-checks');
const noBoundsChecksJs = pragma('dart2js:index-bounds:trust');
