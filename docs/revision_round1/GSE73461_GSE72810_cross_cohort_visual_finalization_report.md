# GSE73461-GSE72810 cross-cohort figure visual finalization

## Final corrections

The displayed module order was changed to BACT_M1, BACT_M2, VIR_M1a, VIR_M1b and VIR_M2 from top to bottom.

The in-figure footer was removed because the full interpretive legend is provided separately in the manuscript-facing figure caption.

No analytical values, confidence intervals, P values, cohort definitions, colours, shapes or effect orientations were changed.

## Figure manifest

```text
           figure_role
                <char>
1:     publication_png
2: editable_vector_svg
3:          vector_pdf
                                                                                                                                     file_path
                                                                                                                                        <char>
1: results/revision_round1/GSE73461_GSE72810_cross_cohort_validation/figures/Figure_3_GSE73461_GSE72810_cross_cohort_Hodges_Lehmann_forest.png
2: results/revision_round1/GSE73461_GSE72810_cross_cohort_validation/figures/Figure_3_GSE73461_GSE72810_cross_cohort_Hodges_Lehmann_forest.svg
3: results/revision_round1/GSE73461_GSE72810_cross_cohort_validation/figures/Figure_3_GSE73461_GSE72810_cross_cohort_Hodges_Lehmann_forest.pdf
   file_format width_inches height_inches   dpi
        <char>        <num>         <num> <int>
1:         PNG         10.5           6.8  1800
2:         SVG         10.5           6.8    NA
3:         PDF         10.5           6.8    NA
         final_module_order_top_to_bottom in_figure_footer_present file_exists
                                   <char>                   <lgcl>      <lgcl>
1: BACT_M1;BACT_M2;VIR_M1a;VIR_M1b;VIR_M2                    FALSE        TRUE
2: BACT_M1;BACT_M2;VIR_M1a;VIR_M1b;VIR_M2                    FALSE        TRUE
3: BACT_M1;BACT_M2;VIR_M1a;VIR_M1b;VIR_M2                    FALSE        TRUE
   file_size_bytes                              md5 svg_contains_raster_image
             <num>                           <char>                    <lgcl>
1:         1749256 d7a2b3e965f0c38de5dcb94f981ef831                        NA
2:          123001 2584ef04224befc3e2e13d12163194ed                     FALSE
3:           26254 71337803e9241a6b6db3e3d1c572dd2d                        NA
   svg_path_elements
               <int>
1:                NA
2:              1097
3:                NA
```

## Automated visual-quality gate

```text
    check_id
      <char>
 1:     VQ01
 2:     VQ02
 3:     VQ03
 4:     VQ04
 5:     VQ05
 6:     VQ06
 7:     VQ07
 8:     VQ08
 9:     VQ09
10:     VQ10
11:     VQ11
12:     VQ12
13:     VQ13
14:     VQ14
                                                      check_description   pass
                                                                 <char> <lgcl>
 1:                              Validated source-data table is present   TRUE
 2:                   Source-data table contains ten cohort-module rows   TRUE
 3:                              Source-data table contains two cohorts   TRUE
 4:                      Source-data table contains five locked modules   TRUE
 5:              All plotted estimates and confidence limits are finite   TRUE
 6:                All confidence-interval bounds are correctly ordered   TRUE
 7: The plotting factor encodes the required top-to-bottom module order   TRUE
 8:                               The in-figure footer has been removed   TRUE
 9:             The built forest plot contains ten confidence intervals   TRUE
10:                  The built forest plot contains ten point estimates   TRUE
11:                               PNG, SVG and PDF files were generated   TRUE
12:                                PNG, SVG and PDF files are non-empty   TRUE
13:                           The SVG contains no embedded raster image   TRUE
14:          The figure manifest records the final visual configuration   TRUE
```

- Quality gate: `PASS`.
- Final status: `READY_FOR_FINAL_VISUAL_CONFIRMATION_AND_COMMIT`.

## Required human confirmation

The final PNG or PDF should be inspected for label clipping, confidence-interval visibility, zero-line visibility, legend placement and overall balance before the package is committed.
