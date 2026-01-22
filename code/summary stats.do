*******************************************************
* CCHS 2019-20 PUMF – Summary Statistics Do-file
* Creates cleaned analytic sample + summary stats
*******************************************************
log using final_output.log, replace text
version 17.0
clear all
set more off
set linesize 120

*------------------------------------------------------
* 1. Set working directory and open data
*------------------------------------------------------
* EDIT THIS PATH TO WHERE YOUR .dta FILE LIVES
cd "C:\Users\user\Downloads\research proposal\cchs 19-20\cchs_201920_stata_dta\stata" 
use "cchs_201920_pumf.dta", clear

* Optional: start a log file
* capture log close
* log using "cchs_summstats.log", replace text

*------------------------------------------------------
* 2. Define analytic sample
*   - Drop 12–17 (keep 18+)
*   - Clean mental health DV
*   - Keep nonmissing DV & main IV
*------------------------------------------------------

* Age group dhhgage: drop youngest group (likely 12–17)
drop if dhhgage == 1

* Mental health DV: gendvmhi
* In the PUMF, 0 looks like a non-valid category.
* Check the user guide; if 0 = Not applicable, this is correct:
recode gendvmhi (0 = .)

* Keep only observations with defined mental health and weekly alcohol
drop if missing(gendvmhi, alwdvwky)

*------------------------------------------------------
* 3. Create weekly alcohol categories (from alwdvwky)
*------------------------------------------------------

capture drop alc_cat

gen alc_cat = .
replace alc_cat = 0 if alwdvwky == 0
replace alc_cat = 1 if alwdvwky > 0   & alwdvwky <= 7
replace alc_cat = 2 if alwdvwky >= 8  & alwdvwky <= 20
replace alc_cat = 3 if alwdvwky >= 21

label define alc_cat_lbl ///
    0 "0 drinks/week" ///
    1 "1–7 drinks/week" ///
    2 "8–20 drinks/week" ///
    3 "21+ drinks/week"

label values alc_cat alc_cat_lbl


*------------------------------------------------------
* 4. (Optional) Inspect and label control variables
*   Check the codebook or built-in labels before editing.
*------------------------------------------------------

* Quick look at distributions & existing labels
codebook dhhgage DHH_SEX EHG2DVH3 incdgrca geogprv sdcdvfla sdcdvimm

* If you want to override / add simpler labels, UNCOMMENT and
* fill in according to the PUMF user guide:

* Example template (EDIT text & codes to match guide, then remove the *):
* label define agegrp 1 "12–17" 2 "18–34" 3 "35–49" 4 "50–64" 5 "65+"
* label values dhhgage agegrp
*
* label define sex_lbl 1 "Male" 2 "Female"
* label values DHH_SEX sex_lbl
*
* label define educ_lbl 1 "Less than HS" 2 "High school" 3 "Post-secondary"
* label values EHG2DVH3 educ_lbl
*
* label define inc_lbl 1 "<$20k" 2 "$20–39k" 3 "$40–59k" 4 "$60–79k" 5 "$80k+"
* label values incdgrca inc_lbl
*
* label define imm_lbl 1 "Canadian-born" 2 "Immigrant"
* label values sdcdvimm imm_lbl
*
* label define lang_lbl 1 "Speaks official language(s)" 2 "Does not speak official language(s)"
* label values sdcdvfla lang_lbl

*------------------------------------------------------
* 5. Survey weighting
*------------------------------------------------------

svyset [pweight = WTS_M]

*------------------------------------------------------
* 6. Summary statistics for proposal table
*   - DV: gendvmhi
*   - Main IV: alwdvwky (continuous) + alc_cat (categorical)
*   - Controls: age group, gender, education, income, province,
*               language ability, immigrant status
*------------------------------------------------------

* 6.1 Continuous variables: means (N, mean, SD)
display "===== CONTINUOUS VARIABLES (MENTAL HEALTH, WEEKLY ALCOHOL) ====="
svy: mean gendvmhi alwdvwky

* 6.2 Alcohol categories: percentage distribution
display "===== WEEKLY ALCOHOL CATEGORIES (alc_cat) ====="
svy: tab alc_cat, percent

* 6.3 Control variables: percentage distributions
display "===== AGE GROUP (dhhgage) ====="
svy: tab dhhgage, percent

display "===== GENDER (DHH_SEX) ====="
svy: tab DHH_SEX, percent

display "===== EDUCATION (EHG2DVH3) ====="
svy: tab EHG2DVH3, percent

display "===== INCOME (incdgrca) ====="
svy: tab incdgrca, percent

display "===== PROVINCE (geogprv) ====="
svy: tab geogprv, percent

display "===== VISIBLE MINORITY (sdcdvfla) ====="
svy: tab sdcdvfla, percent

display "===== IMMIGRANT STATUS (sdcdvimm) ====="
svy: tab sdcdvimm, percent

*------------------------------------------------------
* 7. (Optional) Save cleaned analysis file
*------------------------------------------------------
* save "cchs_201920_clean_analytic.dta", replace

* log close
exit
