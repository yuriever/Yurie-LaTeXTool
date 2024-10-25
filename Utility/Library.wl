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


prepareLibrary::texfmtfailed =
    "the library tex-fmt fails to download."

prepareLibrary::autocorrectfailed =
    "the library autocorrect fails to download."


(* ::Subsection:: *)
(*Main*)


prepareLibrary["tex-fmt"] :=
    WithCleanup[
        If[ !DirectoryQ[$thisLibraryDir],
            CreateDirectory[$thisLibraryDir]
        ],
        (**)
        ExtractArchive[
            URL["https://github.com/WGUNDERWOOD/tex-fmt/releases/latest/download/tex-fmt-aarch64-macos.tar.gz"],
            $thisLibraryDir,
            OverwriteTarget->True
        ];
        ,
        (**)
        If[ !FileExistsQ@FileNameJoin[$thisLibraryDir,"tex-fmt"],
            Message[prepareLibrary::texfmtfailed]
        ]
    ];


prepareLibrary["autocorrect"] :=
    WithCleanup[
        If[ !DirectoryQ[$thisLibraryDir],
            CreateDirectory[$thisLibraryDir]
        ],
        (**)
        ExtractArchive[
            URL["https://github.com/huacnlee/autocorrect/releases/latest/download/autocorrect-darwin-arm64.tar.gz"],
            $thisLibraryDir,
            OverwriteTarget->True
        ];
        ,
        (**)
        If[ !FileExistsQ@FileNameJoin[$thisLibraryDir,"autocorrect"],
            Message[prepareLibrary::autocorrectfailed]
        ]
    ];


(* ::Subsection:: *)
(*End*)


End[];


(* ::Section:: *)
(*End*)


EndPackage[];
