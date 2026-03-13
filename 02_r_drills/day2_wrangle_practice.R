library(tidyverse)

# Load built-in dataset
data("mpg")

# View first rows
head(mpg)

# View structure
glimpse(mpg)

# View dimensions
dim(mpg)

# View column names
names(mpg)

# Basic summary statistics
summary(mpg)



# Select only a few columns
mpg_small <- mpg %>%
  select(manufacturer, model, year, cyl, displ, cty, hwy, class)

head(mpg_small)


# Only cars with 6 cylinders
mpg_6cyl <- mpg_small %>%
  filter(cyl == 6)

head(mpg_6cyl)

# Only cars from year 2008
mpg_2008 <- mpg_small %>%
  filter(year == 2008)

head(mpg_2008)

# Multiple conditions
mpg_filtered <- mpg_small %>%
  filter(cyl >= 6, hwy > 20)

head(mpg_filtered)




# Create new columns
mpg_new <- mpg_small %>%
  mutate(
    avg_mileage = (cty + hwy) / 2,
    fuel_gap = hwy - cty,
    engine_group = if_else(displ < 3, "small", "large")
  )

head(mpg_new)


# Sort by highway mileage descending
mpg_sorted <- mpg_new %>%
  arrange(desc(hwy))

head(mpg_sorted)



# Average highway mileage overall
mpg_new %>%
  summarise(avg_hwy = mean(hwy))

# Average highway mileage by car class
mpg_new %>%
  group_by(class) %>%
  summarise(
    avg_hwy = mean(hwy),
    avg_cty = mean(cty),
    count = n()
  )

# Average mileage by engine group
mpg_new %>%
  group_by(engine_group) %>%
  summarise(
    avg_avg_mileage = mean(avg_mileage),
    count = n()
  )



# Plot 1: highway mileage by class
ggplot(mpg_new, aes(x = class, y = hwy)) +
  geom_boxplot()

# Plot 2: engine size vs highway mileage
ggplot(mpg_new, aes(x = displ, y = hwy)) +
  geom_point()

# Plot 3: average highway mileage by class
mpg_new %>%
  group_by(class) %>%
  summarise(avg_hwy = mean(hwy)) %>%
  ggplot(aes(x = class, y = avg_hwy)) +
  geom_col()



# how many cars have 8 cylinders
mpg_new %>%
  group_by(cyl) %>%
  summarise(
    count = n()
  )

# 70 cars have 8 cylinders

# there seems to be an imbalance in the data, 
# we only have 4 cars with 5 cylinders
# if we fit a model on this data, we should remove
# the 5 cylinders from the analysis 


# Which car class has the highest average highway mileage?
mpg_new %>%
  group_by(class) %>%
  summarise(avg_hwy = mean(hwy)) %>%
  arrange(desc(avg_hwy))

# How many cars have 8 cylinders?
mpg_new %>%
  filter(cyl == 8) %>%
  summarise(count = n())

# What is the average city mileage for cars from 2008?
mpg_new %>%
  filter(year == 2008) %>%
  summarise(avg_cty_2008 = mean(cty))


# grouping 
# group_by needs a command like summarize() after
mpg_new %>%
  group_by(year) %>%
  summarize(avg_cty = mean(cty))

mpg_new %>%
  group_by(year) %>%
  summarise(
    avg_cty = mean(cty),
    avg_hwy = mean(hwy),
    count = n()
  )
