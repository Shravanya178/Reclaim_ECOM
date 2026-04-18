# Experiment 10 Project Report
## ReClaim: Campus Circular Economy E-Commerce Platform
### Consolidated Report of Experiments 1 to 9

Institute: Vivekanand Education Society's Institute of Technology  
Department: Information Technology  
Course Context: E-Business Application Development  
Experiment: 10 (Comprehensive Project Report)  
Project Name: ReClaim  
Date: April 15, 2026  

Team Members:  
- Shravanya Andhale - Roll No. 30  
- Sanket Patil - Roll No. 37

---

## 1. Executive Summary

ReClaim is a full-stack e-commerce and resource-exchange platform built for academic campuses to operationalize circular economy principles. The platform enables students, labs, and administrators to list reusable materials, discover relevant items, request or purchase products, and track operational status in a centralized digital system.

Across Experiments 1 to 9, ReClaim progressed from problem definition and requirement engineering to a cloud-enabled, security-aware, business-driven implementation. The final system integrates commerce workflows, order and inventory control, payment orchestration, ERP-CRM-SCM intelligence dashboards, revenue tracking, and digital marketing support.

The completed project demonstrates:
- Multi-role architecture for Student, Lab/Department, and Admin personas
- End-to-end commerce journey (catalog -> cart -> checkout -> orders)
- Inventory and request lifecycle management with operational alerts
- Admin orchestrator with CRM, SCM, ERP, Revenue, Marketing, and Security views
- Firebase authentication with Google Sign-In and hardened validation controls
- Cloud-integrated backend with Supabase data services and web deployment readiness
- Landing page and simulation modules for business communication and engagement

---

## 2. Project Objective

To build a complete e-commerce and e-business platform for campus material reuse that combines commerce execution, operational governance, analytical intelligence, and secure cloud deployment.

### Core Objectives

1. Digital Commerce
- Material listing, product discovery, cart management, checkout, and order tracking.

2. Operational Excellence
- Inventory visibility, request processing, status transitions, and admin interventions.

3. Business Intelligence
- CRM, SCM, ERP, and revenue analytics for data-informed decision making.

4. Security and Risk Mitigation
- Robust authentication, validation, access control, and safe error handling.

5. Deployment Readiness
- Cloud-compatible architecture, scalable backend integration, and demonstrable web deployment.

---

## 3. Experiment-wise Consolidated Implementation (Exp 1 to Exp 9)

## Experiment 1
### Preparation of Project Proposal and Requirement Analysis

### Work Completed
- Identified core business gap: high volume of underutilized reusable campus materials.
- Defined ReClaim as a campus circular economy marketplace and exchange platform.
- Finalized stakeholders:
  - Students as buyers/requesters
  - Labs/departments as suppliers
  - Admin as governance and operations authority
- Documented system scope for listing, transaction traceability, workflow management, and analytics.

### Functional Requirements Finalized
- Role-based onboarding and dashboard routing
- Product catalog with search, filters, and category views
- Cart, checkout, and order management
- Request lifecycle creation and processing
- Inventory monitoring with low-stock signals
- Admin dashboards and event/notification capabilities

### Non-functional Requirements Finalized
- Responsive web/mobile user experience
- Secure authentication and protected sessions
- Scalable cloud-connected backend services
- Consistent data flow between auth and profile domains
- User-safe error feedback and reliability

---

## Experiment 2
### System Planning and Architecture Design of E-Commerce Application

### Architecture Vision
The system was designed as a layered, modular, and extensible architecture to isolate concerns and support future expansion.

### Architectural Layers
1. Presentation Layer (Flutter UI)
- Screens, widgets, reusable components, and role-specific dashboards.
- Responsive interaction patterns for web and mobile form factors.

2. Routing and Navigation Layer
- Declarative route orchestration using `go_router`.
- Controlled transitions for onboarding, commerce, requests, and admin modules.

3. State Management Layer
- Riverpod-based state providers for deterministic business state updates.
- Reduced UI-business coupling and improved testability of flows.

4. Domain and Service Layer
- Encapsulated modules under core and feature boundaries.
- Service abstractions for auth, payments, analytics, inventory, and orchestrator actions.

5. Data and Integration Layer
- Supabase-backed data persistence for entities such as users, products, orders, requests, inventory, and events.
- Firebase Auth integration for identity and federated sign-in.
- External payment integration via Razorpay hooks.

### Work Completed
- Defined modular codebase structure (`core`, `features`, `services`, `providers`).
- Planned entity-level data modeling for users, inventory, requests, and transactions.
- Designed process flows:
  - Onboarding -> role selection -> role-specific dashboard
  - Shop -> cart -> checkout -> order history
  - Request creation -> approval pipeline -> fulfillment
- Established integration points for analytics and business simulations.

