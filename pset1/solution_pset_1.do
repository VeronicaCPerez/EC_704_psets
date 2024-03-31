clear all
set more off

cd "/Users/veronica/Dropbox/PhD/2024_1/EC_704_Macro_Theory/EC_704_psets/pset1"

use "make_704_data/704.dta", clear
//
//
// * FRISCH ELASTICITY = 1/phi = 1
//
// * GAMMA = IS CRRA = 2
// * ALPHA = 2/3
// * ALPHA = 2/3
//
// * LABOR WEDGE = log(Nt)(1+\phi) + gamma*(logC) - log(Y)
// * 1 + phi = 1.6666667
//
// *********************
// ***		G 2 A	  ***
// *********************
//
// tsset qtr
//
// gen l_labor_wedge_hp = 2*lhours_hp + 2*consumption_hp - gdp_pc_hp
//
// tsline l_labor_wedge_hp gdp_pc_hp, legend(order(1 "labor wedge" 2 "GDP pc")) ///
// 			graphregion(color(white)) 
//			
// graph export "/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_2/g_2_a.png", replace
//
//
// *********************
// ***		G 2 B	  ***
// *********************
//
// gen l_MRS_hp = l_labor_wedge_hp + wages_hp
//
// gen lab_market_dist = wages_hp - prices_hp - l_MRS_hp
// gen product_market_dist = labor_prod_hp - wages_hp + prices_hp
//
// * why isn't the inverse ^-1
// gen l_labor_wedge_hp_inv = l_labor_wedge_hp*-1
//
// tsline product_market_dist lab_market_dist l_labor_wedge_hp_inv, ///
// 						legend(order(1 "product market distortion" ///
// 									2  "labor market distortion" ///
// 									3 "labor wedge inverse")) ///
// 									graphregion(color(white)) ///
// 									lpatter("l" "l" "-") ///
// 									lwidth("medium" "medium" "medthin")
//
//
// graph export "/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_2/g_2_b.png", replace
//
//
// *********************
// ***		G 3 A	  ***
// *********************
//
//
// /*
// Run a VAR with four lags on three variables: Real GDP Per Captia, Inflation, 
// and the Fed Funds rate. You should use the HP filtered versions, which are 
// denoted by \_hp at the end
// */
//
// /*
// "var [variables], lags(1/4)" runs a VAR with your variables with four lags.
// */
//
// /*
// "irf create [order name], order([variables ordered]) step([periods]) set([irf file name],
// replace)" creates an IRF with the ordering you describe in order that lasts
// for 20 periods. It is saved in irf file name.
// */
//
// /*
// "irf graph oirf, impulse([impulse var]) response([response variables]) byopts(yrescale)"
// creates IRF graphs. OIRF is an orthogonalized impulse response (Cholesky) rather 
// than the reduced form response. Impulse controls the impulse variable and response 
// the response variables. Byopts(yrescale) makes it so that each graph uses its own 
// y axis scale rather than a common y axis scale. Note that this is an impulse 
// response to a one standard deviation shock to impulse va
// */
//
// /* (a) Run a VAR with four lags on three variables: Real GDP Per Captia, 
// Inflation, and the Fed Funds rate. You should use the HP filtered versions, 
// which are denoted by hp at the end.*/
//
// var gdp_pc_hp prices_hp fedfunds_hp, lags(1/4)
//
// // i. Show the impulse response functions for 20 quarters for 
// // these three variables to a fed funds shock.
//
// irf create o_1, order(gdp_pc_hp prices_hp fedfunds_hp) step(20) ///
// 		set("/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_2/order1_irf", replace) 
//
// irf graph oirf, impulse(fedfunds_hp) response(gdp_pc_hp prices_hp fedfunds_hp)
// graph export "/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_2/2_irf_1.png", replace
//
//
// // ii. Explain your impulse responses and how they relate to monetary non-neutrality. What do they show? What is problematic?
//
//
// /* (b) Run a VAR with four lags with the nine HP filtered variables ordered in 
// the order above as in CEE. Plot the impulse responses to an expansionary shock 
// to the fed funds rate (Stata defaults to a positive shock, which is why I have 
// multiplied FFR by -1). */
//
// var gdp_pc_hp consumption_hp prices_hp investment_hp wages_hp labor_prod_hp fedfunds_hp corp_profits_hp m2_growth_hp, lags(1/4)
//
// * i. Explain each of the relationships and how they relate to monetary non- neutrality.
//
// irf create o_2, order(gdp_pc_hp consumption_hp prices_hp investment_hp wages_hp labor_prod_hp fedfunds_hp corp_profits_hp m2_growth_hp) step(20) set("/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_2/order2_irf", replace) 
//
// irf graph oirf, impulse(fedfunds_hp) response(gdp_pc_hp consumption_hp prices_hp investment_hp wages_hp labor_prod_hp fedfunds_hp corp_profits_hp m2_growth_hp) byopts(yrescale legend(off)) 
// graph export "/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_2/2_irf_2.png", replace
//
// * ii. Has the CEE VAR fixed the issues you identified in part a? How? Do you believe the results?
//
// /* (c) Run a VAR with four lags with the Romer-Romer (2004) shocks as updated by Johannes Wieland, which you can find in "rrshock updated" in the data set.
//
// */
//
// twoway tsline rrshock_updated if !missing(rrshock_updated), xtitle("Qrtr") graphregion(color(white))
// graph export "/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_2/shock.png", replace 
//
// gen cumrrshock = -1*sum(rrshock_updated)
//
//
// //iii, a
// var lgdp_pc linflation cumrrshock, lags(1/4)
//
// irf create o_3_romer, order(lgdp_pc linflation cumrrshock) step(20) set(romer_irf, replace)
//
// irf graph oirf, impulse(cumrrshock) response(lgdp_pc linflation cumrrshock) byopts(yrescale legend(off)) 
// graph export "/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_2/2_irf_3.png", replace
//
//
// //iii, b
// var lgdp_pc lprices cumrrshock, lags(1/4)
//
// irf create o_4_romer, order(lgdp_pc lprices cumrrshock) step(20) set(romer2_irf, replace)
//
// irf graph oirf, impulse(cumrrshock) response(lgdp_pc lprices cumrrshock)  byopts(yrescale legend(off)) 
// graph export "/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_2/2_irf_4.png", replace


