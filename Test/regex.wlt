

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
	Dataset[StringCases[str, Yurie`LaTeXTool`LaTeXParser`Private`$newcommandP :> Association["Name" -> "$1", "ArgNumber" -> If["$3" === "", 0, ToExpression["$3"]], "Definition" -> "$4"]]]
	,
	Dataset[{Association["Name" -> "ignoredblock", "ArgNumber" -> 0, "Definition" -> "ignored"], Association["Name" -> "ignoredline", "ArgNumber" -> 0, "Definition" -> "ignored"], Association["Name" -> "nn", "ArgNumber" -> 0, "Definition" -> "\\nonumber"], Association["Name" -> "eq", "ArgNumber" -> 0, "Definition" -> "="], Association["Name" -> "eqq", "ArgNumber" -> 0, "Definition" -> "\\equiv"], Association["Name" -> "set", "ArgNumber" -> 1, "Definition" -> "\\{ #1 \\}"], Association["Name" -> "Fpq", "ArgNumber" -> 5, "Definition" -> "\\,{}_{#1}F_{#2}\\biggl(\\genfrac..{0pt}{}{#3}{#4};#5\\biggr)"], Association["Name" -> "textInMath", "ArgNumber" -> 1, "Definition" -> "%\n  \\,\n  \\text{ #1 }\n  \\,\n"], Association["Name" -> "mathred", "ArgNumber" -> 1, "Definition" -> "{\\color{red} #1}"], Association["Name" -> "tp", "ArgNumber" -> 0, "Definition" -> "%\n    {\\scriptscriptstyle \\mathsf{T} }\n"], Association["Name" -> "ignoredblocktwo", "ArgNumber" -> 0, "Definition" -> "ignored"], Association["Name" -> "ignoredMathJax", "ArgNumber" -> 0, "Definition" -> "ignored"], Association["Name" -> "ignoredLaTeXWorkshop", "ArgNumber" -> 0, "Definition" -> "ignored"]}]
	,
	TestID->"3-regex.nb"
]

VerificationTest[
	ClearAll["`*"];
	End[]
	,
	"Global`"
	,
	TestID->"∞-regex.nb"
]