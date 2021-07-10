/// A generic callback function type returning a value of type [R] for a given
/// input of type [T].
typedef Callback<T, R> = R Function(T value);

/// A generic predicate function type returning `true` or `false` for a given
/// input of type [T].
typedef Predicate<T> = Callback<T, bool>;
