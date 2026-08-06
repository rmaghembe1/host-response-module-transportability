# GSE72810-GSE73461 accession-overlap and independence audit

## Scope

This audit distinguishes deposited GEO accession separation, deposited sample separation, platform separation, participant separation and investigator-network independence.

Descriptive labels such as Control_01 and DefiniteBacterial_01 were treated as cohort-local labels rather than participant identifiers.

## GEO accession comparison

```text
                 comparison gse72810_samples gse73461_samples
                     <char>            <int>            <int>
1: GSE72810 versus GSE73461              146              459
   shared_gsm_accessions gse72810_only_accessions gse73461_only_accessions
                   <int>                    <int>                    <int>
1:                     0                      146                      459
   accession_sets_disjoint
                    <lgcl>
1:                    TRUE
                                                                                     accession_level_interpretation
                                                                                                             <char>
1: The deposited GSM accession sets are disjoint, supporting accession-level and deposited-sample-level separation.
```

## Descriptive-title comparison

```text
   gse72810_unique_titles gse73461_unique_titles exact_full_title_overlap
                    <int>                  <int>                    <int>
1:                    146                    459                        0
   normalized_label_overlap_rows normalized_label_overlap_values
                           <int>                           <int>
1:                           122                             122
   normalized_title_labels_are_participant_ids
                                        <lgcl>
1:                                       FALSE
                                                                                            interpretation
                                                                                                    <char>
1: Reused descriptive labels are cohort-local naming conventions and do not establish participant overlap.
```

## Platform comparison

```text
   gse72810_platforms gse73461_platforms expected_gse72810_platform
               <char>             <char>                     <char>
1:            GPL6947           GPL10558                    GPL6947
   expected_gse73461_platform gse72810_platform_matches_expected
                       <char>                             <lgcl>
1:                   GPL10558                               TRUE
   gse73461_platform_matches_expected platform_sets_disjoint
                               <lgcl>                 <lgcl>
1:                               TRUE                   TRUE
                                                                                 platform_interpretation
                                                                                                  <char>
1: GSE72810 and GSE73461 use different Illumina array generations, supporting cross-platform validation.
```

## Participant-identifier audit

```text
Index: <cohort>
     cohort metadata_rows dedicated_participant_identifier_column_count
     <char>         <int>                                         <int>
1: GSE72810           146                                             0
2: GSE73461           459                                             0
   dedicated_participant_identifier_columns
                                     <char>
1:                                     none
2:                                     none
   participant_identifier_key_value_match_count
                                          <int>
1:                                            0
2:                                            0
   participant_identifier_available participant_overlap_assessable
                             <lgcl>                         <lgcl>
1:                            FALSE                          FALSE
2:                            FALSE                          FALSE
                                                                                        interpretation
                                                                                                <char>
1: No dedicated participant identifier was recovered; participant overlap cannot be directly assessed.
2: No dedicated participant identifier was recovered; participant overlap cannot be directly assessed.
```

## Shared contact and network evidence

```text
        contact_field            normalized_value
               <char>                      <char>
1: contact_department                 paediatrics
2:      contact_email    m.kaforou@imperial.ac.uk
3:      contact_email      m.levin@imperial.ac.uk
4:      contact_email     v.wright@imperial.ac.uk
5:  contact_institute       imperialcollegelondon
6: contact_laboratory siralexanderflemingbuilding
7:       contact_name                michaellevin
               gse72810_raw_value             gse73461_raw_value
                           <char>                         <char>
1:                    Paediatrics                    Paediatrics
2:       m.kaforou@imperial.ac.uk       m.kaforou@imperial.ac.uk
3:         m.levin@imperial.ac.uk         m.levin@imperial.ac.uk
4:        v.wright@imperial.ac.uk        v.wright@imperial.ac.uk
5:        Imperial College London        Imperial College London
6: Sir Alexander Fleming Building Sir Alexander Fleming Building
7:                 Michael,,Levin                 Michael,,Levin
   network_evidence_field
                   <lgcl>
1:                   TRUE
2:                   TRUE
3:                   TRUE
4:                   TRUE
5:                   TRUE
6:                   TRUE
7:                   TRUE
                                                                                  interpretation
                                                                                          <char>
1: Shared deposited contact or institutional field supports a shared broad investigator network.
2: Shared deposited contact or institutional field supports a shared broad investigator network.
3: Shared deposited contact or institutional field supports a shared broad investigator network.
4: Shared deposited contact or institutional field supports a shared broad investigator network.
5: Shared deposited contact or institutional field supports a shared broad investigator network.
6: Shared deposited contact or institutional field supports a shared broad investigator network.
7: Shared deposited contact or institutional field supports a shared broad investigator network.
```

## Independence-dimension assessment

