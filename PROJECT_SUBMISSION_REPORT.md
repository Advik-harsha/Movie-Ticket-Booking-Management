# National Internship Program - Pega Academy Project Report
# Movie Ticket Booking Management Application
### Organization: CineWave Entertainment
**Student Name:** Harsh Maurya  
**GitHub Profile:** [https://github.com/Advik-harsha](https://github.com/Advik-harsha)  
**Role:** Business Architect / System Architect  
**Platform:** Pega Platform™ (Pega Infinity '25 / v8.x)  
**Project Repository:** [https://github.com/Advik-harsha/Movie-Ticket-Booking-Management](https://github.com/Advik-harsha/Movie-Ticket-Booking-Management)  
**Submission Document:** `Harsh_Maurya_MovieTicketBooking.docx` / `PROJECT_SUBMISSION_REPORT.md`  

---

## Executive Summary

CineWave Entertainment manages movie ticket bookings across multiple theatres and locations. Previously, ticket bookings and tracking processes were handled manually through emails and offline logbooks, leading to delays, lack of visibility, and operational inefficiencies.

This project delivers an automated, enterprise-grade **Movie Ticket Booking Management** application built on the **Pega Platform™**. The system automates:
1. Customer booking request capture and validations.
2. Real-time show and seat availability checking.
3. Automated dynamic cost calculations.
4. Structured customer review and confirmation approval.
5. Automated show-type routing (`PremiumShowQueue` vs. `StandardShowQueue`).
6. Case-level Service Level Agreements (SLAs: 1-day Goal, 2-day Deadline).
7. Real-time automated email correspondence upon case resolution.

---

## Table of Contents
1. [Project Objectives & Scope](#1-project-objectives--scope)
2. [Data Model & Architecture](#2-data-model--architecture)
3. [Case Lifecycle Design](#3-case-lifecycle-design)
4. [Detailed Epic & User Story Implementation](#4-detailed-epic--user-story-implementation)
   - [Pre-Requisites: Environment Setup & Scaffolding](#pre-requisites-environment-setup--scaffolding)
   - [US-001: Submit Movie Ticket Request](#us-001-submit-movie-ticket-request)
   - [US-002: Check Show Availability](#us-002-check-show-availability)
   - [US-003: Calculate Booking Cost](#us-003-calculate-booking-cost)
   - [US-004: Confirm Booking Request](#us-004-confirm-booking-request)
   - [US-005: Maintain Movie and Show Data](#us-005-maintain-movie-and-show-data)
   - [US-006: Review Booking Details](#us-006-review-booking-details)
   - [US-007: Process Ticket Booking](#us-007-process-ticket-booking)
   - [US-008: Notify Booking Confirmation](#us-008-notify-booking-confirmation)
   - [US-009: Define Booking SLA](#us-009-define-booking-sla)
   - [US-010: Route Booking Request by Show Type](#us-010-route-booking-request-by-show-type)
   - [Conclusion & Final System Output](#conclusion--final-system-output)
5. [Testing & Verification Results](#5-testing--verification-results)
6. [Conclusion](#6-conclusion)

---

## 1. Project Objectives & Scope

| Objective | Business Impact | Pega Technical Component |
| :--- | :--- | :--- |
| **Case Lifecycle Design** | Standardizes booking lifecycle stages and processes | Case Designer, Stages, Steps, Personas |
| **Data Modeling** | Decouples movie and show information for reusability | Data Objects (`Movie`, `Show`), Properties |
| **Business Logic & Cost Calculation** | Prevents booking errors and automates pricing | Declare Expressions, Data Transforms |
| **Approval Workflow** | Guarantees customer confirmation before charging | Decision Points, App Studio Views |
| **Queue-Based Routing** | Segregates premium VIP services from standard tickets | Decision Tables, Work Queues |
| **SLA Enforcement** | Ensures turnaround within 24–48 hours | Service Level Agreement (SLA) Rules |
| **Customer Communication** | Delivers instant confirmation with dynamic details | Correspondence Rules (`Rule-Obj-Corr`), Email Integration |

---

## 2. Data Model & Architecture

### Case Type Class: `CineWave-Work-MovieTicketRequest`

### Data Classes & Properties

#### A. Case Properties (`CineWave-Work-MovieTicketRequest`)
* `.CustomerName` (Text) - Customer full name.
* `.CustomerEmail` (Email) - Customer contact email for notifications.
* `.CustomerPhone` (Phone) - Customer telephone number.
* `.MovieName` (Text) - Selected movie title.
* `.Genre` (Text) - Movie genre.
* `.ShowDate` (Date) - Date of the show.
* `.ShowTime` (TimeOfDay) - Start time of the show.
* `.ShowType` (Text / PickList) - `Standard`, `Premium`, `IMAX`, `4DX`.
* `.NumberOfTickets` (Integer) - Quantity of requested tickets.
* `.SeatCapacity` (Integer) - Total capacity of the theatre hall.
* `.AvailableSeatsCount` (Integer) - Remaining seats available.
* `.SeatAvailabilityStatus` (Text) - `Available` / `Unavailable`.
* `.TicketPrice` (Currency) - Unit ticket price ($12.00 Standard / $20.00 Premium / $28.00 IMAX / $35.00 4DX).
* `.TotalCost` (Currency) - Calculated field (`.TicketPrice * .NumberOfTickets`).
* `.BookingStatus` (Text) - `Confirmed` / `Cancelled`.
* `.TicketID` (Text) - Unique generated ticket identifier (`TKT-MTR-XXXX-YYYYMMDD`).
* `.SeatNumbers` (Text) - Assigned seat numbers (e.g., `S10, S11` or `P1, P2`).
* `.BookingConfirmationStatus` (Text) - `Booked` / `Pending` / `Failed`.

#### B. Reusable Data Object: `Movie` (`CineWave-Data-Movie`)
* `MovieID` (Text, Key)
* `MovieName` (Text)
* `Genre` (Text)
* `DurationMinutes` (Integer)
* `Language` (Text)
* `Rating` (Text)

#### C. Reusable Data Object: `Show` (`CineWave-Data-Show`)
* `ShowID` (Text, Key)
* `MovieID` (Text)
* `ShowDate` (Date)
* `ShowTime` (TimeOfDay)
* `ShowType` (Text)
* `SeatCapacity` (Integer)
* `AvailableSeats` (Integer)
* `StandardPrice` (Currency)
* `PremiumPrice` (Currency)

---

## 3. Case Lifecycle Design

```
+-------------------+      +-------------------+      +-------------------+      +-------------------+      +-------------------+
|   Initial Stage   | ---> |   Availability    | ---> |     Approval      | ---> | Booking Execution | ---> |    Resolution     |
+-------------------+      +-------------------+      +-------------------+      +-------------------+      +-------------------+
| 1. Submit Movie   |      | 1. Search Seat    |      | 1. Review Booking |      | 1. Route by Show  |      | - Resolved-       |
|    Ticket Request |      |    Availability   |      |    Summary        |      |    Type (Router)  |      |   Completed       |
| 2. Validate Inputs|      | 2. Calculate      |      | 2. Confirm or     |      | 2. Allocate Seats |      | - Resolved-       |
|                   |      |    Pricing        |      |    Cancel         |      | 3. Send Email     |      |   Cancelled       |
+-------------------+      +-------------------+      +-------------------+      +-------------------+      +-------------------+
```

### Case Lifecycle Configuration in App Studio:
![Case Designer Lifecycle Configuration](./Screenshot%202026-08-28%20180122.png)
*Figure 1: Full Case Lifecycle Stages and Process Flow in Pega App Studio Case Designer.*

---

## 4. Detailed Epic & User Story Implementation

### Pre-Requisites: Environment Setup & Scaffolding
* **Action:** Pega Academy Instance initialized for Business Architect mission.
* **Credentials Used:** `author@uplus` / `pega123!`
* **Blueprint Scaffolding:** Imported official Pega Blueprint artifact [`Ticketing and Booking 20260828T092006441 GMT.blueprint`](./Ticketing%20and%20Booking%2020260828T092006441%20GMT.blueprint).
* **Application Generated:** `Movie Ticket Booking Management` (`MovieTic:01.01.01`) for Organization `CineWave`.

![Application Overview](./Screenshot%202026-08-28%20153944.png)
*Figure 2: Active Application Overview in Pega App Studio.*

---

### US-001: Submit Movie Ticket Request
* **User Story:** A case type named `Movie Ticket Request` should be created to represent the end-to-end booking process. An initial stage captures customer details (Movie Name, Show Date, Show Time, Number of Tickets).
* **Implementation:**
  - Configured Case Type `Movie Ticket Request`.
  - Created step `Submit Movie Ticket Request` assigned to persona **Customer**.
  - Configured field validation rules for email, phone, and future date.

---

### US-002: Check Show Availability
* **User Story:** An Availability stage verifies whether the requested show has available seats with `Seat Availability Status` and `Available Seats Count`.
* **Implementation:**
  - Added primary stage `Availability`.
  - Added step `Search Seat Availability` for the Booking Agent.
  - Implemented validation rule ensuring `.AvailableSeatsCount >= .NumberOfTickets`.

---

### US-003: Calculate Booking Cost
* **User Story:** Calculate booking cost using properties `Ticket Price` and `Number of Tickets` to derive calculated field `Total Cost`.
* **Implementation:**
  - Added step `Calculate Pricing`.
  - Created Declare Expression rule:
    $$\text{.TotalCost} = \text{.TicketPrice} \times \text{.NumberOfTickets}$$
  - Defined dynamic pricing: $12.00 (Standard), $20.00 (Premium), $28.00 (IMAX), $35.00 (4DX).

---

### US-004 & US-006: Review Booking Details & Confirm Booking Request
* **User Story:** Approval stage presents structured booking summary to Customer persona to confirm or cancel.
* **Implementation:**
  - Added primary stage `Approval`.
  - Created step `Review Booking Summary` displaying read-only movie title, show time, ticket count, unit price, and total cost.
  - Added decision rule:
    - If `BookingStatus == "Confirmed"` $\rightarrow$ Proceed to `Booking Execution`.
    - If `BookingStatus == "Cancelled"` $\rightarrow$ Stage transition to `Cancellation` with status `Resolved-Cancelled`.

---

### US-005: Maintain Movie and Show Data
* **User Story:** Reusable data objects named `Movie` and `Show` manage movie and show information independently.
* **Implementation:**
  - Configured Data Object `Movie` under `CineWave-Data-Movie`.
  - Configured Data Object `Show` under `CineWave-Data-Show`.
  - Linked Data Page references to the case type dropdown fields.

---

### US-007: Process Ticket Booking & US-010: Route by Show Type
* **User Story:** Booking Execution stage handles show type routing, seat allocation, and Ticket ID.
* **Implementation:**
  - Added primary stage `Booking Execution`.
  - Work Queues: `PremiumShowQueue` (for Premium, IMAX, 4DX) and `StandardShowQueue` (for Standard).
  - Maintained properties: `.TicketID`, `.SeatNumbers`, and `.BookingConfirmationStatus = "Booked"`.

### Live Case Execution View (`M-3` / `M-4`):
![Live Case Execution](./Screenshot%202026-08-28%20154358.png)
*Figure 3: Live Case Instance executing through Initial Stage, Availability, Approval, and Booking Execution stages.*

---

### US-008: Notify Booking Confirmation
* **User Story:** Send automated correspondence upon successful booking containing Case ID, Movie Name, Show Date & Time, Seat Numbers, and Total Cost.
* **Implementation:**
  - Added Send Email notification upon case resolution.
  - Configured Correspondence rule `BookingConfirmationNotification` (`Rule-Obj-Corr`).
  - Mapped dynamic properties: `.pyID`, `.CustomerName`, `.MovieName`, `.ShowDate`, `.ShowTime`, `.NumberOfTickets`, `.SeatNumbers`, `.TotalCost`.

---

### US-009: Define Booking SLA
* **User Story:** Configure SLA with Goal: 1 day (+20 urgency) and Deadline: 2 days (+30 urgency).
* **Implementation:**
  - Configured Case-level SLA rule `MovieTicketRequestSLA`.
  - Set Goal: `1 Day`, Urgency increase: `20`.
  - Set Deadline: `2 Days`, Urgency increase: `30`.

---

### Conclusion & Final System Output Example
* **Automated Output generated upon resolution:**
```text
Subject: Movie Ticket Booking Confirmed - MTR-1001

Dear Harsh Maurya,

Your movie ticket booking has been successfully confirmed.

Dynamic Breakdown:
---------------------------------------------
Case ID:            MTR-1001
Ticket ID:          TKT-MTR-1001-20260828
Movie Name:         The Midnight Chronicles
Show Date & Time:   September 12, 2026 at 7:30 PM
Show Type:          IMAX
Number of Tickets:  3
Seat Numbers:       A10, A11, A12
Total Cost:         $84.00
---------------------------------------------

Instructions: Please arrive at the theatre at least 15 minutes before show time and present your booking details at entry.

Thank you for choosing our services. Enjoy your movie!
— CineWave Entertainment Booking Support Team
```

---

## 5. Testing & Verification Results

| Test Scenario | Input Data | Expected Result | Actual Result | Status |
| :--- | :--- | :--- | :--- | :--- |
| **TS-01: Standard Booking** | 2 Tickets, Standard Show ($12) | Total Cost = $24.00, routes to StandardShowQueue | Verified Total Cost $24.00, routed to StandardShowQueue | **PASS** |
| **TS-02: Premium Booking** | 3 Tickets, Premium Show ($20) | Total Cost = $60.00, routes to PremiumShowQueue | Verified Total Cost $60.00, routed to PremiumShowQueue | **PASS** |
| **TS-03: IMAX Booking** | 3 Tickets, IMAX Show ($28) | Total Cost = $84.00, routes to PremiumShowQueue | Verified Total Cost $84.00, routed to PremiumShowQueue | **PASS** |
| **TS-04: Insufficient Seats** | Request 10 seats, Available 4 | Validation error displayed; case blocked from stage advance | Validation triggered correctly | **PASS** |
| **TS-05: Customer Cancellation** | BookingStatus = Cancelled | Case resolved with `Resolved-Cancelled` | Status set to `Resolved-Cancelled` | **PASS** |
| **TS-06: SLA Urgency** | Goal elapsed | Urgency increases by +20 | Urgency increased as configured | **PASS** |
| **TS-07: Email Dispatch** | Successful booking | Email dispatched with dynamic ticket details | Email generated and sent | **PASS** |

---

## 6. Conclusion
The **Movie Ticket Booking Management** application for CineWave Entertainment has been completely designed, implemented, scaffolded via Pega Blueprint, and verified on the Pega Platform™. The system streamlines ticket operations, minimizes manual intervention, enforces turnaround SLAs, and provides an exceptional customer booking experience.
