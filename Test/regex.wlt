

(*regex.nb*)

VerificationTest[
	Begin["Global`"];
	ClearAll["`*"]
	,
	Null
	,
	TestID->"0-regex.nb"
]

VerificationTest[
	Get["Yurie`LaTeXTool`"]; 
	Get["Yurie`LaTeXTool`Info`"]
	,
	Null
	,
	TestID->"1-regex.nb"
]

VerificationTest[
	str = (Import[#1, "Text"] & )[FileNameJoin[$thisSourceDir, "test.sty"]]; 
	,
	Null
	,
	TestID->"2-regex.nb"
]

VerificationTest[
	clean = StringDelete[str, Yurie`LaTeXTool`Parser`$commentP]
	,
	"\\ProvidesPackage{test}\n\n\n\\newcommand{\\nn}{\\nonumber}\n\\newcommand{\\eq}{=}\n\\newcommand{\\eqq}{\\equiv}\n\n\n\\newcommand{\\set}[1]{\\{ #1 \\}}\n\\newcommand{\\Fpq}[5]{\\,{}_{#1}F_{#2}\\biggl(\\genfrac..{0pt}{}{#3}{#4};#5\\biggr)}\n\n\n\n\\providecommand{\\bra}[1]{{\\langle {#1} |}}\n\\renewcommand{\\bra}[1]{{\\langle {#1} |}}\n\n\n\\newcommand{\\textInMath}[1]{\n    \\,\n    \\text{ #1 }\n    \\,\n}\n\n\n\\newcommand{\\mathred}[1]{{\\color{red} #1}}\n\n\n\\AtBeginDocument{\\renewcommand{\\check}[1]{\\widecheck{#1}}}"
	,
	TestID->"3-regex.nb"
]

VerificationTest[
	StringCases[clean, Yurie`LaTeXTool`Parser`$newcommandP :> Association["Name" -> "$1", "ArgNumber" -> If["$3" === "", 0, ToExpression["$3"]], "Definition" -> "$4"]]
	,
	{Association["Name" -> "nn", "ArgNumber" -> 0, "Definition" -> "\\nonumber"], Association["Name" -> "eq", "ArgNumber" -> 0, "Definition" -> "="], Association["Name" -> "eqq", "ArgNumber" -> 0, "Definition" -> "\\equiv"], Association["Name" -> "set", "ArgNumber" -> 1, "Definition" -> "\\{ #1 \\}"], Association["Name" -> "Fpq", "ArgNumber" -> 5, "Definition" -> "\\,{}_{#1}F_{#2}\\biggl(\\genfrac..{0pt}{}{#3}{#4};#5\\biggr)"], Association["Name" -> "textInMath", "ArgNumber" -> 1, "Definition" -> "\n    \\,\n    \\text{ #1 }\n    \\,\n"], Association["Name" -> "mathred", "ArgNumber" -> 1, "Definition" -> "{\\color{red} #1}"]}
	,
	TestID->"4-regex.nb"
]

VerificationTest[
	StringCases[clean, Yurie`LaTeXTool`Parser`$renewcommandP :> Association["Name" -> "$1", "ArgNumber" -> If["$3" === "", 0, ToExpression["$3"]], "Definition" -> "$4"]]
	,
	{Association["Name" -> "bra", "ArgNumber" -> 1, "Definition" -> "{\\langle {#1} |}"], Association["Name" -> "check", "ArgNumber" -> 1, "Definition" -> "\\widecheck{#1}"]}
	,
	TestID->"5-regex.nb"
]

VerificationTest[
	ClearAll["`*"];
	End[]
	,
	"Global`"
	,
	TestID->"∞-regex.nb"
]