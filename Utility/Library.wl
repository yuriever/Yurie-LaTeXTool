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
(*Message*)


prepareLibrary::failed =
    "the library tex-fmt fails to download."


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
        ,
        (**)
        If[ !FileExistsQ@FileNameJoin[$thisLibraryDir,"tex-fmt"],
            Message[prepareLibrary::failed]
        ]
    ];


(* ::Subsection:: *)
(*End*)


End[];


(* ::Section:: *)
(*End*)


EndPackage[];
