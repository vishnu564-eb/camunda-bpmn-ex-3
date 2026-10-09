# Camunda BPMN 2.0 Process Models

This repository contains fully compliant **Camunda BPMN 2.0 XML** models for two major workflow assignments:

1. **Student Project Approval & Allocation System** (`student_project_approval.bpmn`)
2. **Loan Origination & Approval System** (`loan_origination_approval.bpmn`)

Both diagrams include full executable BPMN semantics, task types, gateways, event definitions (timer SLAs, error boundary events, escalation, compensation, terminate events), pools/lanes, and diagram interchange graphics (`bpmndi`).

---

## 1. Student Project Approval & Allocation System (`student_project_approval.bpmn`)

### Scenario Overview
A department runs a final-year project programme. Every student team submits a project proposal which is screened, reviewed by a committee, and matched with an available faculty guide based on expertise and workload.

### Participants (Pool & Lanes)
* **Student / Team**: Submits proposals, performs resubmissions, and modifies plagiarised topics.
* **Project Coordinator**: Screens proposals, reviews duplicate topics, manages late submissions, and handles manual guide allocation.
* **Review Committee (incl. HoD)**: Evaluates project proposals, requests revisions, approves/rejects, and receives SLA escalation alerts.
* **Faculty Guide**: Accepts or declines assigned student teams within a 5-day SLA.
* **Project Management System**: Executes automated validation rules, duplicate topic checking, DMN guide availability evaluation, guide allocation, and email/DB notifications.

### Failure Paths & BPMN Solutions Register

| ID | Failure Point | Cause / Trigger | Solution & BPMN Construct |
|:---|:---|:---|:---|
| **F1** | Proposal Validation | Missing fields, incomplete form | Exclusive gateway loop with attempt counter (max 2) returning form to student. |
| **F2** | Team Rule Check | Exceeded team size or double registration | Error end event `ERR_INVALID_TEAM` stopping invalid case. |
| **F3** | Duplicate / Plagiarism | Similarity score > threshold | Coordinator review task with exclusive gateway to modify topic or reject. |
| **F4** | Proposal Deadline | Late submission by student team | Timer boundary event on submission task routing to coordinator late approval. |
| **F5** | Committee Revision | Vague objectives or broad scope | 7-day revision loop sub-process (max 2 cycles). |
| **F6** | Committee Rejection | Feasibility or resource issues | Send task with rejection reasons -> End event. |
| **F7** | Review SLA Delay | Committee delays evaluation | Non-interrupting timer boundary event (3 days reminder, 7 days HoD escalation). |
| **F8** | No Guide Available | Domain mismatch / all guides full | DMN returns `none` -> Coordinator manual guide / co-guide allocation task. |
| **F9** | Guide Decline/Silence | Guide rejects or timer expires | 5-day boundary timer event + retry allocation (max 3) before manual assignment. |
| **F10** | System/Email Failure | Database or email service error | Error boundary event `ERR_SYSTEM_FAILURE` triggering manual coordinator fallback. |
| **F11** | Post-Approval Withdrawal| Team dissolves or guide leaves | Sub-process compensation event releasing guide slot and resetting state. |

---

## 2. Loan Origination & Approval System (`loan_origination_approval.bpmn`)

### Scenario Overview
A bank processes personal and secured loan applications through document checks, identity verification, credit score retrieval, income verification, risk scoring, underwriting, loan offer issuance, e-signing, and fund disbursement.

### Participants (Pool & Lanes)
* **Applicant**: Submits application, resubmits docs, evaluates counter-offers, accepts loan offer, e-signs agreement.
* **Loan Officer**: Performs income/employment verification, manual identity check, manual credit fallback, counter-offer structuring.
* **Underwriter / Credit Committee**: Reviews high-value & borderline cases, re-values collateral.
* **Fraud & Compliance Team**: Investigates fraud/AML hits in an isolated sub-process.
* **Operations / Disbursement**: Verifies bank accounts and executes fund disbursement.
* **Core Banking System**: Executes document completeness DMN, automated KYC, Credit Bureau API calls, risk scoring DMN, offer generation, and account creation.
* **External Pool**: `Credit Bureau System`.

### Failure Paths & BPMN Solutions Register

| ID | Failure Point | Cause / Trigger | Solution & BPMN Construct |
|:---|:---|:---|:---|
| **L1** | Document Check | Missing or illegible docs | 7-day timer resubmission loop; lapses into `Application Lapsed` end event. |
| **L2** | KYC Verification | ID mismatch with records | Exclusive gateway to manual officer identity check. |
| **L3** | Fraud / AML Hit | Sanctions list match / forged docs| Escalation to Fraud & Compliance sub-process -> Terminate end event. |
| **L4** | Credit Bureau Call | API timeout or service down | Error boundary event `ERR_CREDIT_BUREAU_TIMEOUT` with manual credit check fallback. |
| **L5** | Low Credit Score | Below minimum cutoff | Exclusive gateway: rejection or counter-offer (guarantor/collateral). |
| **L6** | High DTI / Low Income | Insufficient repayment capacity | Offer reduced amount or longer tenure with re-scoring loop. |
| **L7** | Borderline / High Value | Amount > underwriter limit | Senior Credit Committee review with 48-hour SLA timer. |
| **L8** | Collateral Valuation | LTV ratio too low | Re-valuation task, LTV adjustment, and underwriter re-review. |
| **L9** | Offer Acceptance SLA | Applicant silent > 15 days | 15-day timer boundary event on receive task -> `Offer Expired` end event. |
| **L10** | Applicant Withdrawal | Applicant cancels application | Main process message boundary event -> Compensation reversing fee holds. |
| **L11** | E-signature Failure | Signature mismatch / missing | Reminder resend loop (max 2 attempts) before offer cancellation. |
| **L12** | Disbursement Error | Invalid account / gateway error | Error boundary event `ERR_DISBURSEMENT_FAILED` -> Account verification retry task. |

---

## How to Import & Open in Camunda

1. **Camunda Modeler (Desktop)**:
   - Open **Camunda Modeler**.
   - Click `File -> Open File...` and select either `student_project_approval.bpmn` or `loan_origination_approval.bpmn`.
   - The visual layout, pools, lanes, gateways, and failure events will render automatically.

2. **Camunda 7 / Camunda 8 Engine**:
   - Both `.bpmn` files contain executable process IDs (`Process_StudentProjectApproval` and `Process_LoanOrigination`).
   - Deploy directly via Camunda Modeler, REST API, or Zeebe / Camunda 8 Operates.
