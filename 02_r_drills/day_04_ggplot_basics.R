# load library
library(tidyverse)

# view data
glimpse(mpg)

# --------------------------------------------------
# Plot 1: count of cars by manufacturer
# --------------------------------------------------

mpg %>%
  count(manufacturer, sort = TRUE) %>%
  ggplot(aes(x = reorder(manufacturer, n), y = n)) + 
  geom_col() + 
  coord_flip() + 
  labs(
    title = "Number of Cars by Manufacturer",
    x = "Manufacturer",
    y = "Count"
  ) + 
  theme_minimal()


# reorder() orders the bars in the plot by count n

# improves readability of the plot


# coord_flip() flips the coordinates, bars now go sideways

# use coord_flip() when you have long names for categories/classes

# labels are easier to read





# --------------------------------------------------
# Plot 2: average highway mileage by class
# --------------------------------------------------

mpg %>%
  group_by(class) %>%
  summarise(avg_hwy = mean(hwy), .groups = "drop") %>%
  ggplot(aes(x = reorder(class, avg_hwy), y = avg_hwy)) + 
  geom_col() + 
  coord_flip() + 
  labs(
    title = "Average Highway MPG by Vehicle Class",
    x = "Vehicle Class",
    y = "Average Highway MPG"
  ) + 
  theme_minimal()

# again, good use of reorder() because we order groups/classes with
# highest highway MPG

# also, good use of coord_flip() because the classes are readable
# on the y axis




# --------------------------------------------------
# Plot 3: scatterplot of engine displacement vs highway mileage
# --------------------------------------------------

mpg %>%
  ggplot(aes(x = displ, y = hwy)) + 
  geom_point() + 
  labs(
    title = "Engine Displacement vs Highway Mileage",
    x = "Engine Displacement",
    y = "Highway Mileage MPG"
    
  ) + 
  theme_minimal()
  

# more simple plot, no grouping
# getting the feel for it, just set up ggplot() 
# then your aes() for x and y
# then + for all your extras

# --------------------------------------------------
# Plot 4: scatterplot with color by drive type
# --------------------------------------------------
glimpse(mpg)

mpg %>%
  ggplot(aes(x = displ, y = hwy, color = drv)) + 
  geom_point() + 
  labs(
    title = "Engine Displacement vs Highway MPG by Drive Type",
    x = "Engine Displacement",
    y = "Highway MPG",
    color = "Drive Type"
  ) + 
  theme_minimal()

# grouping by color instead of group_by()




# --------------------------------------------------
# Plot 5: boxplot of highway mileage by class
# --------------------------------------------------

mpg %>%
  ggplot(aes(x = class, y = hwy)) + 
  geom_boxplot() +
  coord_flip() +
  labs(
    title = "Distribution of Highway MPG by Vehicle Class",
    x = "Vehicle Class",
    y = "Highway MPG"
  ) +
  theme_minimal()










