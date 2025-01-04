// Request a function to be inlined.
const inlineVm = pragma('vm:prefer-inline');
const inlineJs = pragma('dart2js:tryInline');

// Removes all array bounds checks.
const noBoundsChecksVm = pragma('vm:unsafe:no-bounds-checks');
const noBoundsChecksJs = pragma('dart2js:index-bounds:trust');
