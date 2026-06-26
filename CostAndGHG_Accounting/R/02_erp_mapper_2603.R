# =============================================================================
# 02_erp_mapper_2603.R
# Maps ERP data (BOM, ROUTING, MAT) to unified ITEM namespace
# =============================================================================

mapERPtoITEM <- function(ITEM.tbl, BOM.erp, ROUTING.erp, MAT.erp) {

  # Helper: lookup itemID from erpCat + erpID
  lookupItemID <- function(erpCat, erpID) {
    match_row <- ITEM.tbl |> filter(.data$erpCat == .env$erpCat, .data$erpID == .env$erpID)
    if (nrow(match_row) == 1) return(match_row$itemID)
    return(NA_integer_)
  }

  # --- BOM.tbl ---
  BOM.tbl <<- BOM.erp |>
    rowwise() |>
    mutate(
      parItemID   = lookupItemID(parCat, parID),
      childItemID = lookupItemID(childCat, childID)
    ) |>
    ungroup() |>
    select(bomID, parItemID, childItemID, rM)

  # --- ROUTING.tbl ---
  ROUTING.tbl <<- ROUTING.erp |>
    rowwise() |>
    mutate(
      itemID = lookupItemID(semFinCat, semFinID)
    ) |>
    ungroup() |>
    select(routeID, itemID, actyID, rE, eqipID, powE)

  # --- MAT.tbl ---
  MAT.tbl <<- MAT.erp |>
    rowwise() |>
    mutate(
      itemID = lookupItemID("mat", matID)
    ) |>
    ungroup() |>
    select(itemID, pM, uMEL)
}
