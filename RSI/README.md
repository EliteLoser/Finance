# SYNOPSIS
PowerShell RSI (Relative Strength Index) calculator.
This function calculates the (first or second) RSI value(s), by default
for a series of 15 numbers, to get 14 percentages, as 14 numbers is the standard to
base the calculations on.

MIT License. Author: Joakim Borger Svendsen. Copyright (C) Svendsen Tech 2022.
        
# DESCRIPTION
You can specify a sample count different from 14, and the (minimum) required number
of numbers is then your sample count plus one ($FirstStepSampleCount+1).
If you supply the -GetSecondStep switch parameter (no value), the number of
supplied numbers must be equal to -SecondStepSampleCount, plus one. By default
14*14+1 (197), for 14 standard periods. The second step smooths out the RSI number
and helps to avoid extremes (0 or 100 being the absolute extremeties).
The corner case of an exactly zero (0) development is handled as a loss
(arguably inflation makes it so, among other things, if working with financial data.
I wasn't sure how to handle it as my reference source (Investopedia) didn't mention
explicitly.
Reference for the RSI formula: https://www.investopedia.com/terms/r/rsi.asp
The relative strength index (RSI) is a momentum indicator used in technical 
analysis that measures the magnitude of recent price changes to evaluate 
overbought or oversold conditions in the price of a stock or other asset. 
The RSI is displayed as an oscillator (a line graph that moves between two
extremes) and can have a reading from 0 to 100. The indicator was originally 
developed by J. Welles Wilder Jr. and introduced in his seminal 1978 book, 
“New Concepts in Technical Trading Systems.”
The relative strength index (RSI) is a popular momentum indicator developed
in 1978.
The RSI provides technical traders with signals about bullish and bearish
price momentum, and it is often plotted beneath the graph of an asset's price.
An asset is usually considered overbought when the RSI is above 70 % and
oversold when it is below 30 %.
        
# PARAMETER Numbers
The numbers to calculate an RSI value for, such as 15 (or 197) stock market
close rates, hourly/whatever crypto currency data, or endless other types of data.
        
# PARAMETER FirstStepSampleCount
Sets the first step sample count to be used (default 14) for calculating RSI
step one.

The traditional RSI formula uses 14 data points/numbers. This parameter allows you
to specify a different count for your RSI calculation. The number of -Numbers
you need is this number plus one (to get $FirstStepSampleCount percentages, the first calculated 
and used percentage requires a "starting number").

# PARAMETER GetSecondStep
Switch parameter (takes no value) indicating you want the RSI second step on a larger
set of data than without this (only the first RSI step is calculated without this
parameter).
        
# PARAMETER SecondStepSampleCount
Sets the second step sample count which should be evenly divisible by $FirstStepSampleCount,
used for calculating the second step of the RSI formula. Default 14 * 14 (14 times
the default $FirstStepSampleCount). 14*14 = 196.
The traditional RSI formula uses 14*14 numbers. This parameter allows you to
specify a different count for your RSI calculation. If you provide the switch
parameter -GetSecondStep, the number of -Numbers you need is this number plus one
(to get $SecondStepSampleCount percentages, the first calculated and used percentage 
requires a "starting number").

