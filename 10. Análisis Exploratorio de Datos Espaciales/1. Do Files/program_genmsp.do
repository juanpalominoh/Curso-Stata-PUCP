
program genmsp, sortpreserve
version 12.1
syntax varname, Weights(name) [Pvalue(real 0.05)]
unab Y : `varlist'
tempname W
matrix `W' = `weights'
tempvar Z
qui summarize `Y'
qui generate `Z' = (`Y' - r(mean)) / sqrt( r(Var) * ( (r(N)-1) / r(N) ) )
qui cap drop std_`Y'
qui generate std_`Y' = `Z'
tempname z Wz
qui mkmat `Z', matrix(`z')
matrix `Wz' = `W'*`z'
matrix colnames `Wz' = Wstd_`Y'
qui cap drop Wstd_`Y'
qui svmat `Wz', names(col)
qui spatlsa `Y', w(`W') moran
tempname M
matrix `M' = r(Moran)
matrix colnames `M' = __c1 __c2 __c3 zval_`Y' pval_`Y'
qui cap drop __c1 __c2 __c3
qui cap drop zval_`Y'
qui cap drop pval_`Y'
qui svmat `M', names(col)
qui cap drop __c1 __c2 __c3
qui cap drop msp_`Y'
qui generate msp_`Y' = .
qui replace msp_`Y' = 1 if std_`Y'<0 & Wstd_`Y'<0 & pval_`Y'<`pvalue'
qui replace msp_`Y' = 2 if std_`Y'<0 & Wstd_`Y'>0 & pval_`Y'<`pvalue'
qui replace msp_`Y' = 3 if std_`Y'>0 & Wstd_`Y'<0 & pval_`Y'<`pvalue'
qui replace msp_`Y' = 4 if std_`Y'>0 & Wstd_`Y'>0 & pval_`Y'<`pvalue'
lab def __msp 1 "Low-Low" 2 "Low-High" 3 "High-Low" 4 "High-High", modify
lab val msp_`Y' __msp
end
exit
