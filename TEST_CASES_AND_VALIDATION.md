# Movie Ticket Booking Management — Test Cases & Validation Matrix
## CineWave Entertainment | Pega Infinity v8.7+ | Author: Harsh Maurya

> **Purpose:** Comprehensive test suite covering positive, negative, boundary, edge-case, SLA escalation, routing, correspondence, and data integrity scenarios.

---

## Test Suite Summary

| Category | Total Test Cases |
| :--- | :--- |
| Positive Flow (Happy Path) | 4 |
| Negative / Validation | 8 |
| Boundary Conditions | 4 |
| SLA & Urgency | 2 |
| Work Queue Routing | 5 |
| Declare Expression (Calculation) | 4 |
| Correspondence | 2 |
| Edge Cases | 4 |
| **Total** | **33** |

---

## Positive Flow (Happy Path)

### TC-P01: Standard Show Full Booking — End to End
| | |
| :--- | :--- |
| **Objective** | Verify complete lifecycle for a Standard show booking from request to resolution. |
| **Pre-conditions** | Pega instance initialized. Customer access group active. |

**Steps:**
1. Log in as Customer → Create Case: `Movie Ticket Request`.
2. Fill: Name=`Harsh Maurya`, Email=`harsh@test.com`, Phone=`9876543210`, Movie=`Inception`, ShowDate=`Tomorrow`, ShowTime=`18:00`, ShowType=`Standard`, TheatreLocation=`CineWave City Centre`, Tickets=`2`.
3. Submit. Verify case advances to **Availability** stage.
4. Log in as BookingAgent → Open case. Set `AvailableSeatsCount=50`, `SeatAvailabilityStatus=Available`. Submit.
5. Verify `TicketPrice = $12.00`, `TotalCost = $24.00`, `FinalCost = $24.00` (auto-calculated).
6. Case advances to **Approval** stage. Log in as Customer → Review booking details. Select `BookingStatus = Confirmed`. Submit.
7. Verify case routes to `StandardShowQueue`.
8. Log in as FulfillmentStaff → Open from `StandardShowQueue`. Verify `TicketID` is auto-populated (format: `TKT-MTR-XXXX-YYYYMMDD`). Enter `SeatNumbers = S10, S11`. Set `BookingConfirmationStatus = Booked`. Submit.
9. Verify confirmation email dispatched to `harsh@test.com`.
10. Verify case status = `Resolved-Completed`.

**Expected Results:**
- ✅ `TotalCost = $24.00`, `FinalCost = $24.00`
- ✅ Routed to `StandardShowQueue`
- ✅ Case = `Resolved-Completed`
- ✅ Confirmation email contains Case ID, Ticket ID, seat numbers, total cost

---

### TC-P02: Premium Show Full Booking — End to End
**Steps:** Repeat TC-P01 with `ShowType = Premium`, `Tickets = 3`.

**Expected Results:**
- ✅ `TicketPrice = $20.00`, `TotalCost = $60.00`, `FinalCost = $60.00`
- ✅ Routed to `PremiumShowQueue`
- ✅ Email shows Premium badge and updated amounts

---

### TC-P03: IMAX Show Booking
**Steps:** Repeat TC-P01 with `ShowType = IMAX`, `Tickets = 1`.

**Expected Results:**
- ✅ `TicketPrice = $28.00`, `TotalCost = $28.00`, `FinalCost = $28.00`
- ✅ Routed to `PremiumShowQueue`

---

### TC-P04: Customer Cancellation Flow
**Steps:**
1. Advance case to Approval stage (use TC-P01 steps 1–5).
2. Customer selects `BookingStatus = Cancelled`, enters `CancellationReason = Change of plans`.
3. Submit.

**Expected Results:**
- ✅ Case status = `Resolved-Cancelled`
- ✅ Cancellation notification email dispatched to customer
- ✅ Case does NOT route to any work queue
- ✅ No ticket ID generated

---

## Negative / Validation Tests

### TC-N01: Submit with Missing Customer Name
**Step:** Leave `CustomerName` blank → Click Submit (Initial Stage).
**Expected:** ❌ Error: `"Customer Name is required."` — form blocked.

---

### TC-N02: Invalid Email Format
**Step:** Enter `CustomerEmail = notanemail` → Click Submit.
**Expected:** ❌ Error: `"Please enter a valid email address (e.g., name@domain.com)."` — form blocked.

