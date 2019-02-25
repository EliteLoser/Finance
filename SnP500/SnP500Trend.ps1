function Get-TrendLine {
    <#
    .SYNOPSIS   
        Calculate the linear trend line from a series of numbers

    .DESCRIPTION
        Assume you have an array of numbers
    
        $inarr = @(15, 16, 12, 11, 14, 8, 10)
    
    and the trendline is represented as
    
        y = a + bx
    
    where y is the element in the array
        x is the index of y in the array.
        a is the intercept of trendline at y axis
        b is the slope of the trendline

    Calling the function with
    
    PS> Get-Trendline -Data $inarr
    
    will return an array of a and b.
    
    .PARAMETER Data
        A one dimensional array containing the series of numbers.

    .EXAMPLE  
        Get-Trendline -Data @(15, 16, 12, 11, 14, 8, 10)
    #>
    Param ([System.Object[]] $Data)
    
    [Decimal] $n = $Data.Count
    [Decimal] $SumX = 0
    [Decimal] $SumX2 = 0
    [Decimal] $SumXY = 0
    [Decimal] $SumY = 0
    
    foreach ($i in 1..$n) { #$i=1; $i -le $n; $i++) 
    
        $SumX += $i
        $SumX2 += [Math]::Pow($i, 2)
        $SumXY += $i * $Data[$i - 1]
        $SumY += $Data[$i-1]
    
    }
    
    $b = ($SumXY - $SumX * $SumY / $n) / ($SumX2 - $SumX * $SumX / $n)
    $a = $SumY / $n - $b * ($SumX / $n)
    
    @($a, $b)

}

function Get-SnP500Trend {
    <#

        .SYNOPSIS

            Get the S & P 500 US index trend based on an arbitrary sample count back in time
            and an arbitrary number of dynamically adaptive predictions ahead.

            Yahoo Finance CSV data is used, so that's where you get the CSV file:
            https://finance.yahoo.com/quote/%5EGSPC/history/

            ^GSPC / S&P 500.

            Copyright (C) Joakim Borger Svendsen, Svendsen Tech.
            All rights reserved.

            GNU Public license v3.

        .DESCRIPTION
            
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
            than the present becoming future, since the latter is where life will take place, but it's
            on the to do list.
        
        .PARAMETER FilePath
            Path to Yahoo Finance CSV file. The standard name as of 2019-01-10 is "^GSPC.csv",
            with a comma as a delimiter in the file. The required headers are assumed to have the names
            "Date" and "Close", but can be overridden.
            
            https://finance.yahoo.com/quote/%5EGSPC/history/
            Choose "Max" for time range and then "Download data".

        .PARAMETER SamplesBackCount
            The number of samples back to base the predictive trend line analysis on.

        .PARAMETER PredictionsAheadCount
            The number of predictions ahead to make. Interesting numbers seem to be in the range 5-20
            or so (to me, based on very limited analyses of also other stocks in this way).

        .PARAMETER Precision
            Number of digits after the decimal separator to display (trailing zeroes are removed by
            [Math]::Round()).

        .PARAMETER LatestFirst
            Switch parameter (don't pass anything to it). If the latest dates are first rather than
            last in the CSV at the time you do this, or you're processing something else in the future
            when this tool is more flexible, you can reverse the order of the data internally in the
            program to handle this seamlessly for you.

            Currently not needed as of January 2019!

        .PARAMETER ExportToCSV
            If you're not that comfortable with PowerShell, you might want to export to a CSV directly
            with this parameter. A (then) mandatory verbose message will tell you the name of the file,
            which by default is put in the current working folder where you started the command from.

        .PARAMETER DateHeader
            If working with other sources than the Yahoo finance data, you can use this to indicate the
            CSV header field title for "date". It needs to be able to be converted to a .NET DateTime
            object for things to work properly.
            
        .PARAMETER RateHeader
            If working with other sources than the Yahoo finance data, you can use this to indicate the
            CSV header field title for "rate" or number you want to use for calculations. Current culture
            settings are used for the number format.

        .LINK
            
    #>
    [CmdletBinding()]
    Param(
        [System.String] $FilePath,
        [System.Int32] $SamplesBackCount = 21,
        [System.Int32] $PredictionsAheadCount = 21, # 21 is about an average month
        [System.Byte] $Precision = 6,
        [Switch] $LatestFirst,
        [Switch] $ExportToCSV,
        [System.String] $DateHeader = "Date",
        [System.String] $RateHeader = "Close")
    
    Begin {

        $FilePath2 = Get-Item -LiteralPath (Resolve-Path -LiteralPath $FilePath) -ErrorAction Stop
    
        Write-Verbose "[$([DateTime]::Now)] Processing $($FilePath2.Name)."

        $Rates = @(Import-Csv -LiteralPath $FilePath2.FullName -ErrorAction Stop)
        
        if ($LatestFirst) {
            $Rates = $Rates[-1..-($Rates.Count)] | Select-Object -Last $SamplesBackCount
        }
        else {
            $Rates = @($Rates | Select-Object -Last $SamplesBackCount)
        }

        if ($Rates.Count -lt $SamplesBackCount) {
            Write-Warning "The number of samples back you requested is greater than the number of data samples available in the CSV file. Will still continue with maximum available."
        }
    }
    Process {
        [Decimal] $WeekDayCounter = 0
        foreach ($i in 1..$PredictionsAheadCount) {
            # Not accounting for weekends/holidays, just tagging with "now".
            $Rates += @([PSCustomObject] @{
                $RateHeader = [Math]::Round([Decimal] $Rates[-1].$RateHeader + (Get-TrendLine -Data $Rates.$RateHeader)[-1], $Precision)
                $DateHeader = [DateTime]::Now.ToString('yyyy\-MM\-dd')
            })
        }

        [Decimal] $Counter = 0
        if ($ExportToCSV) {
            $ExportFileName = $FilePath.Name -replace '\.csv', "-prediction-$([DateTime]::Now.ToString('yyyy\-MM\-dd')).csv"
            $Rates[(-1 * ($SamplesBackCount + $PredictionsAheadCount))..-1] | ForEach-Object {
                [PSCustomObject] @{
                    $DateHeader = ([DateTime] $_.$DateHeader).ToString('yyyy\-MM\-dd')
                    $RateHeader = $_.$RateHeader
                    Count = ++$Counter
                }
            } | Export-Csv -NoTypeInformation -LiteralPath $ExportFileName -Encoding UTF8
        }
        else {
            $Rates[(-1 * ($SamplesBackCount + $PredictionsAheadCount))..-1] | ForEach-Object {
                [PSCustomObject] @{
                    Date = ([DateTime] $_.$DateHeader).ToString('yyyy\-MM\-dd')
                    Rate = $_.$RateHeader
                    Count = ++$Counter
                }
            }
        }
    }
    End {
    }
}

