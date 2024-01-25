# Internal range structure associated with range-limit population trends

### [Neil A. Gilbert](https://gilbertecology.com), [Stephen R. Kolbe](https://nrri.umn.edu/faculty-staff/steve-kolbe-ms), [Harold N. Eyster](https://eyster.com/), [Alexis R. Grinde](https://nrri.umn.edu/faculty-staff/alexis-grinde-phd)

### Data/code DOI: To be added upon acceptance

#### Please contact the first author for questions about the code or data: Neil A. Gilbert (neil.allen.gilbert@gmail.com)
__________________________________________________________________________________________________________________________________________

## Abstract
Poleward and uphill range shifts are a common but variable response to anthropogenic climate change. We lack understanding regarding this interspecific variation in range-shifting; for example, functional traits (e.g., body size, diet) show weak or mixed ability to predict range shifts. Characteristics of species’ ranges may better enable prediction of range shifts; for instance, species with larger geographic ranges are more likely to show range shifts. However, the explanatory power of other range characteristics—especially within-range abundance patterns—remain untested. Here, we introduce a hypothesis framework for understanding range-limit population trends and range shifts via the internal structure of the geographic range, specifically range edge hardness (i.e., abundance within range edges relative to the rest of the range). The dispersal hypothesis predicts that, through dispersal mechanisms, high edge abundance facilitates expansions along the leading edge but creates inertia at the trailing edge such that the range limit recedes slowly. In contrast, the limitation hypothesis suggests that hard range edges are the signature of strong limits (e.g., biotic interactions) that force faster contraction of the trailing edge but block expansions at the leading edge of the range. Using a long-term avian monitoring dataset from northern Minnesota, USA, we estimated population trends for 35 trailing-edge species and 18 leading-edge species and modeled their population trends as a function of range edge hardness calculated from state-of-the-art abundance maps from eBird data. Trailing-edge species with harder range edges were more likely to be declining, demonstrating moderate support for the limitation hypothesis. In contrast, leading-edge species with harder range edges were slightly more likely to be increasing, demonstrated weak support for the dispersal hypothesis. These opposing results for the leading and trailing range edges suggest that different mechanisms may underpin range expansions and contractions, respectively. As data and state-of-the-art modeling efforts continue to proliferate, we will be ever better equipped to map abundance patterns within species’ ranges, offering opportunities to anticipate range shifts through the lens of the geographic range. 

 <img src="https://github.com/n-a-gilbert/range_edges/blob/main/figures/figure_01.png" width="300" /> $~~~~~~~~~~~~~~~~~$ <img src="https://github.com/n-a-gilbert/range_edges/blob/main/figures/figure_02.png" width="300" />


## Repository Directory

### [code](./code): Contains code for formatting and analyzing data
* [calculate_range_metrics.R](./code/calculate_range_metrics.R) Code to calculate range edge hardness metrics using eBird maps and WorldClim
* [edge_analysis.R](./code/edge_analysis.R) Code to run models for Step 2: population trend modeled by temperature index and range edge hardness
* [format_data.R](./code/format_data.R) Code to format raw data for Step 1
* [run_brms_model.R](./code/run_brms_model.R) Code to run the model for Step 1

### [data](./data): Contains data for analyses
* [ebird_abundance](./data/ebird_abundance) Folder containing breeding season abundance rasters from eBird for each species
* [bird_site_1995-2023.RData](./data/bird_site_1995-2023.RData) Raw bird survey data; .RData file with one dataframe
* [code_key.csv](./data/code_key.csv) Key with species common names, scientific names, 4 letter code, and 6-letter code
* [edge_hardness_metrics.csv](./data/edge_hardness_metrics.csv) Range metrics for each species
* [formatted_data_for_model.RData](./data/formatted_data_for_model.RData) Formatted bird survey data
* [species_names_review.csv](./data/species_names_review.csv) File for data filtering, has species flagged for removal (e.g., water birds and nocturnal species)

### [figures](./figures): Contains figures and code for figures
* [code_for_figures](./figures/code_for_figures) Folder with scripts to create figures
  * [figure_02.R](./figures/code_for_figures/figure_02.R) Script to create each panel for Figure 2
  * [figure_03.R](./figures/code_for_figures/figure_03.R) Script to create Figure 3
  * [figure_s1_sr.R](./figures/code_for_figures/figure_s1_s2.R) Script to create Figures S1 and S2
  * [figure_s3.R](./figures/code_for_figures/figure_s3.R) Script to create Figure S3
* [figure_01.png](./figures/figure_01.png) Figure 1
* [figure_01.pptx](./figures/figure_01.pptx) Figure 1 (created in Powerpoint)
* [figure_02.png](./figures/figure_02.png) Figure 2
* [figure_02.pptx](./figures/figure_02.pptx) Figure 2 (panels assembled in Powerpoint)
* [figure_03.png](./figures/figure_03.png) Figure 3
* [figure_s1.png](./figures/figure_s1.png) Figure S1
* [figure_s2.png](./figures/figure_s2.png) Figure S2
* [figure_s3.png](./figures/figure_s3.png) Figure S3

### results NOTE: the files with model results are too large to share on GitHub; download links provided
* brms_results_2023-11-01.rds: Results from Step 1. [Download link](https://1drv.ms/u/s!AtvYBfNq7AMkg4llzxN7tWMFyvXUCQ?e=IITVjK)
* leading_edge_analysis.RData: Results from Step 2 for leading-edge species [Download link](https://1drv.ms/u/s!AtvYBfNq7AMkg4lFAGeIc--nllbz_g?e=dX3CiS)
* trailing_edge_analysis.RData: Results from Step 2 for trailing-edge species [Download link](https://1drv.ms/u/s!AtvYBfNq7AMkg4lG4AFyCAWyMD1LTg?e=Q4z4ja)
