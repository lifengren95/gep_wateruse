# GEP: water use

**Objective:** Compute the Gross Ecosystem Product of water used for agricultural, domestic and industrial sector in the world.


## Descriptions:

From [AQUASTAT (FAO's Global Information System on Water and Agriculture)](https://www.fao.org/aquastat/en/) website, we downloaded the datasets on country-level water use efficiency and water withdrawal for different sectors (agriculture, domestic and industrial) for all countries in the world over the period of 2007 - 2022. 


+ Water Use Efficiency (WUE) measures how much economic output (e.g., crop value) is generated per unit of water used ($\$/m^3$) for each sector. We use this metric as a proxy for the price of water. 
  + According to the methodology outlined by FAO, the dollar values were deflated to a baseline year 2015.
  + We use the following three types of water use efficiency data:
    + Agricultural water use efficiency
    + Industrial water use efficiency
    + Municipal water use efficiency

<br>

+ For quantity of water used, we use the reported volume of water withdrawn for each sector (agriculture, domestic and industrial) in each country. 
  + We use the following three types of water withdrawal data:
    + Agricultural Water withdrawal
    + Industrial water withdrawal
    + Municipal water withdrawal


+ Further descriptions of the data are illustrated by [this pdf](https://unstats.un.org/sdgs/metadata/files/metadata-06-04-01.pdf). 
+ About water use efficiency calculation, see [this pdf: Progress on Water-use Efficiency Global baseline for SDG indicator 6.4.1 - 2018](https://openknowledge.fao.org/server/api/core/bitstreams/603a9f36-61cf-42dd-978e-da846e5d76b0/content)

+ [FAO AQUASTAT and the SDG indicators 6.4.1. and 6.4.2.](https://unstats.un.org/unsd/envstats/fdes/EGES7/Sess3_FAO2_%20AQUASTAT.pdf)


## Folder Structures:

To reproduce the results, please follow the folder structures below:

```bash
.
├── script
└── Data
  └── raw
    └── AQUASTAT_2007_2022.csv
```

