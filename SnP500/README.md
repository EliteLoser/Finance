# Predict how the S&P US stock index develops short-term

Get the S & P 500 US index trend based on an arbitrary sample count back in time
and an arbitrary number of dynamically adaptive predictions ahead.

Yahoo Finance CSV data is used, so that's where you get the CSV file:
https://finance.yahoo.com/quote/%5EGSPC/history/

^GSPC / S&P 500.

Copyright (C) Joakim Borger Svendsen, Svendsen Tech.
All rights reserved. GNU Public license v3.

To get the S&P 500 US stock index predictions, I use trend line math to calculate
the "next step", then include that in the new, resulting set, and repeat this process
once for each prediction wanted ahead, before returning the numbers that are presented to you.

I would call this a mathematical trend-line-predictive, dynamically adaptive algorithm for the
US S&P 500 Stock Exchange future development. How accurate it is remains highly debatable. In my
own opinion it is simply an indicator - and a quite weak one. It completely ignores everything
but the math/numbers, but then again the graphs with sliding averages and such often seem
eerily accurate. Use it at your own will.

It can be used to identify changes in short-term trends.

In addition to this, I included parameters for great flexibility in the data set used
to calculate, except (at least) one flaw, in that I only focus on the *latest* measurements, so
this tool is currently not suited for "retro-analysis", meaning looking at periods 
back in time, and omitting the present, predicting from, say January 1982
to February 1982, to see if it matches. The assumed need for this is in less demand
than the present becoming future, since the latter is where life takes place, but it's
on the to do list.

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

Here I predict the rate of the S&P index 10 working days from now based on 10, 20, 30 ... to ... 490, 500 samples.

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
