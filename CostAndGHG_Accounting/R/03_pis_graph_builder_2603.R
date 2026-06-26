# =============================================================================
# 03_pis_graph_builder_2603.R
# Builds the PIS Graph (Digital Twin) from mapped data
# =============================================================================

buildPIS <- function(ITEM.tbl, ROUTING.tbl, ACTY.erp, BOM.tbl, EQIP.erp, ENERGY.erp) {

  nodes <- list()

  for (i in seq_len(nrow(ROUTING.tbl))) {
    route  <- ROUTING.tbl[i, ]
    itemID <- route$itemID
    item   <- ITEM.tbl |> filter(.data$itemID == !!itemID)
    acty   <- ACTY.erp |> filter(actyID == route$actyID)
    eqip   <- EQIP.erp |> filter(eqipID == route$eqipID)
    energy <- ENERGY.erp |> filter(enyID == eqip$enyID)

    # Child node IDs: semi-finished children from BOM
    child_boms <- BOM.tbl |>
      filter(parItemID == itemID) |>
      inner_join(ITEM.tbl |> filter(itemCat == "intermediate"),
                 by = c("childItemID" = "itemID"))
    chilNodeIDs <- child_boms$childItemID

    # Material list
    mat_boms <- BOM.tbl |>
      filter(parItemID == itemID) |>
      inner_join(ITEM.tbl |> filter(itemCat == "material"),
                 by = c("childItemID" = "itemID"))

    matList <- mat_boms |>
      left_join(MAT.tbl, by = c("childItemID" = "itemID")) |>
      select(itemID = childItemID, rM, pM, uMEL)

    # Equipment list
    eqipList <- tibble(
      eqipID   = eqip$eqipID,
      eqipName = eqip$eqipName,
      qE       = eqip$qE,
      cuEEL    = eqip$cuEEL,
      enyID    = energy$enyID,
      enyName  = energy$enyName,
      emE      = energy$emE,
      scopeCat = energy$scopeCat
    )

    nodes[[i]] <- tibble(
      nodeID      = itemID,
      chilNodeIDs = list(chilNodeIDs),
      routeID     = route$routeID,
      itemID      = itemID,
      itemName    = item$itemName,
      itemCat     = item$itemCat,
      actyID      = acty$actyID,
      actyName    = acty$actyName,
      pA          = acty$pA,
      rE          = route$rE,
      powE        = route$powE,
      eqipList    = list(eqipList),
      matList     = list(matList)
    )
  }

  PIS.tbl <- bind_rows(nodes)
  return(PIS.tbl)
}
