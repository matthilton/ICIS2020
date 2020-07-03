library(tidyverse)




read.csv("data/ages.csv", header=F) %>% 
  rename(months=V1, days=V2) %>% 
  mutate(days=replace_na(days, 0), 
         months2days=months*30.417, 
         age.days=days+months2days, 
         age.months=age.days/30.417) %>% 
  summarize(mean(age.months), sd(age.months))

