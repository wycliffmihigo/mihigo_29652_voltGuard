# Dataset card: UCI Individual Household Electric Power Consumption

## Source and licence
| Item | Detail |
|---|---|
| Name | Individual Household Electric Power Consumption |
| Creators | Georges Hebrail and Alice Berard (2012) |
| Source link | https://archive.ics.uci.edu/dataset/235/individual+household+electric+power+consumption |
| DOI | https://doi.org/10.24432/C58K54 |
| Licence | Creative Commons Attribution 4.0 International (CC BY 4.0): sharing and adaptation allowed for any purpose, with credit |
| Date collected | 17 November 2026 (downloaded from the UCI page) |

## Format and size
| Item | Detail |
|---|---|
| File stored in the repository | `data/raw/individual+household+electric+power+consumption.zip`, exactly as downloaded and never edited |
| Size of the zip | 20,640,916 bytes (about 19.7 MiB) |
| File inside the zip | `household_power_consumption.txt`, a text file with fields separated by semicolons and a header row |
| Size of the extracted file | 132,960,755 bytes (about 127 MiB) |
| Records | 2,075,259 data rows, 9 columns |
| Period covered | 16/12/2006 17:24:00 to 26/11/2010 21:02:00 |

The raw file is stored as a zip because the extracted file is larger than GitHub's upload limits. The zip is the original download. A small sample of the extracted file is in `data/sample_uci_power.csv`.

## What one record represents
One record is the electrical measurements of a single household in Sceaux, France (near Paris) for one minute.

## Personal data
None. The dataset describes one household and contains only electrical measurements (date, time, power, voltage, current and sub-metering). No names, phone numbers or ID numbers appear, so no anonymisation was needed.

## Columns
| Column | Meaning | Unit |
|---|---|---|
| Date | Day of the measurement, written dd/mm/yyyy | text |
| Time | Minute of the measurement, written hh:mm:ss | text |
| Global_active_power | Household active power, averaged over the minute | kilowatts |
| Global_reactive_power | Household reactive power, averaged over the minute | kilovolt-amperes reactive |
| Voltage | Average voltage | volts |
| Global_intensity | Average current | amperes |
| Sub_metering_1 | Energy used by the kitchen circuit (dishwasher, oven, microwave) | watt-hours |
| Sub_metering_2 | Energy used by the laundry room (washing machine, tumble dryer, refrigerator, light) | watt-hours |
| Sub_metering_3 | Energy used by an electric water heater and an air conditioner | watt-hours |

## Data quality results (counts)
Checked with a read-only script on the extracted file. Nothing was changed or fixed; cleaning is planned for Phase IV.

| Check | Result |
|---|---|
| Total data rows | 2,075,259 |
| Rows with at least one missing value | 25,979 (1.25%) |
| Missing values per measurement column | 25,979 in each of the 7 columns, because a row with a missing value is missing all 7 together |
| Separate stretches of consecutive rows with missing values | 71 |
| How missing values are written | `?` in six columns; an empty field in Sub_metering_3 (25,979 rows) |
| Exact duplicate rows | 0 |
| Duplicate date and time combinations | 0 |
| Rows with a wrong number of fields | 0 |
| Dates or times that cannot be read | 0 |
| Gaps in the minute-by-minute sequence | 0 (no minute is absent between the first and last record) |
| Rows out of time order | 0 |

Other findings that affect the design:
- Date and Time are stored as separate text columns in the format dd/mm/yyyy and hh:mm:ss, so they need converting to a date and time.
- Every measurement column is read as text because of the `?` marker, so each needs converting to a number.
- The file has no ID column. A reading is identified only by its date and time.
- Sub_metering columns are in watt-hours while the other power columns are in kilowatts, so units differ.
- Value ranges seen: Global_active_power 0.076 to 11.122; Voltage 223.2 to 254.15; Sub_metering_1 0 to 88; Sub_metering_2 0 to 80; Sub_metering_3 0 to 31.

## Credit
Hebrail, G., & Berard, A. (2012). *Individual household electric power consumption* [Data set]. UCI Machine Learning Repository. https://doi.org/10.24432/C58K54