### Technology Stack
- Frontend: Flutter
- State Management: Riverpod
- Backend/Data: Supabase
- Authentication: Firebase Auth + Google Sign-In
- Analytics/Visualization: fl_chart
- Payment: Razorpay
- Utilities: shared_preferences and secure storage services

---

## Experiment 3
### Design and Development of E-Commerce Website for Selected Product/Service

### Work Completed
- Built the commerce UI foundation:
  - Product catalog views
  - Rich product cards (stock, rating, category, condition)
  - Search, filter, and sorting controls
- Implemented role-aware onboarding and access flow.
- Developed cart engine:
  - Add/remove item operations
  - Quantity adjustment
  - Price computation
- Added product detail interactions with contextual material data.
- Optimized responsive behavior for desktop and mobile navigation.

### Key Screens Delivered
- Shop (`/shop`)
- Cart (`/cart`)
- Checkout (`/checkout`)
- Orders (`/orders`)
- Order Detail (`/order/:id`)
- Supporting role-based dashboard and discovery interfaces

---

## Experiment 4
### Implementation of Order Management and Basic Inventory System

### Work Completed
- Implemented order lifecycle control from checkout to order history and detailed tracking.
- Linked inventory intelligence into operational dashboards:
  - Current stock health
  - Low stock and out-of-stock warnings
  - Demand-supply gap indicators
- Added admin control panels for monitoring, intervention, and prioritization.
- Connected inventory state with product visibility and operational alerts.
- Integrated SCM simulation hooks for replenishment logic (push/pull models).

### Outputs Demonstrated
- Traceable order status transitions
- Inventory health metrics and actionable warnings
- Decision-support charts/cards for operations team

---

## Experiment 5
### Design and Implementation of Online Payment System

### Work Completed
- Implemented checkout workflow with payment service hooks.
- Integrated Razorpay transaction path for online payment processing.
- Linked transaction completion with order generation and status updates.
- Built billing summaries and payable amount calculations.
- Exposed transaction context in admin intelligence views for governance.

### Evidence in Implementation
- Checkout module supports payment initiation and order completion flow.
- Revenue-oriented data points are consumed by service-level analytics modules.

---

## Experiment 6
### Integration of ERP, CRM, SCM, and Revenue Concepts in E-Business Application

Experiment 6 is the business intelligence core of ReClaim. This phase transformed the platform from a transactional app into an integrated e-business decision system.

### 6.1 Business-Orchestrator Architecture

The Admin Orchestrator acts as a control tower, consolidating multiple business domains into one operational interface:
- CRM Domain: customer interactions, complaints, feedback quality
- SCM Domain: stock movement, replenishment strategy, demand-supply balancing
- ERP Domain: process synchronization across procurement, inventory, order execution, and reporting
- Revenue Domain: payment-derived performance indicators and business trend analysis
- Marketing Domain: campaign and engagement-driven impacts
- Security Domain: governance and risk-aware controls

This architecture follows an event-informed model where operational actions in one domain influence other modules through shared service/state layers.

### 6.2 CRM (Customer Relationship Management) Implementation

Implemented CRM capabilities include:
- Structured feedback and complaint intake from the home interface.
- Automated complaint categorization into operational buckets for triage.
- Live visibility of customer voice data in the Admin CRM panel.
- Complaint-to-action mapping, enabling administrators to execute corrective actions.

CRM Outcomes:
- Faster issue discovery and response loop closure.
- Quantified customer sentiment through categorized feedback.
- Higher operational transparency for service quality monitoring.

### 6.3 SCM (Supply Chain Management) Implementation

Implemented SCM capabilities include:
- Inventory health cards (available, low stock, out-of-stock, critical items).
- Demand-supply gap insight tables and trend surfaces.
- Simulation hooks for push, pull, and hybrid replenishment strategies.
- Stock-aware operational alerts that influence listing/availability behavior.

SCM Outcomes:
- Better replenishment planning support.
- Reduced mismatch between demand and available reusable materials.
- Actionable early-warning signals for supply risk.

### 6.4 ERP (Enterprise Resource Planning) Implementation

ERP integration in ReClaim connects business processes as one synchronized flow:
- Procurement/Listing -> inventory update -> order process -> transaction status -> reporting visibility.
- Centralized process monitoring through orchestrator sections and KPI cards.
- Cross-functional view for admin to supervise operations, service quality, and revenue movement.
- Lifecycle consistency through shared service modules and role-driven process states.

ERP Outcomes:
- Reduced process silos between commerce, operations, and analytics.
- Improved traceability of each transaction across functional stages.
- Stronger governance for end-to-end workflow monitoring.

### 6.5 Revenue Intelligence Implementation

Revenue-focused features include:
- Transaction-aware data capture from checkout/payment flow.
- Revenue-linked dashboard indicators in admin decision panels.
- Performance trend surfaces for evaluating business strategy effects.
- Integration with promotional actions (for example, discount controls from orchestrator) and observed shop-side behavior changes.

