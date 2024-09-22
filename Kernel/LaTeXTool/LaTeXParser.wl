(* ::Package:: *)

(* ::Section:: *)
(*Begin*)


BeginPackage["Yurie`LaTeXTool`LaTeXParser`"];


Needs["Yurie`LaTeXTool`"];


(* ::Section:: *)
(*Public*)


LaTeXParser::usage =
    "a simple parser of LaTeX.";


(* ::Section:: *)
(*Private*)


(* ::Subsection:: *)
(*Begin*)


Begin["`Private`"];


(* ::Subsection:: *)
(*Constant*)


(*FileNameJoin[$thisPromptDir,"regex for newcommand.nb"]*)

$newcommandP =
    RegularExpression["\\\\newcommand\\{\\\\(\\w+)\\}(\\[(\\d+)\\])?\\{((?:[^{}]|\\{(?:[^{}]|\\{[^{}]*\\})*\\})*)\\}"];

$commandP =
    RegularExpression["\\\\(newcommand|renewcommand)\\{\\\\(\\w+)\\}(?:\\[(\\d+)\\])?\\{((?:[^{}]|\\{(?:[^{}]|\\{[^{}]*\\})*\\})*)\\}"];


$newenvironmentP =
    Pass;


(*FileNameJoin[$thisPromptDir,"regex for comment.nb"]*)

$usepackageP =
    RegularExpression["\\\\usepackage(\\[([^\\]]*)\\])?\\{([^\\}]*)\\}"];


(*FileNameJoin[$thisPromptDir,"regex for comment.nb"]*)

$commentP =
    RegularExpression["(?m)(%.*)$"];


(* ::Text:: *)
(*types of skipped lines*)


$skipTypeList =
    {"MathJax","LaTeXWorkshop"};


$skippedLineP[type_] :=
    $skippedLineP[type] =
        StartOfLine~~Shortest[Except["\n"]...]~~"% LaTeXTool-"~~type~~"-Skip"~~EndOfLine;

$skippedLineP["Default"] =
    StartOfLine~~Shortest[Except["\n"]...]~~"% LaTeXTool-Skip"~~EndOfLine;


$skippedBlockP[type_] :=
    $skippedBlockP[type] =
        "% LaTeXTool-"~~type~~"-Off"~~Shortest[___]~~"% LaTeXTool-"~~type~~"-On";

$skippedBlockP["Default"] =
    "% LaTeXTool-Off"~~Shortest[___]~~"% LaTeXTool-On";


(* ::Text:: *)
(*template*)


$MathJaxJSONT =
    TemplateObject[
        TemplateSlot["Name"]->
            TemplateIf[TemplateSlot["ArgNumber"]===0,
                TemplateSlot["Definition"],
                {TemplateSlot["Definition"],TemplateSlot["ArgNumber"]}
            ]
    ];


$MathJaxTestT =
    StringTemplate["\\`Name`<* StringRepeat[\"{*}\",#ArgNumber] *>"];


$newcommmandT[0] =
    StringTemplate["\\newcommand{\\`Name`}{`Definition`}"];

$newcommmandT[_] =
    StringTemplate["\\newcommand{\\`Name`}[`ArgNumber`]{`Definition`}"];


$LaTeXWorkshopCommandT =
    TemplateObject[
        TemplateIf[TemplateSlot["IsRedefined"],
            Nothing,
            {
                "name"->TemplateSlot["Name"],
                TemplateIf[TemplateSlot["ArgNumber"]===0,
                    Nothing,
                    "arg"->{
                        "format"->TemplateExpression@StringRepeat["{}",TemplateSlot["ArgNumber"]],
                        "snippet"->
                            TemplateExpression@StringJoin[
                                TemplateSlot["Name"],
                                TemplateSequence[
                                    StringTemplate["{${``:}}"],
                                    TemplateExpression@Range@TemplateSlot["ArgNumber"]
                                ]
                            ]
                    }
                ]
            }
        ]
    ];


$LaTeXWorkshopPackageT =
    TemplateObject[
        {
            "name"->TemplateSlot["Name"]
        }
    ];


(* ::Subsection:: *)
(*Option*)


parseString//Options = {
    "SkipType"->Automatic,
    "TrimDefinition"->True,
    "TrimOption"->True
};


LaTeXParser//Options =
    Options@parseString;


(* ::Subsection:: *)
(*Message*)


LaTeXParser::notype =
    "the option SkipType only accepts `` or All. The default option value All is adopted.";


(* ::Subsection:: *)
(*Main*)


LaTeXParser[opts:OptionsPattern[]][file:_String|_File]/;FileExistsQ[file] :=
    file//Import[#,"Text"]&//
		parseString[FilterRules[{opts,Options@LaTeXParser},Options@parseString]];


