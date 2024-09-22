(* ::Package:: *)

(* ::Section:: *)
(*Begin*)


BeginPackage["Yurie`LaTeXTool`LaTeXFormat`"];


Needs["Yurie`LaTeXTool`"];


(* ::Section:: *)
(*Public*)





adjustPunctuationSpacingOfEquation::usage =
    "adjust the spacing of punctuations in equations.";


addPercentageAroundEquation::usage =
    "add a percentage symbol before and after equations.";

deletePercentageAroundEquation::usage =
    "delete all percentage symbols before and after equations.";


(* ::Section:: *)
(*Private*)


(* ::Subsection:: *)
(*Begin*)


Begin["`Private`"];


(* ::Subsection:: *)
(*Constant*)


$maxNumberOfPercentage::usage =
    "maximal number of percentage symbols to be deleted around equations.";

$maxNumberOfPercentage = 6;


equationP = Alternatives@@Map["{"<>#<>"}"&,{"equation","align"}];


(* ::Subsection:: *)
(*adjustPunctuationSpacingOfEquation*)


(* ::Subsubsection:: *)
(*Constant*)


$listOfPunctuation = {",",".",";"};

punctuationP = Alternatives@@$listOfPunctuation;

spacingP = " "|"\\;"|"\\,"|"\\:"|"\\>"|"\\ ";

equationEndP = EndOfString|"\\end"|"\\\\"|"\\nn"|"\\label"|"\\quad"|"\\qquad";


(* ::Subsubsection:: *)
(*Main*)


adjustPunctuationSpacingOfEquation[targetDir_?DirectoryQ,spacing:spacingP:"\\,",ignoreBefore_List:{}][file_] :=
    adjustPunctuationSpacingInFile[targetDir,spacing,ignoreBefore][file]


(* ::Subsubsection:: *)
(*Helper*)


adjustPunctuationSpacingInFile[targetDir_,spacing_,ignoreBefore_][file_] :=
    file//Import[#,"String"]&//deleteAllPercentageAroundEquationInString[$maxNumberOfPercentage]//addPercentageAroundEquationInString//
	    adjustPunctuationSpacingInString[spacing,ignoreBefore]//
		    moveSpacingToNewline[spacing]//
				Export[FileNameJoin@{targetDir,FileNameTake[file]},#,"String"]&//File;


adjustPunctuationSpacingInString[spacing_,ignoreBefore_][str_] :=
    str//StringReplace[{
        "\\begin"~~env:equationP~~Shortest[body___]~~"\\end"~~env__:>
            "\\begin"~~env~~adjustPunctuationSpacingInEquation[spacing,ignoreBefore][body]~~"\\end"~~env
    }];


adjustPunctuationSpacingInEquation[spacing_,ignoreBefore_][eq_] :=
    eq//StringReplace[{
        (*default dummy rules.*)
        "\\,"->"\\,","\\;"->"\\;","\\left."->"\\left.","\\right."->"\\right.",
        (*dummy rules.*)
        Flatten@Outer[StringJoin,ignoreBefore,$listOfPunctuation]//Map[#->#&]//Splice,
        (*only match the punctuations before the end characters.*)
        pun:punctuationP~~spaces:WhitespaceCharacter...~~end:equationEndP:>
            spacing~~" "~~pun~~spaces~~end
    }]//deleteDuplicatedSpacing[spacing];


deleteDuplicatedSpacing[spacing_][eq_] :=
    eq//StringReplace[{
        spacingP~~WhitespaceCharacter...~~spacing~~" "~~pun:punctuationP~~spaces:WhitespaceCharacter...~~end:equationEndP:>
            spacing~~" "~~pun~~spaces~~end
    }];


moveSpacingToNewline[spacing_][eq_] :=
    eq//StringSplit[#,"%"]&//moveSpacingToNewlineIgnoringComment[spacing]//StringRiffle[#,"%"]&;


moveSpacingToNewlineIgnoringComment[spacing_][eqs_List] :=
    Map[moveSpacingToNewlineIgnoringComment[spacing],eqs];

moveSpacingToNewlineIgnoringComment[spacing_][eq_String] :=
    If[ StringCount[eq,"\n"]>=2,
        eq//StringReplace[{
            StartOfLine~~spaces1:WhitespaceCharacter...~~Shortest[words:Except[{"\n","\t"}]..]~~Longest[spaces2:WhitespaceCharacter...]~~spacing~~" "~~pun:punctuationP~~Shortest[spaces3:WhitespaceCharacter...]~~end:equationEndP:>
                spaces1~~words~~"\n"~~spaces1~~spacing~~" "~~pun~~spaces3~~end
        }],
        (*Else*)
        eq
    ];


(* ::Subsection:: *)
(*addDollarAroundEquation*)


(* ::Subsubsection:: *)
(*Main*)


addPercentageAroundEquation[targetDir_?DirectoryQ][file_] :=
    addPercentageAroundEquationInFile[targetDir,$maxNumberOfPercentage][file];


deletePercentageAroundEquation[targetDir_?DirectoryQ][file_] :=
    deletePercentageAroundEquationInFile[targetDir,$maxNumberOfPercentage][file];


(* ::Subsubsection:: *)
(*Helper*)


addPercentageAroundEquationInFile[targetDir_][file_] :=
    file//Import[#,"String"]&//deleteAllPercentageAroundEquationInString[limit]//addPercentageAroundEquationInString//
	    Export[FileNameJoin@{targetDir,FileNameTake[file]},#,"String"]&//File;


deletePercentageAroundEquationInFile[targetDir_][file_] :=
    file//Import[#,"String"]&//deleteAllPercentageAroundEquationInString[limit]//
	    Export[FileNameJoin@{targetDir,FileNameTake[file]},#,"String"]&//File;


addPercentageAroundEquationInString[str_] :=
    str//StringReplace[{
        StartOfLine~~Shortest[spaces:WhitespaceCharacter...]~~"\\begin"~~env:equationP~~Shortest[body___]~~"\\end"~~env__:>
            spaces~~"% \n"~~spaces~~"\\begin"~~env~~body~~"\\end"~~env~~"\n"~~spaces~~"% "
    }];


deleteAllPercentageAroundEquationInString[limit_][str_] :=
    Nest[deletePercentageAroundEquationInString,str,limit];


deletePercentageAroundEquationInString[str_] :=
    str//StringReplace[{
        (*dummy rule to skip the commented equations.*)
        "% \\begin"~~env:equationP~~Shortest[body___]~~"\\end"~~env__:>
            "% \\begin"~~env~~body~~"\\end"~~env,
        (*delete percentage before equations.*)
        "%"~~spaces1:WhitespaceCharacter...~~"\\begin"~~env:equationP~~Shortest[body___]~~"\\end"~~env__:>
            "\\begin"~~env~~body~~"\\end"~~env,
        (*delete percentage after equations.*)
        "\\begin"~~env:equationP~~Shortest[body___]~~"\\end"~~env__~~spaces2:WhitespaceCharacter...~~"%"~~Shortest[spaces3:WhitespaceCharacter...]~~"\n":>
            "\\begin"~~env~~body~~"\\end"~~env~~"\n"
    }];


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
(*End*)


End[];


(* ::Section:: *)
(*End*)


EndPackage[];
