# Movie Ticket Booking Management Application
### CineWave Entertainment | Pega Platform™ (Pega Infinity v8.7+)
**Author:** Harsh Maurya · **GitHub:** [@Advik-harsha](https://github.com/Advik-harsha) · **Role:** Business Architect

---

## 🎬 Project Overview

CineWave Entertainment needed to replace a fragmented manual booking process (email chains + spreadsheets) with a unified, automated **Movie Ticket Booking Management** system built on the **Pega Platform™**.

This repository contains all essential project design artifacts, the official Pega `.blueprint` file, live screenshots, implementation guides, demo video script, and test cases needed to scaffold, configure, and evaluate the complete application in a Pega Infinity environment.

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
│ Search Availability │    Validation: seat count vs request
│ Calculate Cost      │    Declare Expr: TotalCost, FinalCost
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│   Approval Stage    │  ← Customer reviews full summary
│  Review Summary     │    Decision: Confirm or Cancel
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
│  │Allocate Seat│   │
│  │ FulfillStaff│   │
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
├── README.md                                          ← Project overview & architecture
├── Ticketing and Booking 20260828T092006441 GMT.blueprint  ← Official Pega Blueprint File (for App Studio)
├── PEGA_IMPLEMENTATION_GUIDE.md                       ← Step-by-step App Studio configuration guide
├── PROJECT_SUBMISSION_REPORT.md                       ← Complete report for Harsh_Maurya.docx / PDF
├── DEMO_VIDEO_SCRIPT.md                               ← 2-to-3 minute video demonstration script & walkthrough
├── TEST_CASES_AND_VALIDATION.md                       ← 33 test cases (positive, negative, SLA, routing)
├── Screenshot 2026-08-28 180122.png                   ← Screenshot: Case Lifecycle Configuration
├── Screenshot 2026-08-28 153944.png                   ← Screenshot: App Studio Application Overview
└── Screenshot 2026-08-28 154358.png                   ← Screenshot: Live Case Execution (M-3)
```

---

## 📸 Application Screenshots

### 1. Case Lifecycle in App Studio
![Case Lifecycle Configuration](./Screenshot%202026-08-28%20180122.png)

### 2. Application Dashboard
![Application Overview](./Screenshot%202026-08-28%20153944.png)

### 3. Live Case Execution (M-3)
![Live Case Instance](./Screenshot%202026-08-28%20154358.png)

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
2. Upload `Ticketing and Booking 20260828T092006441 GMT.blueprint`.
3. Set Organization: `CineWave` | Division: `Entertainment` | Unit: `Operations`.
4. Click **Build Now** → **Submit** → **Go to new application**.

### Step 3 — Configure Rules & Test
1. Follow [`PEGA_IMPLEMENTATION_GUIDE.md`](./PEGA_IMPLEMENTATION_GUIDE.md) for rule configuration.
2. Execute test cases from [`TEST_CASES_AND_VALIDATION.md`](./TEST_CASES_AND_VALIDATION.md).
3. Review the complete submission report in [`PROJECT_SUBMISSION_REPORT.md`](./PROJECT_SUBMISSION_REPORT.md).

---

## 📄 License
This project is created for academic and internship purposes under the National Internship Program. All Pega Platform trademarks belong to Pegasystems Inc.
