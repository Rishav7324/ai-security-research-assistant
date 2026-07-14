# Security Assessment Report

**Target:** {{target_name}}
**Engagement type:** {{engagement_type}}
**Date:** {{date}}
**Scope confirmed:** {{scope_confirmed}}

---

## 1. Executive Summary

{{executive_summary}}

**Findings overview**

| Severity | Confirmed | Suspected | Manual Review |
|---|---|---|---|
| Critical | | | |
| High | | | |
| Medium | | | |
| Low | | | |
| Info | | | |

---

## 2. Scope

**In-scope assets:** {{in_scope_assets}}
**Excluded (out of scope):** {{excluded_assets}}
**Artifacts analyzed:** {{artifact_list}}

---

## 3. Confirmed Findings

### {{finding.id}} — {{finding.title}}
- **Category:** {{finding.category}} | **CWE:** {{finding.cwe}}
- **Severity:** {{finding.severity.level}} ({{finding.severity.cvss_estimate}})
- **Confidence:** {{finding.confidence.level}} — {{finding.confidence.rationale}}

**Evidence**
- {{evidence.source}} — {{evidence.locator}}
  ```
  {{evidence.excerpt}}
  ```

**Why this matters (mechanism)**
{{finding.mechanism}}

**Business impact**
{{finding.business_impact}}

**Remediation**
{{finding.remediation.summary}}
1. {{remediation.steps[0]}}
2. {{remediation.steps[1]}}

**References:** {{remediation.references}}
**Effort estimate:** {{remediation.effort}}

*(repeat block per confirmed finding)*

---

## 4. Suspected Findings
*(same structure as §3 — clearly labeled as requiring corroboration before action)*

---

## 5. Manual Review Items
*(items where static evidence is insufficient to confirm or rule out — requires
runtime/manual verification by the security team; never auto-escalated to confirmed)*

---

## 6. False Positives (Ruled Out)

| Pattern matched | Reason ruled out | Evidence reviewed |
|---|---|---|
| | | |

---

## 7. Prioritized Remediation Roadmap

| Priority | Related Findings | Action | Effort | Risk Reduction |
|---|---|---|---|---|
| 1 | | | | |
| 2 | | | | |

---

## 8. Coverage Notes & Limitations

**Coverage notes:** {{coverage_notes}}
**Limitations:** {{limitations}}

---

## Appendix A — Bug Bounty Submission Draft (per confirmed/high-confidence finding)

**Title:** {{finding.title}}
**Summary:** One or two sentence impact-focused summary.
**Steps to reproduce (descriptive, not weaponized):**
1. ...
2. ...
**Impact:** {{finding.business_impact}}
**Suggested severity:** {{finding.severity.level}} (CWE-{{finding.cwe}})
**Suggested fix:** {{finding.remediation.summary}}
