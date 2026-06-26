# =============================================================================
# 01_item_master_builder_2603.R
# Builds the unified Item Master (ITEM.tbl) from ERP master data
# =============================================================================

buildItemMaster <- function(MAT.erp, SEMI.erp, FINAL.erp) {

  # Finals (finished products)
  final_items <- tibble(
    erpID   = FINAL.erp$fpID,
    erpCat  = "final",
    itemName = FINAL.erp$fpName,
    itemCat  = "finished"
  )

  # Semis (intermediate products)
  semi_items <- tibble(
    erpID   = SEMI.erp$spID,
    erpCat  = "semi",
    itemName = SEMI.erp$spName,
    itemCat  = "intermediate"
  )

  # Materials
  mat_items <- tibble(
    erpID   = MAT.erp$matID,
    erpCat  = "mat",
    itemName = MAT.erp$matName,
    itemCat  = "material"
  )

  # Combine and assign sequential itemIDs
  ITEM.tbl <- bind_rows(final_items, semi_items, mat_items) |>
    mutate(itemID = row_number()) |>
    select(itemID, erpID, erpCat, itemName, itemCat)

  return(ITEM.tbl)
}
