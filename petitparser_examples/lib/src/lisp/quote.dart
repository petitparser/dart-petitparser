import 'package:petitparser/petitparser.dart';

/// A quoted datum
///
class Quote {
  /// The quoted datum.
  final Parser datum;
  
  /// Constructs as a quote.
  Quote(this.datum);
}
