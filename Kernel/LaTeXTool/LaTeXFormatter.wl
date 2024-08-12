(* ::Package:: *)

(* ::Section:: *)
(*Begin*)


BeginPackage["Yurie`LaTeXTool`LaTeXFormatter`"];


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


numberOfPercentage::usage =
    "maximal number of percentage symbols to be deleted around equations.";

numberOfPercentage = 6;


patternOfEquation = Alternatives@@Map["{"<>#<>"}"&,{"equation","align"}];


(* ::Subsection:: *)
(*adjustPunctuationSpacingOfEquation*)


(* ::Subsubsection:: *)
(*Constant*)


listOfPunctuation = {",",".",";"};

patternOfPunctuation = Alternatives@@listOfPunctuation;

patternOfSpacing = " "|"\\;"|"\\,"|"\\:"|"\\>"|"\\ ";

patternOfEndCharacter = EndOfString|"\\end"|"\\\\"|"\\nn"|"\\label"|"\\quad"|"\\qquad";


(* ::Subsubsection:: *)
(*Main*)


adjustPunctuationSpacingOfEquation[targetDir_?DirectoryQ,spacing:patternOfSpacing:"\\,",ignoreBefore_List:{}][file_] :=
    adjustPunctuationSpacingInFile[targetDir,spacing,ignoreBefore][file]


(* ::Subsubsection:: *)
(*Helper*)


adjustPunctuationSpacingInFile[targetDir_,spacing_,ignoreBefore_][file_] :=
    file//Import[#,"String"]&//deleteAllPercentageAroundEquationInString[numberOfPercentage]//addPercentageAroundEquationInString//
	    adjustPunctuationSpacingInString[spacing,ignoreBefore]//
		    moveSpacingToNewline[spacing]//
				Export[FileNameJoin@{targetDir,FileNameTake[file]},#,"String"]&//File;


adjustPunctuationSpacingInString[spacing_,ignoreBefore_][str_] :=
    str//StringReplace[{
        "\\begin"~~env:patternOfEquation~~Shortest[body___]~~"\\end"~~env__:>
            "\\begin"~~env~~adjustPunctuationSpacingInEquation[spacing,ignoreBefore][body]~~"\\end"~~env
    }];


adjustPunctuationSpacingInEquation[spacing_,ignoreBefore_][eq_] :=
    eq//StringReplace[{
        (*default dummy rules.*)
        "\\,"->"\\,","\\;"->"\\;","\\left."->"\\left.","\\right."->"\\right.",
        (*dummy rules.*)
        Flatten@Outer[StringJoin,ignoreBefore,listOfPunctuation]//Map[#->#&]//Splice,
        (*only match the punctuations before the end characters.*)
        pun:patternOfPunctuation~~spaces:WhitespaceCharacter...~~end:patternOfEndCharacter:>
            spacing~~" "~~pun~~spaces~~end
    }]//deleteDuplicatedSpacing[spacing];


deleteDuplicatedSpacing[spacing_][eq_] :=
    eq//StringReplace[{
        patternOfSpacing~~WhitespaceCharacter...~~spacing~~" "~~pun:patternOfPunctuation~~spaces:WhitespaceCharacter...~~end:patternOfEndCharacter:>
            spacing~~" "~~pun~~spaces~~end
    }];


moveSpacingToNewline[spacing_][eq_] :=
    eq//StringSplit[#,"%"]&//moveSpacingToNewlineIgnoringComment[spacing]//StringRiffle[#,"%"]&;


moveSpacingToNewlineIgnoringComment[spacing_][eqs_List] :=
    Map[moveSpacingToNewlineIgnoringComment[spacing],eqs];

moveSpacingToNewlineIgnoringComment[spacing_][eq_String] :=
    If[ StringCount[eq,"\n"]>=2,
        eq//StringReplace[{
            StartOfLine~~spaces1:WhitespaceCharacter...~~Shortest[words:Except[{"\n","\t"}]..]~~Longest[spaces2:WhitespaceCharacter...]~~spacing~~" "~~pun:patternOfPunctuation~~Shortest[spaces3:WhitespaceCharacter...]~~end:patternOfEndCharacter:>
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
    addPercentageAroundEquationInFile[targetDir,numberOfPercentage][file];


deletePercentageAroundEquation[targetDir_?DirectoryQ][file_] :=
    deletePercentageAroundEquationInFile[targetDir,numberOfPercentage][file];


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
        StartOfLine~~Shortest[spaces:WhitespaceCharacter...]~~"\\begin"~~env:patternOfEquation~~Shortest[body___]~~"\\end"~~env__:>
            spaces~~"% \n"~~spaces~~"\\begin"~~env~~body~~"\\end"~~env~~"\n"~~spaces~~"% "
    }];


deleteAllPercentageAroundEquationInString[limit_][str_] :=
    Nest[deletePercentageAroundEquationInString,str,limit];


deletePercentageAroundEquationInString[str_] :=
    str//StringReplace[{
        (*dummy rule to skip the commented equations.*)
        "% \\begin"~~env:patternOfEquation~~Shortest[body___]~~"\\end"~~env__:>
            "% \\begin"~~env~~body~~"\\end"~~env,
        (*delete percentage before equations.*)
        "%"~~spaces1:WhitespaceCharacter...~~"\\begin"~~env:patternOfEquation~~Shortest[body___]~~"\\end"~~env__:>
            "\\begin"~~env~~body~~"\\end"~~env,
        (*delete percentage after equations.*)
        "\\begin"~~env:patternOfEquation~~Shortest[body___]~~"\\end"~~env__~~spaces2:WhitespaceCharacter...~~"%"~~Shortest[spaces3:WhitespaceCharacter...]~~"\n":>
            "\\begin"~~env~~body~~"\\end"~~env~~"\n"
    }];


(* ::Subsection:: *)
(*End*)


End[];


(* ::Section:: *)
(*End*)


EndPackage[];