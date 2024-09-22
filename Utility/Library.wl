(* ::Package:: *)

(* ::Section:: *)
(*Begin*)


BeginPackage["Yurie`LaTeXTool`Library`"];


Needs["Yurie`LaTeXTool`Info`"];


(* ::Section:: *)
(*Public*)


prepareLibrary::usage =
    "prepare the library.";


(* ::Section:: *)
(*Private*)


(* ::Subsection:: *)
(*Begin*)


Begin["`Private`"];


(* ::Subsection:: *)
(*Main*)


prepareLibrary[] :=
    WithCleanup[
        Quiet@DeleteDirectory[$thisLibraryDir,DeleteContents->True];
        CreateDirectory[$thisLibraryDir],
        (**)
        ExtractArchive[
            URL["https://github.com/WGUNDERWOOD/tex-fmt/releases/latest/download/tex-fmt-aarch64-macos.tar.gz"],
            $thisLibraryDir
        ];
        File@FileNameJoin[$thisLibraryDir,"tex-fmt"]
        ,
        (**)
        Null
    ];


(* ::Subsection:: *)
(*End*)


End[];


(* ::Section:: *)
(*End*)


EndPackage[];
