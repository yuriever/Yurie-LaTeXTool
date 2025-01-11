(* ::Package:: *)

(* ::Section:: *)
(*Begin*)


BeginPackage["Yurie`LaTeXTool`LaTeXFormat`"];


Needs["Yurie`LaTeXTool`"];

Needs["Yurie`LaTeXTool`Info`"];


(* ::Section:: *)
(*Public*)


LaTeXFormat::usage =
    "format the LaTeX file.";


adjustMarkSpacingInEquation;


(* ::Section:: *)
(*Private*)


(* ::Subsection:: *)
(*Begin*)


Begin["`Private`"];


(* ::Subsection:: *)
(*Constant*)


(*maximal number of percent signs to be deleted around equations.*)

$percentLimit = 5;


(*maximal number of spacing to be deleted before equation marks.*)

$spacingLimit = 5;


(*spacing of indentation.*)

$indentationSpacing = 2;


$equationList =
    {"equation","align","gather","alignat","multline"};

$equationP =
    $equationList//Map[{"{"<>#<>"}","{"<>#<>"*}"}&]//Flatten//Apply[Alternatives];


$markList =
    {",",".",";"};

$markP =
    $markList//Apply[Alternatives];


$markSpacingList =
    {"\\;","\\,","\\:","\\>","\\ "};

$markSpacingP =
    $markSpacingList//Apply[Alternatives];


$hintAfterMarkP =
    {EndOfString,"\\end","\\\\","\\nn","\\label","\\quad","\\qquad","\\text"}//Apply[Alternatives];


(* ::Subsection:: *)
(*Option*)


LaTeXFormatKernel//Options = {
    "SurroundEquationWithPercent"->False,
    "EquationMarkSpacing"->None
};


LaTeXFormat//Options = 
    Options@LaTeXFormatKernel;


(* ::Subsection:: *)
(*Message*)


LaTeXFormat::filenotexist =
    "the file does not exist.";

LaTeXFormat::libnotexist =
    "the library tex-fmt does not exist.";

LaTeXFormat::spacingnotmatch =
    "the option EquationMarkSpacing only accepts `` or None.";

LaTeXFormat::nottex =
    "the file is not TeX."


(* ::Subsection:: *)
(*Main*)


LaTeXFormat[opts:OptionsPattern[]][file:_String|_File]/;FileExistsQ[file] :=
    Module[ {library = FileNameJoin[$thisLibraryDir,"tex-fmt"]},
        If[ !FileExistsQ[library],
            Message[LaTeXFormat::libnotexist];
            Throw[file]
        ];
        If[ !FileExistsQ[file],
            Message[LaTeXFormat::filenotexist];
            Throw[file]
        ];
        If[ FileExtension[file]=!="tex",
            Message[LaTeXFormat::nottex];
            Throw[file]
        ];
        If[ !MatchQ[OptionValue["EquationMarkSpacing"],$markSpacingP|None],
            Message[LaTeXFormat::spacingnotmatch,StringRiffle[$markSpacingList,", "]];
            Throw[file]
        ];
        LaTeXFormatByLibrary[library][file];
        Import[file,"Text"]//
            LaTeXFormatKernel[FilterRules[{opts,Options@LaTeXFormat},Options@LaTeXFormatKernel]]//
                Export[file,#,"Text"]&//File
    ]//Catch;


LaTeXFormatKernel[OptionsPattern[]][string_] :=
    string//surroundEquationWithPercent[OptionValue["SurroundEquationWithPercent"]]//
        adjustEquationMarkSpacing[OptionValue["EquationMarkSpacing"]];


(* ::Subsection:: *)
(*Helper*)


(* ::Subsubsection:: *)
(*Format by tex-fmt*)


LaTeXFormatByLibrary[library_][file_] :=
    ExternalEvaluate[
        "Shell",
        <|
            "Command"->"`texfmtpath` --nowrap --tabsize 4 `file`",
            "TemplateArguments"-><|
                "texfmtpath"->robustPath[library],
                "file"->robustPath[file]
        |>
    |>];


robustPath[path_] :=
    "'"<>AbsoluteFileName[path]<>"'";


(* ::Subsubsection:: *)
(*Percent sign around equation*)


surroundEquationWithPercent[True][string_String] :=
    string//deleteAllPercentAroundEquation//addPercentPairAroundEquation;

surroundEquationWithPercent[False][string_String] :=
    string//deleteAllPercentAroundEquation;


deleteAllPercentAroundEquation[string_String] :=
    FixedPoint[deleteSinglePercentAroundEquation,string,$percentLimit];


deleteSinglePercentAroundEquation[string_String] :=
    string//StringReplace[{
        (*dummy rule to skip the commented equations.*)
        "% \\begin"~~env:$equationP~~Shortest[body___]~~"\\end"~~env__:>
            "% \\begin"~~env~~body~~"\\end"~~env,
        (*delete percent before equations.*)
        "%"~~Shortest[WhitespaceCharacter...]~~"\\begin"~~env:$equationP~~Shortest[body___]~~"\\end"~~env__:>
            "\\begin"~~env~~body~~"\\end"~~env,
        (*delete percent after equations.*)
        "\\begin"~~env:$equationP~~Shortest[body___]~~"\\end"~~env__~~Shortest[WhitespaceCharacter...]~~"%"~~Shortest[WhitespaceCharacter...]~~EndOfLine:>
            "\\begin"~~env~~body~~"\\end"~~env
    }];


