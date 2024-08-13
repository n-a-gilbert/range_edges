# Can internal range structure predict range shifts?

### [Neil A. Gilbert](https://gilbertecology.com), [Stephen R. Kolbe](https://nrri.umn.edu/faculty-staff/steve-kolbe-ms), [Harold N. Eyster](https://eyster.com/), [Alexis R. Grinde](https://nrri.umn.edu/faculty-staff/alexis-grinde-phd)

### Data/code DOI: To be added upon acceptance

#### Please contact the first author for questions about the code or data: Neil A. Gilbert (neil.allen.gilbert@gmail.com)
__________________________________________________________________________________________________________________________________________

## Abstract
Poleward and uphill range shifts are a common—but variable—response to climate change. We lack understanding regarding this interspecific variation; for example, functional traits show weak or mixed ability to predict range shifts. Characteristics of species’ ranges may enhance prediction of range shifts. However, the explanatory power of many range characteristics—especially within-range abundance patterns—remains untested. Here, we introduce a hypothesis framework for predicting range-limit population trends and range shifts from the internal structure of the geographic range, specifically range edge hardness, defined as abundance within range edges relative to the whole range. The inertia hypothesis predicts that high edge abundance facilitates expansions along the leading range edge but creates inertia (either more individuals must disperse or perish) at the trailing range edge such that the trailing edge recedes slowly. In contrast, the limitation hypothesis suggests that hard range edges are the signature of strong limits (e.g., biotic interactions) that force faster contraction of the trailing edge but block expansions at the leading edge of the range. Using a long-term avian monitoring dataset from northern Minnesota, USA, we estimated population trends for 35 trailing-edge species and 18 leading-edge species and modeled their population trends as a function of range edge hardness derived from eBird data. Trailing-edge species with harder range edges were more likely to be declining, demonstrating weak support for the limitation hypothesis. In contrast, leading-edge species with harder range edges were slightly more likely to be increasing, demonstrating weak support for the inertia hypothesis. These opposing results for the leading and trailing range edges might suggest that different mechanisms underpin range expansions and contractions, respectively. As data and state-of-the-art modeling efforts continue to proliferate, we will be ever better equipped to map abundance patterns within species’ ranges, offering opportunities to anticipate range shifts through the lens of the geographic range. 

 <img src="https://github.com/n-a-gilbert/range_edges/blob/main/figures/figure_01.png" width="300" /> $~~~~~~~~~~~~~~~~~$ <img src="https://github.com/n-a-gilbert/range_edges/blob/main/figures/figure_02.png" width="300" />


## Repository Directory

### [code](./code): Contains code for formatting and analyzing data
* [calculate_range_metrics.R](./code/calculate_range_metrics.R) Code to calculate range edge hardness metrics using eBird maps and WorldClim
* [edge_analysis.R](./code/edge_analysis.R) Code to run models for Step 2: population trend modeled by temperature index and range edge hardness
* [format_data.R](./code/format_data.R) Code to format raw data for Step 1
* [phylogenetic_regression_subsets.R](./code/phylogenetic_regression_subsets.R) Code to fit PGLMMs to subsets of the dataset (see Supplement)
* [run_brms_model.R](./code/run_brms_model.R) Code to run the model for Step 1

### [data](./data): Contains data for analyses
* [ebird_abundance](./data/ebird_abundance) Folder containing breeding season abundance rasters from eBird for each species
* [ebird_ranges](./data/ebird_ranges) Folder containing breeding season range maps from eBird for each species
* [brms_data_revision.RData](./data/brms_data_revision.RData) Formatted data for brms model
* [brms_data_revision2.RData](./data/brms_data_revision2.RData) Formatted data with phylo info
* [code_key.csv](./data/code_key.csv) Key with species common names, scientific names, 4 letter code, and 6-letter code
* [coordinates.csv](./data/coordinates.csv) Site coordinates for calculating proximity to range edges; cannot be linked to bird survey data
* [edge_hardness_metrics.csv](./data/edge_hardness_metrics.csv) Range metrics for each species
* [formatted_data_for_model.RData](./data/formatted_data_for_model.RData) Formatted bird survey data; no site coordinates for data sharing restrictions.
* [species_names_review.csv](./data/species_names_review.csv) File for data filtering, has species flagged for removal (e.g., water birds and nocturnal species)

### [figures](./figures): Contains figures and code for figures
* [code_for_figures](./figures/code_for_figures) Folder with scripts to create figures
  * [figure_02.R](./figures/code_for_figures/figure_02.R) Script to create Figure 2
  * [figure_03.R](./figures/code_for_figures/figure_03.R) Script to create Figure 3 panels
  * [figure_04.R](./figures/code_for_figures/figure_04.R) Script to create Figure 4
  * [figure_05.R](./figures/code_for_figures/figure_05.R) Script to create Figure 5
  * [figure_s01.R](./figures/code_for_figures/figure_s01.R) Script to create Figure S1
  * [figure_s02.R](./figures/code_for_figures/figure_s02.R) Script to create Figure S2
  * [figure_s03.R](./figures/code_for_figures/figure_s03.R) Script to create Figure S3
  * [figure_s04.R](./figures/code_for_figures/figure_s04.R) Script to create Figure S4
  * [figure_s05.R](./figures/code_for_figures/figure_s05.R) Script to create Figure S5
* [figure_01.png](./figures/figure_01.png) Figure 1
* [figure_01.pptx](./figures/figure_01.pptx) Figure 1 (created in Powerpoint)
* [figure_02.png](./figures/figure_02.png) Figure 2
* [figure_03.png](./figures/figure_03.png) Figure 3
* [figure_03.pptx](./figures/figure_03.pptx) Figure 3 (panels assembled in Powerpoint)
* [figure_04.png](./figures/figure_04.png) Figure 4
* [figure_05.png](./figures/figure_05.png) Figure 5
* [figure_s01.png](./figures/figure_s01.png) Figure S1
* [figure_s02.png](./figures/figure_s02.png) Figure S2
* [figure_s03.png](./figures/figure_s03.png) Figure S3
* [figure_s04.png](./figures/figure_s04.png) Figure S4
* [figure_s05.png](./figures/figure_s05.png) Figure S5

### results NOTE: the files with model results are too large to share on GitHub; download links provided
* brms_results_2024-05-15.rds: Results from Step 1. [Download link](https://1drv.ms/u/s!AtvYBfNq7AMkhKgyHsRmtvRMK0WCbQ?e=aQp17C)
* edge_analysis_leading.RData: Results from Step 2 for leading-edge species [Download link](https://1drv.ms/u/s!AtvYBfNq7AMkhKsz13VTqKFps_McQg?e=AxqBll)
* edge_analysis_trailing.RData: Results from Step 2 for trailing-edge species [Download link](https://1drv.ms/u/s!AtvYBfNq7AMkhKsyxZokyDlvJtbZTA?e=ibvqTO)
* edge_analysis_trailing_no_conw.RData: Results for Step 2 for trailing-edge species with outlier omitted [Download link](https://1drv.ms/u/s!AtvYBfNq7AMkhKsxdttorVStYyPSUg?e=VsF9hh)
