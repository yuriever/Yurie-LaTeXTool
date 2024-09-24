window.MathJax = {
	loader: {
		load: ['[tex]/tagformat', '[tex]/configmacros', '[tex]/physics']
	},
	tex: {
		// packages included
		packages: { '[+]': ['tagformat', 'configmacros', 'physics'] },
		// inline math mode delimiters
		physics: {
			italicdiff: true,
			arrowdel: false
		},
		inlineMath: [['$', '$'], ['\\(', '\\)']],
		// display math mode delimiters
		displayMath: [['$$', '$$'], ['\\[', '\\]']],
		// use \$ to escape the dollar sign
		processEscapes: true,
		// process \begin{xxx}...\end{xxx} outside of math mode
		processEnvironments: true,
		// process \ref{...} outside of math mode
		processRefs: true,
		// pattern for recognizing numbers
		digits: /^(?:[0-9]+(?:\{,\}[0-9]{3})*(?:\.[0-9]*)?|\.[0-9]+)/,
		// tag options
		tags: 'ams',
		tagSide: 'right',
		tagIndent: '2em',
		tagformat: {
			number: (n) => n.toString(),
			tag: (tag) => '(' + tag + ')',
			id: (id) => 'mjx-eqn:' + id.replace(/\s/g, '_'),
			url: (id, base) => base + '#' + encodeURIComponent(id)
		},
		useLabelIds: true,
		// MathJaxJSOverwrite-Macro-Begin
		macros: {
			"nn":"\\nonumber",
			"eq":"=",
			"eqq":"\\equiv",
			"set":[
				"\\{ #1 \\}",
				1
			],
			"Fpq":[
				"\\,{}_{#1}F_{#2}\\biggl(\\genfrac..{0pt}{}{#3}{#4};#5\\biggr)",
				5
			],
			"bra":[
				"{\\langle {#1} |}",
				1
			],
			"textInMath":[
				"\\, \\text{ #1 } \\,",
				1
			],
			"mathred":[
				"{\\color{red} #1}",
				1
			],
			"tp":"{\\scriptscriptstyle \\mathsf{T} }",
			"check":[
				"\\widecheck{#1}",
				1
			],
			"ignoredLaTeXWorkshop":"ignored"
		},
		// MathJaxJSOverwrite-Macro-End
		environments: {
		}
	},
	showProcessingMessages: true,
	options: {
		ignoreHtmlClass: '.',
		processHtmlClass: 'arithmatex'
	}
};