LaTeXParser[opts:OptionsPattern[]][dir:_String|_File,fileNameList:{__String}]/;DirectoryQ[dir] :=
    fileNameList//Map[FileNameJoin[dir,#]&]//Map[Import[#,"Text"]&]//StringRiffle[#,"\n"]&//
		parseString[FilterRules[{opts,Options@LaTeXParser},Options@parseString]];


parseString[opts:OptionsPattern[]][string1_String] :=
    Module[ {string,data,typeList},
        typeList =
            checkAndReturnSkipType[OptionValue["SkipType"]];
        string =
            string1//removeSkippedLine[typeList]//removeSkippedBlock[typeList]//removeComment;
        data =
            <|
                "Command"->extractCommand[string,OptionValue["TrimDefinition"]],
                "Environment"->extractEnvironment[string],
                "Package"->extractPackage[string,OptionValue["TrimOption"]]
            |>;
        <|
            "Data"->data,
            "MathJaxJSON"->getMathJaxJSON[data["Command"]],
            "MathJaxTest"->getMathJaxTest[data["Command"]],
            "LaTeXWorkshopPreviewCode"->getLaTeXWorkshopPreviewCode[data["Command"]],
            "LaTeXWorkshopCompletion"->getLaTeXWorkshopCompletion[data["Command"],data["Package"]]
        |>
    ];


(* ::Subsection:: *)
(*Helper*)


checkAndReturnSkipType[types_] :=
    Module[ {typeList},
        typeList =
            Which[
                types===Automatic,
                    {},
                types===All,
                    $skipTypeList,
                MatchQ[types,Alternatives@@$skipTypeList],
                    {types},
                MatchQ[types,_List]&&SubsetQ[$skipTypeList,types],
                    types,
                True,
                    Message[LaTeXParser::notype,StringRiffle[$skipTypeList,", "]];
                    $skipTypeList
            ];
        Join[{"Default"},typeList]
    ];


removeSkippedLine[typeList_List][string_String] :=
    Fold[StringDelete[#1,$skippedLineP[#2]]&,string,typeList];


removeSkippedBlock[typeList_List][string_String] :=
    Fold[StringDelete[#1,$skippedBlockP[#2]]&,string,typeList];


removeComment[string_String] :=
    StringDelete[string,$commentP];


extractCommand[string_String,ifTrimDefinition_] :=
    StringCases[string,$commandP:><|
        "Name"->"$2",
        "ArgNumber"->
            If[ "$3"==="",
                0,
                (*Else*)
                ToExpression["$3"]
            ],
        "Definition"->
            If[ ifTrimDefinition,
                trimWhiteSpace["$4"],
                (*Else*)
                "$4"
            ],
        "IsRedefined"->
            Switch[ "$1",
                "newcommand",
                    False,
                "renewcommand",
                    True
            ],
        "Code"->"$0"
    |>];


trimWhiteSpace[string_String] :=
    string//StringReplace[WhitespaceCharacter->" "]//StringReplace[" "..->" "]//StringTrim;


extractEnvironment[string_String] :=
    Pass;


extractPackage[string_String,ifTrimOption_] :=
    StringCases[string,$usepackageP:><|
        "Name"->"$3",
        "Option"->
            If[ ifTrimOption,
                trimWhiteSpace["$2"],
                (*Else*)
                "$2"
            ],
        "Code"->"$0"
    |>];


getMathJaxJSON[command:{___Association}] :=
    command//Query[All,$MathJaxJSONT]//
    	ExportString[#,"JSON",CharacterEncoding->"ASCII"]&;


getMathJaxTest[command:{___Association}] :=
    command//Query[All,$MathJaxTestT]//
    	StringRiffle[#,{
            "# LaTeXTool-MathJax\n\n${}$\n\\begin{align}\n&",
            "\\\\\n&",
            "\n\\end{align}\n"
        }]&;


getLaTeXWorkshopPreviewCode[command:{___Association}] :=
    command//Query[All,$newcommmandT[#ArgNumber][#]&]//
    	StringRiffle[#,"\n"]&


getLaTeXWorkshopCompletion[command:{___Association},package:{___Association}] :=
    {
        "deps"->Query[All,$LaTeXWorkshopPackageT][package],
        "macros"->Query[All,$LaTeXWorkshopCommandT][command],
        "envs"->{},
        "keys"->{},
        "args"->{}
    }//ExportString[#,"JSON",CharacterEncoding->"ASCII"]&;


(* ::Subsection:: *)
(*End*)


End[];


(* ::Section:: *)
(*End*)


EndPackage[];