/* (d)



*/
local hmax = 20
gen horizon = _n - 1 if _n <= `hmax'
gen zero = 0 if _n <= `hmax'

gen neg_rrshockupdates = -1*rrshock_updated

foreach y in fedfunds lgdp_pc lprices linflation {
  gen `y'_est = .
  gen `y'_ub = .
  gen `y'_lb = .

  forvalues h = 0/`hmax' {
    newey f`h'.`y' l(0/2).neg_rrshockupdates l(1/2).fedfunds l(1/2).lgdp_pc l(1/2).lprices, lag(`=`h'+1')
    replace `y'_est = _b[neg_rrshockupdates] if _n == `h'+1
    replace `y'_ub = _b[neg_rrshockupdates] + 1.645 * _se[neg_rrshockupdates] if _n == `h'+1
    replace `y'_lb = _b[neg_rrshockupdates] - 1.645 * _se[neg_rrshockupdates] if _n == `h'+1
  }
}

foreach pair in "fedfunds federal funds rate" "lgdp_pc output" "lprices prices" "linflation inflation" {
  gettoken y desc : pair
  twoway ///
  (rarea `y'_ub `y'_lb horizon,  ///
  fcolor(dimgray) lcolor(dimgray) lw(none) lpattern(solid)) ///
  (line `y'_est horizon, lcolor(green) lpattern(solid) lwidth(medthick)) ///
  (line zero horizon, lcolor(black)), legend(off) ///
  title("`desc' to Romer Shock", color(black) size(medsmall)) ///
  ytitle("%", size(medsmall)) xtitle("quarters post shock", size(medsmall)) ///
  graphregion(color(white)) plotregion(color(white)) ///
  name(p_`y', replace) nodraw
}

graph combine p_fedfunds p_lprices p_lgdp_pc p_linflation, ///
      rows(2) cols(2) graphregion(color(white)) name(combined, replace)
graph export "/Users/veronica/Dropbox/Apps/Overleaf/EC_704_vcperez/pset_2/2_irf_d.png", replace


