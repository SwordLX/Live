program = commands: ( Command + _) + {
     return commands.join("");
}

Command = element: (defineCommand/groupFormationCommand/constructionCommand) _ ";" _ ?
{ return element; }

//command for define variable
defineCommand 
    = element: (variableName: variable _ "=" _ object chain)
    { let selected = ["Object", "Definition", element[4], element[5]];
      return selected; }

//define Group formation Function
groupFormationCommand
    = element: (variableName: variable _ "=" _ list) 
    { let selected = [element[0], element[2], element[4]];
       return selected; }
       
//define command for building object in circle
buildObjectsInCircleCommand
    = element: ( "circle" variable "center" '(' _ vector _ ')' '.' "radius" '('_ number _')')
    { let selected = [element[0], element[1], element[3]];
      return selected;}

//define command for Complex Construction
constructionCommand = InitializeConstruction/constructionOperation

//define command for Construction Mesh Initialization
InitializeConstruction = "construction:" _ Base:objectTypeKeyword _ properties:(loc _ vector) _ material:assignMaterial?
   {  let selected = ["construct", "setup", Base, properties[0], properties[2]];
      if(material) selected.push(material);
      return selected; }

//define the struct of construction operation
constructionOperation = rotate:rot _ angle:number _ rotateTime:positiveInterger _ objectNumber:positiveInterger _ gapLength:positiveNumber?_ 
   { if(angle>360.0) { angle = angle%360.0}
     let selected = ["construct", "op", rotate, angle, rotateTime, objectNumber]; 
     if(gapLength) { selected.push(gapLength);}
     return selected; }

//define function chain
chain = a:(_ function "."? )+
   { return a.map (element => element[1]);}

//define function
function = functionFormat01/functionFormat02

functionFormat01= functionName:keyword _ parameter:(list/vector/variable/number)  _
    { 
      let selected = [functionName, parameter];
      return selected; }

functionFormat02 = functionName:keyword '(' parameter:(list/vector/variable/number) _ ')' _
    {
       let selected = [functionName, parameter];
       return selected
    }

//define object function
object = objectFormat01/objectFormat02

objectFormat01 = objectType: objectTypeKeyword '('_ id:integer _ ')'? "."?
    { let selected = [objectType, id];
       return selected; }
       
objectFormat02 = objectType: objectTypeKeyword "."?
     { return objectType;}

//define keyword
keyword = "ID"/"speed"/"mat"/loc/rot/scale

//define object type
objectTypeKeyword = "particle"/"cube"/"sphere"/"cylinder"

//define material assignment command
assignMaterial = cm:"mat" _ "(" matName: (_ variable _) ")" _ 
{  let selected = [cm, matName[1]];
    return selected; }

//define position symbol
loc = ">"{ return "location";}

//define rotation symbol
rot = op: ("@x"/"@y"/"@")
   { if(op == "@") { return "rotateZ"; }
     else if(op == "@x") { return "rotateX"; }
     else if(op == "@y") { return "rotateY"; }
     }

//define scale symbol
scale = "^" { return "scale"; }

//define variable name
variable = name :(number/word)+ { return text();}

//define list
list = "(" item:(  _ number _ ","* )+ ")"
       { console.log(item);
         return item.map ( arr => arr[1]);}

//define vector
vector 
    = "vec3"*"("  _ x: number _ "," _ y: number _ "," _ z: number _ ")"
    { return [x, y, z]; }
    
//define number
number = "-"? (([0-9]+ "." [0-9]*) / ("."? [0-9]+)) { return text(); }
//define positive number
positiveNumber = (([0-9]+ "." [0-9]*) / ("."? [0-9]+)) { return text(); }

//define integer
integer = "-"?[0-9]+
{ return text();}
positiveInterger = [0-9]+
{ return text();}

//define word
word = digit+ { return text();}

digit = [a-zA-Z@]

_ "whitespace"
  = [ \t\n\r]*