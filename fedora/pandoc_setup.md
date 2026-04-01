On Fedora, the cleanest way is to install **Pandoc + a LaTeX engine**, then Pandoc can convert Markdown directly to PDF. Below is a reliable setup that works well for assignments like yours (math, code blocks, images).

---

# 1. Install Pandoc

```bash
sudo dnf install pandoc
```

Check:

```bash
pandoc --version
```

---

# 2. Install a LaTeX Engine

Pandoc does **not generate PDFs by itself** — it converts Markdown → LaTeX → PDF using a LaTeX engine.

### Recommended (lightweight)

```bash
sudo dnf install texlive-scheme-basic
```

But for math, code highlighting, graphics etc., it's safer to install:

```bash
sudo dnf install texlive-scheme-medium
```

This avoids missing package errors.

Check:

```bash
pdflatex --version
```

---

# 3. Install Syntax Highlighting (optional but useful)

Pandoc uses **Skylighting**, but installing `pygments` helps with some templates.

```bash
sudo dnf install python3-pygments
```

---

# 4. Your Working Directory Structure

Example:

```
assignment/
├── assignment.md
├── screenshots/
│   ├── 1.png
│   ├── 2.png
│   └── 3.png
```

---

# 5. Convert Markdown → PDF

Basic command:

```bash
pandoc assignment.md -o assignment.pdf --pdf-engine=pdflatex
```

Recommended command for assignments:

```bash
pandoc assignment.md \
-o assignment.pdf \
--pdf-engine=pdflatex \
--number-sections \
--toc
```

This adds:

* numbered sections
* table of contents

---

# 6. Better Fonts (Highly Recommended)

Install a modern engine:

```bash
sudo dnf install texlive-xetex
```

Then run:

```bash
pandoc assignment.md \
-o assignment.pdf \
--pdf-engine=xelatex
```

Advantages:

* better fonts
* Unicode support
* nicer PDF output

---

# 7. Use a Pandoc Template (Optional but Professional)

Create a command like:

```bash
pandoc assignment.md \
-o assignment.pdf \
--pdf-engine=xelatex \
-V geometry:margin=1in \
-V fontsize=12pt
```

---

# 8. Automatic Build Script (Useful)

Create a **build script**:

`build.sh`

```bash
#!/bin/bash

pandoc assignment.md \
-o assignment.pdf \
--pdf-engine=xelatex \
--number-sections \
--toc
```

Run:

```bash
chmod +x build.sh
./build.sh
```

---

# 9. Even Better: Use a Makefile

If you write assignments frequently.

Create `Makefile`:

```
pdf:
	pandoc assignment.md -o assignment.pdf --pdf-engine=xelatex
```

Run:

```bash
make
```

---

# 10. Useful Pandoc Options

| Option                    | Purpose            |
| ------------------------- | ------------------ |
| `--toc`                   | table of contents  |
| `--number-sections`       | numbered headings  |
| `--pdf-engine=xelatex`    | better font engine |
| `-V geometry:margin=1in`  | page margin        |
| `--highlight-style=tango` | code highlighting  |

Example full command:

```bash
pandoc assignment.md \
-o assignment.pdf \
--pdf-engine=xelatex \
--toc \
--number-sections \
--highlight-style=tango \
-V geometry:margin=1in
```

---

# 11. Recommended Markdown Style (Pandoc-friendly)

Avoid:

```
$$ \text{Name} $$ 
```

Better:

```
**Name:** Omm Satyakam Behera  
**Roll No:** 424MA5005
```

This produces **cleaner LaTeX**.

---

# 12. Verify Everything Works

Test with a small file:

`test.md`

```
# Test

Hello world.

$$
x^2 + y^2 = z^2
$$
```

Run:

```bash
pandoc test.md -o test.pdf --pdf-engine=xelatex
```

If you get a PDF → setup is complete.

---

# 13. (Optional but Powerful) Install Pandoc Filters

Useful for academic writing.

```
sudo dnf install pandoc-crossref
```

Enables automatic figure numbering.

---

✅ After this setup you can do:

```
pandoc assignment.md -o assignment.pdf
```

and get a **fully formatted PDF instantly**.

---

# Resources

[Deep Learning book notation](https://github.com/goodfeli/dlbook_notation)
