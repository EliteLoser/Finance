#requires -version 4
function Get-RSI {
    <#
    .SYNOPSIS
        PowerShell RSI (Relative Strength Index) calculator.

        This function calculates the (first or second) RSI value(s), by default
        for a series of 15 numbers, to get 14 percentages, as 14 numbers is the standard to
        base the calculations on.

    .DESCRIPTION
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

    .PARAMETER Numbers
        The numbers to calculate an RSI value for, such as 15 (or 197) stock market
        close rates, hourly/whatever crypto currency data, or endless other types of data.
    .PARAMETER FirstStepSampleCount
        Sets the first step sample count to be used (default 14) for calculating RSI
        step one.
    
        The traditional RSI formula uses 14 data points/numbers. This parameter allows you
        to specify a different count for your RSI calculation. The number of -Numbers
        you need is this number plus one (to get $FirstStepSampleCount percentages, the first calculated 
        and used percentage requires a "starting number").
    .PARAMETER GetSecondStep
        Switch parameter (takes no value) indicating you want the RSI second step on a larger
        set of data than without this (only the first RSI step is calculated without this
        parameter).
    .PARAMETER SecondStepSampleCount
        Sets the second step sample count which should be evenly divisible by $FirstStepSampleCount,
        used for calculating the second step of the RSI formula. Default 14 * 14 (14 times
        the default $FirstStepSampleCount). 14*14 = 196.

        The traditional RSI formula uses 14*14 numbers. This parameter allows you to
        specify a different count for your RSI calculation. If you provide the switch
        parameter -GetSecondStep, the number of -Numbers you need is this number plus one
        (to get $SecondStepSampleCount percentages, the first calculated and used percentage 
        requires a "starting number").
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline = $False)]
        [Decimal[]]$Numbers,
        [Int]$FirstStepSampleCount = 14,
        [Switch]$GetSecondStep,
        [Int]$SecondStepSampleCount = 14 * 14
    )
    Begin {
        Set-StrictMode -version Latest
        if ($Numbers.Count -lt ($FirstStepSampleCount + 1)) {
            Write-Error "With a sample count of $FirstStepSampleCount (default/traditional is 14), we need $($FirstStepSampleCount + 1) rates/numbers in order to calculate $FirstStepSampleCount percentages." -ErrorAction Stop
        }
        if ($GetSecondStep -and $Numbers.Count -lt ($SecondStepSampleCount + 1)) {
            Write-Error "With a second step sample count of $SecondStepSampleCount (default/traditional is 14 * 14), we need $($SecondStepSampleCount + 1) rates/numbers in order to calculate $SecondStepSampleCount percentages." -ErrorAction Stop
        }
        if (-not $GetSecondStep -and $Numbers.Count -gt ($FirstStepSampleCount + 1)) {
            Write-Verbose "You provided more numbers than the sample count for the formula dictates (plus one as a starting point). Be aware that the last $($FirstStepSampleCount + 1) samples were chosen to perform calculations on."
            $Numbers = $Numbers | Select-Object -Last ($FirstStepSampleCount + 1)
        }
        if ($GetSecondStep -and $Numbers.Count -gt ($SecondStepSampleCount + 1)) {
            Write-Verbose "You provided more numbers than the sample count for the formula dictates (plus one as a starting point). Be aware that the last $($SecondStepSampleCount + 1) samples were chosen to perform calculations on."
            $Numbers = $Numbers | Select-Object -Last ($SecondStepSampleCount + 1)
        }
        function Get-RsiFirstStepInternal {
            Param(
                [Decimal[]]$Numbers
            )
            [Bool]$FirstRun = $True
            $Percentages = @(foreach ($Number in $Numbers) {
                if ($FirstRun) {
                    #$PreviousNumber = $Numbers[0]
                    [Decimal]$PreviousNumber = $Number
                    $FirstRun = $False
                    continue
                }
                # This is returned, and collected in $Percentages.
                ($PreviousNumber - $Number) / $PreviousNumber * -100
                $PreviousNumber = $Number
            })
            # We need to add one 0 for each loss, for the gain average,
            # and vice versa: One 0 for each gain for the loss average.
            # Ensure the variablea are arrays using @() notation,
            # to account for the cases of only one loss or gain,
            # which would cause the += to not do what we want (add
            # the numbers together rather than append the number to an array,
            # and adding a bunch of zeroes amounts to a sophisticated NOOP
            # ("it does nothing")).
            $Gains = @($Percentages.Where({$_ -gt 0}))
            foreach ($Count in 1..($Percentages.Count - $Gains.Count)) {
                # Needed for a correct average according to the RSI formula.
                $Gains += 0
            }
            $AverageGain = $Gains | 
                Measure-Object -Average |
                Select-Object -ExpandProperty Average
            $Losses = @($Percentages.Where({$_ -le 0}))
            foreach ($Count in 1..($Percentages.Count - $Losses.Count)) {
                # Needed for a correct average according to the RSI formula.
                $Losses += 0
            }
            $AverageLoss = $Losses | 
                Measure-Object -Average |
                Select-Object -ExpandProperty Average
            $RsiStepOne = 100 - (100/( 1 + ( ($AverageGain/$FirstStepSampleCount) / (-1*$AverageLoss/$FirstStepSampleCount) )) )
            # Emit an object to the pipeline.
            [PSCustomObject]@{
                Numbers = $Numbers
                Percentages = $Percentages
                Gains = $Gains
                AverageGain = $AverageGain
                Losses = $Losses
                AverageLoss = $AverageLoss
                SampleCount = $FirstStepSampleCount
                RSIStepOne = $RsiStepOne
                DateTime = [datetime]::Now
            }
        }
    }
    Process {
        
        if (-not $GetSecondStep) {
            Get-RsiFirstStepInternal -Numbers $Numbers
        }
        else {
            $Periods = @{}
            foreach ($Index in 1..$SecondStepSampleCount) {
                $Periods[[String]$Index] = @()
            }
            $RsiStepOnesForStepTwo = @()
            [Decimal]$Counter = 0
            [Decimal]$PeriodCounter = 1
            [Decimal]$StartNumber = $Numbers | Select-Object -First 1
            foreach ($Number in $Numbers | Select-Object -Skip 1) {
                $Periods[[String]$PeriodCounter] += $Number
                # We've processed 14 (or specified number of) samples.
                if (++$Counter % $FirstStepSampleCount -eq 0) {
                    $RsiStepOnesForStepTwo += Get-RsiFirstStepInternal -Numbers (@($StartNumber) + @($Periods[[String]$PeriodCounter]))
                    # Save this from the previous iteration. This triggers for
                    # every 14th number, and we need 15 numbers to get 14 percentages.
                    $StartNumber = $Number
                    ++$PeriodCounter
                }
            }
            Write-Verbose "Processed $($PeriodCounter - 1) periods."
            $PreviousXAverageGain = $RsiStepOnesForStepTwo.AverageGain | 
                Select-Object -SkipLast 1 |
                Measure-Object -Average |
                Select-Object -ExpandProperty Average
            $PreviousXAverageLoss = $RsiStepOnesForStepTwo.AverageLoss | 
                Select-Object -SkipLast 1 |
                Measure-Object -Average |
                Select-Object -ExpandProperty Average
            Write-Verbose "`$PreviousXAverageGain = $PreviousXAverageGain`n`$PreviousXAverageLoss = $PreviousXAverageLoss"
            $RsiStepTwo = 100 - (100 / (1 + (($PreviousXAverageGain * 13 + $RsiStepOnesForStepTwo.AverageGain[-1]
                ) / (-1 * $PreviousXAverageLoss * 13 + -1 * $RsiStepOnesForStepTwo.AverageLoss[-1]))))
            [PSCustomObject]@{
                RsiStepOnesCalulationsForStepTwo = $RsiStepOnesForStepTwo
                RsiStepOnesString = ($RsiStepOnesForStepTwo.RSIStepOne | ForEach-Object {[Math]::Round($_, 2)}) -join ' - '
                RsiStepOnesAverage = [Math]::Round(($RsiStepOnesForStepTwo.RSIStepOne | Measure-Object -Average | Select-Object -ExpandProperty Average), 2)
                SecondStepSampleCount = $SecondStepSampleCount
                PreviousXAverageGain = $PreviousXAverageGain
                PreviousXAverageLoss = $PreviousXAverageLoss
                RSIStepTwo = [Math]::Round($RsiStepTwo, 2)
                Numbers = $Numbers
                DateTime = [DateTime]::Now
            }
        }
    }
    End {
    }
}
