 part of reflection;

 /**
  * Removes all setable parsers reachable from [root] in-place.
  */
 Parser removeSetables(Parser root) {
   allParser(root).forEach((parent) {
     parent.children.forEach((source) {
       var target = _removeSetable(source);
       if (source != target) {
         parent.replace(source, target);
       }
     });
   });
   return _removeSetable(root);
 }

 Parser _removeSetable(Parser parser) {
   while (parser is SetableParser) {
     parser = parser.children.first;
   }
   return parser;
 }

 /**
  * Removes duplicated parsers reachable from [root] in-place.
  */
 Parser removeDuplicates(Parser root) {
   var uniques = new Set();
   allParser(root).forEach((parent) {
     parent.children.forEach((source) {
       var target = uniques.firstWhere((each) {
         return source != each && source.equals(each);
       }, orElse: () => null);
       if (target == null) {
         uniques.add(source);
       } else {
         parent.replace(source, target);
       }
     });
   });
   return root;
 }