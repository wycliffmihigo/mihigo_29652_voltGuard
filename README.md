# VoltGuard Rwanda: Electricity Billing and Meter Tamper Monitor

**Student:** Mihigo Wycliff | **Student ID:** 29652
**Course:** INSY 8311, Database Development with PL/SQL | **Instructor:** Eric Maniraguha
**Repository:** https://github.com/wycliffmihigo/mihigo_29652_voltGuard

## Problem statement
A utility must apply the correct tariff to every meter reading, and tariffs change: the Rwanda Utilities Regulatory Authority
(RURA) revised the electricity end-user tariff with effect from 1 October 2025. Faulty or manipulated readings and billing errors are a
recognised source of lost revenue, called non-technical losses (Glauner et al., 2016). Without rules inside the
database, a reading lower than the previous one, or a bill calculated with an outdated tariff, can pass unnoticed.
Public information shows how customers buy prepaid electricity, but not how readings are validated and audited.
VoltGuard models that part: reading validation, tariff-accurate billing and an audit trail.

## Objectives
**Main objective:** build an Oracle PL/SQL database that bills meter readings with the correct versioned tariff and
rejects and logs suspicious readings.

**Specific objectives**
1. Normalise real consumption data and the RURA tariff documents into 3NF tables.
2. Store tariffs by effective date and bill each reading with the tariff version valid on that date.
3. Reject any reading lower than the previous one and log the attempt.
4. Audit every change to readings, bills and tariffs, and restrict who may change tariffs.
5. Give staff and customers an easy app to enter readings, generate bills and look up a bill.

## Data source
- **Consumption data (real):** UCI Machine Learning Repository, *Individual Household Electric Power Consumption*
  (Hebrail & Berard, 2012). 2,075,259 measurements, 9 attributes, December 2006 to November 2010, one household in Sceaux, France,
  about 1.25% missing values. https://archive.ics.uci.edu/dataset/235/individual+household+electric+power+consumption
- **Tariffs (real):** RURA, *Electricity end-user tariff* public notice of 17 September 2025, effective 1 October 2025:
  https://www.rura.rw/fileadmin/user_upload/RURA/Documents/Tariffs/Public_Notice_on_Electricity_End_User_Tariff__October_2025_.pdf
  and the earlier RURA Board Decision N°01/BD/ER-EWS/RURA/2020, effective 21 January 2020 (the old tariff versions):
  https://www.rura.rw/fileadmin/user_upload/RURA/Documents/Tariffs/Board_Decision_on_Electricity_End_User_Tariffs_in_Rwanda.pdf
- **Simulated and labelled as such:** customers, meters, districts and billing periods. The UCI household is French,
  so its readings are used for the *shape* of consumption and scaled to Rwandan levels (about 22 kWh per month
  in 2019, Mugyenyi et al.). The scaling method is documented in `data/DATA_NOTES.md`.
- Licence: CC BY 4.0, confirmed on the UCI page on 6 Nov 2026. It allows sharing and adaptation for any purpose
  with credit, so educational use is allowed. Credit: Hebrail & Berard (2012), https://doi.org/10.24432/C58K54
- No personal data: one household, and the columns are electrical measurements only (date, time, power, voltage,
  intensity, sub-metering), so no person is identified 

## Innovation 
**Option:** User interface. **Tool:** Oracle APEX (fallback: Python Streamlit or Flask, both allowed by the brief).
Staff enter readings and generate bills; each action calls a PL/SQL procedure. A customer looks up a bill through an
ORDS REST endpoint. The rules stay in PL/SQL; the app only shows and uses the data.

## Planned tables
DISTRICT, CUSTOMER_CATEGORY, CUSTOMER, METER, METER_READING, TARIFF_VERSION, TARIFF_BAND, BILL, TAMPER_EVENT,
AUDIT_LOG, plus STG_UCI_POWER (staging table for the raw UCI file).

Main relationships: DISTRICT 1-N CUSTOMER; CUSTOMER_CATEGORY 1-N CUSTOMER; CUSTOMER 1-N METER;
METER 1-N METER_READING; TARIFF_VERSION 1-N TARIFF_BAND; CUSTOMER_CATEGORY 1-N TARIFF_BAND;
METER_READING 1-1 BILL (per billing period); TARIFF_VERSION 1-N BILL; METER 1-N TAMPER_EVENT.

## Planned PL/SQL features (and where each is used)
| Feature | Where it is used |
|---|---|
| Function `fn_energy_charge(category, kwh, date)` | Applies the bands of the tariff version valid on that date |
| Procedure `record_reading(meter, date, kwh)` | The only way readings enter the system; validates and inserts |
| Procedure `generate_bill(meter, period)` | Creates the monthly bill from two readings |
| Trigger on METER_READING | Rejects a reading lower than the previous one |
| Autonomous-transaction logging | Saves the rejected attempt in TAMPER_EVENT even though the insert is rolled back |
| Audit triggers | Record changes to readings, bills and tariffs in AUDIT_LOG |
| Restriction rule | Limits who and when tariffs can be changed (refined in Phase VI) |
| Cursor | Monthly consumption report per district and customers in the top band |
| Package `volt_pkg` | Groups the procedures and functions |
| Custom exceptions | Unknown meter, missing tariff, reading below previous |