Revenue Outcomes:
- Better visibility into financial performance and conversion impacts.
- Measurement support for promotional and operational decisions.
- Practical business intelligence layer for academic e-business demonstration.

### 6.6 End-to-End Cross-Domain Enhancement Added

- Home page now includes structured complaint and feedback capture.
- Admin CRM view receives live complaint visibility.
- Orchestrator material-control actions produce real-time shop effects (example: discount impact).
- Customer voice is auto-classified into three operational categories for action planning.

### 6.7 Experiment 6 Significance

Experiment 6 establishes ReClaim as a true e-business platform by integrating customer insights, supply planning, enterprise process coordination, and revenue decision support into a single operational intelligence system.

---

## Experiment 7
### Risk Assessment and Security Implementation for E-Commerce Systems

### Work Completed
Security controls were implemented with production-oriented practices and documented in dedicated project artifacts.

### Major Security Implementations
- Firebase authentication integration
- Google OAuth Sign-In
- Strong password policy enforcement:
  - Minimum 12 characters
  - Uppercase, lowercase, digit, and special character checks
- Email validation aligned with RFC 5322 format rules
- Secure error handling with user-safe messaging
- Login protection through rate-limiting service
- Secure token storage and migration guidance

### Security Deliverables
- `SECURITY_FIXES.md`
- `FIREBASE_SETUP.md`
- `FIREBASE_IMPLEMENTATION_SUMMARY.md`
- Security service components under `lib/core/services/`

---

## Experiment 8
### Design of Digital Marketing and Landing Pages

### Work Completed
- Built dedicated landing portal in `landing/index.html`.
- Added clear value communication and conversion-oriented sections.
- Implemented interactive business simulation blocks for:
  - CRM lifecycle understanding
  - SCM strategy selection (push/pull/hybrid)
  - Revenue model estimation
- Included benchmarking and business messaging blocks for pitch readiness.

### Marketing Value Added
- Improved communication of business value to academic evaluators and stakeholders.
- Demonstration-ready narrative connecting platform features to measurable business outcomes.

---

## Experiment 9
### Deployment of E-Commerce Application on Cloud Platform

### Work Completed
- Integrated Firebase and Supabase into deployable cloud architecture.
- Linked Firebase project configuration and runtime initialization.
- Validated web execution workflow (`flutter run -d chrome` successful in environment).
- Deployed web-facing components for demonstration, including Vercel-based hosting path.
- Documented domain/CORS/authorized-domain setup steps in deployment checklists.

### Deployment Status
- Application is cloud-ready and demo-deployed.
- Final production hardening (policy tightening, key restrictions, domain governance) remains as environment-level completion work.

---

## 4. Features Delivered Across Experiments 1 to 9

1. Role-based onboarding and access-controlled navigation
2. Product catalog with filtering, sorting, and detail interactions
3. Cart, checkout, payment, and order tracking lifecycle
4. Inventory intelligence with SCM-driven monitoring dashboards
5. Razorpay-backed payment integration in checkout workflow
6. ERP, CRM, SCM, and revenue decision-support visual analytics
7. Security controls for authentication, validation, safe errors, and rate limiting
8. Marketing landing page with engagement and business simulation modules
9. Cloud-integrated architecture with Firebase/Supabase and web deployment readiness

---

## 5. Challenges Encountered and Resolution

1. Multi-service integration complexity (Flutter + Firebase + Supabase)
- Resolution: service abstraction, modular architecture, and strict routing/state boundaries.

2. Security hardening beyond prototype-level controls
- Resolution: validation service, secure error handling, rate limiting, and security documentation.

3. Business-domain synchronization (CRM/SCM/ERP/Revenue)
- Resolution: orchestrator-led shared state and cross-domain action pipelines.

4. Aligning simulation outcomes with operational UI behavior
- Resolution: linked orchestrator actions to live shop and dashboard updates.

5. Presentation readiness for technical and business evaluation
- Resolution: consolidated dashboards, KPI cards, and narrative-friendly visual modules.

---

## 6. Conclusion

ReClaim successfully achieved the targeted outcomes of Experiments 1 to 9 and now operates as a practical, scalable, and security-aware e-business platform for campus circular economy workflows.

Project-level achievements include:
- Fully functional e-commerce lifecycle implementation
- Integrated CRM, SCM, ERP, and revenue intelligence layer
- Secure authentication and risk mitigation framework
- Marketing and communication readiness for business demonstration
- Cloud-enabled architecture with deployment viability

This Experiment 10 report confirms that the project is academically review-ready with strong implementation depth, cross-domain integration maturity, and end-to-end demonstrable workflows.

---

## 7. Future Scope

1. Full production hardening of Firebase/Supabase policies, rules, and key restrictions
2. Advanced KPI export, audit dashboards, and periodic reporting automation
3. AI-driven recommendation engine for material-demand matching and personalization
4. Expanded invoicing, reconciliation, and payment automation features
5. CI/CD pipeline with automated testing, security scanning, and release governance
