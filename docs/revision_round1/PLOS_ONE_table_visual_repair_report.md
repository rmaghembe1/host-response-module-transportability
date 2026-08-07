# PLOS ONE Table Visual Repair

Input clean DOCX SHA256: `a82a36dac6d69fa642c0a749a1514ca2db795e8c5297418fde8d5feb69e8768e`
Candidate SHA256: `b6537d79201d6a750a6de0479ac756861ec5b826cb8573d9b43f66c539df65f5`
Promoted DOCX SHA256: `b6537d79201d6a750a6de0479ac756861ec5b826cb8573d9b43f66c539df65f5`

Visual QA identified Tables 1 and 2 as unreadable in portrait because Word compressed the wide editable tables into very narrow columns.

Table 1 was converted to an 11-column reader-facing table by removing the internal supplementary_table_section provenance column. All scientific data columns were retained. The title was shortened and its methodological detail was retained as a legend below the table.

Table 2 retained all nine columns. Both tables were assigned dedicated landscape sections, fixed reader-oriented column widths, repeating header rows, black Times New Roman table text, and compact within-cell spacing.

Checks passed: 38/38
Quality gate: `PASS`
Final status: `READY_FOR_TABLE_FOCUSED_FULL_RENDER_AND_VISUAL_QA`

A full render and page-by-page visual inspection remain required before the clean manuscript can be accepted.
