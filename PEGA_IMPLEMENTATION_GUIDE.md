# Movie Ticket Booking Management — Advanced Pega Implementation Guide
## CineWave Entertainment | Pega Infinity v8.7+ | Author: Harsh Maurya

---

> **Target Audience:** This guide is written for Business Architect / System Architect roles with intermediate-to-advanced Pega knowledge. Every configuration step is production-ready and follows Pega guardrails, naming conventions, and best practices.

---

## Table of Contents
1. [Architecture & Design Decisions](#1-architecture--design-decisions)
2. [Environment Setup & Application Scaffolding](#2-environment-setup--application-scaffolding)
3. [Data Modeling (Data Objects)](#3-data-modeling-data-objects)
4. [Case Type Configuration — Full Lifecycle](#4-case-type-configuration--full-lifecycle)
   - [4.1 Initial Stage — Submit Movie Ticket Request](#41-initial-stage--submit-movie-ticket-request-us-001)
   - [4.2 Availability Stage — Check Availability](#42-availability-stage--check-show-availability-us-002)
   - [4.3 Availability Stage — Calculate Cost](#43-availability-stage--calculate-booking-cost-us-003)
   - [4.4 Approval Stage — Review & Confirm](#44-approval-stage--review-booking-details--confirm-us-004--us-006)
   - [4.5 Booking Execution — Route by Show Type](#45-booking-execution--route-by-show-type-us-010)
   - [4.6 Booking Execution — Process Ticket](#46-booking-execution--process-ticket-booking-us-007)
   - [4.7 Booking Execution — Notify Confirmation](#47-booking-execution--notify-booking-confirmation-us-008)
5. [SLA Configuration](#5-sla-configuration-us-009)
6. [Validation Rules (All Stages)](#6-validation-rules)
7. [Declare Expressions (Calculated Fields)](#7-declare-expressions)
8. [Decision Table — Work Queue Routing](#8-decision-table--work-queue-routing)
9. [Correspondence Rule Setup](#9-correspondence-rule-setup)
10. [Access Groups, Personas & Portals](#10-access-groups-personas--portals)
11. [Error Handling & Edge Cases](#11-error-handling--edge-cases)
12. [Verification & Testing Checklist](#12-verification--testing-checklist)

---

## 1. Architecture & Design Decisions

### 1.1 Why Separate Data Objects for Movie & Show?
Separating `Movie` and `Show` as reusable Data Objects (not embedded case properties) gives:
- **Reusability:** Any future case type (e.g., refunds, loyalty rewards) can reference these without duplication.
- **Data Integrity:** Centralized pricing and scheduling prevents inconsistencies across bookings.
- **Scalability:** Allows a separate UI/CRUD layer for cinema managers to maintain the catalogue.

### 1.2 Declare Expressions over Data Transforms for Calculations
`TotalCost` and `FinalCost` are modeled as **Declare Expressions**, not manually calculated fields, because:
- They recalculate **automatically** whenever inputs change (reactive computation).
- No step needs to manually "trigger" the calculation.
- Prevents stale/incorrect values if the agent edits `NumberOfTickets` later.

### 1.3 Decision Table for Queue Routing
Using a **Decision Table** (not a When rule) for `RouteByShowType` because:
- Decision Tables are centrally managed — adding a new show type (e.g., "Dolby Atmos") only requires a new row, not code change.
- Easier to hand off to business users via App Studio.

### 1.4 Status Mapping
Pega's `pxObjStatus` system statuses are mapped to human-readable case statuses so the Customer Portal and tracking views show meaningful labels (e.g., `Pending Approval` instead of `Open-InProgress`).

---

## 2. Environment Setup & Application Scaffolding

### 2.1 Pre-Requisites Checklist
- [ ] Active Pega Academy account with access to the Business Architect mission exercise.
- [ ] Google Chrome or Edge browser (latest version).
- [ ] Blueprint JSON file (`PEGA_BLUEPRINT_SPECIFICATION.json`) downloaded from the GitHub repository.

### 2.2 Initialize Pega Instance
1. Navigate to: https://academy.pega.com/mission/business-architect/v8/exercise?
2. Sign in with your **Pega Academy email and password**.
3. Click **"Initialize Pega instance for this Mission Exercise"** → wait 3–5 minutes.
4. Click **"Launch Pega instance for this Mission Exercise"**.
5. Login with: **Username:** `author@uplus` | **Password:** `pega123!`

> ⚠️ **Common Error:** If the instance times out during initialization, refresh the browser and click "Launch" again — the environment is already prepared. Do NOT click "Initialize" again.

### 2.3 Create Application from Blueprint
1. In App Studio: Click the **Application** menu → **New Application**.
2. Select **"Build from Blueprint"** → Click **"Upload Blueprint File"**.
3. Upload `PEGA_BLUEPRINT_SPECIFICATION.json` from your local filesystem.
4. Review generated configuration:
   - **Application Name:** `Movie Ticket Booking Management`
   - **Version:** `01-01-01`
   - **Organization:** `CineWave` | **Division:** `Entertainment` | **Unit:** `Operations`
5. Click **"Build Now"** → wait for generation → Click **"Submit"**.
6. Click **"Go to new application"**.

---

## 3. Data Modeling (Data Objects)

### 3.1 Create Movie Data Object
**Navigation:** App Studio → **Data** → **+ Add data object**

| Setting | Value |
| :--- | :--- |
| Object Name | `Movie` |
| Class | `CineWave-Data-Movie` |
| Storage | Pega database |

**Properties to add:**

| Property Name | Type | Key? | Notes |
| :--- | :--- | :--- | :--- |
| `MovieID` | Text (20) | ✅ Yes | Unique identifier |
| `MovieName` | Text (100) | No | Movie title |
| `Genre` | Text (50) | No | Action, Drama, etc. |
| `Language` | Text (30) | No | English, Hindi, etc. |
| `DurationMinutes` | Integer | No | Runtime in minutes |
| `Rating` | Text (10) | No | U, UA, A |
| `Director` | Text (100) | No | Director's name |
| `Cast` | Text (255) | No | Lead cast |
| `ReleaseDate` | Date | No | Theatrical release date |
| `IsActive` | TrueFalse | No | Default: `true` |

### 3.2 Create Show Data Object
**Navigation:** App Studio → **Data** → **+ Add data object**

| Property Name | Type | Key? | Notes |
| :--- | :--- | :--- | :--- |
| `ShowID` | Text (20) | ✅ Yes | Unique show identifier |
| `MovieID` | Text (20) | No | FK → Movie.MovieID |
| `ShowDate` | Date | No | Date of screening |
| `ShowTime` | Time | No | Start time |
| `ShowType` | Text | No | Standard / Premium / IMAX / 4DX |
| `TheatreLocation` | Text (100) | No | Theatre address/name |
| `ScreenNumber` | Text (10) | No | Hall/screen number |
| `SeatCapacity` | Integer | No | Total seats |
| `AvailableSeats` | Integer | No | Live availability count |
| `StandardPrice` | Decimal | No | Standard ticket price |
| `PremiumPrice` | Decimal | No | Premium ticket price |
| `IMAXPrice` | Decimal | No | IMAX ticket price |
| `FourDXPrice` | Decimal | No | 4DX ticket price |
| `IsActive` | TrueFalse | No | Default: `true` |

### 3.3 Associate Data Objects to Case Type
**Navigation:** Case Designer → **Data** tab → **+ Add Data Object**
- Add `Movie` (CineWave-Data-Movie)
- Add `Show` (CineWave-Data-Show)

---

## 4. Case Type Configuration — Full Lifecycle

**Navigation:** App Studio → **Cases** → Click **Movie Ticket Request** → **Case Designer**

### 4.1 Initial Stage — Submit Movie Ticket Request (US-001)
**Stage Name:** `Initial Stage` | **Step Type:** Collect Information | **Persona:** Customer

**View Configuration (SubmitMovieTicketRequestView):**
- Layout: Two-column responsive layout.
- **Column 1 — Customer Information:**
  - `CustomerName` (Text, Required)
  - `CustomerEmail` (Email, Required)
  - `CustomerPhone` (Phone, Required)
  - `CustomerID` (Text, Optional)
- **Column 2 — Booking Details:**
  - `MovieName` (Text, Required)
  - `Genre` (Text, Optional)
  - `ShowDate` (Date Picker, Required — disable past dates)
  - `ShowTime` (Time Picker, Required)
  - `ShowType` (Dropdown: Standard / Premium / IMAX / 4DX, Required)
  - `TheatreLocation` (Text, Required)
  - `ScreenNumber` (Text, Optional)
  - `NumberOfTickets` (Number Input 1–10, Required)

**Pre-Processing (On Enter):**
- Trigger Data Transform: `InitializeCaseDefaults`
  - Sets `Currency = 'USD'`, `DiscountPercent = 0`, `BookingConfirmationStatus = 'Pending'`

**Validation (On Submit):**
- Attach Validate Rule: `ValidateCustomerInfo`
- Attach Validate Rule: `ValidateBookingDetails`

> ✅ **Error-Proof Tip:** Set `ShowDate` field property `pxMinDate` to `@P +0` (today) in the UI metadata so the date picker never allows past dates at the UI level — before the validation rule even fires.

---

### 4.2 Availability Stage — Check Show Availability (US-002)
**Stage Name:** `Availability` | **Step Type:** Collect Information | **Persona:** BookingAgent

**View Configuration (CheckShowAvailabilityView):**
- **Section 1 — Customer Booking Request (Read-Only):**
  - `MovieName`, `ShowDate`, `ShowTime`, `ShowType`, `TheatreLocation`, `NumberOfTickets`
  - Mark all as read-only (display-only controls).
- **Section 2 — Availability Assessment:**
  - `SeatCapacity` (Integer, read-only — prefilled from Show data object)
  - `AvailableSeatsCount` (Integer, editable — agent enters verified count)
  - `SeatAvailabilityStatus` (Dropdown: Available / Limited / Houseful, Required)

**Validation (On Submit):**
- Attach Validate Rule: `ValidateSeatAvailability`

**Error Behavior:**
- If `SeatAvailabilityStatus = Houseful` → Hard stop with message: *"This show is currently houseful. Please contact the customer to select an alternate show date or time."*
- If `AvailableSeatsCount < NumberOfTickets` → Hard stop with message: *"Only @{AvailableSeatsCount} seats available — insufficient for the requested @{NumberOfTickets} tickets."*

---

### 4.3 Availability Stage — Calculate Booking Cost (US-003)

**Step 1: Create Data Transform `SetTicketPricingDT`**
**Navigation:** Dev Studio → **Create** → **Data Transform** → Class: `CineWave-Work-MovieTicketRequest`

| Condition | Property | Value |
| :--- | :--- | :--- |
| When `.ShowType = "Standard"` | `.TicketPrice` | `12.00` |
| When `.ShowType = "Premium"` | `.TicketPrice` | `20.00` |
| When `.ShowType = "IMAX"` | `.TicketPrice` | `28.00` |
| When `.ShowType = "4DX"` | `.TicketPrice` | `35.00` |

**Step 2: Create Declare Expression `CalcTotalCost`**
**Navigation:** Dev Studio → **Create** → **Declare Expression** → Class: `CineWave-Work-MovieTicketRequest`

| Setting | Value |
| :--- | :--- |
| Target property | `.TotalCost` |
| Expression | `.TicketPrice * .NumberOfTickets` |
| Triggers | `.TicketPrice`, `.NumberOfTickets` |

**Step 3: Create Declare Expression `CalcFinalCost`**

| Setting | Value |
| :--- | :--- |
| Target property | `.FinalCost` |
| Expression | `.TotalCost * (1 - (.DiscountPercent / 100))` |
| Triggers | `.TotalCost`, `.DiscountPercent` |

**Wire into lifecycle:**
- In the Availability stage after `Check Show Availability` step, add a **Change Stage** utility:
  - Action: **Run Data Transform**: `SetTicketPricingDT`
- The Declare Expressions fire automatically once `TicketPrice` is set.

---

### 4.4 Approval Stage — Review Booking Details & Confirm (US-004 & US-006)
**Stage Name:** `Approval` | **Step Type:** Approve/Reject | **Persona:** Customer

**View Configuration (ReviewBookingDetailsView):**
- **Section 1 — Booking Summary (all read-only):**
  - `CustomerName`, `MovieName`, `Genre`, `ShowDate`, `ShowTime`, `ShowType`, `TheatreLocation`, `ScreenNumber`
- **Section 2 — Pricing Breakdown (all read-only):**
  - `NumberOfTickets`, `TicketPrice`, `TotalCost`, `DiscountPercent`, `FinalCost`, `Currency`
  - Style `FinalCost` with bold formatting and a highlight color.
- **Section 3 — Your Decision:**
  - `BookingStatus` (Radio group: Confirmed / Cancelled)
  - `CancellationReason` (Text area — conditionally visible only when `BookingStatus = Cancelled`)

**Stage Transitions:**
- If `BookingStatus = Confirmed` → Move to **Booking Execution** stage.
- If `BookingStatus = Cancelled`:
  - Change case status to `Resolved-Cancelled`.
  - Trigger Correspondence: `BookingCancellationNotification`.
  - Close case.

---

### 4.5 Booking Execution — Route by Show Type (US-010)

**Step 1: Create Work Queues**
**Navigation:** Dev Studio → **Org & Security** → **Work Queues**
- Create `PremiumShowQueue@CineWave` (Priority: High)
- Create `StandardShowQueue@CineWave` (Priority: Normal)

**Step 2: Create Decision Table `RouteByShowType`**
**Navigation:** Dev Studio → **Create** → **Decision Table** → Class: `CineWave-Work-MovieTicketRequest`

| Input: `.ShowType` | Result |
| :--- | :--- |
| `== "Premium"` | `PremiumShowQueue` |
| `== "IMAX"` | `PremiumShowQueue` |
| `== "4DX"` | `PremiumShowQueue` |
| `== "Standard"` | `StandardShowQueue` |
| Otherwise | `StandardShowQueue` |

**Step 3: Add Router Step in Booking Execution Stage**
- Add a **Router step** → Select **Decision Table** → `RouteByShowType`
- Enable **"Assign to work queue"** routing action.
- Post-Processing: Run Data Transform `RecordRoutedQueue` (sets `.RoutedToQueue = .pyWorkQueue`)

---

### 4.6 Booking Execution — Process Ticket Booking (US-007)
**Step Type:** Collect Information | **Persona:** FulfillmentStaff | **Routing:** Work Queue

**View Configuration (ProcessTicketBookingView):**
- **Section 1 — Booking Reference (Read-Only):**
  - `CaseID (.pyID)`, `CustomerName`, `CustomerEmail`, `MovieName`, `ShowDate`, `ShowTime`, `ShowType`, `TheatreLocation`, `NumberOfTickets`, `FinalCost`
- **Section 2 — Fulfillment Details (Editable):**
  - `TicketID` (auto-populated by pre-processing, but editable)
  - `SeatNumbers` (Text, Required — e.g., `A1, A2, A3`)
  - `BookingConfirmationStatus` (Dropdown: Booked / Pending / Failed, Default: Booked)
  - `ScreenNumber` (if not already set)

**Pre-Processing (On Enter):**
- Run Data Transform `SetTicketID`:
  - `.TicketID = Concatenate("TKT-", .pyID, "-", FormatDate(.ShowDate, "YYYYMMDD"))`

**Validation (On Submit):**
- Attach: `ValidateFulfillmentDetails`

---

### 4.7 Booking Execution — Notify Booking Confirmation (US-008)

**Step Type:** Send Email (Automation step, not a user step)

**Configuration:**
| Setting | Value |
| :--- | :--- |
| Correspondence Rule | `BookingConfirmationNotification` |
| Recipient | `.CustomerEmail` |
| Subject | `Movie Ticket Booking Confirmed - @{.pyID}` |
| Trigger | After `Process Ticket Booking` step completes |

**Followed by:** Change Stage to `Resolution` → Status `Resolved-Completed`.

---

## 5. SLA Configuration (US-009)

**Navigation:** Case Designer → **Settings** → **Goal and deadline (SLA)**

| Setting | Value |
| :--- | :--- |
| SLA Rule Name | `MovieTicketRequestSLA` |
| Goal Interval | **1 Day** from case creation |
| Goal Action | Increase urgency by +20 |
| Goal Notification | Notify assigned operator |
| Deadline Interval | **2 Days** from case creation |
| Deadline Action | Increase urgency by +30 |
| Deadline Notification | Notify assigned operator + supervisor |
| Passed Deadline | +4 hours (repeat 3 times), Urgency +10 per repeat |

> 💡 **Why this matters:** With `DefaultUrgency = 10`, the Goal breach raises it to 30, and the Deadline breach raises it to 60. Pega's workbasket will automatically sort these cases to the top for agents.

---

## 6. Validation Rules

All validation rules are attached to their corresponding steps (not stage-level) to ensure precise error context.

### `ValidateCustomerInfo`
| Rule | Error Message |
| :--- | :--- |
| `IsBlank(.CustomerName)` | "Customer Name is required." |
| `IsBlank(.CustomerEmail)` | "Email Address is required." |
| `NOT IsValidEmail(.CustomerEmail)` | "Please enter a valid email address (e.g., name@domain.com)." |
| `IsBlank(.CustomerPhone)` | "Phone Number is required." |

### `ValidateBookingDetails`
| Rule | Error Message |
| :--- | :--- |
| `IsBlank(.MovieName)` | "Movie Name is required." |
| `IsBlank(.ShowDate)` | "Show Date is required." |
| `.ShowDate < Today()` | "Show Date must be today or a future date." |
| `IsBlank(.ShowTime)` | "Show Time is required." |
| `IsBlank(.ShowType)` | "Show Type is required." |
| `.NumberOfTickets < 1 OR .NumberOfTickets > 10` | "Number of tickets must be between 1 and 10." |
| `IsBlank(.TheatreLocation)` | "Theatre Location is required." |

### `ValidateSeatAvailability`
| Rule | Error Message |
| :--- | :--- |
| `.SeatAvailabilityStatus == "Houseful"` | "This show is currently houseful. Please select a different show." |
| `.AvailableSeatsCount < .NumberOfTickets` | "Only @{.AvailableSeatsCount} seat(s) available — cannot fulfill request for @{.NumberOfTickets} tickets." |

### `ValidateBookingDecision`
| Rule | Error Message |
| :--- | :--- |
| `IsBlank(.BookingStatus)` | "Please select Confirmed or Cancelled to proceed." |
| `.BookingStatus == "Cancelled" AND IsBlank(.CancellationReason)` | "Please provide a reason for cancellation." |

### `ValidateFulfillmentDetails`
| Rule | Error Message |
| :--- | :--- |
| `IsBlank(.TicketID)` | "Ticket ID is required." |
| `IsBlank(.SeatNumbers)` | "Assigned Seat Numbers are required." |
| `IsBlank(.BookingConfirmationStatus)` | "Booking Confirmation Status is required." |

---

## 7. Declare Expressions

**Navigation:** Dev Studio → **Create** → **Declare Expression** → Class: `CineWave-Work-MovieTicketRequest`

| Expression Rule | Target Property | Formula | Auto-Fires When |
| :--- | :--- | :--- | :--- |
| `CalcTotalCost` | `.TotalCost` | `.TicketPrice * .NumberOfTickets` | `.TicketPrice` or `.NumberOfTickets` changes |
| `CalcFinalCost` | `.FinalCost` | `.TotalCost * (1 - (.DiscountPercent / 100))` | `.TotalCost` or `.DiscountPercent` changes |

> ✅ Because these are Declare Expressions (not manual calculations), the customer will always see the updated `FinalCost` in real-time during the Review stage — even if a discount is applied later.

---

## 8. Decision Table — Work Queue Routing

**Navigation:** Dev Studio → **Create** → **Decision Table**
- **Rule Name:** `RouteByShowType`
- **Class:** `CineWave-Work-MovieTicketRequest`
- **Input Column:** `.ShowType`
- **Result Type:** Text

| `.ShowType` equals | Queue Result |
| :--- | :--- |
| `Standard` | `StandardShowQueue` |
| `Premium` | `PremiumShowQueue` |
| `IMAX` | `PremiumShowQueue` |
| `4DX` | `PremiumShowQueue` |
| *(Otherwise)* | `StandardShowQueue` |

---

## 9. Correspondence Rule Setup

**Navigation:** Dev Studio → **Create** → **Correspondence**
- **Rule Name:** `BookingConfirmationNotification`
- **Class:** `CineWave-Work-MovieTicketRequest`
- **Type:** Email

**Subject field:**
```
Movie Ticket Booking Confirmed - <pega:reference name=".pyID"/>
```

**From field:** `bookings@cinewave.com`

**Body:** Paste the contents of `CORRESPONDENCE_TEMPLATE.html`, replacing all `[PropertyName]` tokens with Pega property references:

| Token in HTML | Pega Tag in Rule Editor |
| :--- | :--- |
| `[CustomerName]` | `<pega:reference name=".CustomerName"/>` |
| `[pyID]` | `<pega:reference name=".pyID"/>` |
| `[TicketID]` | `<pega:reference name=".TicketID"/>` |
| `[MovieName]` | `<pega:reference name=".MovieName"/>` |
| `[Genre]` | `<pega:reference name=".Genre"/>` |
| `[ShowDate]` | `<pega:reference name=".ShowDate" format="pxDate"/>` |
| `[ShowTime]` | `<pega:reference name=".ShowTime"/>` |
| `[ShowType]` | `<pega:reference name=".ShowType"/>` |
| `[TheatreLocation]` | `<pega:reference name=".TheatreLocation"/>` |
| `[ScreenNumber]` | `<pega:reference name=".ScreenNumber"/>` |
| `[NumberOfTickets]` | `<pega:reference name=".NumberOfTickets"/>` |
| `[SeatNumbers]` | `<pega:reference name=".SeatNumbers"/>` |
| `[TicketPrice]` | `<pega:reference name=".TicketPrice" format="pxCurrency"/>` |
| `[FinalCost]` | `<pega:reference name=".FinalCost" format="pxCurrency"/>` |
| `[Currency]` | `<pega:reference name=".Currency"/>` |

---

## 10. Access Groups, Personas & Portals

### Access Groups
| Access Group | Roles | Portal |
| :--- | :--- | :--- |
| `CineWave:Customer` | Customer | Customer Cosmos Portal |
| `CineWave:Staff` | BookingAgent, FulfillmentStaff, Administrator | Staff Cosmos Portal |

**Navigation:** Dev Studio → **Org & Security** → **Access Groups** → Create each.

### Portals
- **Customer Portal (`CineWave-Portal-CustomerPortal`):** Cosmos React. Allows customers to submit cases, track status, and view correspondence.
- **Staff Portal (`CineWave-Portal-StaffPortal`):** Cosmos React. Includes workbasket management, case search, case processing views.

---

## 11. Error Handling & Edge Cases

| Scenario | Handling |
| :--- | :--- |
| Customer submits a Show Date in the past | `ValidateBookingDetails` blocks submission with clear error |
| All seats are taken (Houseful) | `ValidateSeatAvailability` blocks availability step, prompts agent to contact customer |
| Customer requests more tickets than available | Validation error shows exact count available |
| Customer cancels in Approval stage | Case transitions to `Resolved-Cancelled` + cancellation email sent |
| Ticket pricing not set (blank `TicketPrice`) | `SetTicketPricingDT` runs before Declare Expressions; if ShowType is unrecognized, `TicketPrice` stays 0 and CalcTotalCost = 0 — reviewer can spot the anomaly |
| SLA Goal exceeded | Urgency auto-increases +20; agent notified |
| SLA Deadline exceeded | Urgency auto-increases +30; supervisor notified |
| Fulfillment staff leaves `SeatNumbers` blank | `ValidateFulfillmentDetails` blocks submission |

---

## 12. Verification & Testing Checklist

- [ ] Create a new case as Customer persona — verify all required field validations fire.
- [ ] Enter a past date for ShowDate — verify validation blocks progression.
- [ ] Enter `NumberOfTickets = 0` or `11` — verify min/max validation fires.
- [ ] Complete Initial Stage — verify `InitializeCaseDefaults` data transform sets defaults.
- [ ] As BookingAgent, enter `AvailableSeatsCount < NumberOfTickets` — verify hard stop.
- [ ] Set `SeatAvailabilityStatus = Houseful` — verify hard stop.
- [ ] Complete Availability Stage — verify `TicketPrice` is set correctly for each ShowType:
  - Standard → $12.00
  - Premium → $20.00
  - IMAX → $28.00
  - 4DX → $35.00
- [ ] Verify `TotalCost` and `FinalCost` calculate automatically (Declare Expressions).
- [ ] As Customer, cancel booking — verify case resolves as `Resolved-Cancelled` + cancellation email fires.
- [ ] As Customer, confirm booking — verify case routes to Booking Execution.
- [ ] Verify `Standard` show routes to `StandardShowQueue`.
- [ ] Verify `Premium`, `IMAX`, `4DX` route to `PremiumShowQueue`.
- [ ] Verify `TicketID` auto-generates with correct format: `TKT-MTR-XXXX-YYYYMMDD`.
- [ ] Complete fulfillment — verify confirmation email dispatched with all dynamic fields.
- [ ] Verify case status changes to `Resolved-Completed`.
- [ ] Simulate SLA by advancing urgency — verify urgency increment fires on Goal and Deadline.
