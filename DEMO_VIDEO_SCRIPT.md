# Movie Ticket Booking Management Application — Video Demo Script
### National Internship Program — CineWave Entertainment | Pega Platform™
**Author / Presenter:** Harsh Maurya  
**Project Repository:** [https://github.com/Advik-harsha/Movie-Ticket-Booking-Management](https://github.com/Advik-harsha/Movie-Ticket-Booking-Management)  

---

## 📝 Demo Video Description Paragraph (For Portal Submission Box)

> "This video demonstration presents the end-to-end implementation of the **Movie Ticket Booking Management** application built on the **Pega Platform™** for **CineWave Entertainment**. The walkthrough begins with application scaffolding via **Pega Blueprint**, showcasing the complete case lifecycle of the **Movie Ticket Request** case type across five primary stages: Initial Stage, Availability, Approval, Booking Execution, and Resolution. We demonstrate the customer submitting a ticket booking request, real-time seat availability validation, automated dynamic cost calculation based on show types (Standard, Premium, IMAX, and 4DX), structured customer review and confirmation, intelligent work queue routing (`PremiumShowQueue` vs. `StandardShowQueue`), seat allocation with unique Ticket ID generation, case-level SLA urgency escalation (1-day Goal / 2-day Deadline), and automated HTML correspondence dispatch upon successful case resolution. The solution eliminates manual ticketing bottlenecks and establishes a scalable, automated enterprise booking workflow."

---

## 🎙️ Complete Video Recording Script (2 to 3 Minutes)

### [0:00 – 0:30] Introduction & Problem Statement
* **Screen Action:** Show the Pega App Studio Overview page with the application name *Movie Ticket Booking Management* and your GitHub repository.
* **Narration:**
  > *"Hello everyone and welcome. My name is Harsh Maurya, and today I am demonstrating the Movie Ticket Booking Management application built on Pega Platform for CineWave Entertainment. Previously, CineWave managed ticket bookings through manual offline channels, leading to tracking errors and processing delays. Our objective was to build an automated, enterprise-grade case management application that streamlines the entire customer booking journey—from initial request to automated email confirmation."*

---

### [0:30 – 1:15] Case Lifecycle & Architecture in App Studio
* **Screen Action:** Navigate to **Case Types $\rightarrow$ Movie Ticket Request** and show the clean Case Lifecycle chevron stages on screen.
* **Narration:**
  > *"Here in App Studio, we have designed the core case type: Movie Ticket Request. The case lifecycle is organized into structured stages:
  > 1. Initial Stage—to capture customer contact and movie preferences.
  > 2. Availability Stage—where staff verify seating availability and the system computes dynamic pricing.
  > 3. Approval Stage—where the customer reviews a structured summary and confirms or cancels.
  > 4. Booking Execution Stage—which automatically routes the booking to dedicated work queues based on show type, allocates seat numbers, and generates a unique Ticket ID.
  > 5. Resolution Stage—which resolves the case and triggers automated customer correspondence."*

---

### [1:15 – 2:00] Live Case Execution & Business Logic Demo
* **Screen Action:** Click **Save and Run** to launch a new case instance (e.g., `M-3` / `M-4`).
* **Narration:**
  > *"Let us execute a live booking request. In the Initial Stage, the customer provides their name, email, selects the movie 'Inception', picks the show date and time, chooses 'Premium' as the show type, and requests 2 tickets. 
  > Upon submission, the case advances to the Availability stage. Pega verifies that seats are available and uses a Declare Expression to dynamically calculate the total cost: 2 tickets at $20 equals $40. 
  > Next, in the Approval stage, the customer is presented with a read-only pricing breakdown and confirms the reservation."*

---

### [2:00 – 2:45] Queue Routing, Fulfillment & Automated Correspondence
* **Screen Action:** Advance to the **Booking Execution** stage, show seat assignment (`P1, P2`), Ticket ID generation, and show the HTML confirmation email layout.
* **Narration:**
  > *"Because this is a Premium show, the case automatically routes to the PremiumShowQueue for fulfillment staff. Staff assign the seat numbers—P1 and P2—and generate the unique Ticket ID. 
  > Furthermore, the case is governed by a Service Level Agreement with a 1-day Goal and 2-day Deadline with automated urgency escalation. 
  > Upon final submission, the case transitions to Resolved-Completed, and Pega dispatches a branded, responsive HTML confirmation email containing the dynamic Case ID, Ticket ID, show timing, seat numbers, and total cost directly to the customer's email."*

---

### [2:45 – 3:00] Conclusion & Project Deliverables
* **Screen Action:** Switch back to your GitHub repository showing all files (`README.md`, `.blueprint` file, implementation guide, and screenshots).
* **Narration:**
  > *"All 12 user stories, data models, blueprints, test matrices, and documentation have been fully implemented, verified, and published on GitHub. Thank you for your time!"*
