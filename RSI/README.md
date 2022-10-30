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

The corner case of an exactly zero (0) development is handled as a loss.
Arguably inflation makes it so, among other things, if working with financial data.
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
the default $FirstStepSampleCount). `14*14 = 196`.

The traditional RSI formula uses `14*14` numbers. This parameter allows you to
specify a different count for your RSI calculation. If you provide the switch
parameter -GetSecondStep, the number of -Numbers you need is this number plus one
(to get $SecondStepSampleCount percentages, the first calculated and used percentage 
requires a "starting number").

# Examples where I get the RSI number for Bitcoin and Ethereum prices

Here I get the RSI value of the last 197 five-minute intervals as of the evening of 2022-10-30 (happy Halloween!).

```
PS C:\> $EthPrices = gci "$MyHome\coinmarketcapdata_5m\*.json" | 
    sort-object LastWriteTime | 
    select-object -last 197 | 
    %{ ((gc -raw $_.fullname) | 
    ConvertFrom-Json).data.where({
    $_.slug -eq 'ethereum'}).quote.usd.price }
PS C:\> $EthPrices.Count                                                                                               
197
PS C:\> $EthPrices[0,-1]                                                                                               
1619.804828821538
1588.1437982934824
PS C:\> Get-RSI -Numbers $EthPrices -GetSecondStep                                                                     

RsiStepOnesCalulationsForStepTwo : {@{Numbers=System.Decimal[]; Percentages=System.Object[]; Gains=System.Object[];    
                                   AverageGain=0.0332195783966708; Losses=System.Object[];
                                   AverageLoss=-0.0143569386067286; SampleCount=14; RSIStepOne=69.8234769777225;       
                                   DateTime=10/30/2022 11:11:06 PM}, @{Numbers=System.Decimal[];
                                   Percentages=System.Object[]; Gains=System.Object[];
                                   AverageGain=0.0828497999703561; Losses=System.Object[];
                                   AverageLoss=-0.0259971421649874; SampleCount=14; RSIStepOne=76.1158727521607;       
                                   DateTime=10/30/2022 11:11:06 PM}, @{Numbers=System.Decimal[];
                                   Percentages=System.Object[]; Gains=System.Object[];
                                   AverageGain=0.0182880118722195; Losses=System.Object[];
                                   AverageLoss=-0.0662359869957693; SampleCount=14; RSIStepOne=21.6364726197847;       
                                   DateTime=10/30/2022 11:11:06 PM}, @{Numbers=System.Decimal[];
                                   Percentages=System.Object[]; Gains=System.Object[];
                                   AverageGain=0.0286163046781352; Losses=System.Object[];
                                   AverageLoss=-0.0681690762665304; SampleCount=14; RSIStepOne=29.5667634913746;       
                                   DateTime=10/30/2022 11:11:06 PM}...}
RsiStepOnesString                : 69.82 - 76.12 - 21.64 - 29.57 - 15.51 - 72.93 - 37.96 - 26.01 - 72.43 - 45.24 -     
                                   26.99 - 70.55 - 72.06 - 26.68
RsiStepOnesAverage               : 47.39
SecondStepSampleCount            : 196
PreviousXAverageGain             : 0.0387438591514454
PreviousXAverageLoss             : -0.0471697208659479
RSIStepTwo                       : 44.08
Numbers                          : {1619.804828821538, 1619.8921283607126, 1619.9369185512846, 1621.1149589714098...}  
DateTime                         : 10/30/2022 11:11:06 PM

PS C:\>
```

Take note that this method relies on the "LastWriteTime" property being correct on the files. I recommend including an ISO8601 timestamp in the filename (or a variant of ISO8601, rather) so you can sort on the filename if something happens to the files, they are moved to another disk, etc. My files are named e.g. `crypto-json-coinmarketcap-top-100-2022-10-26_21_00_29.json`, which technically isn't ISO8601.

The "RsiStepOnesCalulationsForStepTwo" property is there in case you want to perform math operations or similar on the 14 RSI step ones that are combined to get the second step RSI number.

The "RsiStepOnesString" is a convenience property for visual inspection of the 14 RSI step ones that form the RSI step two number, in chronological order.

The average is also calculated for potential elucidation.

The "PreviousXAverageGain" number by default is the average gain based on the previous 13 average gain percentages for the RSI step one periods, which are then again averaged to produce this number. The same logic applies to "PreviousXAverageLoss", only for losses.

In the example above you have `0.0387` as the average gain and `-0.04717` as the average loss. This is as expected when the RSI step two is below 50, so it also serves as a sanity-check of the calculations. If the gains are higher than the losses, the RSI step two will be higher than 50. At least typically.

