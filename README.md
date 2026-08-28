# Movie Ticket Booking Management Application
### CineWave Entertainment | Pega Platform™ (Pega Infinity v8.7+)
**Author:** Harsh Maurya · **GitHub:** [@Advik-harsha](https://github.com/Advik-harsha) · **Role:** Business Architect

---

## 🎬 Project Overview

CineWave Entertainment needed to replace a fragmented manual booking process (email chains + spreadsheets) with a unified, automated **Movie Ticket Booking Management** system built on the **Pega Platform™**.

This repository contains all design artifacts, configuration blueprints, implementation guides, email templates, and test cases needed to scaffold, configure, and verify the complete application in a Pega Infinity v8.7+ environment.

---

## 📋 Case Lifecycle

```
Customer Submits Request
         │
         ▼
┌─────────────────────┐
│    Initial Stage    │  ← Customer fills booking request
│ Submit Ticket Req   │    Validation: customer info + booking details
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│  Availability Stage │  ← BookingAgent verifies seats
│ Check Availability  │    Validation: seat count vs request
│ Calculate Cost      │    Declare Expr: TotalCost, FinalCost
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│   Approval Stage    │  ← Customer reviews full summary
│  Review Details     │    Decision: Confirm or Cancel
└────────┬────────────┘
         │
    ┌────┴────┐
    │Confirmed│                    │Cancelled│
    ▼                              ▼
┌────────────────────┐   ┌─────────────────────┐
│ Booking Execution  │   │ Resolved-Cancelled   │
│  ┌─────────────┐   │   │ Cancellation email   │
│  │ Route by    │   │   │ sent to customer     │
│  │ Show Type   │   │   └─────────────────────┘
│  └──────┬──────┘   │
│  Premium/IMAX/4DX ─┼─► PremiumShowQueue
│  Standard ─────────┼─► StandardShowQueue
│  ┌─────────────┐   │
│  │Process Ticket│  │
│  │ FulfillStaff│  │
│  └──────┬──────┘   │
│  ┌─────────────┐   │
│  │ Send Email  │   │
│  │Confirmation │   │
│  └─────────────┘   │
└────────┬───────────┘
         │
         ▼
  Resolved-Completed
```

---

## 📁 Repository Structure

```
Movie-Ticket-Booking-Management/
├── README.md                          ← This file — project overview
├── PEGA_BLUEPRINT_SPECIFICATION.json  ← Complete Pega Blueprint for import
├── PEGA_IMPLEMENTATION_GUIDE.md       ← Step-by-step App Studio configuration
├── CORRESPONDENCE_TEMPLATE.html       ← Booking confirmation email template
├── TEST_CASES_AND_VALIDATION.md       ← 33 test cases (positive, negative, SLA, routing)
├── PROJECT_SUBMISSION_REPORT.md       ← Full submission report for Harsh_Maurya.docx
└── push_to_github.ps1                 ← Helper script for git operations
```

---

## ✅ User Stories Implemented

| US # | User Story | Stage | Persona | Status |
| :--- | :--- | :--- | :--- | :--- |
| Pre-Req | Environment setup & Blueprint scaffolding | — | Author | ✅ Done |
| US-001 | Submit Movie Ticket Request | Initial Stage | Customer | ✅ Done |
| US-002 | Check Show Availability | Availability | BookingAgent | ✅ Done |
| US-003 | Calculate Booking Cost | Availability | System (Automation) | ✅ Done |
| US-004 | Confirm Booking Request | Approval | Customer | ✅ Done |
| US-005 | Maintain Movie and Show Data | Data Objects | Administrator | ✅ Done |
| US-006 | Review Booking Details | Approval | Customer | ✅ Done |
| US-007 | Process Ticket Booking | Booking Execution | FulfillmentStaff | ✅ Done |
| US-008 | Notify Booking Confirmation | Resolution | System (Email) | ✅ Done |
| US-009 | Define Booking SLA | Case Type Level | System (SLA) | ✅ Done |
| US-010 | Route Booking Request by Show Type | Booking Execution | System (Router) | ✅ Done |
| Conclusion | End-to-end automated case resolution & email dispatch | — | — | ✅ Done |

---

## 🏗️ Key Technical Components

| Component | Rule/Artifact Name | Type |
| :--- | :--- | :--- |
| Case Type | `Movie Ticket Request` | Rule-Obj-CaseType |
| SLA | `MovieTicketRequestSLA` | Rule-Obj-ServiceLevel |
| Data Transform (Init) | `InitializeCaseDefaults` | Rule-Obj-DataTransform |
| Data Transform (Pricing) | `SetTicketPricingDT` | Rule-Obj-DataTransform |
| Data Transform (Ticket ID) | `SetTicketID` | Rule-Obj-DataTransform |
| Declare Expression | `CalcTotalCost` | Rule-Declare-Expressions |
| Declare Expression | `CalcFinalCost` | Rule-Declare-Expressions |
| Validate Rule | `ValidateCustomerInfo` | Rule-Obj-Validate |
| Validate Rule | `ValidateBookingDetails` | Rule-Obj-Validate |
| Validate Rule | `ValidateSeatAvailability` | Rule-Obj-Validate |
| Validate Rule | `ValidateBookingDecision` | Rule-Obj-Validate |
| Validate Rule | `ValidateFulfillmentDetails` | Rule-Obj-Validate |
| Decision Table | `RouteByShowType` | Rule-Declare-DecisionTable |
| Correspondence | `BookingConfirmationNotification` | Rule-Obj-Corr |
| Correspondence | `BookingCancellationNotification` | Rule-Obj-Corr |
| Data Object | `Movie` (`CineWave-Data-Movie`) | Data Object |
| Data Object | `Show` (`CineWave-Data-Show`) | Data Object |
| Work Queue | `PremiumShowQueue@CineWave` | Org/Security |
| Work Queue | `StandardShowQueue@CineWave` | Org/Security |

---

## 💰 Show Type Pricing Matrix

| Show Type | Ticket Price | Queue |
| :--- | :--- | :--- |
| Standard | \$12.00 | StandardShowQueue |
| Premium | \$20.00 | PremiumShowQueue |
| IMAX | \$28.00 | PremiumShowQueue |
| 4DX | \$35.00 | PremiumShowQueue |

---

## 🚀 Quick Start

### Step 1 — Set up Pega Academy Instance
1. Visit: https://academy.pega.com/mission/business-architect/v8/exercise?
2. Sign in with your Pega Academy credentials.
3. Click **Initialize Pega instance** → wait → Click **Launch Pega instance**.
4. Log in: `author@uplus` / `pega123!`

### Step 2 — Import Blueprint & Build App
1. App Studio → **Application** → **New Application** → **Build from Blueprint**.
2. Upload `PEGA_BLUEPRINT_SPECIFICATION.json`.
3. Set Organization: `CineWave` | Division: `Entertainment` | Unit: `Operations`.
4. Click **Build Now** → **Submit** → **Go to new application**.

### Step 3 — Configure Rules
Follow [`PEGA_IMPLEMENTATION_GUIDE.md`](./PEGA_IMPLEMENTATION_GUIDE.md) section by section.

### Step 4 — Run Tests
Execute test cases from [`TEST_CASES_AND_VALIDATION.md`](./TEST_CASES_AND_VALIDATION.md) and fill in sign-off table.

### Step 5 — Submit
- Convert [`PROJECT_SUBMISSION_REPORT.md`](./PROJECT_SUBMISSION_REPORT.md) to `Harsh_Maurya.docx` / PDF.
- Add screenshots and paste this GitHub URL into the internship portal **"Add Github Link"** field.

---

## 📄 License
This project is created for academic and internship purposes under the National Internship Program. All Pega Platform trademarks belong to Pegasystems Inc.
