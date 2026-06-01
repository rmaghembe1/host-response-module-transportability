# CMI-Facing Manuscript Adaptation Checklist

## Purpose

This document defines the required adaptation steps for targeting **Clinical Microbiology and Infection (CMI)** as the first financial-first journal option. CMI is prioritized because it appears to offer a subscription/non-open-access route with no publication fee charged to authors, while also providing strong infection and clinical microbiology visibility.

## Current manuscript anchor

Current central manuscript draft:

- `docs/complete_manuscript_draft_v0.4.md`

Current target decision source:

- `docs/cmi_vs_jmm_target_fit_decision.md`

Current financial constraint:

- No APC funding is available.
- CMI should be pursued only through the subscription/non-open-access route unless full open-access coverage is confirmed.

## CMI-facing positioning

### Preferred positioning

The manuscript should be positioned as a reproducible host-response transcriptomics study that identifies site-aware bacterial- and viral-associated immune programmes and tests their fixed-module transportability in an independent infection cohort.

### Avoided positioning

Do not position the manuscript as:

- A diagnostic classifier study.
- A diagnostic model validation study.
- A clinical diagnostic test.
- A biomarker discovery paper claiming clinical readiness.
- A causal pathway validation study.
- A gene rediscovery or module redefinition analysis in GSE73461.

## Title adaptation

### Current working title

Site-aware discovery and external transportability of bacterial- and viral-associated host-response modules across public infection transcriptomes

### CMI-facing title options

1. Site-aware discovery and external transportability of bacterial- and viral-associated host-response modules in public infection transcriptomes
2. Transportability of bacterial- and viral-associated host-response modules across public infection transcriptomes
3. Site-aware host-response module discovery and external projection across bacterial and viral infection transcriptomes

### Recommendation

Use option 1 or 2. Option 1 is more methodological and precise; option 2 is cleaner and more readable.

## Abstract adaptation

### Required changes

- Keep the abstract structured if allowed by the journal.
- Strengthen the infection/clinical microbiology motivation in the Background.
- State clearly that this is not diagnostic classifier validation.
- Keep numerical results for GSE73461 module projection.
- Emphasize external fixed-module projection rather than model performance.
- Mention the no-reselection/no-retraining design.

### Phrases to include

- “host-response programmes”
- “bacterial versus viral infection”
- “site-aware discovery”
- “fixed-module external projection”
- “independent infection cohort”
- “not diagnostic model validation”

### Phrases to avoid

- “diagnostic accuracy”
- “clinical test”
- “validated classifier”
- “biomarker ready for clinical use”
- “causal mechanism”

## Introduction adaptation

### Required additions

- Add stronger infectious-disease and antimicrobial-stewardship motivation.
- Explain why host-response transcriptomics matters when pathogen detection is delayed, incomplete or confounded.
- Explain why classifier-centric studies are useful but insufficient for biological transportability.
- Clarify why public infection transcriptomes require site-aware analysis.
- End with a concise CMI-facing study objective.

### Tone

The Introduction should be clinically aware but not clinically overclaiming. It should motivate infection biology and stewardship relevance without implying that the current analysis is a deployable diagnostic tool.

## Methods adaptation

### Required checks

- Ensure dataset accessions and sample groups are clearly stated.
- Keep the discovery/projection firewall explicit.
- Keep GSE161731 clearly labelled as technical rehearsal only.
- Avoid excessive internal repository details in the main Methods.
- Move long audit/provenance explanations to supplementary materials if needed.
- State statistical tests and BH correction clearly.
- State figure export standards only briefly or move to reproducibility/supplement.

### CMI-facing emphasis

Methods should emphasize rigor and reproducibility, but not overwhelm clinical microbiology readers with too much repository machinery in the main text.

## Results adaptation

### Required checks

- Keep the Results concise and biologically focused.
- Emphasize all five modules retained expected-direction concordance.
- Highlight strongest external support for antiviral/interferon modules.
- Interpret BACT_M2 as robust bacterial-associated immune-metabolic transportability.
- Keep BACT_M1 cautious: directionally concordant but borderline.
- Avoid any classifier-performance language.

### Figure/table use

- Figure 1: discovery and module locking.
- Figure 2: external fixed-module projection.
- Table 1: GSE73461 projection summary.

## Discussion adaptation

### Required strengthening

- Strengthen infection-biology relevance.
- Add cautious antimicrobial-stewardship motivation.
- Emphasize why module transportability complements diagnostic classifier studies.
- Discuss biological plausibility of interferon and immune-metabolic modules.
- Keep limitations prominent.

### Required limitations

- Public dataset metadata constraints.
- Cohort/platform heterogeneity.
- Transcriptomic module associations do not prove causality.
- No prospective clinical validation.
- No diagnostic classifier training or validation.
- GSE161731 was technical rehearsal only.

## Cover letter adaptation

### Required message

The cover letter should emphasize:

- No-APC subscription route requested/selected.
- Manuscript is suitable for CMI because it addresses bacterial-versus-viral host-response biology across public infection transcriptomes.
- The analysis is reproducible and conservative.
- The work avoids diagnostic overclaiming and focuses on transportable host-response programmes.
- The manuscript may interest readers concerned with infection biology, clinical microbiology and antimicrobial-stewardship research.

## Supplementary material adaptation

### Recommended supplementary files

- Candidate external cohort search register.
- GSE261482 audit.
- GSE68310 audit.
- GSE161731 technical rehearsal summary.
- GSE211567 locked module gene tables.
- GSE73461 identifier coverage table.
- GSE73461 projection sample table.
- Session information.
- Package/path audit outputs.
- Figure export standard.

### Supplementary strategy

Move detailed workflow audit/provenance materials to supplement so the main manuscript remains readable for CMI.

## Financial/submission note

CMI should be pursued through the standard subscription/non-open-access route unless full OA coverage is confirmed. Do not select optional open access during submission unless a full waiver or institutional/publisher coverage route is secured.

## Immediate next actions

1. Draft a CMI-facing title and abstract variant.
2. Create a CMI-facing Introduction revision checklist with references needed.
3. Create a CMI-facing cover letter draft.
4. Prepare supplementary-material inventory.
5. Confirm CMI author instructions for word limits, article type, figure/table requirements and subscription publication route.

## Interpretation boundary

The CMI adaptation must preserve the manuscript's central claim: fixed-module transportability analysis of host-response programmes. It must not become diagnostic classifier discovery, diagnostic model validation, clinical diagnostic test development, gene rediscovery, module redefinition or causal validation.
