(* ::Package:: *)

(* ::Section:: *)
(*Begin*)


BeginPackage["Yurie`LaTeXTool`MathJaxOverwriteMacro`"];


Needs["Yurie`LaTeXTool`"];


(* ::Section:: *)
(*Public*)


MathJaxOverwriteMacro::usage =
    "overwrite the macros in JSON files used by MathJax.";


(* ::Section:: *)
(*Private*)


(* ::Subsection:: *)
(*Begin*)


Begin["`Private`"];


(* ::Subsection:: *)
(*Constant*)


$MathJaxMacroOpener =
    "// LaTeXTool-MathJax-Begin";

$MathJaxMacroCloser =
    "// LaTeXTool-MathJax-End";


(* ::Subsection:: *)
(*Main*)


MathJaxOverwriteMacro[file:_String|_File,macro_String] :=
    Import[file,"String"]//StringReplace[
        $MathJaxMacroOpener~~"\n"~~blanks:Whitespace~~"macros: "~~___~~$MathJaxMacroCloser:>
            $MathJaxMacroOpener~~"\n"~~lineMoveRight[blanks]@StringJoin["macros: ",macro]~~",\n"~~blanks~~$MathJaxMacroCloser
    ]//Export[file,#,"Text"]&//File;

MathJaxOverwriteMacro[fileList_List,macro_String] :=
    Map[MathJaxOverwriteMacro[#,macro]&,fileList];


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
