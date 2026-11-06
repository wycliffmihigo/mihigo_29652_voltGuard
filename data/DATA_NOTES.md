# Data notes

## Real data
- **UCI Individual Household Electric Power Consumption** (Hebrail & Berard, 2012): 2,075,259 minute-level
  rows, 9 attributes (Date, Time, Global_active_power, Global_reactive_power, Voltage, Global_intensity,
  Sub_metering_1, Sub_metering_2, Sub_metering_3), December 2006 to November 2010, one household in Sceaux,
  France. About 1.25% of rows have missing measurements. Licence: CC BY 4.0.
  DOI: https://doi.org/10.24432/C58K54
- The raw file is larger than GitHub's 100 MB limit, so it is not stored in this repository. A small sample
  (the first 500 rows) will be stored as `data/sample_uci_power.csv`.
- **RURA tariffs:** the 2020 board decision (effective 21 January 2020) and the October 2025 public notice
  (effective 1 October 2025) are entered into TARIFF_VERSION and TARIFF_BAND from the official PDFs. Prices
  exclude VAT and the regulatory fee, so bills show the energy charge before VAT.

## Simulated data
- CUSTOMER, METER, DISTRICT assignment and billing periods are simulated and labelled as such.
- Monthly consumption is derived from UCI daily energy (kWh per minute = Global_active_power / 60, summed per
  day) and scaled to match published Rwandan averages of about 22 kWh per month (Mugyenyi et al.). The exact
  scaling factor will be recorded here when the data is loaded.

## Limitations
The UCI household is French, so it provides a real consumption pattern, not Rwandan usage.

