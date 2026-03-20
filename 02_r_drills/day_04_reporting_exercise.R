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
  ggplot(aes(x = reorder(manufacturer, avg_hwy), y = avg_hwy)) + 
  geom_col() + 
  coord_flip() +
  labs(
    title = "Average Highway MPG by Manufacturer",
    x = "Manufacturer",
    y = "Average Highway MPG"
  ) +
  theme_minimal()


# ----------------------------------------
# 3. Plot city vs highway MPG
# ----------------------------------------

glimpse(manufacturer_summary)

manufacturer_summary %>%
  ggplot(aes(x = avg_cty, y = avg_hwy)) +
  geom_point() +
  labs(
    title = "Avg City MPG vs Avg Highway MPG by Manufacturer",
    x = "Average City MPG",
    y = "Average Highway MPG"
  ) + 
  theme_minimal()


# ----------------------------------------
# 4. Plot average highway MPG by year
# ----------------------------------------

mpg %>%
  group_by(year) %>%
  summarise(avg_hwy = mean(hwy), .groups = "drop") %>%
  ggplot(aes(x = factor(year), y = avg_hwy)) +
  geom_col() +
  labs(
    title = "Average Highway MPG by Year",
    x = "Year",
    y = "AVerage Highway MPG"
  ) +
  theme_minimal()

# this last plot is weak analytically
# it doesnt give much insight because there's a small difference 
# in highway MPG between the years

# however, notice that this plot is highly aggregated,
# it aggregates (hides) differences between
# vehicle class, manufacturer, engine size, etc.
# it only compares years. 
# simpsons paradox

# use group_by(manufacturer, year) to start taking apart
# the aggregations and see differences between groups in data

  
'
Mini Exercises
'

# Exercise 1
# Create a plot of average engine displacement by vehicle class.

mpg %>%
  group_by(class) %>%
  summarise(avg_displ = mean(displ)) %>%
  ggplot(aes(x = reorder(class, avg_displ), y = avg_displ)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Avg Engine Displ. by Vehicle Class",
    x = "Vehicle Class",
    y = "Avg Engine Displ."
  ) +
  theme_minimal()


#Exercise 2
#Create a summary table by drv and year

glimpse(mpg)  

mpg_summary_3 <- mpg %>%
  group_by(drv, year) %>%
  summarise(
    avg_cty = mean(cty),
    avg_hwy = mean(hwy),
    car_count = n(),
    .groups = "drop"
  )
# the count is important because it shows if there's imbalanced data
print(mpg_summary_3)


# Exercise 3
# Create a boxplot of city mileage by drive type

mpg %>%
  ggplot(aes(x = (drv), y = cty)) +
  geom_boxplot() +
  labs(
    title = "City Mileage by Drive Type",
    x = "Drive Type",
    y = "City Mileage"
  ) +
  theme_minimal()

# important to see the distribution in box plots 



