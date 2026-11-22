# Data dictionary (logical design)

Oracle data types and sizes are left out on purpose; they are added in Phase IV.

Key: **PK** primary key, **FK** foreign key. "Required" means the value can never be empty. "Unique" means no two rows may repeat the value (or the combination shown).

## DISTRICT
A district of Rwanda where meters are installed.  
*Source of the data:* Simulated

| Column | Key | Meaning | Required | Unique |
|---|---|---|---|---|
| district_id | PK | Identifier of the district | Yes | Yes |
| district_name |  | Name of the district | Yes | Yes |

## CUSTOMER_CATEGORY
A customer category that decides which tariff bands apply (for example Residential).  
*Source of the data:* RURA tariff documents

| Column | Key | Meaning | Required | Unique |
|---|---|---|---|---|
| category_id | PK | Identifier of the category | Yes | Yes |
| category_name |  | Name of the category | Yes | Yes |

## CUSTOMER
A person or organisation that is billed. Names are simulated.  
*Source of the data:* Simulated

| Column | Key | Meaning | Required | Unique |
|---|---|---|---|---|
| customer_id | PK | Identifier of the customer | Yes | Yes |
| customer_name |  | Simulated customer name (no real person) | Yes | No |
| district_id | FK → DISTRICT | District where the customer lives | Yes | No |
| category_id | FK → CUSTOMER_CATEGORY | Category of the customer | Yes | No |

## METER
An electricity meter installed for one customer.  
*Source of the data:* Simulated

| Column | Key | Meaning | Required | Unique |
|---|---|---|---|---|
| meter_id | PK | Identifier of the meter | Yes | Yes |
| meter_number |  | Number printed on the meter | Yes | Yes |
| customer_id | FK → CUSTOMER | Customer who owns the connection | Yes | No |
| installed_date |  | Date the meter was installed | No | No |

## POWER_READING
One-minute electrical measurement of a meter. One row for each row of the raw UCI file.  
*Source of the data:* UCI raw file

| Column | Key | Meaning | Required | Unique |
|---|---|---|---|---|
| power_reading_id | PK | Identifier of the measurement | Yes | Yes |
| meter_id | FK → METER | Meter that was measured (assigned when loading, not in the raw file) | Yes | With reading_ts |
| reading_ts |  | Date and time of the minute (raw Date and Time combined) | Yes | With meter_id |
| active_power_kw |  | Household active power for the minute, in kilowatts (raw Global_active_power) | No (missing in 25,979 raw rows) | No |
| reactive_power_kvar |  | Reactive power for the minute (raw Global_reactive_power) | No (missing in 25,979 raw rows) | No |
| voltage_v |  | Average voltage in volts (raw Voltage) | No (missing in 25,979 raw rows) | No |
| intensity_a |  | Average current in amperes (raw Global_intensity) | No (missing in 25,979 raw rows) | No |

## CIRCUIT
A sub-metered part of the household (kitchen, laundry, water heater and air conditioner).  
*Source of the data:* UCI dataset description

| Column | Key | Meaning | Required | Unique |
|---|---|---|---|---|
| circuit_id | PK | Identifier of the circuit (1, 2 or 3, matching Sub_metering_1 to 3) | Yes | Yes |
| circuit_name |  | Name of the circuit | Yes | Yes |
| appliances |  | Appliances connected to the circuit | No | No |

## CIRCUIT_READING
Junction table: the energy of one circuit during one measurement minute.  
*Source of the data:* UCI raw file

| Column | Key | Meaning | Required | Unique |
|---|---|---|---|---|
| power_reading_id | PK, FK → POWER_READING | Measurement the value belongs to | Yes | With circuit_id |
| circuit_id | PK, FK → CIRCUIT | Circuit the value belongs to | Yes | With power_reading_id |
| energy_wh |  | Energy used by the circuit in the minute, in watt-hours (raw Sub_metering_1 to 3) | No (missing in 25,979 raw rows) | No |

## METER_READING
A cumulative meter reading taken for billing. Built from the minute data in Phase IV.  
*Source of the data:* Derived from UCI (sum of Global_active_power / 60)

| Column | Key | Meaning | Required | Unique |
|---|---|---|---|---|
| meter_reading_id | PK | Identifier of the reading | Yes | Yes |
| meter_id | FK → METER | Meter that was read | Yes | With reading_date |
| reading_date |  | Date of the reading | Yes | With meter_id |
| kwh_value |  | Cumulative energy shown by the meter, in kWh | Yes | No |

## TARIFF_VERSION
One official version of the tariff, valid from a date.  
*Source of the data:* RURA documents (2020 decision, 2025 notice)

| Column | Key | Meaning | Required | Unique |
|---|---|---|---|---|
| tariff_version_id | PK | Identifier of the version | Yes | Yes |
| effective_from |  | First date the version applies | Yes | Yes |
| effective_to |  | Last date the version applies (empty while it is current) | No | No |
| source_document |  | Name of the RURA document that set the version | Yes | No |

## TARIFF_BAND
Junction table: the price of one kWh band for one category in one tariff version.  
*Source of the data:* RURA documents

| Column | Key | Meaning | Required | Unique |
|---|---|---|---|---|
| tariff_band_id | PK | Identifier of the band | Yes | Yes |
| tariff_version_id | FK → TARIFF_VERSION | Version the band belongs to | Yes | With category and band_min_kwh |
| category_id | FK → CUSTOMER_CATEGORY | Category the band applies to | Yes | With version and band_min_kwh |
| band_min_kwh |  | Lower limit of the band, in kWh | Yes | With version and category |
| band_max_kwh |  | Upper limit of the band (empty for the last band) | No | No |
| rate_per_kwh |  | Price of one kWh in this band, in RWF, VAT excluded | Yes | No |

## BILL
The bill produced from one meter reading.  
*Source of the data:* Generated by the system

| Column | Key | Meaning | Required | Unique |
|---|---|---|---|---|
| bill_id | PK | Identifier of the bill | Yes | Yes |
| meter_reading_id | FK → METER_READING | Reading the bill is based on | Yes | Yes |
| tariff_version_id | FK → TARIFF_VERSION | Tariff version used to calculate the bill | Yes | No |
| consumption_kwh |  | Energy billed: this reading minus the previous reading | Yes | No |
| total_amount |  | Amount to pay in RWF, before VAT and the regulatory fee | Yes | No |
| issue_date |  | Date the bill was issued | Yes | No |

## TAMPER_EVENT
A rejected reading that was lower than the previous one.  
*Source of the data:* Generated by the system

| Column | Key | Meaning | Required | Unique |
|---|---|---|---|---|
| tamper_id | PK | Identifier of the event | Yes | Yes |
| meter_id | FK → METER | Meter the attempted reading was for | Yes | No |
| attempted_value |  | The rejected reading, in kWh | Yes | No |
| previous_value |  | The last accepted reading, in kWh | Yes | No |
| event_time |  | Date and time of the attempt | Yes | No |

## AUDIT_LOG
A record of every change to readings, bills and tariffs. It stands alone because it logs changes to all tables.  
*Source of the data:* Generated by the system

| Column | Key | Meaning | Required | Unique |
|---|---|---|---|---|
| audit_id | PK | Identifier of the log entry | Yes | Yes |
| table_name |  | Table that was changed | Yes | No |
| action |  | Insert, update or delete | Yes | No |
| changed_by |  | User who made the change | Yes | No |
| changed_at |  | Date and time of the change | Yes | No |
| details |  | Short description of what changed | No | No |
