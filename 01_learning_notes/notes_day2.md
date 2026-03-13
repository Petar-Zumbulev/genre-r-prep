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
