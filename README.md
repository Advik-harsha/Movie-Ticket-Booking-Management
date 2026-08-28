# CineWave Entertainment - Movie Ticket Booking Management Application
### National Internship Program — Pega Platform™ Project

Welcome to the project repository for the **Movie Ticket Booking Management Application** built for **CineWave Entertainment** on the **Pega Platform™** (Pega Infinity v8.x / v25.x).

---

## 📁 Project Deliverables & Repository Structure

| File | Description |
| :--- | :--- |
| [`PEGA_BLUEPRINT_SPECIFICATION.json`](file:///e:/Sage_drama/Pega/PEGA_BLUEPRINT_SPECIFICATION.json) | Complete Pega Blueprint JSON specification matching all 10 User Stories, Data Objects, Work Queues, and Case Lifecycle stages. |
| [`PEGA_IMPLEMENTATION_GUIDE.md`](file:///e:/Sage_drama/Pega/PEGA_IMPLEMENTATION_GUIDE.md) | Detailed, click-by-click implementation manual for Pega App Studio and Dev Studio covering all 12 Epics/Stories. |
| [`PROJECT_SUBMISSION_REPORT.md`](file:///e:/Sage_drama/Pega/PROJECT_SUBMISSION_REPORT.md) | Complete submission report (ready for `Harsh_Maurya.docx` / PDF conversion) with screenshots placeholders, rule specifications, and test summaries. |
| [`CORRESPONDENCE_TEMPLATE.html`](file:///e:/Sage_drama/Pega/CORRESPONDENCE_TEMPLATE.html) | Styled HTML correspondence template for automated booking confirmation emails (US-008 & Conclusion). |
| [`TEST_CASES_AND_VALIDATION.md`](file:///e:/Sage_drama/Pega/TEST_CASES_AND_VALIDATION.md) | Comprehensive test suite covering positive, negative, routing, SLA escalation, and validation test cases. |

---

## 🎯 Case Lifecycle Overview

1. **Initial Stage:** Customer submits ticket request (`.MovieName`, `.ShowDate`, `.ShowTime`, `.ShowType`, `.NumberOfTickets`).
2. **Availability Stage:** System/Agent verifies seat availability (`.AvailableSeatsCount`) and calculates `.TotalCost` (`.TicketPrice * .NumberOfTickets`).
3. **Approval Stage:** Customer reviews the structured summary and confirms or cancels (`.BookingStatus`).
4. **Booking Execution Stage:**
   - Routes automatically to `PremiumShowQueue` (if Premium) or `StandardShowQueue` (if Standard).
   - Staff processes allocation (`.TicketID`, `.SeatNumbers`).
   - Automated correspondence dispatched upon resolution.
5. **Resolution:** Case resolves as `Resolved-Completed` or `Resolved-Cancelled`.

---

## 🚀 Quick Start Guide

1. Log in to your [Pega Academy Exercise System](https://academy.pega.com/mission/business-architect/v8/exercise?) with `author@uplus` / `pega123!`.
2. Follow the steps in [`PEGA_IMPLEMENTATION_GUIDE.md`](file:///e:/Sage_drama/Pega/PEGA_IMPLEMENTATION_GUIDE.md) or import [`PEGA_BLUEPRINT_SPECIFICATION.json`](file:///e:/Sage_drama/Pega/PEGA_BLUEPRINT_SPECIFICATION.json) via Blueprint.
3. Validate your application using [`TEST_CASES_AND_VALIDATION.md`](file:///e:/Sage_drama/Pega/TEST_CASES_AND_VALIDATION.md).
4. Fill your screenshots into [`PROJECT_SUBMISSION_REPORT.md`](file:///e:/Sage_drama/Pega/PROJECT_SUBMISSION_REPORT.md) and export to Word/PDF for submission.
