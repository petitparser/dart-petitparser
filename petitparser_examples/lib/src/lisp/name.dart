/// An unique symbolic name.
///
/// This provides essentially the behavior of the built-in [Symbol], but
/// allows access and printing of the underlying string.
class Name {
  /// The interned symbols.
  static final Map<String, Name> _interned = {};

  /// Factory for new symbol cells.
  factory Name(String name) =>
      _interned.putIfAbsent(name, () => Name._internal(name));

  /// The name of the symbol.
  final String _name;

  /// Internal constructor for symbol.
  Name._internal(this._name);

  /// Returns the string representation of the symbolic name.
  @override
  String toString() => _name;
}
