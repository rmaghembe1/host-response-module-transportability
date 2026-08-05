# GSE72810 candidate validation audit

## Cohort structure

- Total samples: 146.
- Definite bacterial: 23.
- Definite viral: 28.
- Probable bacterial: 17.
- Probable viral: 7.
- Uncertain: 55.
- Controls: 16.

## Structural validation

- Matrix probes: 48803.
- Matrix samples: 146.
- Matrix probes absent from GPL6947 annotation: 0.
- Matrix probes with multiple parsed symbols: 0.

## Sample groups

```text
             category expected_n observed_n count_match
               <char>      <int>      <int>      <lgcl>
1: Definite Bacterial         23         23        TRUE
2:     Definite Viral         28         28        TRUE
3: Probable Bacterial         17         17        TRUE
4:     Probable Viral          7          7        TRUE
5:          Uncertain         55         55        TRUE
6:            Control         16         16        TRUE
```

## Locked-module coverage

```text
   final_module_id locked_gene_count mapped_gene_count missing_gene_count
            <char>             <int>             <int>              <int>
1:         BACT_M1                25                24                  1
2:         BACT_M2                21                14                  7
3:         VIR_M1a               128               120                  8
4:         VIR_M1b                33                31                  2
5:          VIR_M2               106                98                  8
   coverage_fraction mapped_probe_count eligible_at_50_percent
               <num>              <int>                 <lgcl>
1:         0.9600000                 46                   TRUE
2:         0.6666667                 18                   TRUE
3:         0.9375000                210                   TRUE
4:         0.9393939                 57                   TRUE
5:         0.9245283                165                   TRUE
   high_coverage_at_70_percent
                        <lgcl>
1:                        TRUE
2:                       FALSE
3:                        TRUE
4:                        TRUE
5:                        TRUE
                                          missing_symbols
                                                   <char>
1:                                                 HYDIN2
2:    ATP5F1A;ATP5ME;ATP5MF;MTFR2;NDUFAF6;NDUFAF7;NDUFAF8
3:     ADGRB1;DDX60L;IFIT1B;NT5C3A;PLPP6;POLR3E;RIGI;URI1
4:                                            RIGI;TOMM70
5: ACKR3;BTN2A3P;CCRL2;CTSL;GPR183;KIR3DS1;MARCHF1;ZBTB49
```

## Decision

- Quality gate: `PASS`.
- Scoring readiness: `READY_WITH_LOW_COVERAGE_SENSITIVITY_REQUIRED`.
- Candidate role: `SECOND_INDEPENDENT_SAMPLE_COHORT_AND_CROSS_PLATFORM_VALIDATION`.

The primary validation contrast is restricted to Definite Bacterial versus Definite Viral samples.

Probable cases are reserved for an expanded sensitivity analysis. Controls provide contextual reference information, and uncertain-aetiology samples are excluded from pathogen-class contrasts.

Participant overlap with another GEO accession cannot be excluded directly because no participant identifier was recovered from the deposited GSE72810 metadata.
