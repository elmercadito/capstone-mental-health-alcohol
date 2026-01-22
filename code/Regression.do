*******************************************************
* CCHS 2019-20 PUMF – Logistic Regression Do-file
* Binary mental health DV + weighted logistic models
*******************************************************

version 17.0
clear all
set more off
set linesize 120

*------------------------------------------------------
* 1. Set working directory and open data
*------------------------------------------------------
cd "C:\Users\user\Downloads\research proposal\cchs 19-20\cchs_201920_stata_dta\stata"
use "cchs_201920_pumf.dta", clear

*------------------------------------------------------
* 2. Define analytic sample
*------------------------------------------------------

* Drop 12–17 (keep only adults)
drop if dhhgage == 1

* Clean mental health DV (0 is not valid)
recode gendvmhi (0 = .)

* Keep only observations with mental health + alcohol data
drop if missing(gendvmhi, alwdvwky)

*------------------------------------------------------
* 3. Create binary mental health DV
*------------------------------------------------------

gen mh_good = .
replace mh_good = 0 if gendvmhi >= 4 & gendvmhi != .
replace mh_good = 1 if gendvmhi <= 3 & gendvmhi != .

label define mh_good_lbl 0 "Poor/fair mental health" 1 "Good/very good/excellent"
label values mh_good mh_good_lbl
label var mh_good "Good mental health (1=yes)"

*------------------------------------------------------
* 4. Alcohol variable(s)
*------------------------------------------------------

label var alwdvwky "Weekly alcohol consumption (drinks)"

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
* 5. Label controls (variables already clean)
*------------------------------------------------------

label var dhhgage   "Age group"
label var DHH_SEX   "Sex at birth"
label var EHG2DVH3  "Education (3 levels)"
label var incdgrca  "Income quintile (national)"
label var geogprv   "Province"
label var sdcdvfla  "Visible minority flag"
label var sdcdvimm  "Immigrant status"

*------------------------------------------------------
* 6. Survey weighting
*------------------------------------------------------

svyset [pweight = WTS_M]

*------------------------------------------------------
* 7. BASELINE MODEL
*------------------------------------------------------

display "===== BASELINE MODEL: mh_good on weekly alcohol ====="

svy: logistic mh_good c.alwdvwky, or

*------------------------------------------------------
* 8. EXTENDED MODEL (with controls)
*   Ontario (35) set as reference: ib35.geogprv
*------------------------------------------------------

display "===== EXTENDED MODEL: add controls ====="

svy: logistic mh_good ///
    c.alwdvwky ///
    i.dhhgage ///
    i.DHH_SEX ///
    i.EHG2DVH3 ///
    i.incdgrca ///
    ib35.geogprv ///
    i.sdcdvfla ///
    i.sdcdvimm, or


*------------------------------------------------------
* Weighting
*------------------------------------------------------
svyset [pweight = WTS_M]

*------------------------------------------------------
* Install estout if needed
*------------------------------------------------------
capture ssc install estout

*------------------------------------------------------
* BASELINE MODEL
*------------------------------------------------------
svy: logistic mh_good c.alwdvwky, or
estimates store baseline

*------------------------------------------------------
* EXTENDED MODEL
*------------------------------------------------------
svy: logistic mh_good ///
    c.alwdvwky ///
    i.dhhgage ///
    i.DHH_SEX ///
    i.EHG2DVH3 ///
    i.incdgrca ///
    ib35.geogprv /// Ontario base
    i.sdcdvfla ///
    i.sdcdvimm, or
estimates store extended

*------------------------------------------------------
* EXPORT TABLE (THIS IS WHAT YOU NEED)
*------------------------------------------------------
esttab baseline extended using "mh_logit_results.rtf", ///
    replace ///
    eform ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N, fmt(0) labels("N")) ///
    label ///
    title("Weighted Logistic Regression: Good Mental Health (Odds Ratios)")
log close

exit
