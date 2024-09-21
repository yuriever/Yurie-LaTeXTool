(* ::Package:: *)

(* ::Section:: *)
(*Begin*)


BeginPackage["Yurie`LaTeXTool`STYParser`"];


Needs["Yurie`LaTeXTool`"];


(* ::Section:: *)
(*Public*)


extractMacroFromSTY::usage =
    "extract the macros in STY files.";

overwriteMacroInJSON::usage =
    "overwrite the macros in JSON files used by MathJax.";


(* ::Section:: *)
(*Private*)


(* ::Subsection:: *)
(*Begin*)


Begin["`Private`"];


(* ::Subsection:: *)
(*extractMacroFromSTY*)


(* ::Subsubsection:: *)
(*Main*)


extractMacroFromSTY[sourceDir_?DirectoryQ,styNameList:{__String},excludedMacroList:{___String}] :=
    styNameList//Map[FileNameJoin@{sourceDir,#<>".sty"}&]//Map[Import[#,"Text"]&]//StringRiffle[#,"\n"]&//
		extractMacroFromString[excludedMacroList];


(* ::Subsubsection:: *)
(*Helper*)


extractMacroFromString[excludedMacroList_List][string_String] :=
    Module[ {macroList,macroCache,stringRest},
        macroCache = <|
            "Command"-><||>,
            "Environment"->{},
            "Test"->{},
            "CWL"->{}
        |>;
        macroList =
            string//preprocess//extractMacro;
        stringRest =
            macroList//StringReplace[converter[macroCache,excludedMacroList,"with_parameter"]]//
				StringReplace[converter[macroCache,excludedMacroList,"plain"]]//
					StringReplace[converter[macroCache,excludedMacroList,"environment"]];
        macroCache//Query[<|
            "Origin"->macroList,
            "Command"->#Command,
            "Environment"->#Environment,
            "Rest"->DeleteCases[stringRest,""|" "],
            "Test"->StringRiffle[#Test,{"# MathJax macro\n\nWatched by LaTeX-macro-convert.nb${}$\n\n\\begin{align}\n&","\\\\\n&","\n\\end{align}\n"}],
            "JSON"->ExportString[#Command,"JSON",CharacterEncoding->"ASCII"],
            "CWL"->StringRiffle[#CWL,"\n"]
        |>&]
    ];


preprocess[string_] :=
    string//StringSplit[#,"\n"]&//StringTrim//Nest[regulator,#,2]&;


extractMacro[stringList_] :=
    StringCases[stringList,{StartOfString~~"\\newcommand"~~___,StartOfString~~"\\newenvironment"~~___}]//Flatten;


regulator[string_] :=
    StringReplace[
        string,
        {
            "\\renewcommand"->"\\newcommand",
            "\\providecommand"~~__:>"",
            "\\AtBeginDocument{"~~Longest[string1__]~~"}":>string1
        }
    ];


converter//Attributes =
    {HoldFirst};

converter[macroCache_,excludedMacroList_List,"with_parameter"] :=
    {
        "\\newcommand{\\"~~Shortest[macroName__]~~"}["~~num_?DigitQ~~"]{"~~Longest[macroBody__]~~"}"/;validQ[excludedMacroList][macroName]:>
            (
                AppendTo[
                    macroCache["Test"],
                    "\\"~~macroName~~StringRepeat["{*}",ToExpression@num]
                ];
                AppendTo[
                    macroCache["CWL"],
                    "\\"~~macroName~~StringRepeat["{}",ToExpression@num]
                ];
                AssociateTo[
                    macroCache["Command"],
                    macroName->{macroBody,num}
                ];
                ""
            )
    };

converter[macroCache_,excludedMacroList_List,"plain"] :=
    {
        "\\newcommand{\\"~~Shortest[macroName__]~~"}{"~~Longest[macroBody__]~~"}"/;validQ[excludedMacroList][macroName]:>
            (
                AppendTo[
                    macroCache["Test"],
                    "\\"~~macroName
                ];
                AppendTo[
                    macroCache["CWL"],
                    "\\"~~macroName
                ];
                AssociateTo[
                    macroCache["Command"],
                    macroName->macroBody
                ];
                ""
            )
    };


converter[macroCache_,excludedMacroList_List,"environment"] :=
    {
        "\\newenvironment{"~~Shortest[macroName__]~~"}"/;validQ[excludedMacroList][macroName]:>
            (
                AppendTo[
                    macroCache["Test"],
                    "\\begin{"~~macroName~~"}*\\end{"~~macroName~~"}"
                ];
                AppendTo[
                    macroCache["CWL"],
                    "\\begin{"~~macroName~~"}\n\\end{"~~macroName~~"}"
                ];
                AppendTo[
                    macroCache["Environment"],
                    macroName
                ];
                ""
            )
    };


validQ[excludedMacroList_List][macroName_String] :=
    !StringMatchQ[macroName,excludedMacroList];


(* ::Subsection:: *)
(*overwriteMacroInJSON*)


(* ::Subsubsection:: *)
(*Main*)


overwriteMacroInJSON[file:_String|_File,macro_String,{opener_String,closer_String}] :=
    (
        Import[file,"String"]//StringReplace[
            opener~~blanks:Whitespace~~"macros: "~~___~~closer:>
                opener~~lineMoveRight[blanks]@StringJoin["macros: ",macro]~~",\n"~~blanks~~closer
        ]//Export[file,#,"Text"]&;
    );

overwriteMacroInJSON[fileList_List,macro_String,{opener_String,closer_String}] :=
    Scan[overwriteMacroInJSON[#,macro,{opener,closer}]&,fileList];


(* ::Subsubsection:: *)
(*Helper*)


lineMoveRight[blanks_String][str_String] :=
    StringSplit[str,"\n"]//Map[StringJoin[blanks,#]&]//StringRiffle[#,"\n"]&;


(* ::Subsection:: *)
(*End*)


End[];


(* ::Section:: *)
(*End*)


EndPackage[];
