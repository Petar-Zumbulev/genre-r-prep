---
editor_options: 
  markdown: 
    wrap: 72
---

# Day 2

Goal: Learn the core R data workflow: - inspect data - clean data -
create columns - filter - summarize - plot

Main functions today: glimpse() select() filter() mutate() group_by()
summarise() arrange() ggplot()


## What I learned today

- glimpse() helps me understand the structure of a dataset quickly
- select() chooses columns
- filter() chooses rows
- mutate() creates new variables
- group_by() + summarise() is one of the most important workflows in R
- group_by() just by itself does not give valuable output, pair it with another command
- ggplot() is the basic plotting system I will use a lot
- This feels similar to pandas, but written in the tidyverse style

Working with group_by() made perfect sense to me and felt like review, 
I have my SQL prep to thank for this. 

I'm starting to understand the overall structure of R code better and
the tidyverse style, but its still not as intuitive as Python code

I prefer using group_by() for several classes instead of filtering for
a single value I'm looking for. For me, the general group by and then 
having multiple groupings in front of me feels better because of the 
reusability of that command for other values

I still have to work with mutate() select() and ggplot() more






tidyverse - a collection of packages for data analysis

tibble - data frames

tidyverse - tidy data - atomic values, one obervation per row, 
  one feature per column
  
tidyverse code structure:
operation, pass the result, operation

here's an example:

mpg %>%
  filter(year == 2008) %>%
  group_by(class) %>%
  summarise(avg_hwy = mean(hwy))

the %>% part is passing the result

→ keep only rows where year is 2008
→ group the remaining rows by class
→ calculate average highway mileage for each class


summarise() takes many rows and turns them into
fewer rows by calculating summary values.


mutate() - feature engineering


