#!/usr/bin/env python3
from __future__ import annotations

import csv
import hashlib
import os
import shutil
import subprocess
import zipfile
from pathlib import Path

from lxml import etree


W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
NS = {"w": W_NS}


def q(tag: str) -> str:
    return f"{{{W_NS}}}{tag}"


RESPONSE_DOCX = Path(
    "submission/revision_round1/"
    "PONE-D-26-30583_response_to_editor_and_reviewers.docx"
)

EXPECTED_RESPONSE_SHA = (
    "2043b60fb61e8aa6787a1d730b46b099"
    "17465f867f9fa8f5e9c97b6253a24dd5"
)

CLEAN_DOCX = Path(
    "submission/revision_round1/"
    "PONE-D-26-30583_clean_revised_manuscript.docx"
)

EXPECTED_CLEAN_SHA = (
    "3a9db22fe7e1847bc9f994d2833f80ba"
    "fd5395a92aa4fc87964218172cf4835e"
)

MARKED_DOCX = Path(
    "submission/revision_round1/"
    "PONE-D-26-30583_marked_up_revised_manuscript.docx"
)

EXPECTED_MARKED_SHA = (
    "829134652d86d049585366ef9ab61dde"
    "6eb87520a411a60c4c9c2cdf5ce92084"
)

SOURCE_V24 = Path(
    "docs/complete_manuscript_draft_v2.4_"
    "submission_candidate_ai_methods_compliance.md"
)

EXPECTED_SOURCE_SHA = (
    "54aabce4263c581dd9685a1ae9d2fd1b"
    "05030d1c3fe072bff78512a293acd6bd"
)


RR11_HEADING = (
    "Reviewer 2, Comment 3 — Control samples and z-score reference"
)

LOCATION_PREFIX = "Changes in the revised manuscript:"
EVIDENCE_PREFIX = "Supporting analysis/material:"


WORK = Path(
    "work/plosone_revision_round1_2026/"
    "phaseR1E15E_minimal_response_pagination"
)

OUT = Path(
    "results/revision_round1/"
    "plosone_response_letter_minimal_pagination_v2.4"
)

CANDIDATE = (
    WORK
    / "PONE-D-26-30583_response_minimal_pagination_candidate.docx"
)

RENDER = WORK / "render"
PROFILE = WORK / "libreoffice_profile"
PAGES = WORK / "pages"
CONTACT = WORK / "contact_sheets"

QUALITY = (
    OUT
    / "PLOS_ONE_response_minimal_pagination_quality_gate.tsv"
)

SUMMARY = (
    OUT
    / "PLOS_ONE_response_minimal_pagination_summary.tsv"
)

