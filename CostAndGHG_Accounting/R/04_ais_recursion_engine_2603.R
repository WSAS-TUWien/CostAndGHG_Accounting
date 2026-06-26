# =============================================================================
# 04_ais_recursion_engine_2603.R
# AIS Recursion Engine: recursive cost & GHG calculation over the PIS graph
# =============================================================================

# Recursive calculation for a single node
calcNodeAccData <- function(nodeID, PIS.tbl, ITEM.tbl, MAT.tbl) {

  node <- PIS.tbl |> filter(.data$nodeID == !!nodeID)
  if (nrow(node) == 0) return(NULL)

  matList  <- node$matList[[1]]
  eqipList <- node$eqipList[[1]]
  rE       <- node$rE
  pA       <- node$pA
  powE     <- node$powE

  comps <- list()
  comp_idx <- 0

  # --- Materials (direct cost, Scope 3 GHG) ---
  for (j in seq_len(nrow(matList))) {
    mat <- matList[j, ]
    matCost <- mat$pM * mat$rM
    matGHG  <- mat$uMEL * mat$rM
    itemInfo <- ITEM.tbl |> filter(.data$itemID == mat$itemID)
    comp_idx <- comp_idx + 1
    comps[[comp_idx]] <- tibble(
      compType = "material",
      compName = itemInfo$itemName,
      compCost = matCost,
      compGHG  = matGHG,
      costCat  = "direct",
      scopeCat = 3
    )
  }

  # --- Activity (indirect cost, no GHG) ---
  actyCost <- pA * rE
  comp_idx <- comp_idx + 1
  comps[[comp_idx]] <- tibble(
    compType = "activity",
    compName = node$actyName,
    compCost = actyCost,
    compGHG  = 0,
    costCat  = "indirect",
    scopeCat = NA_real_
  )

  # --- Equipment (indirect cost, Scope 3 GHG for embodied) ---
  for (k in seq_len(nrow(eqipList))) {
    eq <- eqipList[k, ]
    eqCost <- eq$qE * rE
    eqGHG  <- eq$cuEEL * rE
    comp_idx <- comp_idx + 1
    comps[[comp_idx]] <- tibble(
      compType = "equipment",
      compName = eq$eqipName,
      compCost = eqCost,
      compGHG  = eqGHG,
      costCat  = "indirect",
      scopeCat = 3
    )

    # --- Energy (indirect cost, Scope 1 or 2 GHG) ---
    enCost <- eq$cuEEL * rE
    enGHG  <- powE * rE * eq$emE
    comp_idx <- comp_idx + 1
    comps[[comp_idx]] <- tibble(
      compType = "energy",
      compName = eq$enyName,
      compCost = enCost,
      compGHG  = enGHG,
      costCat  = "indirect",
      scopeCat = eq$scopeCat
    )
  }

  nodeCompsList <- bind_rows(comps)
  nodePC  <- sum(nodeCompsList$compCost)
  nodePCF <- sum(nodeCompsList$compGHG)

  # --- Recursive: process children ---
  chilNodeIDs <- node$chilNodeIDs[[1]]
  childResults <- list()
  if (length(chilNodeIDs) > 0) {
    for (cid in chilNodeIDs) {
      cr <- calcNodeAccData(cid, PIS.tbl, ITEM.tbl, MAT.tbl)
      if (!is.null(cr)) childResults <- c(childResults, list(cr))
    }
  }

  # Aggregate
  totalPC  <- nodePC  + sum(vapply(childResults, function(x) x$PC, numeric(1)))
  totalPCF <- nodePCF + sum(vapply(childResults, function(x) x$PCF, numeric(1)))

  # nodeTotalsList
  nodeTotalsList <- tibble(nodeID = nodeID, nodePC = nodePC, nodePCF = nodePCF)
  for (cr in childResults) {
    nodeTotalsList <- bind_rows(nodeTotalsList, cr$nodeTotalsList)
  }

  # Aggregate all component details
  allComps <- nodeCompsList
  for (cr in childResults) {
    allComps <- bind_rows(allComps, cr$nodeCompsList)
  }

  return(list(
    nodeID         = nodeID,
    PC             = totalPC,
    PCF            = totalPCF,
    nodeCompsList  = allComps,
    nodeTotalsList = nodeTotalsList
  ))
}

# Multi-item wrapper
buildMultiItemAccData <- function(nodeIDs, PIS.tbl, ITEM.tbl, MAT.tbl) {

  results <- list()
  for (nid in nodeIDs) {
    res <- calcNodeAccData(nid, PIS.tbl, ITEM.tbl, MAT.tbl)
    if (!is.null(res)) {
      results <- c(results, list(tibble(
        nodeID         = res$nodeID,
        PC             = res$PC,
        PCF            = res$PCF,
        nodeCompsList  = list(res$nodeCompsList),
        nodeTotalsList = list(res$nodeTotalsList)
      )))
    }
  }

  AIS.tbl <- bind_rows(results)
  return(AIS.tbl)
}
