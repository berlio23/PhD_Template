\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{2024/01/28 Ph.D LaTeX Class}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}

\ProcessOptions\relax


\LoadClass[a4]{book}

\newcommand{\addchap}[1]{\include{chap_#1/chap}}
\renewcommand{\thesection}{\arabic{section}}