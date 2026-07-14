# OWASP / CWE Quick-Reference Mappings

Used by all analyzer agents to keep category + CWE mapping consistent across findings.
Not exhaustive — extend as needed. Never force a mapping that doesn't clearly fit.

## OWASP Top 10 (2021)

| Code | Category | Common CWEs |
|---|---|---|
| A01 | Broken Access Control | CWE-22, CWE-284, CWE-639 |
| A02 | Cryptographic Failures | CWE-259, CWE-327, CWE-330 |
| A03 | Injection | CWE-79, CWE-89, CWE-78, CWE-611 |
| A04 | Insecure Design | CWE-1021, CWE-841 |
| A05 | Security Misconfiguration | CWE-16, CWE-2, CWE-548 |
| A06 | Vulnerable and Outdated Components | CWE-1104, CWE-937 |
| A07 | Identification and Authentication Failures | CWE-287, CWE-384, CWE-620 |
| A08 | Software and Data Integrity Failures | CWE-502, CWE-829 |
| A09 | Security Logging and Monitoring Failures | CWE-778, CWE-223 |
| A10 | Server-Side Request Forgery (SSRF) | CWE-918 |

## OWASP API Security Top 10 (2023)

| Code | Category |
|---|---|
| API1 | Broken Object Level Authorization (BOLA) |
| API2 | Broken Authentication |
| API3 | Broken Object Property Level Authorization |
| API4 | Unrestricted Resource Consumption |
| API5 | Broken Function Level Authorization |
| API6 | Unrestricted Access to Sensitive Business Flows |
| API7 | Server-Side Request Forgery |
| API8 | Security Misconfiguration |
| API9 | Improper Inventory Management |
| API10 | Unsafe Consumption of APIs |

## Frequently used CWEs in this skill's findings

- CWE-89 — SQL Injection
- CWE-79 — Cross-Site Scripting
- CWE-798 — Use of Hard-coded Credentials
- CWE-256 — Plaintext Storage of Password
- CWE-330 — Use of Insufficiently Random Values
- CWE-352 — Cross-Site Request Forgery
- CWE-434 — Unrestricted Upload of File with Dangerous Type
- CWE-611 — Improper Restriction of XML External Entity Reference
- CWE-918 — Server-Side Request Forgery
- CWE-1188 — Insecure Default Initialization of Resource (cloud/IaC misconfig)
- CWE-284 — Improper Access Control
- CWE-522 — Insufficiently Protected Credentials

## ASVS 4.0 chapters commonly referenced

- V2 — Authentication
- V3 — Session Management
- V4 — Access Control
- V5 — Validation, Sanitization, Encoding
- V7 — Error Handling and Logging
- V9 — Communications
- V13 — API and Web Service
- V14 — Configuration
