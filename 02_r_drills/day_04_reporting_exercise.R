library(tidyverse)

# ----------------------------------------
# 1. Summary table by manufacturer and year
# ----------------------------------------

manufacturer_year_summary <- mpg %>%
  group_by(manufacturer, year) %>%
  summarise(
    avg_city_mpg = mean(cty),
    avg_highway_mpg = mean(hwy),
    avg_engine_size = mean(displ),
    car_count = n(),
    .groups = "drop"
  )

print(manufacturer_year_summary)


# group by and summarise to make a summary


# ----------------------------------------
# 2. Plot average highway MPG by manufacturer
# ----------------------------------------


manufacturer_summary <- mpg %>%
  group_by(manufacturer) %>%
  summarise(
    avg_hwy = mean(hwy),
    avg_cty = mean(cty),
    car_count = n(),
    .groups = "drop"
    )
  
manufacturer_summary %>%
  ggplot(aes(x = avg_hwy, y = manufacturer))








