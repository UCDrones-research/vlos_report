#| message: false
#| warning: false
#| echo: false
# === Load data ===
library(ggplot2)
library(plotly)
library(readxl)
library(pROC)
library(dplyr)
library(tidyverse)
library(forcats)
library(gt)
library(emmeans)
library(kableExtra)



file_path <- "./data/processed/AllDroneTrialsActual.xlsx"
sheets <- excel_sheets(file_path)

# Example mapping (customize to your actual data)
observer_skill <- c(
  "UI5" = "Beginner",
  "UI6" = "Beginner",
  "UI7" = "Beginner",
  "UI3" = "Competent",
  "UI8" = "Competent",
  "UI1" = "Experienced",
  "UI2" = "Experienced",
  "UI4" = "Experienced"
)

# === Clean 4-column dataset ===
all_data <- map_dfr(sheets, function(sheet) {
  df <- read_excel(file_path, sheet = sheet)
  if (!("VLOS_AM" %in% names(df)) || !("Visible" %in% names(df))) return(NULL)
  df %>%
    select(altitude = Lat_Alt, arcminutes = VLOS_AM, visible = Visible) %>%
    filter(altitude > 10) %>%
    mutate(
      visible = as.integer(visible),
      drone_name = str_extract(sheet, "^[^-]+"),
      user_id = str_extract(sheet, "[^-]+$")
    )
})

acuity_score <- all_data$arcminutes
altitude <- all_data$altitude
visibility <- all_data$visible
observers <-all_data$user_id
skill_level <- observer_skill[all_data$user_id]
drone_type <-all_data$drone_name