addPercentPairAroundEquation[string_String] :=
    string//StringReplace[{
        StartOfLine~~Shortest[spaces:Except["\n",WhitespaceCharacter]...]~~"\\begin"~~env:$equationP~~Shortest[body___]~~"\\end"~~env__:>
            spaces~~"%\n"~~spaces~~"\\begin"~~env~~body~~"\\end"~~env~~"\n"~~spaces~~"%"
    }];


(* ::Subsubsection:: *)
(*Spacing before equation mark*)


adjustEquationMarkSpacing[spacing_][string_String] :=
    string//StringReplace[{
        (*dummy rule to skip the magic-commented equations.*)
        magic:("% LaTeXFormat-EMS-Off"~~Shortest[___]~~"% LaTeXFormat-EMS-On"):>
            magic,
        (*find and replace equations.*)
        "\\begin"~~env:$equationP~~Shortest[body___]~~"\\end"~~env__:>
            "\\begin"~~env~~adjustMarkSpacingInEquation[spacing][body]~~"\\end"~~env
    }];


adjustMarkSpacingInEquation[spacing_][string_String] :=
    string//deleteMarkSpacingInEquation//
        addMarkSpacingInEquation[spacing]//
            moveMarkSpacingToNewline[spacing]//
                trimEmptyLine;


deleteMarkSpacingInEquation[string_String] :=
    FixedPoint[deleteSingleMarkSpacingInEquation,string,$spacingLimit];


deleteSingleMarkSpacingInEquation[string_String] :=
    string//StringReplace[{
        $markSpacingP~~Shortest[WhitespaceCharacter...]~~mark:$markP~~Shortest[spaces:WhitespaceCharacter...]~~end:$hintAfterMarkP:>
            mark~~spaces~~end
    }];


addMarkSpacingInEquation[spacing_String][string_String] :=
    string//StringReplace[{
        (*dummy rules.*)
        "\\,"->"\\,",
        "\\;"->"\\;",
        "\\left."->"\\left.",
        "\\right."->"\\right.",
        (*only match the marks before the end characters.*)
        mark:$markP~~Shortest[spaces:WhitespaceCharacter...]~~end:$hintAfterMarkP:>
            spacing~~" "~~mark~~spaces~~end
    }];

addMarkSpacingInEquation[None][string_String] :=
    string;


moveMarkSpacingToNewline[spacing_][string_String] :=
    With[ {spacing1 = Which[spacing===None,"",True,spacing~~" "]},
        string//StringReplace[{
            StartOfLine~~spaces1:WhitespaceCharacter...~~spacing1~~mark:$markP~~Shortest[spaces3:WhitespaceCharacter...]~~end:$hintAfterMarkP:>
                spaces1~~spacing1~~mark~~spaces3~~end,
            StartOfLine~~spaces1:WhitespaceCharacter...~~Shortest[words:Except["\n"]..]~~Longest[WhitespaceCharacter...]~~spacing1~~mark:$markP~~Shortest[spaces3:WhitespaceCharacter...]~~end:$hintAfterMarkP:>
                spaces1~~words~~"\n"~~spaces1~~spacing1~~mark~~spaces3~~end
        }]
    ];


trimEmptyLine[string_String] :=
    string//StringReplace["\n"~~WhitespaceCharacter..~~"\n"->"\n"]//StringReplace["\n"..->"\n"];


(* ::Subsection:: *)
(*End*)


End[];


(* ::Section:: *)
(*End*)


EndPackage[];
