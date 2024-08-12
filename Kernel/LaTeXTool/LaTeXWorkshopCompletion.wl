(* ::Package:: *)

(* ::Section:: *)
(*Begin*)


BeginPackage["Yurie`LaTeXTool`LaTeXWorkshopCompletion`"];


Needs["Yurie`LaTeXTool`"];

Needs["Yurie`LaTeXTool`Info`"];


(* ::Section:: *)
(*Public*)


convertCWLToJSON::usage =
    "convert the macros in CWL files into JSON format used by LaTeX-Workshop.";

addPackageToJSON::usage =
    "add package information to JSON files used by LaTeX-Workshop";


(* ::Section:: *)
(*Private*)


(* ::Subsection:: *)
(*Begin*)


Begin["`Private`"];


(* ::Subsection:: *)
(*convertCWLToJSON*)


(* ::Subsubsection:: *)
(*Main*)


convertCWLToJSON[sourceDir_?DirectoryQ,targetDir_?DirectoryQ] :=
    WithCleanup[
        shell =
            StartExternalSession["Shell"],
        Scan[
            ExternalEvaluate[shell,"python "<>robustPath[$thisLibrary]<>" -i "<>robustPath[#]<>" -o "<>robustPath[targetDir]]&,
            FileNames["*.cwl",sourceDir]
        ],
        DeleteObject[shell]
    ];


(* ::Subsubsection:: *)
(*Helper*)


robustPath[path_] :=
    "\""<>AbsoluteFileName[path]<>"\"";


(* ::Subsection:: *)
(*addPackageToJSON*)


(* ::Subsubsection:: *)
(*Main*)


addPackageToJSON[file:_String|_File,packageList:{__String}] :=
    (
        Import[file,"String"]//StringReplace[
            "\"includes\": {},":>
                "\"includes\": {"<>StringRiffle[packageList,{"\"","\": [],\"","\": []"}]<>"},"
        ]//Export[file,#,"Text"]&;
    );

addPackageToJSON[file:_String|_File,{}] :=
    Null;


(* ::Subsubsection:: *)
(*Helper*)


(* ::Subsection:: *)
(*End*)


End[];


(* ::Section:: *)
(*End*)


EndPackage[];
