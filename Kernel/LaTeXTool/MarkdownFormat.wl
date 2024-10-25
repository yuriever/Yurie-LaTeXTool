(* ::Package:: *)

(* ::Section:: *)
(*Begin*)


BeginPackage["Yurie`LaTeXTool`MarkdownFormat`"];


Needs["Yurie`LaTeXTool`"];

Needs["Yurie`LaTeXTool`Info`"];


(* ::Section:: *)
(*Public*)


MarkdownFormat::usage =
    "format the Markdown file.";


(* ::Section:: *)
(*Private*)


(* ::Subsection:: *)
(*Begin*)


Begin["`Private`"];


(* ::Subsection:: *)
(*Constant*)


(*maximal number of empty lines to be deleted around equations.*)

$emptyLineLimit = 5;


$equationList =
    {"equation","align","gather","alignat","multline"};

$equationP =
    $equationList//Map[{"{"<>#<>"}","{"<>#<>"*}"}&]//Flatten//Apply[Alternatives];


(* ::Subsection:: *)
(*Option*)


MarkdownFormatKernel//Options = {
    "SurroundEquationWithEmptyLine"->True
};


MarkdownFormat//Options = {
    Splice@Options@MarkdownFormatKernel
}


(* ::Subsection:: *)
(*Message*)


MarkdownFormat::filenotexist =
    "the file does not exist.";

MarkdownFormat::libnotexist =
    "the library autocorrect does not exist.";


(* ::Subsection:: *)
(*Main*)


MarkdownFormat[opts:OptionsPattern[]][file:_String|_File]/;FileExistsQ[file] :=
    Module[ {library = FileNameJoin[$thisLibraryDir,"autocorrect"]},
        If[ !FileExistsQ[library],
            Message[MarkdownFormat::libnotexist];
            Throw[file]
        ];
        If[ !FileExistsQ[file],
            Message[MarkdownFormat::filenotexist];
            Throw[file]
        ];
        MarkdownFormatByLibrary[library][file];
        Import[file,"Text"]//
            MarkdownFormatKernel[FilterRules[{opts,Options@MarkdownFormat},Options@MarkdownFormatKernel]]//
                Export[file,#,"Text"]&//File
    ]//Catch;


MarkdownFormatKernel[OptionsPattern[]][string_] :=
    string//surroundInlineEquationWithBlank//surroundEquationWithEmptyLine[OptionValue["SurroundEquationWithEmptyLine"]];


(* ::Subsection:: *)
(*Helper*)


(* ::Subsubsection:: *)
(*Format by autocorrect*)


MarkdownFormatByLibrary[library_][file_] :=
    ExternalEvaluate[
        "Shell",
        <|
            "Command"->"`autocorrectpath` --fix `file` --quiet",
            "TemplateArguments"-><|
                "autocorrectpath"->robustPath[library],
                "file"->robustPath[file]
        |>
    |>];


robustPath[path_] :=
    "'"<>AbsoluteFileName[path]<>"'";


(* ::Subsubsection:: *)
(*Blank around inline equation*)


surroundInlineEquationWithBlank[string_] :=
    string//StringReplace[{
        (*dummy rule to skip the magic-commented equations.*)
        magic:("<!-- MarkdownFormat-IEB-Off -->"~~Shortest[___]~~"<!-- MarkdownFormat-IEB-Off -->"):>
            magic,
        RegularExpression[" (\$[^\$]*?\$) "]:>" $1$2 ",
        RegularExpression["([^ ])(\$[^\$]*?\$)([^ ])"]:>"$1 $2 $3",
        RegularExpression["([^ ])(\$[^\$]*?\$) "]:>"$1 $2 ",
        RegularExpression[" (\$[^\$]*?\$)([^ ])"]:>" $1 $2"
    }]//StringReplace[{
        (*dummy rule to skip the magic-commented equations.*)
        magic:("<!-- MarkdownFormat-IEB-Off -->"~~Shortest[___]~~"<!-- MarkdownFormat-IEB-Off -->"):>
            magic,
        RegularExpression["(\$[^\$]*?\$) ([,.?!;:\:ff0c\:3002\:ff1f\:ff01\:ff1b\:ff1a\:3001])"]:>"$1$2",
        RegularExpression["([,.?!;:\:ff0c\:3002\:ff1f\:ff01\:ff1b\:ff1a\:3001]) (\$[^\$]*?\$)"]:>"$1$2"
    }];


(* ::Subsubsection:: *)
(*Percent sign around equation*)


surroundEquationWithEmptyLine[True][string_String] :=
    string//deleteAllEmptyLineAroundEquation//addEmptyLineAroundEquation;

surroundEquationWithEmptyLine[False][string_String] :=
    string//deleteAllEmptyLineAroundEquation;


deleteAllEmptyLineAroundEquation[string_String] :=
    FixedPoint[deleteSingleEmptyLineAroundEquation,string,$emptyLineLimit];


deleteSingleEmptyLineAroundEquation[string_String] :=
    string//StringReplace[{
        (*delete empty line before equations.*)
        StartOfLine~~"\n"~~Shortest[spaces:WhitespaceCharacter...]~~"\\begin"~~env:$equationP~~Shortest[body___]~~"\\end"~~env__:>
            spaces~~"\\begin"~~env~~body~~"\\end"~~env,
        (*delete percent after equations.*)
        "\\begin"~~env:$equationP~~Shortest[body___]~~"\\end"~~env__~~"\n"~~EndOfLine:>
            "\\begin"~~env~~body~~"\\end"~~env
    }];


addEmptyLineAroundEquation[string_String] :=
    string//StringReplace[{
        StartOfLine~~Shortest[spaces:Except["\n",WhitespaceCharacter]...]~~"\\begin"~~env:$equationP~~Shortest[body___]~~"\\end"~~env__:>
            "\n"~~spaces~~"\\begin"~~env~~body~~"\\end"~~env~~"\n"
    }];


(* ::Subsection:: *)
(*End*)


End[];


(* ::Section:: *)
(*End*)


EndPackage[];
