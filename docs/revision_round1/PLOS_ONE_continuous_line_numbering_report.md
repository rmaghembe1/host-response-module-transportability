# PLOS ONE Continuous Line-Numbering Repair

Input clean DOCX SHA256: `b6537d79201d6a750a6de0479ac756861ec5b826cb8573d9b43f66c539df65f5`
Candidate SHA256: `691f494f5f2335b1a96f5b8d009c815d733b3c74fab0f230eaa3f73274f6b38f`
Promoted DOCX SHA256: `691f494f5f2335b1a96f5b8d009c815d733b3c74fab0f230eaa3f73274f6b38f`

Visual QA showed that the landscape table sections rendered correctly, but line numbering restarted at each section boundary.

The repair retains start=1 only for the first section and removes forced start values from sections 2-5 while retaining restart=continuous throughout.

The two landscape tables retain their data matrices. Column widths were modestly refined for module identifiers and compact numeric fields; no table text or scientific value was changed.

Checks passed: 34/34
Quality gate: `PASS`
Final status: `READY_FOR_FINAL_CONTINUOUS_LINE_NUMBER_VISUAL_QA`

A focused render spanning the landscape section boundaries is still required to confirm visible line-number continuity.
