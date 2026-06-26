# =============================================================================
# 05_ais_analyzer_2603.R
# AIS Data Analysis: Comparison of Cost & GHG Structures + Plotting
# =============================================================================

buildMultiItemCatShareData <- function(nodeIDs, AIS.tbl) {

  rows <- list()
  idx <- 0

  for (nid in nodeIDs) {
    ais <- AIS.tbl |> filter(nodeID == nid)
    if (nrow(ais) == 0) next

    comps <- ais$nodeCompsList[[1]]

    # Cost shares
    directCost   <- comps |> filter(costCat == "direct")   |> pull(compCost) |> sum()
    indirectCost <- comps |> filter(costCat == "indirect") |> pull(compCost) |> sum()
    totalCost    <- directCost + indirectCost

    idx <- idx + 1
    rows[[idx]] <- tibble(nodeID = nid, category = "direct",   share = "Cost", percent = directCost / totalCost)
    idx <- idx + 1
    rows[[idx]] <- tibble(nodeID = nid, category = "indirect", share = "Cost", percent = indirectCost / totalCost)

    # Emission shares by scope
    s1 <- comps |> filter(scopeCat == 1) |> pull(compGHG) |> sum()
    s2 <- comps |> filter(scopeCat == 2) |> pull(compGHG) |> sum()
    s3 <- comps |> filter(scopeCat == 3) |> pull(compGHG) |> sum()
    totalGHG <- s1 + s2 + s3

    idx <- idx + 1
    rows[[idx]] <- tibble(nodeID = nid, category = "1", share = "Emission", percent = s1 / totalGHG)
    idx <- idx + 1
    rows[[idx]] <- tibble(nodeID = nid, category = "2", share = "Emission", percent = s2 / totalGHG)
    idx <- idx + 1
    rows[[idx]] <- tibble(nodeID = nid, category = "3", share = "Emission", percent = s3 / totalGHG)
  }

  Comparison.tbl <- bind_rows(rows)
  return(Comparison.tbl)
}


plotMultiItemCatSharesData <- function(Comparison.tbl) {

  # Prepare data for dual-axis stacked bar chart
  plot_data <- Comparison.tbl |>
    mutate(
      facet_label = paste0("itemID", nodeID),
      fill_label  = category
    )

  cost_data <- plot_data |> filter(share == "Cost")
  emis_data <- plot_data |> filter(share == "Emission")

  # Cost plot
  p_cost <- ggplot(cost_data, aes(x = share, y = percent, fill = fill_label)) +
    geom_col(position = "stack", width = 0.6) +
    facet_wrap(~facet_label) +
    scale_y_continuous(labels = scales::percent_format()) +
    scale_fill_manual(values = c("direct" = "#8e44ad", "indirect" = "#e8a0d0")) +
    labs(y = "Cost share (%)", fill = "Category / Scope") +
    theme_minimal()

  # Emission plot
  p_emis <- ggplot(emis_data, aes(x = share, y = percent, fill = fill_label)) +
    geom_col(position = "stack", width = 0.6) +
    facet_wrap(~facet_label) +
    scale_y_continuous(labels = scales::percent_format()) +
    scale_fill_manual(values = c("1" = "#27ae60", "2" = "#e74c3c", "3" = "#f39c12")) +
    labs(y = "Emission share (%)", fill = "Category / Scope") +
    theme_minimal()

  # Combined plot
  combined_data <- plot_data |>
    mutate(y_label = ifelse(share == "Cost", "Cost share (%)", "Emission share (%)"))

  p <- ggplot(combined_data, aes(x = share, y = percent, fill = fill_label)) +
    geom_col(position = "stack", width = 0.6) +
    facet_wrap(~facet_label) +
    scale_y_continuous(labels = scales::percent_format()) +
    scale_fill_manual(
      values = c("direct" = "#8e44ad", "indirect" = "#e8a0d0",
                 "1" = "#27ae60", "2" = "#e74c3c", "3" = "#f39c12"),
      name = "Category / Scope"
    ) +
    labs(
      title = "Cost Categories and Emission Scopes for FPs",
      subtitle = "Dual axis, stacked percentage comparison",
      x = NULL, y = NULL
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold"),
      plot.subtitle = element_text(hjust = 0.5)
    )

  print(p)
  return(invisible(p))
}