REPORT = Path(
    "docs/revision_round1/"
    "PLOS_ONE_response_minimal_pagination_report.md"
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()

    with path.open("rb") as handle:
        for chunk in iter(
            lambda: handle.read(1024 * 1024),
            b"",
        ):
            digest.update(chunk)

    return digest.hexdigest()


def norm(value: str) -> str:
    return " ".join(
        value.replace("\u00a0", " ").split()
    )


def paragraph_text(
    paragraph: etree._Element,
) -> str:
    return norm(
        "".join(
            paragraph.xpath(
                ".//w:t/text() | .//w:delText/text()",
                namespaces=NS,
            )
        )
    )


def xml_bytes(
    root: etree._Element,
) -> bytes:
    return etree.tostring(
        root,
        xml_declaration=True,
        encoding="UTF-8",
        standalone="yes",
    )


def ensure_ppr(
    paragraph: etree._Element,
) -> etree._Element:
    ppr = paragraph.find(
        "w:pPr",
        namespaces=NS,
    )

    if ppr is None:
        ppr = etree.Element(
            q("pPr")
        )
        paragraph.insert(
            0,
            ppr,
        )

    return ppr


def add_keep_next(
    paragraph: etree._Element,
) -> None:
    ppr = ensure_ppr(
        paragraph
    )

    if (
        ppr.find(
            "w:keepNext",
            namespaces=NS,
        )
        is None
    ):
        ppr.append(
            etree.Element(
                q("keepNext")
            )
        )


def add_keep_lines(
    paragraph: etree._Element,
) -> None:
    ppr = ensure_ppr(
        paragraph
    )

    if (
        ppr.find(
            "w:keepLines",
            namespaces=NS,
        )
        is None
    ):
        ppr.append(
            etree.Element(
                q("keepLines")
            )
        )


def has_control(
    paragraph: etree._Element,
    control: str,
) -> bool:
    ppr = paragraph.find(
        "w:pPr",
        namespaces=NS,
    )

    if ppr is None:
        return False

    return (
        ppr.find(
            f"w:{control}",
            namespaces=NS,
        )
        is not None
    )


def direct_paragraphs(
    body: etree._Element,
) -> list[etree._Element]:
    return [
        child
        for child in body
        if child.tag == q("p")
    ]


def find_exact(
    body: etree._Element,
    text: str,
) -> etree._Element:
    matches = [
        paragraph
        for paragraph in direct_paragraphs(body)
        if paragraph_text(paragraph) == text
    ]

    if len(matches) != 1:
        raise RuntimeError(
            f"Expected one paragraph {text!r}; "
            f"found {len(matches)}"
        )

    return matches[0]


def find_rr11_field(
    body: etree._Element,
    heading: etree._Element,
    prefix: str,
) -> etree._Element:
    children = list(body)
    start = children.index(
        heading
    )

    for node in children[
        start + 1:
    ]:

        if node.tag == q("p"):

            text = paragraph_text(
                node
            )

            if (
                text.startswith("Reviewer 2, Comment 4")
                or text.startswith("Reviewer 2, Comment 5")
            ):
                break

            if text.startswith(
                prefix
            ):
                return node

    raise RuntimeError(
        f"Could not locate RR11 field: {prefix}"
    )


def write_docx(
    source: Path,
    destination: Path,
    document_xml: bytes,
) -> None:
    destination.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    with zipfile.ZipFile(
        source,
        "r",
    ) as zin:

        with zipfile.ZipFile(
            destination,
            "w",
            zipfile.ZIP_DEFLATED,
        ) as zout:

            for info in zin.infolist():

                if (
                    info.filename
                    == "word/document.xml"
                ):
                    payload = (
                        document_xml
                    )
                else:
                    payload = zin.read(
                        info.filename
                    )

                zout.writestr(
                    info,
                    payload,
                )


def write_tsv(
    path: Path,
    rows: list[dict[str, object]],
) -> None:
    path.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    with path.open(
        "w",
        encoding="utf-8",
        newline="",
    ) as handle:

        writer = csv.DictWriter(
            handle,
            fieldnames=list(
                rows[0].keys()
            ),
            delimiter="\t",
            lineterminator="\n",
        )

        writer.writeheader()
        writer.writerows(rows)


def render_docx(
    path: Path,
) -> tuple[int, Path, str]:
    RENDER.mkdir(
        parents=True,
        exist_ok=True,
    )

    PROFILE.mkdir(
        parents=True,
        exist_ok=True,
    )

    for old in RENDER.glob(
        "*.pdf"
    ):
        old.unlink()

    env = os.environ.copy()
    env["HOME"] = str(
        PROFILE.resolve()
    )

    result = subprocess.run(
        [
            "soffice",
            "--headless",
            (
                "-env:UserInstallation="
                f"file://{PROFILE.resolve()}"
            ),
            "--convert-to",
            "pdf",
            "--outdir",
            str(RENDER.resolve()),
            str(path.resolve()),
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        env=env,
        timeout=120,
    )

    pdf = (
        RENDER
        / f"{path.stem}.pdf"
    )

    return (
        result.returncode,
        pdf,
        result.stdout.strip(),
    )


def pdf_pages(
    pdf: Path,
) -> int:
    result = subprocess.run(
        [
            "pdfinfo",
            str(pdf),
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )

    for line in result.stdout.splitlines():
        if line.startswith("Pages:"):
            return int(
                line.split(
                    ":",
                    1,
                )[1].strip()
            )

    return 0


def make_pngs(
    pdf: Path,
) -> list[Path]:
    PAGES.mkdir(
        parents=True,
        exist_ok=True,
    )

    for old in PAGES.glob(
        "page-*.png"
    ):
        old.unlink()

    result = subprocess.run(
        [
            "pdftoppm",
            "-png",
            "-r",
            "180",
            str(pdf),
            str(PAGES / "page"),
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )

    if result.returncode != 0:
        raise RuntimeError(
            result.stdout
        )

    return sorted(
        PAGES.glob(
            "page-*.png"
        )
    )


def make_contacts(
    pages: list[Path],
) -> list[Path]:
    CONTACT.mkdir(
        parents=True,
        exist_ok=True,
    )

    for old in CONTACT.glob(
        "contact_*.png"
    ):
        old.unlink()

    if shutil.which("montage") is None:
        return []

    outputs = []

    for start in range(
        0,
        len(pages),
        6,
    ):
        group = pages[
            start:
            start + 6
        ]

        output = (
            CONTACT
            / (
                f"contact_{start + 1:02d}-"
                f"{start + len(group):02d}.png"
            )
        )

        result = subprocess.run(
            [
                "montage",
                *[str(p) for p in group],
                "-thumbnail",
                "700x",
                "-tile",
                "2x3",
                "-geometry",
                "+16+16",
                str(output),
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )

        if result.returncode != 0:
            raise RuntimeError(
                result.stdout
            )

        outputs.append(
            output
        )

    return outputs


WORK.mkdir(
    parents=True,
    exist_ok=True,
)

OUT.mkdir(
    parents=True,
    exist_ok=True,
)

REPORT.parent.mkdir(
    parents=True,
    exist_ok=True,
)


locks = {
    "response": sha256(
        RESPONSE_DOCX
    ),
    "clean": sha256(
        CLEAN_DOCX
    ),
    "marked": sha256(
        MARKED_DOCX
    ),
    "source": sha256(
        SOURCE_V24
    ),
}


expected = {
    "response": EXPECTED_RESPONSE_SHA,
    "clean": EXPECTED_CLEAN_SHA,
    "marked": EXPECTED_MARKED_SHA,
    "source": EXPECTED_SOURCE_SHA,
}


for key in locks:

    if locks[key] != expected[key]:
        raise RuntimeError(
            f"{key} SHA mismatch: "
            f"{locks[key]}"
        )


with zipfile.ZipFile(
    RESPONSE_DOCX,
    "r",
) as zin:

    original_root = etree.fromstring(
        zin.read(
            "word/document.xml"
        )
    )


original_text = original_root.xpath(
    ".//w:t/text()",
    namespaces=NS,
)


candidate_root = etree.fromstring(
    xml_bytes(
        original_root
    )
)


body = candidate_root.find(
    "w:body",
    namespaces=NS,
)

if body is None:
    raise RuntimeError(
        "Missing w:body"
    )


rr11 = find_exact(
    body,
    RR11_HEADING,
)

location = find_rr11_field(
    body,
    rr11,
    LOCATION_PREFIX,
)

evidence = find_rr11_field(
    body,
    rr11,
    EVIDENCE_PREFIX,
)


# The only pagination modification:
# keep the RR11 location line with its following
# supporting-material line, and keep each paragraph
# internally together.

add_keep_next(
    location
)

add_keep_lines(
    location
)

add_keep_lines(
    evidence
)


candidate_text = candidate_root.xpath(
    ".//w:t/text()",
    namespaces=NS,
)


if original_text != candidate_text:
    raise RuntimeError(
        "Text changed during "
        "pagination-only repair"
    )


write_docx(
    RESPONSE_DOCX,
    CANDIDATE,
    xml_bytes(
        candidate_root
    ),
)


candidate_sha = sha256(
    CANDIDATE
)


with zipfile.ZipFile(
    CANDIDATE,
    "r",
) as zin:

    audit_root = etree.fromstring(
        zin.read(
            "word/document.xml"
        )
    )

    settings_root = etree.fromstring(
        zin.read(
            "word/settings.xml"
        )
    )


audit_body = audit_root.find(
    "w:body",
    namespaces=NS,
)

if audit_body is None:
    raise RuntimeError(
        "Candidate missing w:body"
    )


audit_rr11 = find_exact(
    audit_body,
    RR11_HEADING,
)

audit_location = find_rr11_field(
    audit_body,
    audit_rr11,
    LOCATION_PREFIX,
)

audit_evidence = find_rr11_field(
    audit_body,
    audit_rr11,
    EVIDENCE_PREFIX,
)


(
    render_status,
    pdf,
    render_output,
) = render_docx(
    CANDIDATE
)


pdf_bytes = (
    pdf.stat().st_size
    if pdf.exists()
    else 0
)

page_count = (
    pdf_pages(pdf)
    if pdf_bytes > 0
    else 0
)

page_pngs = (
    make_pngs(pdf)
    if page_count > 0
    else []
)

contacts = (
    make_contacts(
        page_pngs
    )
    if page_pngs
    else []
)


checks = []


def check(
    description,
    passed,
    observed,
    expected_value,
):
    checks.append(
        {
            "check_id": (
                f"Q{len(checks) + 1:02d}"
            ),
            "check_description": description,
            "pass": (
                "TRUE"
                if passed
                else "FALSE"
            ),
            "observed": str(
                observed
            ),
            "expected": str(
                expected_value
            ),
        }
    )


check(
    "Original response SHA locked",
    locks["response"]
    == EXPECTED_RESPONSE_SHA,
    locks["response"],
    EXPECTED_RESPONSE_SHA,
)

check(
    "Clean manuscript SHA locked",
    locks["clean"]
    == EXPECTED_CLEAN_SHA,
    locks["clean"],
    EXPECTED_CLEAN_SHA,
)

check(
    "Marked manuscript SHA locked",
    locks["marked"]
    == EXPECTED_MARKED_SHA,
    locks["marked"],
    EXPECTED_MARKED_SHA,
)

check(
    "Scientific source SHA locked",
    locks["source"]
    == EXPECTED_SOURCE_SHA,
    locks["source"],
    EXPECTED_SOURCE_SHA,
)

check(
    "Text-node sequence unchanged",
    original_text
    == candidate_text,
    (
        "identical"
        if original_text
        == candidate_text
        else "different"
    ),
    "identical",
)

check(
    "RR11 location has keepNext",
    has_control(
        audit_location,
        "keepNext",
    ),
    has_control(
        audit_location,
        "keepNext",
    ),
    True,
)

check(
    "RR11 location has keepLines",
    has_control(
        audit_location,
        "keepLines",
    ),
    has_control(
        audit_location,
        "keepLines",
    ),
    True,
)

check(
    "RR11 evidence has keepLines",
    has_control(
        audit_evidence,
        "keepLines",
    ),
    has_control(
        audit_evidence,
        "keepLines",
    ),
    True,
)

check(
    "No tracked insertions introduced",
    len(
        audit_root.xpath(
            ".//w:ins",
            namespaces=NS,
        )
    ) == 0,
    len(
        audit_root.xpath(
            ".//w:ins",
            namespaces=NS,
        )
    ),
    0,
)

check(
    "No tracked deletions introduced",
    len(
        audit_root.xpath(
            ".//w:del",
            namespaces=NS,
        )
    ) == 0,
    len(
        audit_root.xpath(
            ".//w:del",
            namespaces=NS,
        )
    ),
    0,
)

check(
    "Track Changes remains disabled",
    settings_root.find(
        "w:trackRevisions",
        namespaces=NS,
    ) is None,
    (
        settings_root.find(
            "w:trackRevisions",
            namespaces=NS,
        )
        is not None
    ),
    False,
)

check(
    "LibreOffice render succeeds",
    (
        render_status == 0
        and pdf_bytes > 0
    ),
    (
        f"status={render_status}; "
        f"bytes={pdf_bytes}"
    ),
    "status=0 and non-empty PDF",
)

check(
    "Rendered response remains compact",
    page_count <= 6,
    page_count,
    "<=6 pages",
)

check(
    "Every PDF page has PNG",
    (
        page_count > 0
        and len(page_pngs)
        == page_count
    ),
    len(page_pngs),
    page_count,
)

check(
    "Canonical response remains unchanged",
    sha256(
        RESPONSE_DOCX
    )
    == EXPECTED_RESPONSE_SHA,
    sha256(
        RESPONSE_DOCX
    ),
    EXPECTED_RESPONSE_SHA,
)

check(
    "Canonical manuscripts remain unchanged",
    (
        sha256(CLEAN_DOCX)
        == EXPECTED_CLEAN_SHA
        and sha256(MARKED_DOCX)
        == EXPECTED_MARKED_SHA
    ),
    (
        f"clean={sha256(CLEAN_DOCX)}; "
        f"marked={sha256(MARKED_DOCX)}"
    ),
    "locked",
)


passed = sum(
    row["pass"] == "TRUE"
    for row in checks
)

failed = (
    len(checks)
    - passed
)

gate = (
    "PASS"
    if failed == 0
    else "FAIL"
)

status = (
    "READY_FOR_FINAL_RESPONSE_VISUAL_QA"
    if failed == 0
    else "MINIMAL_RESPONSE_REPAIR_REQUIRES_CORRECTION"
)


write_tsv(
    QUALITY,
    checks,
)

write_tsv(
    SUMMARY,
    [
        {
            "input_response_sha256": (
                EXPECTED_RESPONSE_SHA
            ),
            "candidate_response_sha256": (
                candidate_sha
            ),
            "layout_strategy": (
                "RR11_orphan_control_only"
            ),
            "rendered_pdf_pages": (
                page_count
            ),
            "page_pngs": (
                len(page_pngs)
            ),
            "contact_sheets": (
                len(contacts)
            ),
            "quality_checks": (
                len(checks)
            ),
            "quality_checks_passed": (
                passed
            ),
            "quality_checks_failed": (
                failed
            ),
            "quality_gate": gate,
            "final_status": status,
        }
    ],
)


REPORT.write_text(
    "\n".join(
        [
            "# PLOS ONE Minimal Response-Letter Pagination Repair",
            "",
            (
                "Visual comparison showed that the "
                "eight-page targeted-break candidate "
                "over-corrected the original six-page "
                "response-letter layout."
            ),
            "",
            (
                "The canonical six-page response letter "
                "was therefore retained as the baseline."
            ),
            "",
            (
                "Only the RR11 manuscript-location paragraph "
                "and its supporting-material paragraph were "
                "given keep-together pagination controls to "
                "remove the isolated supporting line."
            ),
            "",
            (
                "No response wording or other pagination "
                "break was changed."
            ),
            "",
            f"- Candidate SHA256: `{candidate_sha}`",
            f"- Rendered pages: {page_count}",
            f"- Quality gate: `{gate}`",
            f"- Final status: `{status}`",
            "",
        ]
    ),
    encoding="utf-8",
    newline="\n",
)


print(
    "===== PLOS ONE MINIMAL RESPONSE PAGINATION REPAIR ====="
)

print(
    f"input_response_sha256\t"
    f"{EXPECTED_RESPONSE_SHA}"
)

print(
    f"candidate_response_sha256\t"
    f"{candidate_sha}"
)

print(
    "layout_strategy\t"
    "RR11_orphan_control_only"
)

print(
    f"rendered_pdf_pages\t"
    f"{page_count}"
)

print(
    f"page_pngs\t"
    f"{len(page_pngs)}"
)

print(
    f"contact_sheets\t"
    f"{len(contacts)}"
)

print(
    f"quality_checks_passed\t"
    f"{passed}/{len(checks)}"
)

print(
    f"quality_gate\t"
    f"{gate}"
)

print(
    f"final_status\t"
    f"{status}"
)

print(
    f"candidate_docx\t"
    f"{CANDIDATE}"
)

print(
    f"quality_gate_file\t"
    f"{QUALITY}"
)

print(
    f"summary\t"
    f"{SUMMARY}"
)

print(
    f"report\t"
    f"{REPORT}"
)

print()

print(
    "===== LIBREOFFICE OUTPUT ====="
)

print(
    render_output
)

if contacts:

    print()
    print(
        "===== CONTACT SHEETS ====="
    )

    for path in contacts:
        print(path)


if failed:

    raise RuntimeError(
        "Minimal response pagination repair "
        f"failed {failed} check(s)."
    )
