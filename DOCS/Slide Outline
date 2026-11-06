# Slide outline: VoltGuard Rwanda (12 slides, per the Phase 0 brief)

1. **Title.** VoltGuard Rwanda: Electricity Billing and Meter Tamper Monitor. Your name and ID, INSY 8311, Eric Maniraguha, GitHub link.
2. **Background and problem.** Who is affected: utility and customers. RURA revised the tariff effective 1 Oct 2025 (band limits changed too); a wrong reading or outdated tariff gives a wrong bill; non-technical losses are a recognised problem (Glauner et al.).
3. **Motivation.** Your own reason for choosing it (write this yourself; it is graded as yours).
4. **Objectives.** One main objective and five specific ones (see README).
5. **Research.** Papers 1-2, REG Cash Power (existing system). Gap: public information does not show reading validation and audit rules.
6. **Data source.** UCI dataset (link, 2,075,259 rows, 9 attributes, CC BY 4.0, credit Hebrail & Berard 2012) and the RURA tariff documents (2020 and 2025). Paste 4-5 real sample rows from the file. State clearly what is simulated.
7. **Proposed solution and innovation.** Innovation option: **User interface**. Tool: **Oracle APEX** (staff enter readings, generate bills; customer bill lookup through ORDS REST). Rules stay in PL/SQL.
8. **Planned database.** Main tables and relationships (small ERD sketch): CUSTOMER, METER, METER_READING, TARIFF_VERSION, TARIFF_BAND, BILL, TAMPER_EVENT, AUDIT_LOG.
9. **PL/SQL approach (say where each is used).**
   - Trigger: rejects a reading lower than the previous one.
   - Autonomous transaction: still saves the rejected attempt in TAMPER_EVENT.
   - Function `fn_energy_charge`: bills by the tariff version valid on the reading date.
   - Procedure `generate_bill`: monthly bill from two readings.
   - Cursor: monthly consumption report per district.
   - Package `volt_pkg`: groups the code. Exceptions: unknown meter, missing tariff.
10. **Expected results.** Live demo: enter a reading, get the exact bill, submit a lower reading and watch it get refused and logged, look up a bill through the REST endpoint.
11. **Future improvements and limitations.** Customers and meters are simulated; the data is a French household; add time-of-use demand charges for industrial smart meters, usage-jump alerts, a dashboard.
12. **References (APA).** Copy only sources you have read from the research log.
