# Normalisation: from the raw UCI file to 3NF

Raw file: `data/raw/individual+household+electric+power+consumption.zip` (file inside: `household_power_consumption.txt`, 2,075,259 rows, 9 columns, fields separated by semicolons). All rows below are copied from that file.

## Task 3: Entities

The raw file describes one household in one flat table. Looking for repeated values and values that describe something other than one measurement gives these entities:

| Entity | Where it comes from | Why it is separate |
|---|---|---|
| POWER_READING | Raw: Date, Time, Global_active_power, Global_reactive_power, Voltage, Global_intensity | One measurement per minute |
| CIRCUIT | Raw: the three Sub_metering columns | The same measurement is repeated in three columns (repeating group), and each circuit has its own name and appliances |
| CIRCUIT_READING | Raw: values of Sub_metering_1 to 3 | **Junction table**: a measurement has many circuits, and a circuit appears in many measurements |
| METER | Not in the raw file: every reading must belong to a meter | A reading needs an owner, and the billing process is built on meters |
| CUSTOMER, DISTRICT, CUSTOMER_CATEGORY | Not in the raw file (simulated) | A meter belongs to a customer, a customer lives in a district and has a category |
| METER_READING | Derived from the raw minute data (sum of Global_active_power / 60) | The cumulative reading used for billing and for the tamper rule |
| TARIFF_VERSION, TARIFF_BAND | RURA documents (2020 and 2025) | Prices change by date, so versions and bands are separate; TARIFF_BAND is a **junction table** between versions and categories |
| BILL, TAMPER_EVENT, AUDIT_LOG | Produced by the system | Results of billing, rejected readings and the change log |

That is 13 related tables. The raw file feeds three of them directly. The other tables come from the business process (Phase I) and from the RURA documents.

## Task 4: Normal forms

### UNF (unnormalised form)
One row of the raw file is one minute. The three `Sub_metering` columns hold the same kind of value (energy of a circuit) repeated across columns: that is a **repeating group**.

`HOUSEHOLD_POWER(Date, Time, Global_active_power, Global_reactive_power, Voltage, Global_intensity, Sub_metering_1, Sub_metering_2, Sub_metering_3)`, identified by (Date, Time).

| Date | Time | Global_active_power | Global_reactive_power | Voltage | Global_intensity | Sub_metering_1 | Sub_metering_2 | Sub_metering_3 |
|---|---|---|---|---|---|---|---|---|
| 16/12/2006 | 17:24:00 | 4.216 | 0.418 | 234.840 | 18.400 | 0.000 | 1.000 | 17.000 |
| 16/12/2006 | 17:25:00 | 5.360 | 0.436 | 233.630 | 23.000 | 0.000 | 1.000 | 16.000 |
| 16/12/2006 | 17:26:00 | 5.374 | 0.498 | 233.290 | 23.000 | 0.000 | 2.000 | 17.000 |
| 16/12/2006 | 17:27:00 | 5.388 | 0.502 | 233.740 | 23.000 | 0.000 | 1.000 | 17.000 |
| 21/12/2006 | 11:23:00 | ? | ? | ? | ? | ? | ? | *(empty)* |

The last row shows a minute with missing values (written as `?`). It is not fixed now; cleaning is planned for Phase IV.

### 1NF: remove the repeating group
**Dependency removed: repeating group** (Sub_metering_1, Sub_metering_2 and Sub_metering_3 are one attribute repeated in three columns). Each reading now has one row per circuit, so every column holds a single value. The key becomes (Date, Time, Circuit_no).

`HOUSEHOLD_POWER_1NF(Date, Time, Circuit_no, Energy_wh, Global_active_power, Global_reactive_power, Voltage, Global_intensity)`

