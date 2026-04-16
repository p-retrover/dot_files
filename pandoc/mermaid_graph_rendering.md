To make your diagrams perfectly compatible with Markdown previews (like GitHub, VS Code, or Obsidian) and seamlessly convertible via Pandoc, the absolute best tool is **Mermaid.js**.

Mermaid allows you to generate flowcharts, state-space trees, and sequence diagrams using plain text directly inside your `.md` files.

### The Mermaid Diagram

Copy and paste this exactly as it appears into your Markdown file. Notice that it uses `mermaid` as the language tag for the code block:

```mermaid
graph TD
    %% Root Node
    Root(((Start: A)))
    
    %% Level 1: First City Visited
    Root -->|Cost: 10 <br> Lower Bound: 45| B(Path: A ➔ B)
    Root -->|Cost: 15 <br> Lower Bound: 55| C(Path: A ➔ C)
    
    %% PRUNED BRANCH
    Root -.->|Cost: 20 <br> Lower Bound: 95 <br> Exceeds Best Cost!| D[Path: A ➔ D <br> ❌ PRUNED]
    style D fill:#ffe6e6,stroke:#cc0000,stroke-width:2px,stroke-dasharray: 5 5

    %% Level 2: Second City Visited (from B)
    B -->|Cost: 35| BC(Path: A ➔ B ➔ C)
    B -->|Cost: 25| BD(Path: A ➔ B ➔ D)

    %% Level 2: Second City Visited (from C)
    C -->|Cost: 35| CB(Path: A ➔ C ➔ B)
    C -->|Cost: 30| CD(Path: A ➔ C ➔ D)

    %% Leaves: Final City and Return to A (Optimal vs Sub-optimal)
    BC -->|Return Cost: 20| BCA(((Tour: A-B-C-D-A <br> Total: 95)))
    BD -->|Return Cost: 15| BDA(((Tour: A-B-D-C-A <br> Total: 80)))
    style BDA fill:#d4edda,stroke:#28a745,stroke-width:3px
```

### How to process this with Pandoc

To get Pandoc to convert this text block into a beautiful image in your final PDF, you need to use a **Pandoc Filter**.

1. **Install the filter:** The most common one for Node.js users is `mermaid-filter`.

   ```bash
   npm install --global mermaid-filter
   ```

2. **Update your Pandoc Command:** Add the `--filter` flag to your existing workflow.

   ```bash
   pandoc 424ma5005_assignment_5.md -o 424ma5005_assignment_5.pdf \
   --pdf-engine=pdflatex \
   --number-sections \
   --toc \
   --listings \
   --filter mermaid-filter
   ```
