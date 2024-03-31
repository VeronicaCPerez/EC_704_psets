cd "/Users/veronica/Dropbox/PhD/2024_1/EC_704_Macro_Theory/EC_704_psets/pset1/make_704_data"
set more off

clear
insheet using 704_weekly.csv
ren observation_date date
gen yr = substr(date,1,4)
gen month = substr(date,6,2)
destring yr month, replace
drop date
gen date = ym(yr,month)
drop yr month
gen qtr = qofd(dofm(date))
collapse (mean) ff, by(qtr)
keep ff qtr
ren ff fedfunds
save 704.dta, replace

clear
insheet using 704_monthly.csv
ren observation_date date
gen yr = substr(date,1,4)
gen month = substr(date,6,2)
destring yr month, replace
drop date
gen date = ym(yr,month)
drop yr month
gen qtr = qofd(dofm(date))
collapse (mean) m2sl, by(qtr)
keep m2sl qtr
ren m2sl m2
merge 1:1 qtr using 704.dta
keep if _m == 3
drop _m
save 704.dta, replace

clear
insheet using 704_quarterly.csv
ren observation_date date
gen yr = substr(date,1,4)
gen month = substr(date,6,2)
destring yr month, replace
drop date
gen date = ym(yr,month)
drop yr month
gen qtr = qofd(dofm(date))
merge 1:1 qtr using 704.dta
keep if _m == 3
drop _m
drop date

ren hoabs hours
ren compnfb wages
ren cp corp_profits
ren gdpc1 gdp_pc
ren gdpdef prices
ren gpdic1 investment
ren pcecc96 consumption
save 704.dta, replace

// corp profits to real
replace corp_profits = corp_profits / prices
// Create labor prod
gen labor_prod = gdp_pc / hours
// create m2 growth
tsset qtr, quarterly
gen lm2_growth = log(m2) - log(L.m2)
save 704.dta, replace

// Merge in Romer-Romer shocks from Wieland
ren qtr date
merge 1:1 date using RR_monetary_shock_quarterly.dta
drop _m
ren resid rrshock_original
drop resid_romer
ren resid_full rrshock_updated
ren date qtr
label var rrshock_original "Original Romer-Romer Shock"
label var rrshock_updated "Updated Romer-Romer Shock by Wieland"

tsset qtr, quarterly
save 704.dta ,replace

gen lgdp_pc = log(gdp_pc)
gen lconsumption = log(consumption)
gen lprices = log(prices)
gen linvestment = log(investment)
gen lwages = log(wages)
gen llabor_prod = log(labor_prod)
replace fedfunds = -fedfunds // negative so response to expansion
gen lcorp_profits = log(corp_profits)
gen lhours = log(hours)
gen linflation = (log(prices) - log(L.prices))

tsfilter hp gdp_pc_hp = lgdp_pc, smooth(1600)
tsfilter hp consumption_hp = lconsumption, smooth(1600)
tsfilter hp prices_hp = lprices, smooth(1600)
tsfilter hp inflation_hp = linflation, smooth(1600)
tsfilter hp investment_hp = linvestment, smooth(1600)
tsfilter hp wages_hp = lwages, smooth(1600)
tsfilter hp labor_prod_hp = llabor_prod, smooth(1600)
tsfilter hp fedfunds_hp = fedfunds, smooth(1600)
tsfilter hp corp_profits_hp = lcorp_profits, smooth(1600)
tsfilter hp m2_growth_hp = lm2_growth, smooth(1600)
tsfilter hp lhours_hp = lhours, smooth(1600)

// convert to percent
replace gdp_pc_hp = gdp_pc_hp * 100
replace consumption_hp = consumption_hp * 100 
replace prices_hp = prices_hp * 100
replace inflation_hp = inflation_hp * 400 // annual
replace investment_hp = investment_hp * 100
replace wages_hp = wages_hp * 100
replace lhours_hp = lhours_hp * 100
replace labor_prod_hp = labor_prod_hp * 100
replace corp_profits_hp = corp_profits_hp * 100
replace m2_growth_hp = m2_growth_hp * 400 // annual

format qtr %tq
keep if yofd(dofq(qtr)) < 2020
save 704.dta ,replace