---

### TC-N03: Show Date in the Past
**Step:** Set `ShowDate = Yesterday` → Click Submit.
**Expected:** ❌ Error: `"Show Date must be today or a future date."` — form blocked.

---

### TC-N04: Number of Tickets = 0
**Step:** Set `NumberOfTickets = 0` → Click Submit.
**Expected:** ❌ Error: `"Number of tickets must be between 1 and 10."` — form blocked.

---

### TC-N05: Number of Tickets = 11 (Exceeds Maximum)
**Step:** Set `NumberOfTickets = 11` → Click Submit.
**Expected:** ❌ Error: `"Number of tickets must be between 1 and 10."` — form blocked.

---

### TC-N06: Houseful Show — Seat Availability
**Step:** In Availability stage, set `SeatAvailabilityStatus = Houseful` → Submit.
**Expected:** ❌ Error: `"This show is currently houseful. Please select a different show."` — agent cannot advance.

---

### TC-N07: Insufficient Seats — Requested 5, Available 2
**Step:** Set `NumberOfTickets = 5`, `AvailableSeatsCount = 2`, `SeatAvailabilityStatus = Limited` → Submit.
**Expected:** ❌ Error: `"Only 2 seat(s) available — cannot fulfill request for 5 tickets."` — blocked.

---

### TC-N08: Cancel Without Providing Reason
**Step:** In Approval stage, select `BookingStatus = Cancelled`, leave `CancellationReason` blank → Submit.
**Expected:** ❌ Error: `"Please provide a reason for cancellation."` — blocked.

---

## Boundary Condition Tests

### TC-B01: Minimum Tickets (1 Ticket)
**Step:** Set `NumberOfTickets = 1`, Standard show.
**Expected:** ✅ `TotalCost = $12.00`. No validation error. Full flow completes.

---

### TC-B02: Maximum Tickets (10 Tickets)
**Step:** Set `NumberOfTickets = 10`, Premium show.
**Expected:** ✅ `TotalCost = $200.00`. No validation error. Full flow completes.

---

### TC-B03: Show Date = Today (Boundary — must pass)
**Step:** Set `ShowDate = Today`.
**Expected:** ✅ No validation error — today's date should be accepted.

---

### TC-B04: Available Seats Exactly Equal Requested Tickets
**Step:** `NumberOfTickets = 4`, `AvailableSeatsCount = 4`, `SeatAvailabilityStatus = Limited`.
**Expected:** ✅ No validation error — exact match should be allowed.

---

## SLA & Urgency Tests

