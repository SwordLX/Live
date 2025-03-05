program = commands: ( Command + _) + {
     return commands.join("");
}

Command = element: (chain/ManagerCommand/ObjectCommand/SingleLoop) _ ";"? _
{ return element; }

//function and chain
//define function chain
chain = a:(_ function _ ("."/"&")? )+
   { let elements = a.map (element => element[1]);
     let result = [];
      elements.forEach((el, index)=>{
      result.push(el);
      result.push("//");
     })
     return result;
    }

//define function
function = ManagerCommand/ObjectCommand

//define loop

SingleLoop = "Loop" "(" _ time:(positiveInteger) _ ")" _ "{" _ commandGroup:(_ SingleLoopElement _ ";"? _)* _ "}" _
              {
                let commands = commandGroup.map(arr=>arr[1]);
                let result = [];
                let max = parseInt(time);
                let i = 0;
                while(i<max)
                {
                   commands.forEach(command=>{
                   result.push(command, "//");
                   });
                   i++;
                }
                return result;
              }
SingleLoopElement = directionalSpawn/setSpawnRotation/BuildCircleCommand/SingleLoop/ShaderCommand

//define command for Complex Construction
ManagerCommand = constructionCommand/SpawnCommand/ShaderCommand/IterationCommand
constructionCommand = constructionOperation/BuildCircleCommand/SetMeshCommand
SpawnCommand = directionalSpawn;
ShaderCommand = SetMaterialCommand/SetColorCommand;
IterationCommand = moveSpawnLocation/setSpawnRotation/SetGapCommand


//define the struct of construction operation
constructionOperation = rotate:rot _ angle:number _ rotateTime:positiveInteger _ objectNumber:positiveInteger _ gapLength:positiveNumber?_ 
   { if(angle>360.0) { angle = angle%360.0}
     let selected = ["construct", rotate, angle, rotateTime, objectNumber]; 
     if(gapLength) { selected.push(gapLength);}
     return selected; }

//define command for building object in circle
BuildCircleCommand
    = element: ( _ "O" '('_ positiveNumber _')' _ '*' _ objectNumber: (positiveInteger) _ )
    { let selected = ["create", "circle", element[4], element[10]];
      return selected;}

moveSpawnLocation = op:moveSymbol _ parameter: vector _ { return [op, "position",parameter]; }
setSpawnRotation = op:rot _ parameter:number _ { return ["rotate", op, parameter];}
directionalSpawn = op:directionalSymbol _ parameter:positiveInteger _ { return [op, "create", parameter];}
SetMaterialCommand = _ parameter: assignMaterial { return ["set", parameter]}
SetMeshCommand = op: "=>" _ parameter: variable { return ["set", "mesh", parameter]; }
SetGapCommand = op: "__" _ parameter: positiveNumber _ { return ["set","gaplength", parameter];}
SetColorCommand = op: colorOp _ parameter: vector _ { return ["set", op, parameter]; }
directionalSymbol = forwardSymbol/backwardSymbol/leftwardSymbol/rightwardSymbol/upwardSymbol/downwardSymbol
moveSymbol = item:(_ "->"_ ) { return "move"; }
forwardSymbol = "::" { return "forward"; }
backwardSymbol = "xx" { return "backward" ;}
leftwardSymbol = "<<" { return "leftward";}
rightwardSymbol = ">>" { return "rightward"; }
upwardSymbol = "^^" { return "upward"; }
downwardSymbol = "vv" { return "downward"; }

//**************** Object Command ****************************/
ObjectCommand = ObjectCommandRegion/NewObjectCommandRegion/SpecificObjectControlCommand/NewestObjectControlCommand
//Control Object
NewObjectCommandRegion = ids:lastObjects _ "{" _ commandGroup:(_ ObjectFunction _)* _"}"
   {
     let commands = commandGroup.map(arr=>arr[1]);
     let result = [];
     commands.forEach((command, index) =>{
        result.push(ids, command, "//");
     })
     return result;
   }

ObjectCommandRegion = ids:idFormat _ "{" _ commandGroup: (_ ObjectFunction _ )* _ "}"
   {
     let commands = commandGroup.map(arr=>arr[1]);
     let result = [];
     ids.forEach((item, index) => {
         commands.forEach(command => {
            result.push("Object", command, item, "//");
         })
     })
     
     return result;
   }

//Control last group (the newest objects just be created)
NewestObjectControlCommand = ids:lastObjects _ op2: objectOP _ parameter: objectParameter? _
   {
     let result = [];
     result.push("LastGroup", op2);
     if(parameter) { result.push(parameter);}
     return result;
   }

//Control 
SpecificObjectControlCommand = ids:idFormat _ op2:objectOP _ parameter: objectParameter? _
    {
       let result = [];
       ids.forEach( (item, index) => {
          result.push("Object", op2, item);
          if(parameter) { result.push(parameter);}
          result.push("//");
       })
       return result;
    }
//Object Function format
ObjectFunction = op:objectOP _ parameter: objectParameter? _ ";"? _
{
    let result = [];
    result.push(op);
    if(parameter) { result.push(parameter);}
    return result;
}

idFormat = list/IDGroup
objectOP = offsetSymbol/rot/rotRate/scale/assignMaterial/colorOp
objectParameter = variable/vector/number
offsetSymbol = "$" { return "offset";}
lastObjects = "[...]" { return "LastGroup";}

//define material assignment command
assignMaterial = op:(":") _  matName: (_ variable _)  _ 
{  let selected = ["material" , matName[1]];
    return selected; }

colorOp = _ "#" _ { return ["color"]}


//define rotation symbol
rot = op: ("@x"/"@y"/"@z")
   { let result = ["direction"];
     if(op == "@z") { result.push("Z"); }
     else if(op == "@x") { result.push("X"); }
     else if(op == "@y") { result.push("Y"); }
     return result;
     }

rotRate = op: ("@@x"/"@@y"/"@@z")
  {let result = ["rotateRate"];
     if(op == "@@z") { result.push("Z"); }
     else if(op == "@@x") { result.push("X"); }
     else if(op == "@@y") { result.push("Y"); }
     return result;
  }

//define scale symbol
scale = "^" { return "scale"; }

//define variable name
variable = name :(number/word)+ { return text();}

//define list
list = "[" item:(  _ number _ ","* )+ "]"
       { console.log(item);
         return item.map ( arr => arr[1]);}

IDGroup = "[" item:( _ positiveIntegerRange _ ","*) + "]" _ rule: ("++" _ positiveInteger)?
       { let result = [];
         let filter = item.map(arr => arr[1]);
         filter.forEach(element=>{
            if(element.length<2) { result.push(element[0]);}
            else{
               let minValue = parseInt(element[0]);
               let increment = 1;
               if(rule) { increment = parseInt(rule[2]);}
               for(let maxValue = parseInt(element[1]); minValue <= maxValue; minValue+= increment){
                  console.log(minValue);
                  result.push(minValue);
               }
            }
         })
          return result;
       }

//define positiveNumber range
positiveIntegerRange = integer01: positiveInteger _ "~" _ integer02: positiveInteger
        { let value01 = parseInt(integer01); 
          let value02 = parseInt(integer02);
          if(value01>value02){ return [value02, value01];}
          else if(value01<value02) { return [value01, value02]}
          else { return [value01];}
          }

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
positiveInteger = [0-9]+
{ return text();}
word = digit+ { return text();}
digit = [a-zA-Z@]

_ "whitespace"
  = [ \t\n\r]*