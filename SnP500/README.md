# Predict how the S&P US stock index develops short-term

Get the S & P 500 US index trend based on an arbitrary sample count back in time
and an arbitrary number of dynamically adaptive predictions ahead (to the degree the data samples and laws of nature allows).

Yahoo Finance CSV data is used, so that's where you get the CSV file:
https://finance.yahoo.com/quote/%5EGSPC/history/

^GSPC / S&P 500.

Copyright (C) Joakim Borger Svendsen, Svendsen Tech.
All rights reserved. GNU Public license v3.

To get the S&P 500 US stock index predictions, I use trend line math to calculate
the "next step", then include that in the new, resulting set, and repeat this process
once for each prediction wanted ahead, before returning the numbers that are presented to you.

I would call this a mathematical trend-line-predictive, dynamically adaptive algorithm for the
US S&P 500 Stock Index' future development. How accurate it is remains highly debatable. In my
own opinion it is simply an indicator - and a quite weak one. It completely ignores everything
but the math/numbers, but then again the graphs with sliding averages and such often seem
eerily accurate. Use it at your own will.

It can be used to identify changes in short-term trends.

In addition to this, I included parameters for great flexibility in the data set used
to calculate, except (at least) one flaw, in that I only focus on the *latest* measurements, so
this tool is currently not suited for "retro-analysis", meaning looking at periods 
back in time, and omitting the present, predicting from, say January 1982
to February 1982, to see if it matches. The assumed need for this is in less demand
than the present becoming future, since the latter is where life will take place, but it's
on the to do list.

# Graph

This is a graph of the trend line over an increasing number of samples back, as seen in the "more advanced" example below.

![excel-snp500-example-graph](/SnP500/Images/Get-SnP500Trend-example-excel-graph.jpg)

# Examples

## Basic

Based on 10 samples back and making 10 predictions ahead. Tip! Use " | Select-Object -Last 30" for only the last 30 results if basing it on a lot of samples back or making a lot of predictions ahead, and not wanting to see all the clutter.

Another tip: Add " | Export-Csv -NoType -Path snp500-predictions.csv" to create a CSV file to open in Excel.

```
PS C:\temp> Get-SnP500Trend -FilePath .\^GSPC.csv -SamplesBackCount 10 `
    -PredictionsAheadCount 10

Date                Rate        Count
----                ----        -----
2018-12-26 00:00:00 2467.699951     1
2018-12-27 00:00:00 2488.830078     2
2018-12-28 00:00:00 2485.739990     3
2018-12-31 00:00:00 2506.850098     4
2019-01-02 00:00:00 2510.030029     5
2019-01-03 00:00:00 2447.889893     6
2019-01-04 00:00:00 2531.939941     7
2019-01-07 00:00:00 2549.689941     8
2019-01-08 00:00:00 2574.409912     9
2019-01-09 00:00:00 2584.959961    10
2019-01-10 03:47:18 2597.004071    11
2019-01-10 03:47:18 2609.773521    12
2019-01-10 03:47:18 2622.961437    13
2019-01-10 03:47:18 2636.402271    14
2019-01-10 03:47:18 2650.002083    15
2019-01-10 03:47:18 2663.705230    16
2019-01-10 03:47:18 2677.477521    17
2019-01-10 03:47:18 2691.297263    18
2019-01-10 03:47:18 2705.150305    19
2019-01-10 03:47:18 2719.027182    20
```

Based on 20 samples back and still 10 predictions ahead. Also an example of "Select -Last" to limit results displayed.

```
PS C:\temp> Get-SnP500Trend -FilePath .\^GSPC.csv -SamplesBackCount 20 `
    -PredictionsAheadCount 10 | Select -Last 20

Date                Rate        Count
----                ----        -----
2018-12-26 00:00:00 2467.699951    11
2018-12-27 00:00:00 2488.830078    12
2018-12-28 00:00:00 2485.739990    13
2018-12-31 00:00:00 2506.850098    14
2019-01-02 00:00:00 2510.030029    15
2019-01-03 00:00:00 2447.889893    16
2019-01-04 00:00:00 2531.939941    17
2019-01-07 00:00:00 2549.689941    18
2019-01-08 00:00:00 2574.409912    19
2019-01-09 00:00:00 2584.959961    20
2019-01-10 03:57:58 2580.701056    21
2019-01-10 03:57:58 2577.732937    22
2019-01-10 03:57:58 2575.734184    23
2019-01-10 03:57:58 2574.472991    24
2019-01-10 03:57:58 2573.779720    25
2019-01-10 03:57:58 2573.528554    26
2019-01-10 03:57:58 2573.625027    27
2019-01-10 03:57:58 2573.997403    28
2019-01-10 03:57:58 2574.590638    29
2019-01-10 03:57:58 2575.362083    30
```

## More advanced

Here I predict the rate of the S&P index 10 working days from now based on 10, 20, 30 ... to ... 490, 500 samples. First I export it to CSV in the screenshot, then I demonstrate how to show it "live" in the text example.

![snp500-example](/SnP500/Images/Get-SnP500Trend-example.jpg)

Text example:

```
PS C:\temp> 1..500 | Where { $_ % 10 -eq 0 } | foreach {
    [PSCustomObject] @{
        SamplesBack = $_
        Rate = (Get-SnP500Trend -FilePath .\^GSPC.csv -SamplesBackCount $_ `
    -PredictionsAheadCount 10 | select -Last 1).Rate } }