Some other, self-explanatory properties are included for convenience.

If you want to look at periods longer back in time than the minimum ~16.4 hours required with 5-minute samples and 197 files, you can do it in a myriad of ways. One is by skipping every other file (experienced programmers immediately smell the modulus operator here).

Example:

```
PS C:\> $EthPrices = gci "$MyHome\coinmarketcapdata_5m\*.json" | 
    sort-object Name | 
    select-object -last (197*2) | 
    %{ ((gc -raw $_.fullname) | 
    ConvertFrom-Json).data.where({
    $_.slug -eq 'ethereum'}).quote.usd.price
    } | ?{ ++$Counter % 2 -eq 0 }
PS C:\> 10/60*197 # hours back in time
32.8333333333333
PS C:\> $EthPrices.Count                                                                                               
197
PS C:\> $EthPrices[0,-1]                                                                                               
1615.3266220321711                                                                                                     
1579.9086598714698
PS C:\> Get-RSI -Numbers $EthPrices -GetSecondStep                                                                                                                                                                                                
RsiStepOnesCalulationsForStepTwo : {@{Numbers=System.Decimal[]; Percentages=System.Object[]; Gains=System.Object[];    
                                   AverageGain=0.118552230142012; Losses=System.Object[];
                                   AverageLoss=-0.0662788328239305; SampleCount=14; RSIStepOne=64.1408582732962;       
                                   DateTime=10/30/2022 11:39:41 PM}, @{Numbers=System.Decimal[];
                                   Percentages=System.Object[]; Gains=System.Object[]; AverageGain=0.123684936438782;  
                                   Losses=System.Object[]; AverageLoss=-0.0835699033685914; SampleCount=14;
                                   RSIStepOne=59.677707190692; DateTime=10/30/2022 11:39:41 PM},
                                   @{Numbers=System.Decimal[]; Percentages=System.Object[]; Gains=System.Object[];     
                                   AverageGain=0.140858104783539; Losses=System.Object[];
                                   AverageLoss=-0.159408976221101; SampleCount=14; RSIStepOne=46.9109381928425;        
                                   DateTime=10/30/2022 11:39:41 PM}, @{Numbers=System.Decimal[];
                                   Percentages=System.Object[]; Gains=System.Object[];
                                   AverageGain=0.0448580566053057; Losses=System.Object[];
                                   AverageLoss=-0.058203856808144; SampleCount=14; RSIStepOne=43.5253481325834;        
                                   DateTime=10/30/2022 11:39:41 PM}...}
RsiStepOnesString                : 64.14 - 59.68 - 46.91 - 43.53 - 30.8 - 48.75 - 63.91 - 75.73 - 6.85 - 62.67 -       
                                   31.43 - 42.75 - 55.13 - 32.11
RsiStepOnesAverage               : 47.46
SecondStepSampleCount            : 196
PreviousXAverageGain             : 0.0694764665884682
PreviousXAverageLoss             : -0.0780496502403001
RSIStepTwo                       : 46.2
Numbers                          : {1615.3266220321711, 1615.8547104505574, 1623.4563962101934, 1624.8523363985266...} 
DateTime                         : 10/30/2022 11:39:41 PM

PS C:\>
```

The part `| ?{ ++$Counter % 2 -eq 0 }` is a Where-Object filter that simply filters out every other element regardless of what's in the pipeline.

# Example of only RSI step one

If you want only step one, it will look like this:

```
PS C:\> $BitcoinPrices = gci "$MyHome\coinmarketcapdata_5m\*.json" | 
    sort-object Name |
    select-object -Last 15 |
    %{ ((gc -raw $_.fullname) |
    ConvertFrom-Json).data.where({
    $_.slug -eq 'bitcoin'}).quote.usd.price }
    
PS C:\> Get-RSI -Numbers $BitcoinPrices


Numbers     : {20683.39087974569, 20636.932529933252, 20622.68320123975, 20610.905983715078...}
Percentages : {-0.2246166988892162866040907400, -0.0690477069343216385629406400, -0.0571080756550825676848205400,      
              -0.0823152848923622277390376400...}
Gains       : {0.0271876288580736758650996400, 0.0909972287497142741226894700, 0.0047290034963246643462787700,
              0.0933473701018659342565856200...}
AverageGain : 0.0155862868644869
Losses      : {-0.2246166988892162866040907400, -0.0690477069343216385629406400, -0.0571080756550825676848205400,      
              -0.0823152848923622277390376400...}
AverageLoss : -0.0528753152082499
SampleCount : 14
RSIStepOne  : 22.7664652777586
DateTime    : 10/31/2022 12:18:49 AM

PS C:\>
```

Apparently Bitcoin is heavily oversold in the last hour or so.

