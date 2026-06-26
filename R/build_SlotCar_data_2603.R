# =============================================================================
# build_SlotCar_data_2603.R
# Manual Building of Input Data from ERP System
# Run this script to create SlotCar_2603.RData
# =============================================================================

library(tidyverse)

# Building input data by hand
MAT.erp <- tribble(
  ~matID, ~matName,                   ~pM,   ~uMEL,
  1,      "CoverRed",              29.00,   0.15,
  2,      "CoverBlue",             28.00,   0.10,
  3,      "Motor",                 10.00,   0.20,
  4,      "MotorMountingBracket",   0.12,   0.0006,
  5,      "CScrew_M2x6",            0.02,   0.05,
  6,      "UnderBody",              1.44,   0.0072,
  7,      "PowerSystem",            3.26,   0.06,
  8,      "WheelAssembly",         13.40,   0.766,
  9,      "WheelAssemblyDriven",   18.20,   1.10)

SEMI.erp <- tribble(
  ~spID, ~spName,
  50,    "DriveUnit",
  51,    "Chassis")

FINAL.erp <- tribble(
  ~fpID, ~fpName,
  100,   "SlotCarRed",
  101,   "SlotCarBlue")

BOM.erp <- tribble(
  ~bomID, ~parCat,  ~parID, ~childCat, ~childID, ~rM,
  1,      "semi",    50,    "mat",      3,        1,
  2,      "semi",    50,    "mat",      4,        1,
  3,      "semi",    50,    "mat",      5,        1,
  4,      "semi",    51,    "mat",      6,        1,
  5,      "semi",    51,    "mat",      7,        1,
  6,      "semi",    51,    "mat",      8,        1,
  7,      "semi",    51,    "mat",      9,        1,
  8,      "final",  100,    "mat",      1,        1,
  9,      "final",  100,    "mat",      5,        1,
  10,     "final",  100,    "semi",    50,        1,
  11,     "final",  100,    "semi",    51,        1,
  12,     "final",  101,    "mat",      2,        1,
  13,     "final",  101,    "mat",      5,        1,
  14,     "final",  101,    "semi",    50,        1,
  15,     "final",  101,    "semi",    51,        1)

ACTY.erp <- tribble(
  ~actyID, ~actyName,               ~pA,
  1,       "DriveUnitAssembly",      2,
  2,       "ChassisAssembly",        2,
  3,       "SlotCarAssembly",        2)

ENERGY.erp <- tribble(
  ~enyID, ~enyName,       ~emE,  ~scopeCat,
  1,      "Electricity",  0.069,  2,
  2,      "Gas",           0.069,  1)

EQIP.erp <- tribble(
  ~eqipID, ~eqipName,            ~qE,  ~cuEEL,   ~enyID,
  1,       "AssemblerElectric",  0.3,   0.00312,   1,
  2,       "AssemblerGas",       0.3,   0.00312,   2)

ROUTING.erp <- tribble(
  ~routeID, ~semFinCat, ~semFinID, ~actyID,  ~rE,   ~eqipID, ~powE,
  1,        "semi",      50,        1,        7.5,    2,       0.05,
  2,        "semi",      51,        2,       51.0,    1,       0.05,
  3,        "final",    100,        3,        1.5,    1,       0.05,
  4,        "final",    101,        3,        1.5,    1,       0.05)

# Save to RData
save(MAT.erp, SEMI.erp, FINAL.erp, BOM.erp, ACTY.erp,
     ENERGY.erp, EQIP.erp, ROUTING.erp,
     file = "SlotCar_2603.RData")

cat("SlotCar_2603.RData created successfully.\n")
