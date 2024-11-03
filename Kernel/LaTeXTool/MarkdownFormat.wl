(* ::Package:: *)

(* ::Section:: *)
(*Begin*)


BeginPackage["Yurie`LaTeXTool`MarkdownFormat`"];


Needs["Yurie`LaTeXTool`"];

Needs["Yurie`LaTeXTool`Info`"];

Needs["Yurie`LaTeXTool`LaTeXFormat`"];


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


$blockEquationList =
    {"equation","align","gather","alignat","multline"};

$blockEquationP =
    $blockEquationList//Map[{"{"<>#<>"}","{"<>#<>"*}"}&]//Flatten//Apply[Alternatives];


$ENmarks =
    ",.?!;:\-";

$CNmarks =
    "\:ff0c\:3002\:ff1f\:ff01\:ff1b\:ff1a\:3001";

$inlineEquationWithRightMarkP =
    RegularExpression["(\$[^\$]*?\$) (["<>$ENmarks<>$CNmarks<>"])"];

$inlineEquationWithLeftMarkP =
    RegularExpression["(["<>$CNmarks<>"]) (\$[^\$]*?\$)"];

$inlineEquationWithLeftRightMarkP =
    RegularExpression["(["<>$CNmarks<>"]) (\$[^\$]*?\$) (["<>$ENmarks<>$CNmarks<>"])"];


(* ::Subsection:: *)
(*Option*)


MarkdownFormatKernel//Options = {
    "SurroundInlineEquationWithBlank"->True,
    "SurroundBlockEquationWithEmptyLine"->True,
    "BlockEquationMarkSpacing"->None
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

MarkdownFormat::notmd =
    "the file is not Markdown."


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
        If[ FileExtension[file]=!="md",
            Message[MarkdownFormat::notmd];
            Throw[file]
        ];
        MarkdownFormatByLibrary[library][file];
        Import[file,"Text"]//
            MarkdownFormatKernel[FilterRules[{opts,Options@MarkdownFormat},Options@MarkdownFormatKernel]]//
                Export[file,#,"Text"]&//File
    ]//Catch;


MarkdownFormatKernel[OptionsPattern[]][string_] :=
    string//surroundInlineEquationWithBlank[OptionValue["SurroundInlineEquationWithBlank"]]//
        surroundBlockEquationWithEmptyLine[OptionValue["SurroundBlockEquationWithEmptyLine"]]//
            adjustEquationMarkSpacing[OptionValue["BlockEquationMarkSpacing"]];


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


surroundInlineEquationWithBlank[True][string_String] :=
    string//addBlankAroundInlineEquation;

surroundInlineEquationWithBlank[False][string_String] :=
    string;


addBlankAroundInlineEquation[string_] :=
    string//StringReplace[{
        (*surround the inline equations with blanks.*)
        (*dummy rule to skip the magic-commented equations.*)
        magic:("<!-- MarkdownFormat-IEB-Off -->"~~Shortest[___]~~"<!-- MarkdownFormat-IEB-Off -->"):>
            magic,
        RegularExpression[" (\$[^\$]*?\$) "]:>" $1$2 ",
        RegularExpression["([^ ])(\$[^\$]*?\$)([^ ])"]:>"$1 $2 $3",
        RegularExpression["([^ ])(\$[^\$]*?\$) "]:>"$1 $2 ",
        RegularExpression[" (\$[^\$]*?\$)([^ ])"]:>" $1 $2"
    }]//StringReplace[{
	    (*delete the blanks between inline equations and marks.*)
        (*dummy rule to skip the magic-commented equations.*)
        magic:("<!-- MarkdownFormat-IEB-Off -->"~~Shortest[___]~~"<!-- MarkdownFormat-IEB-Off -->"):>
            magic,
        $inlineEquationWithLeftRightMarkP:>"$1$2$3",
        $inlineEquationWithRightMarkP:>"$1$2",
        $inlineEquationWithLeftMarkP:>"$1$2"
    }];


(* ::Subsubsection:: *)
(*Empty line around block equation*)


surroundBlockEquationWithEmptyLine[True][string_String] :=
    string//deleteAllEmptyLineAroundBlockEquation//addEmptyLineAroundBlockEquation;

surroundBlockEquationWithEmptyLine[False][string_String] :=
    string//deleteAllEmptyLineAroundBlockEquation;


deleteAllEmptyLineAroundBlockEquation[string_String] :=
    FixedPoint[deleteSingleEmptyLineAroundBlockEquation,string,$emptyLineLimit];


deleteSingleEmptyLineAroundBlockEquation[string_String] :=
    string//StringReplace[{
        (*delete empty line before equations.*)
        StartOfLine~~"\n"~~Shortest[spaces:WhitespaceCharacter...]~~"\\begin"~~env:$blockEquationP~~Shortest[body___]~~"\\end"~~env__:>
            spaces~~"\\begin"~~env~~body~~"\\end"~~env,
        (*delete percent after equations.*)
        "\\begin"~~env:$blockEquationP~~Shortest[body___]~~"\\end"~~env__~~"\n"~~EndOfLine:>
            "\\begin"~~env~~body~~"\\end"~~env
    }];


addEmptyLineAroundBlockEquation[string_String] :=
    string//StringReplace[{
        StartOfLine~~Shortest[spaces:Except["\n",WhitespaceCharacter]...]~~"\\begin"~~env:$blockEquationP~~Shortest[body___]~~"\\end"~~env__:>
            "\n"~~spaces~~"\\begin"~~env~~body~~"\\end"~~env~~"\n"
    }];


(* ::Subsection:: *)
(*End*)


End[];


(* ::Section:: *)
(*End*)


EndPackage[];
