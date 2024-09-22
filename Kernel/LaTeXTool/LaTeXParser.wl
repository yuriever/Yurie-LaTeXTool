(* ::Package:: *)

(* ::Section:: *)
(*Begin*)


BeginPackage["Yurie`LaTeXTool`Parser`"];


Needs["Yurie`LaTeXTool`"];

ClearAll["`*"];


(* ::Section:: *)
(*Public*)


LaTeXParser::usage =
    "a simple parser of LaTeX.";


(* ::Section:: *)
(*Private*)


(* ::Subsection:: *)
(*Begin*)


Begin["`Private`"];


(* ::Subsection:: *)
(*Constant*)


(*FileNameJoin[$thisPromptDir,"regex for newcommand.nb"]*)

$newcommandP =
    RegularExpression["\\\\newcommand\\{\\\\(\\w+)\\}(\\[(\\d+)\\])?\\{((?:[^{}]|\\{(?:[^{}]|\\{[^{}]*\\})*\\})*)\\}"];

$renewcommandP =
    RegularExpression["\\\\renewcommand\\{\\\\(\\w+)\\}(\\[(\\d+)\\])?\\{((?:[^{}]|\\{(?:[^{}]|\\{[^{}]*\\})*\\})*)\\}"];

$providecommandP =
    RegularExpression["\\\\providecommand\\{\\\\(\\w+)\\}(\\[(\\d+)\\])?\\{((?:[^{}]|\\{(?:[^{}]|\\{[^{}]*\\})*\\})*)\\}"];


$newenvironmentP =
	Pass;


(*FileNameJoin[$thisPromptDir,"regex for comment.nb"]*)

$commentP =
    RegularExpression["(?m)(%.*)$"];


$ignoredLineP =
	StartOfLine~~Shortest[Except["\n"]...]~~"% LaTeXTool: skip"~~EndOfLine;

$ignoredBlockP =
    StartOfLine~~"% LaTeXTool: off"~~Shortest[___]~~"% LaTeXTool: on"~~EndOfLine;


(* ::Subsection:: *)
(*Main*)


Needs["Lacia`Base`"];

ClearAll[LaTeXParser];



LaTeXParser[file_] :=
    Module[ {string,data,newcommand},
        string =
            Import[file,"Text"]//removeIgnoredLine//removeIgnoredBlock//removeComment;
        data =
            <|
                "NewCommand"->extractNewCommand[string],
                "RenewCommand"->extractRenewCommand[string],
                "NewEnvironment"->extractNewEnvironment[string]
            |>;
        newcommand =
            data//Lookup[{"NewCommand","RenewCommand"}]//Flatten;
        <|
            "Data"->data,
            "MathJaxJSONString"->getMathJaxJSONString[newcommand],
            "MathJaxTestString"->getMathJaxTestString[newcommand]
        |>
    ];


(* ::Subsection:: *)
(*Helper*)


removeIgnoredLine[string_String] :=
    StringDelete[string,$ignoredLineP];


removeIgnoredBlock[string_String] :=
    StringDelete[string,$ignoredBlockP];


removeComment[string_String] :=
    StringDelete[string,$commentP];


extractNewCommand[string_String] :=
    StringCases[string,$newcommandP:><|
        "Name"->"$1",
        "ArgNumber"->
            If[ "$3"==="",
                0,
                ToExpression["$3"]
            ],
        "Definition"->"$4"
    |>];


extractRenewCommand[string_String] :=
    StringCases[string,$renewcommandP:><|
        "Name"->"$1",
        "ArgNumber"->
            If[ "$3"==="",
                0,
                ToExpression["$3"]
            ],
        "Definition"->"$4"
    |>];


extractNewEnvironment[string_String]:=
	Pass;


getMathJaxJSONString[data:{___Association}] :=
    data//Query[All,
        If[ #ArgNumber===0,
            #Name->#Definition,
            (*Else*)
            #Name->{#Definition,#ArgNumber}
        ]&
    ]//ExportString[#,"JSON",CharacterEncoding->"ASCII"]&;


getMathJaxTestString[data:{___Association}] :=
    data//Query[All,"\\"~~#Name~~StringRepeat["{*}",#ArgNumber]&]//
    	StringRiffle[#,{
    	    "# MathJax macro\n\nWatched by LaTeX-macro-convert.nb${}$\n\n\\begin{align}\n&",
    	    "\\\\\n&",
    	    "\n\\end{align}\n"
	    }]&;


(* ::Subsection:: *)
(*End*)


End[];


(* ::Section:: *)
(*End*)


EndPackage[];
