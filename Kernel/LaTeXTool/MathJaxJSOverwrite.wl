(* ::Package:: *)

(* ::Section:: *)
(*Begin*)


BeginPackage["Yurie`LaTeXTool`MathJaxJSOverwrite`"];


Needs["Yurie`LaTeXTool`"];


(* ::Section:: *)
(*Public*)


MathJaxJSOverwrite::usage =
    "overwrite JavaScript files used by MathJax.";


(* ::Section:: *)
(*Private*)


(* ::Subsection:: *)
(*Begin*)


Begin["`Private`"];


(* ::Subsection:: *)
(*Constant*)


$MathJaxMacroOpener =
    "// MathJaxJSOverwrite-Macro-Begin";

$MathJaxMacroCloser =
    "// MathJaxJSOverwrite-Macro-End";


(* ::Subsection:: *)
(*Main*)


MathJaxJSOverwrite[macro_String][file:_String|_File] :=
    Import[file,"String"]//StringReplace[
        $MathJaxMacroOpener~~"\n"~~blanks:Whitespace~~"macros: "~~___~~$MathJaxMacroCloser:>
            $MathJaxMacroOpener~~"\n"~~lineMoveRight[blanks]@StringJoin["macros: ",macro]~~",\n"~~blanks~~$MathJaxMacroCloser
    ]//Export[file,#,"Text"]&//File;

MathJaxJSOverwrite[macro_String][fileList_List] :=
    Map[MathJaxJSOverwrite[macro],fileList];


(* ::Subsection:: *)
(*Helper*)


lineMoveRight[blanks_String][str_String] :=
    StringSplit[str,"\n"]//Map[StringJoin[blanks,#]&]//StringRiffle[#,"\n"]&;


(* ::Subsection:: *)
(*End*)


End[];


(* ::Section:: *)
(*End*)


EndPackage[];
