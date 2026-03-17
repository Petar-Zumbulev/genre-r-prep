library(tidyverse)

mpg_new <- mpg %>%
  mutate(
    avg_mileage = (cty + hwy) / 2,
    efficiency_band = case_when(
      hwy >= 30 ~ "High efficiency",
      hwy >= 20 & hwy < 30 ~ "Medium efficiency",
      TRUE ~ "Low efficiency"
    )
  )


mpg_new %>%
  select(manufacturer, avg_mileage, efficiency_band) %>%
  head(10)


mpg_new %>%
  group_by(manufacturer) %>%
  summarise(
    n_cars = n(),
    avg_cty = mean(cty),
    avg_hwy = mean(hwy),
    avg_combined = mean(avg_mileage)
  ) %>%
  arrange(desc(avg_hwy))


# very interesting. 2 groupings, one by manufacturer,
# the other by year, so you have audis in 1999 and their
# average miles and right under them audis in 2008 and 
# you can compare their mileage changes
# also, the n_cars = n() is a useful column because
# it shows how many observations you have in each group
mpg_new %>%
  group_by(manufacturer, year) %>%
  summarise(
    n_cars = n(),
    avg_hwy = mean(hwy),
    avg_cty = mean(cty)
  ) %>%
  arrange(manufacturer, year)

'
So instead of showing every car individually, you are asking:

for each manufacturer in each year, what was the average?

That is why grouping is important.
It changes the level of analysis.
'


mpg_new %>%
  group_by(class, year) %>%
  summarise(
    n_models = n(),
    avg_hwy = mean(hwy),
    avg_cty = mean(cty)
  ) %>%
  arrange(class, year)


manufacturer_summary <- mpg_new %>%
  group_by(manufacturer, efficiency_band) %>%
  summarise(
    n_cars = n(),
    avg_hwy = mean(hwy),
    avg_cty = mean(cty),
    .groups = "drop"
  ) %>%
  arrange(manufacturer, desc(avg_hwy))

manufacturer_summary


manufacturer_plot <- mpg_new %>%
  group_by(manufacturer) %>%
  summarise(avg_hwy = mean(hwy)) %>%
  ggplot(aes(x = reorder(manufacturer, avg_hwy), y = avg_hwy)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Average Highway MPG by Manufacturer",
    x = "Manufacturer",
    y = "Average Highway MPG"
  )

manufacturer_plot



# practice problems

# practice problem 1
# created a new categorical feature from a numeric column
# turn raw numeric values into business categories
mpg_new <- mpg_new %>%
  mutate(
    car_size_flag = if_else(
      displ >= 5, "Large", "Small/Medium")
    )


glimpse(mpg_new)


new_summary <- mpg_new %>%
  select(manufacturer, model, displ, year, car_size_flag)


new_summary

# practice problem 2
# summary table using group by and summarise
# n() is important, count
new_summary_2 <- mpg_new %>%
  group_by(class) %>%
  summarise(
    n_cars = n(),
    avg_engine_displ = mean(displ),
    avg_highway = mean(hwy)
  )


new_summary_2


names(mpg_new)


# practice problem 3
mpg_new <- mpg_new %>%
  mutate(
    efficiency_score = (hwy * 2 + cty) / 3
  )

glimpse(mpg_new)

mpg_new %>%
  select(manufacturer, year, efficiency_score)