| Date | Time | Circuit_no | Energy_wh | Global_active_power | Global_reactive_power | Voltage | Global_intensity |
|---|---|---|---|---|---|---|---|
| 16/12/2006 | 17:24:00 | 1 | 0.000 | 4.216 | 0.418 | 234.840 | 18.400 |
| 16/12/2006 | 17:24:00 | 2 | 1.000 | 4.216 | 0.418 | 234.840 | 18.400 |
| 16/12/2006 | 17:24:00 | 3 | 17.000 | 4.216 | 0.418 | 234.840 | 18.400 |
| 16/12/2006 | 17:25:00 | 1 | 0.000 | 5.360 | 0.436 | 233.630 | 23.000 |
| 16/12/2006 | 17:25:00 | 2 | 1.000 | 5.360 | 0.436 | 233.630 | 23.000 |

The whole-house values (4.216, 0.418, 234.840, 18.400) are now repeated on each circuit row. That repetition is what 2NF removes.

### 2NF: remove partial dependencies
**Dependency removed: partial dependency.** Global_active_power, Global_reactive_power, Voltage and Global_intensity depend only on (Date, Time), which is part of the key, not on Circuit_no. They move to POWER_READING. Energy_wh depends on the whole key (Date, Time, Circuit_no), so it stays in CIRCUIT_READING.

`POWER_READING(Date, Time, Global_active_power, Global_reactive_power, Voltage, Global_intensity)`

| Date | Time | Global_active_power | Global_reactive_power | Voltage | Global_intensity |
|---|---|---|---|---|---|
| 16/12/2006 | 17:24:00 | 4.216 | 0.418 | 234.840 | 18.400 |
| 16/12/2006 | 17:25:00 | 5.360 | 0.436 | 233.630 | 23.000 |
| 16/12/2006 | 17:26:00 | 5.374 | 0.498 | 233.290 | 23.000 |

`CIRCUIT_READING(Date, Time, Circuit_no, Energy_wh)`

| Date | Time | Circuit_no | Energy_wh |
|---|---|---|---|
| 16/12/2006 | 17:24:00 | 1 | 0.000 |
| 16/12/2006 | 17:24:00 | 2 | 1.000 |
| 16/12/2006 | 17:24:00 | 3 | 17.000 |
| 16/12/2006 | 17:25:00 | 1 | 0.000 |

### 3NF: remove transitive dependencies
**Dependency removed: transitive dependency.** A circuit's name and appliances depend on Circuit_no, not on the reading: reading → Circuit_no → circuit name. They move to CIRCUIT. The dataset description names the circuits: 1 is the kitchen, 2 the laundry room, 3 the electric water heater and air conditioner.

`CIRCUIT(circuit_id, circuit_name, appliances)`

| circuit_id | circuit_name | appliances |
|---|---|---|
| 1 | Kitchen | Dishwasher, oven, microwave |
| 2 | Laundry | Washing machine, tumble dryer, refrigerator, light |
| 3 | Water heater and air conditioner | Electric water heater, air conditioner |

Two more changes are needed to make the keys correct:
- Date and Time are combined into one `reading_ts`, and each reading gets a `power_reading_id`. Every reading also belongs to a `meter_id`. The raw file has no meter column, so the meter is assigned when the data is loaded in Phase IV.
- CIRCUIT_READING's key becomes (power_reading_id, circuit_id).

Final raw-derived tables, with the same real rows (the meter is simulated, so `meter_id = 1` is assigned):

`POWER_READING(power_reading_id, meter_id, reading_ts, active_power_kw, reactive_power_kvar, voltage_v, intensity_a)`

| power_reading_id | meter_id | reading_ts | active_power_kw | reactive_power_kvar | voltage_v | intensity_a |
|---|---|---|---|---|---|---|
| 1 | 1 | 16/12/2006 17:24:00 | 4.216 | 0.418 | 234.840 | 18.400 |
| 2 | 1 | 16/12/2006 17:25:00 | 5.360 | 0.436 | 233.630 | 23.000 |
| 3 | 1 | 16/12/2006 17:26:00 | 5.374 | 0.498 | 233.290 | 23.000 |

`CIRCUIT_READING(power_reading_id, circuit_id, energy_wh)`

