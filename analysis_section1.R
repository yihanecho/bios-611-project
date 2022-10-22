library(dplyr)
library(ggplot2)
library(forcats)
library(gridExtra)
library(treemapify)
library(readr)
library(stringr)
select <- dplyr::select

# Violin plot by Industry=====================================================================

OCC.NAICS <- read_csv("./derived_data/Salary_US_major_group.csv")

# Add order for graphing purpose
ord.med <- OCC.NAICS %>%
  group_by(NAICS) %>% summarise(med = median(H_MEAN)) %>%
  arrange(desc(med)) %>% mutate(Ord_Med = row_number()) %>% select(-med)
ord.emp <- OCC.NAICS %>%
  group_by(NAICS) %>% summarise(n = sum(TOT_EMP)) %>%
  arrange(desc(n)) %>% mutate(Ord_Emp = row_number()) %>% select(-n)

OCC.NAICS.ord <- OCC.NAICS  %>%
  left_join(ord.med, by = c("NAICS" = "NAICS")) %>%
  left_join(ord.emp, by = c("NAICS" = "NAICS"))

occup.t <- OCC.NAICS.ord %>%
  mutate(NAICS = substr(NAICS, 1,2)) %>%
  group_by(NAICS, NAICS_TITLE) %>%
  summarise(Employment = sum(TOT_EMP),
            Median_H = median(H_MEAN),
            Range_H = max(H_MEAN) - min(H_MEAN),
            Median_A = median(A_MEAN),
            Range_A = max(A_MEAN) - min(A_MEAN)) %>%
  arrange(desc(Median_H))


# Violin plot of Mean Hourly Wage
p1 <- ggplot(OCC.NAICS.ord,
            aes(fct_reorder(NAICS_TITLE, Ord_Med, .desc = TRUE), H_MEAN)) +
  geom_violin(scale = "count", width=1.3) +
  coord_flip() +
  stat_summary(fun=median, geom="point", size=1, color="red") +
  labs(title="Hourly Wage by Industry") +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank())

# Bar plot of Total Employment
p2 <- ggplot(data = OCC.NAICS.ord, aes(x = reorder(NAICS_TITLE, -Ord_Emp), y = TOT_EMP)) +
  geom_bar(stat = "identity") +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank()) +
  labs(title="Total Empolyment by Industry",
       caption="Source: U.S. BUREAU OF LABOR STATISTICS") +
  coord_flip()

png(filename = "./figures/figure11-12.png", width = 1000, height = 850, units = "px")
p <- grid.arrange(p1, p2, ncol = 2)
dev.off()


# Tree Map for the Utility Industry ==============================================

OCC.NAICS <- read_csv("./derived_data/Salary_US_major_group.csv")

dum <- OCC.NAICS %>%
  filter(NAICS=="22") %>%
  arrange(desc(H_MEAN))

p <- ggplot(dum, aes(area = TOT_EMP, fill = H_MEAN, subgroup = OCC_TITLE)) +
  geom_treemap() +
  geom_treemap_subgroup_border(color = "black") +
  geom_treemap_subgroup_text(place = "centre", grow = T, alpha = 0.5,
                             colour = "white", fontface = "italic",
                             min.size = 2,
                             padding.x = grid::unit(2, "mm"),
                             padding.y = grid::unit(2, "mm")) +
  labs(fill = "Mean Hourly Wage")

png(filename = "./figures/figure13.png", width = 800, height = 500, units = "px")
print(p)
dev.off()