### TC-S01: Goal Breach — Urgency Escalation
**Pre-condition:** Create a new booking case. Leave it in Availability stage.
**Step:** Simulate time advance by 1 day (use Pega's SLA tester or wait with test environment).
**Expected:**
- ✅ `pyUrgency` increases from 10 to 30 (+20).
- ✅ Assigned operator receives SLA goal notification.
- ✅ Case flagged as approaching deadline in workbasket.

---

### TC-S02: Deadline Breach — Priority Escalation
**Pre-condition:** Continue TC-S01. Simulate 2 days elapsed.
**Expected:**
- ✅ `pyUrgency` increases from 30 to 60 (+30).
- ✅ Supervisor receives SLA deadline notification.
- ✅ Case sorted to top of workbasket (highest priority).

---

## Work Queue Routing Tests

### TC-R01: Standard → StandardShowQueue
**Setup:** `ShowType = Standard`.
**Expected:** ✅ Case assigned to `StandardShowQueue`. `RoutedToQueue = StandardShowQueue`.

### TC-R02: Premium → PremiumShowQueue
**Setup:** `ShowType = Premium`.
**Expected:** ✅ Case assigned to `PremiumShowQueue`. `RoutedToQueue = PremiumShowQueue`.

### TC-R03: IMAX → PremiumShowQueue
**Setup:** `ShowType = IMAX`.
**Expected:** ✅ Case assigned to `PremiumShowQueue`.

### TC-R04: 4DX → PremiumShowQueue
**Setup:** `ShowType = 4DX`.
**Expected:** ✅ Case assigned to `PremiumShowQueue`.

### TC-R05: Routing Decision Table — Otherwise Row
**Setup:** Manually set `.ShowType = "Unknown"` (edge case).
**Expected:** ✅ Decision Table falls to "Otherwise" row → `StandardShowQueue`.

---

## Declare Expression (Calculation) Tests

### TC-D01: Standard Pricing Calculation
**Inputs:** `ShowType = Standard`, `NumberOfTickets = 3`, `DiscountPercent = 0`.
**Expected:** `TicketPrice = 12.00`, `TotalCost = 36.00`, `FinalCost = 36.00`.

### TC-D02: Premium Pricing Calculation
**Inputs:** `ShowType = Premium`, `NumberOfTickets = 2`, `DiscountPercent = 0`.
**Expected:** `TicketPrice = 20.00`, `TotalCost = 40.00`, `FinalCost = 40.00`.

### TC-D03: Discount Applied
**Inputs:** `ShowType = Standard`, `NumberOfTickets = 5`, `DiscountPercent = 10`.
**Expected:**
- `TicketPrice = 12.00`
- `TotalCost = 60.00`
- `FinalCost = 60.00 * (1 - 0.10) = 54.00` ✅

### TC-D04: 4DX Full Pricing
**Inputs:** `ShowType = 4DX`, `NumberOfTickets = 4`, `DiscountPercent = 0`.
**Expected:** `TicketPrice = 35.00`, `TotalCost = 140.00`, `FinalCost = 140.00`.

---

## Correspondence Tests

### TC-C01: Booking Confirmation Email
**Pre-condition:** Complete full booking flow (TC-P01).
**Step:** Verify email received at `CustomerEmail`.
**Expected:**
- ✅ Subject: `Movie Ticket Booking Confirmed - MTR-XXXX`
- ✅ Body contains: Case ID, Ticket ID, Movie Name, Show Date & Time, Show Type, Theatre Location, Seat Numbers, Total Amount Paid
- ✅ Email renders correctly in Gmail, Outlook, Mobile (responsive layout)
- ✅ `CancellationNotification` NOT sent

### TC-C02: Cancellation Notification Email
**Pre-condition:** Complete TC-P04 (Customer cancels in Approval).
**Expected:**
- ✅ Cancellation email sent to `CustomerEmail`
- ✅ Subject: `Your Booking MTR-XXXX Has Been Cancelled`
- ✅ Confirmation email NOT sent

---

## Edge Case Tests

### TC-E01: Re-open cancelled case
**Step:** Attempt to re-open a `Resolved-Cancelled` case and advance to Booking Execution.
**Expected:** ✅ Case lifecycle prevents re-opening without administrator override. Cancelled status is terminal.

### TC-E02: Concurrent bookings (same show, limited seats)
**Step:** Create 2 booking cases simultaneously for the same show with only 3 seats available, each requesting 2 tickets.
**Expected:** ✅ Whichever case the agent confirms first completes. Second case should fail `ValidateSeatAvailability` after seats are allocated.

### TC-E03: Empty Movie Name but other fields filled
**Step:** Leave `MovieName` blank, fill all other fields.
**Expected:** ❌ Error: `"Movie Name is required."` — only MovieName error shows, other fields intact.

### TC-E04: All 4 Show Types Pricing Accuracy
**Step:** Create 4 cases, one per ShowType.
**Expected:**
| ShowType | Expected TicketPrice |
| :--- | :--- |
| Standard | $12.00 ✅ |
| Premium | $20.00 ✅ |
| IMAX | $28.00 ✅ |
| 4DX | $35.00 ✅ |

---

## Test Execution Sign-Off

| Test Category | Total | Passed | Failed | Blocked |
| :--- | :--- | :--- | :--- | :--- |
| Positive Flow | 4 | | | |
| Negative / Validation | 8 | | | |
| Boundary Conditions | 4 | | | |
| SLA & Urgency | 2 | | | |
| Work Queue Routing | 5 | | | |
| Declare Expression | 4 | | | |
| Correspondence | 2 | | | |
| Edge Cases | 4 | | | |
| **Total** | **33** | | | |

**Tested By:** Harsh Maurya
**Test Date:** ___________
**Environment:** Pega Academy Exercise Instance v8.7
**Sign-Off Status:** ☐ Pass  ☐ Fail  ☐ Conditional Pass