SamplesBack        Rate
-----------        ----
         10 2719.027182
         20 2575.362083
         30 2514.757663
         40 2523.432923
         50 2533.631919
         60 2538.953612
         70 2533.529239
         80 2532.584177
         90 2536.653974
        100 2542.210897
        110 2548.372599
        120 2554.165615
        130 2559.623655
        140 2565.322257
        150 2568.421793
        160 2571.934647
        170 2574.812782
        180 2578.080067
        190 2580.196636
        200 2582.503698
        210 2583.074025
        220 2583.386995
        230 2584.004204
        240 2583.890054
        250 2583.364490
        260 2583.726123
        270 2584.337866
        280 2585.094598
        290 2586.051188
        300 2586.846843
        310 2587.600504
        320 2588.314338
        330 2589.101077
        340 2589.860075
        350 2590.638599
        360 2591.197926
        370 2591.594253
        380 2592.003882
        390 2592.405165
        400 2592.695441
        410 2592.966444
        420 2593.285781
        430 2593.528669
        440 2593.830533
        450 2594.049135
        460 2594.211412
        470 2594.295093
        480 2594.395961
        490 2594.611629
        500 2594.812072
```

And here's a graph of the same:

![excel-snp500-example-graph](/SnP500/Images/Get-SnP500Trend-example-excel-graph.jpg)

## With 1-10 predictions ahead for 10 and 20 samples back

```
PS C:\temp> 10, 20 | foreach {
    foreach ($p in 1..10) { 
        [PSCustomObject] @{
            SamplesBack = $_
            Rate = (Get-SnP500Trend -FilePath .\^GSPC.csv -SamplesBackCount $_ `
        -PredictionsAheadCount $p | select -Last 1).Rate
            PredictionCount = $p } } }

SamplesBack        Rate PredictionCount
-----------        ---- ---------------
         10 2597.004071               1
         10 2609.773521               2
         10 2622.961437               3
         10 2636.402271               4
         10 2650.002083               5
         10 2663.705230               6
         10 2677.477521               7
         10 2691.297263               8
         10 2705.150305               9
         10 2719.027182              10
         20 2580.701056               1
         20 2577.732937               2
         20 2575.734184               3
         20 2574.472991               4
         20 2573.779720               5
         20 2573.528554               6
         20 2573.625027               7
         20 2573.997403               8
         20 2574.590638               9
         20 2575.362083              10
```

## 10 and 20 predictions based on 2-20 samples back

```
PS C:\temp> 2..20 | foreach {
    foreach ($p in 10, 20) { 
        [PSCustomObject] @{
            SamplesBack = $_
            Rate = (Get-SnP500Trend -FilePath .\^GSPC.csv -SamplesBackCount $_ `
        -PredictionsAheadCount $p | select -Last 1).Rate
            PredictionCount = $p } } } | sort PredictionCount, Rate, SamplesBack | ft -a 

SamplesBack        Rate PredictionCount
-----------        ---- ---------------
         20 2575.362083              10
         19 2587.603351              10
         18 2606.135388              10
         17 2630.891695              10
         16 2654.540729              10
         15 2674.623073              10
          2 2690.460451              10
         14 2701.497336              10
         10 2719.027182              10
          9 2725.329493              10
         13 2726.649181              10
          8 2742.781455              10
         12 2746.867352              10
         11 2751.717512              10
          3 2753.382175              10
          7 2758.599086              10
          4 2761.643526              10
          6 2800.244649              10
          5 2870.165271              10
          
         20 2588.038206              20
         19 2611.598329              20
         18 2646.664623              20
         17 2693.097307              20
         16 2737.445200              20
         15 2775.192702              20
          2 2795.960941              20
         14 2825.420512              20
         10 2858.298170              20
          9 2870.594345              20
         13 2872.401559              20
          8 2904.004702              20
         12 2910.176298              20
         11 2919.309860              20
          3 2920.559534              20
          7 2934.393341              20
          4 2937.002575              20
          6 3014.208302              20
          5 3148.523156              20
```

## Every fifth sample 100 days back, 10 predictions ahead

```
PS C:\temp> 2..100 | Where { $_ % 5 -eq 0 } | foreach {
    foreach ($p in 10) { 
        [PSCustomObject] @{
            SamplesBack = $_
            Rate = (Get-SnP500Trend -FilePath .\^GSPC.csv -SamplesBackCount $_ `
        -PredictionsAheadCount $p | select -Last 1).Rate
            PredictionCount = $p } } } | sort PredictionCount, Rate, SamplesBack | ft -a 

SamplesBack        Rate PredictionCount
-----------        ---- ---------------
         30 2533.977397              10
         45 2537.579240              10
         40 2541.423615              10
         35 2542.854414              10
         80 2545.390241              10
         75 2545.529407              10
         50 2545.964568              10
         85 2546.912401              10
         70 2547.362695              10
         90 2548.947546              10
         95 2550.859942              10
         65 2551.726017              10
         55 2552.192190              10
         60 2552.197674              10
        100 2553.902403              10
         25 2563.330683              10
         20 2610.464246              10
         15 2716.226041              10
         10 2737.819851              10
          5 2753.873020              10
```
