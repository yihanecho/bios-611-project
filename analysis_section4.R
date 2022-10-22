library(dplyr)
library(forcats)
library(ggplot2)
library(ggrepel)
library(gridExtra)
library(readr)
library(stringr)
select <- dplyr::select

# with Automation data ===============================================================
auto.d <- read_csv("./source_data/Automation_by_state.csv")
OCC.NAICS <- read_csv("./derived_data/Salary_US_major_group.csv")

# Group SOC by major group, sum probability as score, order by score
score_table <- auto.d %>% filter(str_detect(SOC, "-")) %>%
  mutate(group = substr(SOC, 1,2)) %>%
  group_by(group) %>% summarise(tot_score = sum(Probability)) %>%
  arrange(desc(tot_score))

# from Salary data group by OCC
salary_table <- OCC.NAICS %>% mutate(SOC = str_sub(OCC_CODE, 1, 2)) %>%
  group_by(SOC, OCC_TITLE) %>% summarise(emp = sum(TOT_EMP),
                              hourly = mean(H_MEAN), annually = mean(A_MEAN))

# Join two tables
d <- inner_join(score_table, salary_table, by = c("group" = "SOC"))
## Add this table to report.

# Plot correlations
panel.cor <- function(x, y, digits = 2, prefix = "", cex.cor, ...) {
  usr <- par("usr")
  on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  Cor <- abs(cor(x, y)) # Remove abs function if desired
  txt <- paste0(prefix, format(c(Cor, 0.123456789), digits = digits)[1])
  if(missing(cex.cor)) {
    cex.cor <- 0.4 / strwidth(txt)
  }
  text(0.5, 0.5, txt,
       cex = 1 + cex.cor * Cor) # Resize the text by level of correlation
}

# Plotting the correlation matrix
d.plot <- d %>% mutate(score = tot_score) %>%
  select(score, emp, hourly, annually)

png(filename = "./figures/figure41.png", width = 400, height = 400, units = "px")
pairs(d.plot,
      upper.panel = panel.cor,    # Correlation panel
      lower.panel = panel.smooth) # Smoothed regression lines
dev.off()

model <- lm(log(score) ~ emp + hourly + annually, data = d.plot)
summary(model)
# there is little association between automation probability and salary
# correlation of 1 between hourly wage and annually wage validates our data

# Plot table
png(filename = "./figures/figure42.png", width = 700, height = 700, units = "px")

ggplot(data = d) +
  aes(x=tot_score, y=hourly, size=emp*1000) + geom_point(alpha=0.5, col='blue') +
  geom_label_repel(aes(label = OCC_TITLE),
                   box.padding   = 0.20,
                   point.padding = 0.1,
                   max.overlaps = 60,
                   segment.color = 'grey50') +
  xlab("Automation Score") +
  ylab("Mean Hourly Wage") +
  theme_classic(base_size = 20)

dev.off()

