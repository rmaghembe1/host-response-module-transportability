#!/usr/bin/env python3

from pathlib import Path

src = Path("docs/complete_manuscript_draft_v1.1_step3_front_end_matter.md")
out = Path("docs/complete_manuscript_draft_v1.2_step4_references.md")

text = src.read_text()

text = text.replace(
    "# Complete Manuscript Draft v1.1 — Step 3 CMI Front and End Matter",
    "# Complete Manuscript Draft v1.2 — Step 4 Vancouver References"
)

replacements = {
    "Distinguishing bacterial from viral infection remains important for infectious-disease medicine, antimicrobial stewardship and host-response biology.":
    "Distinguishing bacterial from viral infection remains important for infectious-disease medicine, antimicrobial stewardship and host-response biology [1–4].",

    "Although pathogen detection is central to diagnosis, microbiological results may be delayed, insensitive or difficult to interpret when colonization, co-infection or previous antimicrobial exposure complicate pathogen attribution.":
    "Although pathogen detection is central to diagnosis, microbiological results may be delayed, insensitive or difficult to interpret when colonisation, co-infection or previous antimicrobial exposure complicate pathogen attribution [2,5,6].",

    "Host transcriptomic studies have therefore been widely explored as complementary approaches, but much work has emphasized diagnostic classifiers and prediction performance rather than whether the underlying host-response biology is transportable across heterogeneous cohorts.":
    "Host transcriptomic studies have therefore been widely explored as complementary approaches, but much work has emphasised diagnostic classifiers and prediction performance rather than whether the underlying host-response biology is transportable across heterogeneous cohorts [7–10].",

    "A classifier may perform well because of cohort-specific, technical or sampling structure, whereas fixed-module projection asks whether predefined gene sets remain directionally stable outside the discovery dataset without gene reselection, module redefinition or model retraining.":
    "A classifier may perform well because of cohort-specific, technical or sampling structure, whereas fixed-module projection asks whether predefined gene sets remain directionally stable outside the discovery dataset without gene reselection, module redefinition or model retraining [8,10,11].",

    "Public infection transcriptomic cohorts are valuable for this purpose but require safeguards because samples may differ by geography, clinical syndrome, pathogen spectrum, platform, preprocessing and case definition.":
    "Public infection transcriptomic cohorts are valuable for this purpose but require safeguards because samples may differ by geography, clinical syndrome, pathogen spectrum, platform, preprocessing and case definition [7,9,11].",

    "GSE211567 metadata and normalized expression data were audited before modelling.":
    "GSE211567 metadata and normalised expression data were audited before modelling [12].",

    "GSE73461 expression and annotation files were audited independently.":
    "GSE73461 expression and annotation files were audited independently [13].",

    "Differential-expression results were treated as a discovery-ranking layer rather than a diagnostic signature.":
    "Differential-expression results were treated as a discovery-ranking layer rather than a diagnostic signature [14].",

    "Redundant enriched terms were reduced and manually reviewed to define biologically interpretable modules.":
    "Redundant enriched terms were reduced and manually reviewed to define biologically interpretable modules using Gene Ontology biological-process annotation [15,16].",

    "Wilcoxon rank-sum tests compared module scores between DefiniteBacterial and DefiniteViral groups, and Benjamini–Hochberg correction was applied across the five modules.":
    "Wilcoxon rank-sum tests compared module scores between DefiniteBacterial and DefiniteViral groups, and Benjamini–Hochberg correction was applied across the five modules [17].",

    "Their robust expected-direction behaviour in GSE73461 is consistent with the central role of interferon-linked host responses in viral infection.":
    "Their robust expected-direction behaviour in GSE73461 is consistent with the central role of interferon-linked host responses in viral infection and with prior host-response studies in which interferon-inducible biomarkers contributed to viral-versus-bacterial discrimination [3,4,18].",

    "The bacterial-associated BACT_M2 module also transported robustly and suggests that mitochondrial respiration and oxidative phosphorylation programmes may form part of a bacterial-associated host-response architecture in this analysis.":
    "The bacterial-associated BACT_M2 module also transported robustly and suggests that mitochondrial respiration and oxidative phosphorylation programmes may form part of a bacterial-associated host-response architecture in this analysis, consistent with evidence that infection and inflammatory activation can remodel leukocyte immunometabolism [19,20].",

    "Several limitations should guide interpretation.":
    "Several limitations should guide interpretation, particularly because bacterial-versus-viral adjudication and host-response studies can be affected by imperfect reference standards, heterogeneous syndromes and mixed pathogen detection [2,6,21].",
}

for old, new in replacements.items():
    if old not in text:
        raise SystemExit(f"Target sentence not found for replacement:\n{old}")
    text = text.replace(old, new)

