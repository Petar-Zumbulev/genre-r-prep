library(tidyverse)

glimpse(mpg)

names(mpg)

unique(mpg$manufacturer)



mpg %>%
  select(manufacturer, year, trans, hwy)

mpg %>% 
  filter(manufacturer == "toyota")

mpg %>% 
  arrange(desc(year))

mpg %>% 
  select(year, manufacturer, hwy) %>%
  arrange(desc(year))


mpg %>% 
  group_by(manufacturer) %>% 
  summarise(avg_hwy = mean(hwy))

mpg %>%
  count(class)

glimpse(mpg)

mpg %>%
  count(manufacturer)




library(tidyverse)

# mutate is for feature engineering
mpg_new <- mpg %>%
  mutate(
    avg_mileage = (cty + hwy) / 2,
    mileage_gap = hwy - cty,
    year_factor = as.factor(year)
  )

glimpse(mpg_new)

glimpse(mpg)

'
Relevant analytically: in real work you create:

ratios

flags

categories

time features

transformed variables

# feature engineering.
'


mpg_new <- mpg_new %>%
  mutate(year_label = paste("Model Year", year))

mpg_new %>%
  select(manufacturer, model, year, year_label) %>%
  head(10)



# case_when
# classify rows into business categories
mpg_new <- mpg_new %>%
  mutate(
    efficiency_band = case_when(
      hwy >= 30 ~ "High efficiency",
      hwy >= 20 & hwy < 30 ~ "Medium efficiency",
      TRUE ~ "Low efficiency"
    )
  )

mpg_new %>% 
  select(manufacturer, model, hwy, efficiency_band) %>% 
  head(15)




unique(mpg_new$class)



mpg_new <- mpg_new %>%
  mutate(
    is_suv = if_else(class == "suv", "Yes", "No")
  )

mpg_new %>% 
  select(manufacturer, model, class, is_suv) %>% 
  head(15)


