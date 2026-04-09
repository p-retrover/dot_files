# Documentation: Markdown to LaTeX/PDF Workflow

This guide details the workflow for converting academic Markdown documents (like Assignment-V) into professional PDFs using `pandoc` and `pdflatex`.

## 1. YAML Front Matter Configuration
To ensure the PDF has a professional title page and proper margins, include this at the top of your `.md` file:

```yaml
---
title: "CS 2066: Design & Analysis of Algorithm Laboratory"
subtitle: "Assignment-V: Dynamic Programming & Network Pathing"
author: |
  | Omm Satyakam Behera
  | Roll No: 424MA5005
  | NIT Rourkela
date: "\\today"
geometry: margin=1in
header-includes:
  - \usepackage{listings}
  - \usepackage{xcolor}
---
```

## 2. Code Block Styling (Listings)
To move away from standard monochrome code blocks to a professional "LaTeX Listings" style with syntax highlighting and frames:

### The Setup File (`listings-setup.tex`)
Create this file to define the visual style of your MATLAB/C++ code:

```latex
\usepackage{xcolor}
\lstset{
    basicstyle=\ttfamily\small,
    breaklines=true,
    frame=single,
    backgroundcolor=\color{gray!3},
    keywordstyle=\color{blue}\bfseries,
    commentstyle=\color{green!50!black},
    stringstyle=\color{orange},
    numbers=left,
    numberstyle=\tiny\color{gray},
    stepnumber=1,
    showstringspaces=false,
    tabsize=4
}
```

## 3. Critical Troubleshooting & Syntax Fixes
When converting math-heavy documents, avoid these common LaTeX engine "Hard Fails":

| Issue | Cause | Fix |
| :--- | :--- | :--- |
| **\textendash error** | Using `–` (en-dash) in math mode `$ ... $` | Replace with standard hyphen `-`. |
| **\textellipsis error** | Using `...` in math mode | Use `\dots` or `\cdots`. |
| **Missing Images** | Incorrect relative path | Ensure paths (e.g., `screenshots/1.png`) are relative to the execution folder. |

## 4. The Conversion Command
Use this specific command from the terminal. This applies the `listings` engine and imports your custom header styles.

```bash
pandoc <input_file>.md -o <output_file>.pdf \
--pdf-engine=pdflatex \
--number-sections \
--toc \
--listings \
-H listings-setup.tex
```

### Command Flags Explained:
* `--number-sections`: Automatically adds 1.1, 1.2 numbering to headers.
* `--toc`: Generates a clickable Table of Contents.
* `--listings`: Forces Pandoc to use the LaTeX `listings` package for code blocks.
* `-H`: Includes the custom styling file in the LaTeX header.

## 5. Visual Layouts
For lab reports, use the `center` environment for screenshots to maintain alignment with the `listings` blocks:

```markdown
\begin{center}
\includegraphics[width=0.8\textwidth]{path/to/screenshot.png}
\end{center}
```

***

