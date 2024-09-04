livebuild "livebuild" 
  = commands: (command + _) + {
      return commands.join("");
  }

command 
  = createRingCommand
  / otherCommands

createRingCommand
  = cmd:word _ !keyword _ tag:objecttype _ id:integer _ "(" _ radius:number _ "," _ count:integer _ "," _ position:vector _ ")" _ ";"
  {
    return [cmd, tag, id, radius, count, position];
  }

otherCommands
  = cmd:word _ !keyword tag:objecttype _ id:integer? _ expression:list? _ ";"*
  {
    return [cmd, tag, id, expression];
  }

// Define keyword
keyword
  = "create"
  / "translate"
  / "move"
  / "rotate"
  / "scale"
  / "reset"
  / "kill"
  / "activate"
  / "deactivate"
  / "paint"
  / "color"
  /"pulse"

// Define word
word
  = letters:letter+ _ { return letters.join("");}

// Define objecttype
objecttype "objectType"
  = !keyword letters: letter+ _ { return letters.join("");}

// Define integer
integer
  = "-"? intValue: digits { return parseInt(intValue); }
  / "-"? intValue: digit digit digit { return parseInt(intValue); }
  
 digits
  = digit+ { return text(); }

// Define number
number
  = "-"?((digit+ "." digit*) / ("."? digit+ )) { return +text(); }

// Define vector
vector 
  = "(" _ x:number _ "," _ y:number _ "," _ z:number _ ")" 
  { return [x, y, z]; }
  
 // define list
 list
  = "(" _ a1:number _ "," _ a2:number _ "," _ a3:number _ ","? _ a4:number? _ ")"
  { return [a1, a2, a3, a4]; }

// Define letter and digit
letter = [a-zA-Z]
digit = [0-9]

// Define whitespace
_ "whitespace"
  = [ \t\n\r]*