| power_reading_id | circuit_id | energy_wh |
|---|---|---|
| 1 | 1 | 0.000 |
| 1 | 2 | 1.000 |
| 1 | 3 | 17.000 |
| 2 | 1 | 0.000 |

### 3NF for the tables that do not come from the raw file
A flat billing record would repeat district and category on every meter, and those depend on the customer, not the meter (meter → customer → district and category). So CUSTOMER, DISTRICT and CUSTOMER_CATEGORY are separate. These rows are **simulated** and only illustrate the split:

| customer_id | customer_name | district | category |
|---|---|---|---|
| 1 | Simulated customer A | Gasabo | Residential |
| 2 | Simulated customer B | Nyarugenge | Residential |

Tariff prices depend on the tariff version, the category and the band, not on the bill, so they sit in TARIFF_VERSION and TARIFF_BAND (**real**, from the RURA documents, residential category):

| Version | effective_from | band_min_kwh | band_max_kwh | rate_per_kwh (RWF, VAT excluded) |
|---|---|---|---|---|
| 2025 notice | 1 October 2025 | 0 | 20 | 89 |
| 2025 notice | 1 October 2025 | 20 | 50 | 310 |
| 2025 notice | 1 October 2025 | 50 | *(none)* | 369 |
| 2020 decision | 21 January 2020 | 0 | 15 | 89 |
| 2020 decision | 21 January 2020 | 15 | 50 | 212 |

## Task 5: Mapping of every raw field

| Raw field | Target table.column | Type conversion needed in Phase IV |
|---|---|---|
| Date | POWER_READING.reading_ts (date part) | Text `dd/mm/yyyy` to a date |
| Time | POWER_READING.reading_ts (time part) | Text `hh:mm:ss` combined with the date into one date-time |
| Global_active_power | POWER_READING.active_power_kw | Text to number; `?` becomes empty (25,979 rows). Also feeds METER_READING.kwh_value (kWh = value / 60 for each minute, summed) |
| Global_reactive_power | POWER_READING.reactive_power_kvar | Text to number; `?` becomes empty |
| Voltage | POWER_READING.voltage_v | Text to number; `?` becomes empty |
| Global_intensity | POWER_READING.intensity_a | Text to number; `?` becomes empty |
| Sub_metering_1 | CIRCUIT_READING.energy_wh, with circuit_id = 1 | Text to number; `?` becomes empty; one row per reading and circuit |
| Sub_metering_2 | CIRCUIT_READING.energy_wh, with circuit_id = 2 | Same as above |
| Sub_metering_3 | CIRCUIT_READING.energy_wh, with circuit_id = 3 | Same as above; missing values are empty fields, not `?` |

No raw field is dropped. Values that are **not** in the raw file and are added when loading:
- `meter_id` on POWER_READING: the loader assigns a simulated meter.
- `power_reading_id`: a generated key.
- `circuit_id` values 1 to 3: set by the column position.

Tables with no raw field (DISTRICT, CUSTOMER, CUSTOMER_CATEGORY, METER, TARIFF_VERSION, TARIFF_BAND, BILL, TAMPER_EVENT, AUDIT_LOG) are filled from simulated data, the RURA documents, or by the system.

## In-class demonstration: where one record goes
Record: `16/12/2006;17:24:00;4.216;0.418;234.840;18.400;0.000;1.000;17.000`

| Value in the record | Ends up in |
|---|---|
| 16/12/2006 and 17:24:00 | POWER_READING.reading_ts |
| 4.216 | POWER_READING.active_power_kw (and 4.216 / 60 kWh feeds METER_READING.kwh_value) |
| 0.418 | POWER_READING.reactive_power_kvar |
| 234.840 | POWER_READING.voltage_v |
| 18.400 | POWER_READING.intensity_a |
| 0.000 | CIRCUIT_READING row for circuit 1 (kitchen) |
| 1.000 | CIRCUIT_READING row for circuit 2 (laundry) |
| 17.000 | CIRCUIT_READING row for circuit 3 (water heater and air conditioner) |
