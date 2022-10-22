library(dplyr)
library(ggplot2)
library(ggrepel)
library(gridExtra)
library(readr)
library(stringr)
select <- dplyr::select

# Violin plot by Occupation=====================================================================

OCC.NAICS <- read_csv("./derived_data/Salary_US_major_group.csv")

# Add order for graphing purpose
ord.med <- OCC.NAICS %>%
  group_by(OCC_CODE) %>% summarise(med = median(H_MEAN)) %>%
  arrange(desc(med)) %>% mutate(Ord_Med = row_number()) %>% select(-med)
ord.emp <- OCC.NAICS %>%
  group_by(OCC_CODE) %>% summarise(n = sum(TOT_EMP)) %>%
  arrange(desc(n)) %>% mutate(Ord_Emp = row_number()) %>% select(-n)

OCC.NAICS.ord <- OCC.NAICS  %>%
  left_join(ord.med, by = c("OCC_CODE" = "OCC_CODE")) %>%
  left_join(ord.emp, by = c("OCC_CODE" = "OCC_CODE"))

occup.t <- OCC.NAICS.ord %>%
  mutate(OCC_CODE = substr(OCC_CODE, 1,2)) %>%
  group_by(OCC_CODE, OCC_TITLE) %>%
  summarise(Employment = sum(TOT_EMP),
            Median_H = median(H_MEAN),
            Range_H = max(H_MEAN) - min(H_MEAN),
            Median_A = median(A_MEAN),
            Range_A = max(A_MEAN) - min(A_MEAN)) %>%
  arrange(desc(Median_H))


# Violin plot of Mean Hourly Wage
p1 <- ggplot(OCC.NAICS.ord,
            aes(fct_reorder(OCC_TITLE, Ord_Med, .desc = TRUE), H_MEAN)) +
  geom_violin(scale = "count", width=1.3) +
  coord_flip() +
  stat_summary(fun=median, geom="point", size=1, color="red") +
  labs(title="Hourly Wage by Occupations") +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())


# Bar plot of Total Employment
p2 <- ggplot(data = OCC.NAICS.ord, aes(x = reorder(OCC_TITLE, -Ord_Emp), y = TOT_EMP)) +
  geom_bar(stat = "identity") +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank()) +
  labs(title="Total Empolyment by Industry",
       caption="Source: U.S. BUREAU OF LABOR STATISTICS") +
  coord_flip()

png(filename = "./figures/figure21-22.png", width = 1000, height = 850, units = "px")
p<- grid.arrange(p1, p2, ncol = 2)
dev.off()


# Scatter Plot of Selected Occupations ======================================

broad.d <- read_csv("./derived_data/DS_broad_group.csv")

plot.d <- broad.d %>% arrange(desc(H_MEAN))

png(filename = "./figures/figure23.png", width = 850, height = 400, units = "px")

ggplot(data = plot.d) +
  aes(x=TOT_EMP, y=H_MEAN, size=TOT_EMP, color = OCC_TITLE) +
  geom_point(alpha=1) +
  theme_bw() +
  scale_colour_discrete(name="SOC") +
  scale_size_continuous(range = c(5, 15)) +
  labs(x="Total Employment", y="Mean Hourly Wage")

dev.off()