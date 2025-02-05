## Overview
These Stata codes collectively process, prepare, and analyze data to evaluate the impact of remote learning during the COVID-19 pandemic on child welfare outcomes, including child maltreatment and maltreatment-related fatalities.

### 1

The first code processes and prepares multiple raw data to create a comprehensive state- and county-level dataset by importing and merging various state- and county-level data sources, such as school learning modalities, child welfare reports, population demographics, and unemployment data, while generating key variables like remote learning proportions and child maltreatment rates.

### 2
The second code visualizes trends through graphs and maps, comparing child welfare outcomes across learning modes and geographic areas. The key graphs analyze allegations of child maltreatment and fatalities across different years, learning modes (remote vs. in-person), and geographic levels (state and county). It also includes counterfactual analyses and pre-trend comparisons to assess differences in allegations and fatalities over time.

### 3
The third code conducts Difference-in-Differences (DID) and event study analyses to estimate the impact of remote learning on child maltreatment allegations and fatalities. It also includes heterogeneous analyses and robustness checks, utilizing continuous treatment variables, parallel trends tests, and subgroup analyses by age, race, reporter and maltreatment types. The code outputs regression results, event study graphs, and cleaned datasets, providing robust evidence on the effects of the pandemic and remote learning on child welfare.
