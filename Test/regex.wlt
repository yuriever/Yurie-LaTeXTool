

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
	Dataset[{Association["Name" -> "ignoredblock", "ArgNumber" -> 0, "Definition" -> "ignored"], Association["Name" -> "ignoredline", "ArgNumber" -> 0, "Definition" -> "ignored"], Association["Name" -> "nn", "ArgNumber" -> 0, "Definition" -> "\\nonumber"], Association["Name" -> "eq", "ArgNumber" -> 0, "Definition" -> "="], Association["Name" -> "eqq", "ArgNumber" -> 0, "Definition" -> "\\equiv"], Association["Name" -> "set", "ArgNumber" -> 1, "Definition" -> "\\{ #1 \\}"], Association["Name" -> "Fpq", "ArgNumber" -> 5, "Definition" -> "\\,{}_{#1}F_{#2}\\biggl(\\genfrac..{0pt}{}{#3}{#4};#5\\biggr)"], Association["Name" -> "textInMath", "ArgNumber" -> 1, "Definition" -> "%\n    \\,\n    \\text{ #1 }\n    \\,\n"], Association["Name" -> "mathred", "ArgNumber" -> 1, "Definition" -> "{\\color{red} #1}"], Association["Name" -> "tp", "ArgNumber" -> 0, "Definition" -> "%\n    {\\scriptscriptstyle \\mathsf{T} }\n"], Association["Name" -> "ignoredblocktwo", "ArgNumber" -> 0, "Definition" -> "ignored"], Association["Name" -> "ignoredMathJax", "ArgNumber" -> 0, "Definition" -> "ignored"], Association["Name" -> "ignoredLaTeXWorkshop", "ArgNumber" -> 0, "Definition" -> "ignored"]}]
	,
	TestID->"3-regex.nb"
]

VerificationTest[
	Dataset[Lookup["Data"][Yurie`LaTeXTool`LaTeXParser`Private`parseString["SkipType" -> All][str]]]
	,
	Dataset[Association["Command" -> {Association["Name" -> "nn", "ArgNumber" -> 0, "Definition" -> "\\nonumber", "IsRedefined" -> False, "Code" -> "\\newcommand{\\nn}{\\nonumber}"], Association["Name" -> "eq", "ArgNumber" -> 0, "Definition" -> "=", "IsRedefined" -> False, "Code" -> "\\newcommand{\\eq}{=}"], Association["Name" -> "eqq", "ArgNumber" -> 0, "Definition" -> "\\equiv", "IsRedefined" -> False, "Code" -> "\\newcommand{\\eqq}{\\equiv}"], Association["Name" -> "set", "ArgNumber" -> 1, "Definition" -> "\\{ #1 \\}", "IsRedefined" -> False, "Code" -> "\\newcommand{\\set}[1]{\\{ #1 \\}}"], Association["Name" -> "Fpq", "ArgNumber" -> 5, "Definition" -> "\\,{}_{#1}F_{#2}\\biggl(\\genfrac..{0pt}{}{#3}{#4};#5\\biggr)", "IsRedefined" -> False, "Code" -> "\\newcommand{\\Fpq}[5]{\\,{}_{#1}F_{#2}\\biggl(\\genfrac..{0pt}{}{#3}{#4};#5\\biggr)}"], Association["Name" -> "bra", "ArgNumber" -> 1, "Definition" -> "{\\langle {#1} |}", "IsRedefined" -> True, "Code" -> "\\renewcommand{\\bra}[1]{{\\langle {#1} |}}"], Association["Name" -> "textInMath", "ArgNumber" -> 1, "Definition" -> "\\, \\text{ #1 } \\,", "IsRedefined" -> False, "Code" -> "\\newcommand{\\textInMath}[1]{\n    \\,\n    \\text{ #1 }\n    \\,\n}"], Association["Name" -> "mathred", "ArgNumber" -> 1, "Definition" -> "{\\color{red} #1}", "IsRedefined" -> False, "Code" -> "\\newcommand{\\mathred}[1]{{\\color{red} #1}}"], Association["Name" -> "tp", "ArgNumber" -> 0, "Definition" -> "{\\scriptscriptstyle \\mathsf{T} }", "IsRedefined" -> False, "Code" -> "\\newcommand{\\tp}{\n    {\\scriptscriptstyle \\mathsf{T} }\n}"], Association["Name" -> "check", "ArgNumber" -> 1, "Definition" -> "\\widecheck{#1}", "IsRedefined" -> True, "Code" -> "\\renewcommand{\\check}[1]{\\widecheck{#1}}"]}, "Environment" -> Pass, "Package" -> {Association["Name" -> "amsmath", "Option" -> "", "Code" -> "\\usepackage{amsmath}"], Association["Name" -> "test", "Option" -> "opt=true,opt2", "Code" -> "\\usepackage[opt=true,opt2]{test}"], Association["Name" -> "test2", "Option" -> "opt=true, opt2", "Code" -> "\\usepackage[\n    opt=true,\n    opt2\n]{test2}"]}]]
	,
	TestID->"4-regex.nb"
]

VerificationTest[
	ClearAll["`*"];
	End[]
	,
	"Global`"
	,
	TestID->"∞-regex.nb"
]