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


(* ::Text:: *)
(*regex for newcommand.nb*)


$newcommandP =
    RegularExpression["\\\\newcommand\\{\\\\(\\w+)\\}(\\[(\\d+)\\])?\\{((?:[^{}]|\\{(?:[^{}]|\\{[^{}]*\\})*\\})*)\\}"];

$renewcommandP =
    RegularExpression["\\\\renewcommand\\{\\\\(\\w+)\\}(\\[(\\d+)\\])?\\{((?:[^{}]|\\{(?:[^{}]|\\{[^{}]*\\})*\\})*)\\}"];

$providecommand =
    RegularExpression["\\\\providecommand\\{\\\\(\\w+)\\}(\\[(\\d+)\\])?\\{((?:[^{}]|\\{(?:[^{}]|\\{[^{}]*\\})*\\})*)\\}"];


(* ::Text:: *)
(*regex for comment.nb*)


$commentP =
    RegularExpression["(?m)%.*$"];


(* ::Subsection:: *)
(*LaTeXParser*)


(* ::Subsubsection:: *)
(*Main*)


LaTeXParser[file_] :=
    Module[ {string},
        string = Import[file,"Text"]//cleanComment;
        <|
            "Newcommand"->extractNewcommand[string],
            "Renewcommand"->extractRenewcommand[string]
        |>
    ];


(* ::Subsubsection:: *)
(*Helper*)


cleanComment[string_] :=
    StringDelete[string,$commentP];


extractNewcommand[string_] :=
    StringCases[string,$newcommandP:><|
        "Name"->"$1",
        "ArgNumber"->
            If[ "$3"==="",
                0,
                ToExpression["$3"]
            ],
        "Definition"->"$4"
    |>];


extractRenewcommand[string_] :=
    StringCases[string,$renewcommandP:><|
        "Name"->"$1",
        "ArgNumber"->
            If[ "$3"==="",
                0,
                ToExpression["$3"]
            ],
        "Definition"->"$4"
    |>];


(* ::Subsection:: *)
(*End*)


End[];


(* ::Section:: *)
(*End*)


EndPackage[];
