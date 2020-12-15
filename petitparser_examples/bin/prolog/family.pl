father_child(massimo, ridge).
father_child(eric, thorne).
father_child(thorne, alexandria).

mother_child(stephanie, thorne).
mother_child(stephanie, kristen).
mother_child(stephanie, felicia).

parent_child(X, Y) :- father_child(X, Y).
parent_child(X, Y) :- mother_child(X, Y).

sibling(X, Y) :- parent_child(Z, X), parent_child(Z, Y).

ancestor(X, Y) :- parent_child(X, Y).
ancestor(X, Y) :- parent_child(X, Z), ancestor(Z, Y).