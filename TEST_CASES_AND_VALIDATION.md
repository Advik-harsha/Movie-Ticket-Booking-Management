# CineWave Entertainment - Test Cases & Validation Matrix

This document provides complete test cases, execution steps, expected outcomes, and verification checkpoints for the **Movie Ticket Booking Management Application** on Pega Platform™.

---

## Test Suite Overview

| Test Case ID | Test Case Title | Target User Story | Priority | Type |
| :--- | :--- | :--- | :--- | :--- |
| **TC-01** | Complete End-to-End Standard Show Booking | US-001, US-002, US-003, US-004, US-006, US-007, US-008, US-010 | High | Positive |
| **TC-02** | Complete End-to-End Premium Show Booking | US-001, US-002, US-003, US-004, US-006, US-007, US-008, US-010 | High | Positive |
| **TC-03** | Seat Availability Validation (Overbooking Prevention) | US-002 | High | Negative |
| **TC-04** | Dynamic Cost Calculation Accuracy | US-003 | High | Functional |
| **TC-05** | Customer Rejection / Cancellation Workflow | US-004, US-006 | Medium | Functional |
| **TC-06** | Work Queue Routing Logic Validation | US-010 | High | Functional |
| **TC-07** | Service Level Agreement (SLA) Urgency Escalation | US-009 | Medium | System |
| **TC-08** | Dynamic Email Correspondence Dispatch | US-008, Conclusion | High | Integration |

---

## Detailed Test Cases

### TC-01: Standard Show Booking Flow
* **Pre-conditions:** System initialized, `Movie` and `Show` data records present.
* **Test Steps:**
  1. Launch portal as Customer (`author@uplus`).
  2. Click **Create $\rightarrow$ Movie Ticket Request**.
  3. Enter Customer details: `Name: John Doe`, `Email: john.doe@example.com`, `Phone: 555-0199`.
  4. Select Movie: `Inception`, Date: `Tomorrow`, Time: `18:00`, Show Type: `Standard`, Tickets: `2`.
  5. Click **Submit**.
  6. In Availability stage, set Available Seats: `50`, Status: `Available`.
  7. Verify unit price = `$12.00` and calculated Total Cost = `$24.00`.
  8. In Approval stage, review details and select `BookingStatus = Confirmed`.
  9. In Booking Execution stage, verify case routed to `StandardShowQueue`.
  10. Assign Seat Numbers: `S10, S11`, Ticket ID: `TKT-MTR-101-STD`.
  11. Submit to complete case.
* **Expected Result:** Case reaches `Resolved-Completed`. Confirmation email sent with Total Cost `$24.00` and seat numbers `S10, S11`.

---

### TC-02: Premium Show Booking Flow
* **Pre-conditions:** System initialized.
* **Test Steps:**
  1. Create new case for `Movie: Avatar: The Way of Water`, Show Type: `Premium`, Tickets: `4`.
  2. In Availability stage, verify unit price = `$20.00` and calculated Total Cost = `$80.00`.
  3. In Approval stage, confirm booking.
  4. In Booking Execution stage, verify routing to `PremiumShowQueue`.
  5. Enter Seat Numbers: `P1, P2, P3, P4`.
  6. Finalize booking.
* **Expected Result:** Case routed to `PremiumShowQueue`, resolved as `Resolved-Completed`, and confirmation dispatched with Total Cost `$80.00`.

---

### TC-03: Seat Availability Validation (Negative Test)
* **Test Steps:**
  1. Create request with `NumberOfTickets = 6`.
  2. In Availability step, set `AvailableSeatsCount = 3` or `SeatAvailabilityStatus = Unavailable`.
  3. Attempt to advance to Approval stage.
* **Expected Result:** Pega validation error is displayed: *"Requested number of tickets exceeds available seats."* The case is blocked from advancing.

---

### TC-04: Customer Cancellation Flow
* **Test Steps:**
  1. Advance case to Approval stage.
  2. In `Review Booking Details` step, select `BookingStatus = Cancelled`.
  3. Click **Submit**.
* **Expected Result:** Case automatically changes stage to Resolution and resolves as `Resolved-Cancelled` without charging or dispatching booking tickets.

---

### TC-05: SLA Verification
* **Test Steps:**
  1. Open case and inspect pyUrgency (Default: 10).
  2. Advance simulation time by 1 Day.
  3. Verify pyUrgency increases to 30 (+20).
  4. Advance simulation time past 2 Days (Deadline).
  5. Verify pyUrgency increases to 60 (+30).
* **Expected Result:** SLA rules trigger accurately according to US-009 requirements.
