exists(A, list(A, _, _, _, _)).
exists(A, list(_, A, _, _, _)).
exists(A, list(_, _, A, _, _)).
exists(A, list(_, _, _, A, _)).
exists(A, list(_, _, _, _, A)).

rightOf(R, L, list(L, R, _, _, _)).
rightOf(R, L, list(_, L, R, _, _)).
rightOf(R, L, list(_, _, L, R, _)).
rightOf(R, L, list(_, _, _, L, R)).

middle(A, list(_, _, A, _, _)).

first(A, list(A, _, _, _, _)).

nextTo(A, B, list(B, A, _, _, _)).
nextTo(A, B, list(_, B, A, _, _)).
nextTo(A, B, list(_, _, B, A, _)).
nextTo(A, B, list(_, _, _, B, A)).
nextTo(A, B, list(A, B, _, _, _)).
nextTo(A, B, list(_, A, B, _, _)).
nextTo(A, B, list(_, _, A, B, _)).
nextTo(A, B, list(_, _, _, A, B)).

puzzle(Houses) :-
  exists(house(red, british, _, _, _), Houses),
  exists(house(_, swedish, _, _, dog), Houses),
  exists(house(green, _, coffee, _, _), Houses),
  exists(house(_, danish, tea, _, _), Houses),
  rightOf(house(white, _, _, _, _), house(green, _, _, _, _), Houses),
  exists(house(_, _, _, pall_mall, bird), Houses),
  exists(house(yellow, _, _, dunhill, _), Houses),
  middle(house(_, _, milk, _, _), Houses),
  first(house(_, norwegian, _, _, _), Houses),
  nextTo(house(_, _, _, blend, _), house(_, _, _, _, cat), Houses),
  nextTo(house(_, _, _, dunhill, _),house(_, _, _, _, horse), Houses),
  exists(house(_, _, beer, bluemaster, _), Houses),
  exists(house(_, german, _, prince, _), Houses),
  nextTo(house(_, norwegian, _, _, _), house(blue, _, _, _, _), Houses),
  nextTo(house(_, _, _, blend, _), house(_, _, water_, _, _), Houses).

solution(FishOwner) :-
  puzzle(Houses),
  exists(house(_, FishOwner, _, _, fish), Houses).