references = """# References

[1] Metlay JP, Waterer GW, Long AC, Anzueto A, Brozek J, Crothers K, et al. Diagnosis and treatment of adults with community-acquired pneumonia. An official clinical practice guideline of the American Thoracic Society and Infectious Diseases Society of America. Am J Respir Crit Care Med. 2019;200:e45–67. DOI:https://doi.org/10.1164/rccm.201908-1581ST

[2] Halabi S, Shiber S, Paz M, Gottlieb TM, Barash E, Navon R, et al. Host test based on tumour necrosis factor-related apoptosis-inducing ligand, interferon gamma-induced protein-10 and C-reactive protein for differentiating bacterial and viral respiratory tract infections in adults: diagnostic accuracy study. Clin Microbiol Infect. 2023;29:1159–65. DOI:https://doi.org/10.1016/j.cmi.2023.05.033

[3] Papan C, Argentiero A, Porwoll M, Hakim U, Farinelli E, Testa I, et al. A host signature based on TRAIL, IP-10, and CRP for reducing antibiotic overuse in children by differentiating bacterial from viral infections: a prospective, multicentre cohort study. Clin Microbiol Infect. 2022;28:723–30. DOI:https://doi.org/10.1016/j.cmi.2021.10.019

[4] Rhedin S, Eklundh A, Ryd-Rinder M, Peltola V, Waris M, Gantelius J, et al. Myxovirus resistance protein A for discriminating between viral and bacterial lower respiratory tract infections in children — The TREND study. Clin Microbiol Infect. 2022;28:1251–7. DOI:https://doi.org/10.1016/j.cmi.2022.05.008

[5] Jain S, Self WH, Wunderink RG, Fakhran S, Balk R, Bramley AM, et al. Community-acquired pneumonia requiring hospitalization among U.S. adults. N Engl J Med. 2015;373:415–27. DOI:https://doi.org/10.1056/NEJMoa1500245

[6] Rutjes AWS, Reitsma JB, Coomarasamy A, Khan KS, Bossuyt PMM. Evaluation of diagnostic tests when there is no gold standard. A review of methods. Health Technol Assess. 2007;11:iii, ix–51. DOI:https://doi.org/10.3310/hta11500

[7] Herberg JA, Kaforou M, Wright VJ, Shailes H, Eleftherohorinou H, Hoggart CJ, et al. Diagnostic test accuracy of a 2-transcript host RNA signature for discriminating bacterial vs viral infection in febrile children. JAMA. 2016;316:835–45. DOI:https://doi.org/10.1001/jama.2016.11236

[8] Andres-Terre M, McGuire HM, Pouliot Y, Bongen E, Sweeney TE, Tato CM, et al. Integrated, multi-cohort analysis identifies conserved transcriptional signatures across multiple respiratory viruses. Immunity. 2015;43:1199–211. DOI:https://doi.org/10.1016/j.immuni.2015.11.003

[9] Sweeney TE, Wong HR, Khatri P. Robust classification of bacterial and viral infections via integrated host gene expression diagnostics. Sci Transl Med. 2016;8:346ra91. DOI:https://doi.org/10.1126/scitranslmed.aaf7165

[10] Oved K, Cohen A, Boico O, Navon R, Friedman T, Etshtein L, et al. A novel host-proteome signature for distinguishing between acute bacterial and viral infections. PLoS One. 2015;10:e0120012. DOI:https://doi.org/10.1371/journal.pone.0120012

[11] Fernandez-Carballo BL, Escadafal C, MacLean E, Kapasi AJ, Dittrich S. Distinguishing bacterial versus non-bacterial causes of febrile illness — a systematic review of host biomarkers. J Infect. 2021;82:1–10. DOI:https://doi.org/10.1016/j.jinf.2021.01.028

[12] National Center for Biotechnology Information. Gene Expression Omnibus accession GSE211567. Available from: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE211567

[13] National Center for Biotechnology Information. Gene Expression Omnibus accession GSE73461. Available from: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE73461

[14] Ritchie ME, Phipson B, Wu D, Hu Y, Law CW, Shi W, et al. limma powers differential expression analyses for RNA-sequencing and microarray studies. Nucleic Acids Res. 2015;43:e47. DOI:https://doi.org/10.1093/nar/gkv007

[15] Ashburner M, Ball CA, Blake JA, Botstein D, Butler H, Cherry JM, et al. Gene Ontology: tool for the unification of biology. Nat Genet. 2000;25:25–9. DOI:https://doi.org/10.1038/75556

[16] Gene Ontology Consortium. The Gene Ontology resource: enriching a GOld mine. Nucleic Acids Res. 2021;49:D325–34. DOI:https://doi.org/10.1093/nar/gkaa1113

[17] Benjamini Y, Hochberg Y. Controlling the false discovery rate: a practical and powerful approach to multiple testing. J R Stat Soc Series B Stat Methodol. 1995;57:289–300. DOI:https://doi.org/10.1111/j.2517-6161.1995.tb02031.x

[18] Schneider WM, Chevillotte MD, Rice CM. Interferon-stimulated genes: a complex web of host defences. Annu Rev Immunol. 2014;32:513–45. DOI:https://doi.org/10.1146/annurev-immunol-032713-120231

[19] O'Neill LAJ, Kishton RJ, Rathmell J. A guide to immunometabolism for immunologists. Nat Rev Immunol. 2016;16:553–65. DOI:https://doi.org/10.1038/nri.2016.70

[20] Russell DG, Huang L, VanderVen BC. Immunometabolism at the interface between macrophages and pathogens. Nat Rev Immunol. 2019;19:291–304. DOI:https://doi.org/10.1038/s41577-019-0124-9

[21] Bossuyt PM, Reitsma JB, Bruns DE, Gatsonis CA, Glasziou PP, Irwig L, et al. STARD 2015: an updated list of essential items for reporting diagnostic accuracy studies. BMJ. 2015;351:h5527. DOI:https://doi.org/10.1136/bmj.h5527
"""

if "# References" in text:
    raise SystemExit("References section already present.")

text = text.rstrip() + "\n\n" + references + "\n"

out.write_text(text)
print(f"Wrote: {out}")