```text
                           dimension directly_assessable
                              <char>              <lgcl>
1:    GEO accession-level separation                TRUE
2: Deposited sample-level separation                TRUE
3:         Platform-level separation                TRUE
4:      Participant-level separation               FALSE
5: Investigator-network independence                TRUE
                                          result
                                          <char>
1:                                     SUPPORTED
2: SUPPORTED_AT_DEPOSITED_SAMPLE_ACCESSION_LEVEL
3:                                     SUPPORTED
4:        NOT_ASSESSABLE_FROM_DEPOSITED_METADATA
5:                                 NOT_SUPPORTED
                                                                                                                                         evidence
                                                                                                                                           <char>
1:                                                                        0 shared GSM accessions among 146 GSE72810 and 459 GSE73461 accessions.
2:                               Every deposited sample has a cohort-specific GSM accession; descriptive title labels are not sample identifiers.
3:                                                                                                                       GPL6947 versus GPL10558.
4:                                                  Neither cohort provides a dedicated participant identifier in the audited deposited metadata.
5: 7 shared contact or institutional evidence rows across contact_name, contact_email, contact_laboratory, contact_department, contact_institute.
                                              manuscript_consequence
                                                              <char>
1:         The cohorts may be described as accession-level separate.
2:    GSE72810 may be described as a second deposited sample cohort.
3: GSE72810 provides cross-platform validation relative to GSE73461.
4:  Do not claim that participant overlap was definitively excluded.
5:       Do not describe GSE72810 as fully investigator-independent.
```

## Manuscript wording

```text
Index: <wording_role>
                    wording_role
                          <char>
1:  preferred_cohort_description
2:           required_limitation
3: preferred_results_description
4:      avoid_unqualified_phrase
5:        avoid_overstated_claim
                                                                                                                                                                                                                                                                                                                wording
                                                                                                                                                                                                                                                                                                                 <char>
1:                                                                                                                                                                   GSE72810 was analysed as a second accession-level and sample-level cohort providing cross-platform validation of the locked host-response modules.
2: The GSE72810 and GSE73461 GEO sample accession sets were disjoint and the cohorts were measured on different Illumina array platforms. However, direct participant overlap could not be assessed because participant identifiers were not deposited, and the studies arose from the same broad investigator network.
3:                                                                                                                       Projection into GSE72810 provided additional sample-level and cross-platform support for the locked module architecture, with no module reselection, reweighting or diagnostic-model training.
4:                                                                                                                                                                                                                                                                                  a fully independent external cohort
5:                                                                                                                                                                                                                                                       participant overlap was excluded between GSE72810 and GSE73461
   use_status
       <char>
1:        USE
2:        USE
3:        USE
4:      AVOID
5:      AVOID
                                                                                                  rationale
                                                                                                     <char>
1:                                             Supported by disjoint GSM accessions and distinct platforms.
2: Required because participant identifiers are absent and contact metadata support a shared broad network.
3:                                                    Accurately describes the additional validation layer.
4:                                                      Investigator-network independence is not supported.
5:                                                    Participant-level overlap is not directly assessable.
```

## Preferred interpretation

- GSE72810 was analysed as a second accession-level and sample-level cohort providing cross-platform validation of the locked host-response modules.
- The GSE72810 and GSE73461 GEO sample accession sets were disjoint and the cohorts were measured on different Illumina array platforms. However, direct participant overlap could not be assessed because participant identifiers were not deposited, and the studies arose from the same broad investigator network.

## Quality gate

```text
    check_id
      <char>
 1:      Q01
 2:      Q02
 3:      Q03
 4:      Q04
 5:      Q05
 6:      Q06
 7:      Q07
 8:      Q08
 9:      Q09
10:      Q10
11:      Q11
12:      Q12
13:      Q13
14:      Q14
15:      Q15
16:      Q16
17:      Q17
18:      Q18
                                                                check_description
                                                                           <char>
 1:                             GSE72810 harmonized metadata contains 146 samples
 2:                                   GSE73461 SOFT metadata contains 459 samples
 3:                          GSE73461 series-matrix metadata contains 459 samples
 4:              All three accession sources contain unique valid GSM identifiers
 5:                          GSE73461 SOFT and series-matrix accession sets match
 6:                     GSE73461 SOFT and series-matrix titles match by accession
 7:                                Combined accession inventory contains 605 rows
 8:                         GSE72810 and GSE73461 have zero shared GSM accessions
 9:                                                GSE72810 contains only GPL6947
10:                                               GSE73461 contains only GPL10558
11:                                         The cohort platform sets are disjoint
12:                 No dedicated participant identifier was recovered in GSE72810
13:                 No dedicated participant identifier was recovered in GSE73461
14:                           Contact inventories were recovered for both cohorts
15:                      Shared broad investigator-network evidence was recovered
16:                                    Five independence dimensions were assessed
17:                        Five manuscript-wording recommendations were generated
18: Preferred wording avoids unqualified participant or investigator independence
      pass
    <lgcl>
 1:   TRUE
 2:   TRUE
 3:   TRUE
 4:   TRUE
 5:   TRUE
 6:   TRUE
 7:   TRUE
 8:   TRUE
 9:   TRUE
10:   TRUE
11:   TRUE
12:   TRUE
13:   TRUE
14:   TRUE
15:   TRUE
16:   TRUE
17:   TRUE
18:   TRUE
```

- Quality gate: `PASS`.
- Overall decision: `SECOND_ACCESSION_LEVEL_AND_SAMPLE_LEVEL_COHORT_WITH_CROSS_PLATFORM_VALIDATION_AND_SHARED_NETWORK_CAUTION`.
