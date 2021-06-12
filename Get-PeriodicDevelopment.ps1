function Get-PeriodicDevelopment {
    <#
        .SYNOPSIS
            Get the development of numbers between given dates, as a percentage.

            The dates have to be able to be "cast" to the .NET DateTime type as they exist
            in the CSV for this to work. You can specify a -DateReplace regex array.
            For instance this:
            # Norwegian to US. Dotted format: -DateReplace '(\d\d)\.(\d\d)\.(\d\d)', '$2/$1/$3'

        .EXAMPLE
            Rates from oslobors.no ... example...

            @(foreach ($Year in 2015..2019) {
                foreach ($Month in 1..12) {
                    [PSCustomObject] @{
                        Year = $Year
                        Month = $Month
                        Development = "{0:N2}" -f ((Get-PeriodicDevelopment -FilePath .\Tomra-2019-02-24.csv -DateName TOM -RateName Siste `
                                -Verbose -StartDate "$Month/1/$Year" -EndDate "$Month/27/$Year" `
                                -DottedEuropeToUS -LatestFirst)).PercentDevelopment
                    }
                }
            }) | Format-Table -AutoSize

        .EXAMPLE
            $JanuarySnP500 = 1951..2019 | %{
                $Year = $_
                $Development = (Get-PeriodicDevelopment -StartDate (Get-Date -Year $_ -Month 1 -Day 2) `
                                                -EndDate (Get-Date -Year $_ -Month 1 -Day 29)).PercentDevelopment
                [PSCustomObject] @{
                        Year = $Year
                        Development = if ($Development) { [Math]::Round($Development, 4) } else { '-' }
                }
            }

            $Global:snpCount = 0; $JanuarySnP500 | sort -desc development | select Year, Development,
                @{ n='Count'; e={++$Global:snpCount; $snpCount}}

            Year Development Count
            ---- ----------- -----
            1987     10.8519     1
            1976      9.8840     2
            1975      8.7685     3
            1985      7.9385     4
            1989      7.4495     5
            1980      7.3581     6
            1967      7.1932     7
            1961      6.8145     8
            2019      6.3788     9
            1997      6.2519    10
            2001      6.0571    11
            1971      5.4657    12
            1963      5.3021    13
            1991      5.0824    14
            1983      4.7901    15
            2018      4.5329    16
            1951      4.1090    17
            1954      4.0015    18
            1965      3.8251    19
            1999      3.5271    20
            1994      3.3575    21
            1958      3.2854    22
            1979      3.2022    23
            2012      2.6935    24
            1998      2.6197    25
            1995      2.4042    26
            1996      2.4040    27
            2013      2.3823    28
            2004      2.3589    29
            1950      2.2874    30
            1972      2.1840    31
            1964      2.0898    32
            1993      1.6135    33
            2007      1.5046    34
            1952      1.4085    35
            2011      1.1080    36
            1986      1.0341    37
            2017      0.9233    38
            2006      0.8812    39
            1966      0.7537    40
            1953     -0.1132    41
            1955     -0.3276    42
            1988     -0.3529    43
            1984     -0.3855    44
            1959     -0.4166    45
            1969     -0.8931    46
            1974     -1.1494    47
            2005     -1.7617    48
            2015     -1.8482    49
            1992     -2.0745    50
            2002     -2.1651    51
            1973     -2.6459    52
            2014     -2.7707    53
            1956     -3.0580    54
            1962     -3.0796    55
            1957     -3.3095    56
            2016     -3.7785    57
            2010     -4.0213    58
            1968     -4.1956    59
            1982     -4.2112    60
            2000     -4.3572    61
            1977     -4.8711    62
            2008     -4.9770    63
            1978     -5.1204    64
            2003     -6.2323    65
            1960     -7.0586    66
            1981     -7.4305    67
            1970     -8.4548    68
            1990     -9.3017    69
            2009    -12.8852    70

        .EXAMPLE
            1..12 | %{ [PSCustomObject] @{
        Month = $_; PercentDevelopment = (Get-PeriodicDevelopment -StartDate (Get-Date -Year 2009 -Month $_ -Day 1 -Hour 0 -Minute 0 -Sec 0) `
              -EndDate (Get-Date -Year 2009 -Month $_ -Day 30 -Hour 0 -Minute 0 -Second 0)).PercentDevelopment } }
        
            Month              PercentDevelopment
            -----              ------------------
                1 -12.885247351993488679992516280
                2 -18.541493522890885228059901370
                3  12.163634252219247823700902550
                4  4.9161288650713632721450617200
                5  3.7788884139854296667909132100
                6 -2.3187779673364610218233596100
                7   9.221452469345251941208975190
                8  1.7626531018530555047571843800
                9  3.4082610883121484871501322400
               10  1.6943506362460175847364146200
               11  5.9502534939070779075863216400
               12  0.5255121626870163254312544300

        .EXAMPLE
            . .\Get-PeriodicDevelopment.ps1
            $YearlySnP500Dev = 1950..2018 | foreach {
                [PSCustomObject] @{
                Year = $_; YearlyDevelopment = (Get-PeriodicDevelopment -StartDate (Get-Date -Year $_ -Month 1 -Day 1) `
                -EndDate (Get-Date -Year $_ -Month 12 -Day 27)).PercentDevelopment } };
    
                $Global:yearsnpct = 0; $YearlySnP500Dev | sort -desc yearlydevelopment | select year, yearlydevelopment, @{
                 n='Count';e={++$Global:yearsnpct; $Global:yearsnpct}}
            
            Year               YearlyDevelopment Count
            ----               ----------------- -----
            1954  29.579449618966977138018628280     1
            1958  26.324441858807385502105023670     2
            1995  25.240997079080611925035920710     3
            1997  22.692607273952456678931095920     4
            1975  22.079212983885930896014564390     5
            1980  21.676662383741852801169020230     6
            1985  21.506549983604755483355270470     7
            1989  21.490293497094660329567444370     8
            1991  21.363877196950045877894955510     9
            2013  20.566839561021219342635448140    10
            1998  20.436724415839577767583397400    11
            1961  19.695915198886450024091225440    12
            1955  18.423971552141432899920819090    13
            1950  18.253185390244621699932369970    14
            2003  18.067018298067893032193334390    15
            1996  17.658685446452809862528933740    16
            2009  17.377505893039714396290307070    17
            1983  16.329987089149318716567526710    18
            1967  16.174785860619312343511443770    19
            2017  15.988969643774672709164427080    20
            1963  15.920063463521015652387758920    21
            1999  15.748532075072314152505604060    22
            1976  14.863721500338714067773177890    23
            1986  14.337680257797688787327328950    24
            1972  13.875480375887834581418858580    25
            1982  12.808130629874813387090619110    26
            2014  12.369357619636597609604731030    27
            1951  12.325879597894487214247057230    28
            2006  10.944525151355346646106232710    29
            1971  10.593423558413640757635333720    30
            2016  10.545259219230114448491025010    31
            1979  10.302293594298723824136640360    32
            1964  10.277149994052575234923278220    33
            2010   9.973700566751948202620970810    34
            1952   9.848488636363636363636363640    35
            2012   8.939482909854982329122276500    36
            2004   8.657321194492537052582572430    37
            1965   7.975522866552200006032994710    38
            1988  7.6295604128204322457976728600    39
            1993  7.5508550662468464507289826700    40
            1968  7.4084795546682209633462149300    41
            1959  6.0020362834859274330281451300    42
            1992   4.984625822401810166027236700    43
            2005  4.4580689444550151759931744200    44
            2007  4.1860286115295241194023910800    45
            1956  3.0068749354193527616118393100    46
            1978  2.5550467652165222810191346200    47
            1984   1.335259272683125005507187700    48
            2015 -0.0826623389253586.....

        .EXAMPLE
            . .\Get-PeriodicDevelopment.ps1
            3..370 | where { $_ % 5 -eq 0 } | foreach {
                $Development = Get-PeriodicDevelopment -StartDate (Get-Date).AddDays(-1 * $_) -EndDate (get-date).AddDays(-2)
                [PSCustomObject] @{
                    DaysBack = $_
                    DevelopmentInPercent = $Development.PercentDevelopment
                    UsedStartDate = $Development.UsedStartDate.ToString('yyyy\-MM\-dd')
                    UsedEndDate = $Development.UsedEndDate.ToString('yyyy\-MM\-dd')
                }
            } | ft

        
            DaysBack            DevelopmentInPercent UsedStartDate UsedEndDate
            --------            -------------------- ------------- -----------
                   5 -2,1921744576077213829823216100 2020-03-02    2020-03-05 
                  10 -3,0572681271383755964616229800 2020-02-26    2020-03-05 
                  15 -10,377522871576105816580435850 2020-02-21    2020-03-05 
                  20 -11,453603734122575286954087030 2020-02-18    2020-03-05 
                  25 -11,038911668649440283311499800 2020-02-11    2020-03-05 
                  30 -10,643071432614805361307934790 2020-02-06    2020-03-05 
                  35 -7,4399619499585821965899950400 2020-02-03    2020-03-05 
                  40  -7,26502332............ and so on

    #>
    [CmdletBinding()]
    Param(
        [DateTime] $StartDate = (Get-Date).AddDays(-21),
        [DateTime] $EndDate = (Get-Date).AddDays(-1),
        [String] $FilePath = "C:\temp\^GSPC.csv",
        [String] $RateName = "Close",
        [String] $DateName = "Date",
        [String[]] $DateReplace = @(), # Norwegian to US, dotted format: '(\d\d)\.(\d\d)\.(\d\d)', '$2/$1/$3'
        [Switch] $DottedEuropeToUS,
        [String] $Delimiter = ",",
        [Switch] $LatestFirst,
        [Switch] $UpdateCsvCache
        )

    Begin {
    ## 2019-01-31. beta version...
        # Retarded caching mechanism... Just want to save time.
        if (-not $Global:SvendsenTechFinanceTechDataStuffVariableCSVImportCache -or $UpdateCsvCache) {
            Write-Verbose "Importing and global var caching '$FilePath' CSV file."
            $Global:SvendsenTechFinanceTechDataStuffVariableCSVImportCache = Import-Csv -LiteralPath $FilePath -Delimiter $Delimiter
        }
    }
    process {

    }
    end {
        if ($LatestFirst) {
            $Global:SvendsenTechFinanceTechDataStuffVariableCSVImportCache = $Global:SvendsenTechFinanceTechDataStuffVariableCSVImportCache[-1..-($Global:SvendsenTechFinanceTechDataStuffVariableCSVImportCache.Count)]
        }
    
        [Bool] $StartDone = $False
        [Bool] $EndDone = $False
        if ($DottedEuropeToUS) {
            Write-Verbose "Setting `$DateReplace regexes to Europe-dotted > US format for the DateTime casts."
            $DateReplace = @('^\s*(\d\d)\.(\d\d)\.(\d\d).*$', '$2/$1/$3')
        }
        [Decimal] $RangeCounter = 0
        # Optimization.
        $DateReplaceCount = $DateReplace.Count
        foreach ($t in $Global:SvendsenTechFinanceTechDataStuffVariableCSVImportCache) {
            ++$RangeCounter
            if ($DateReplaceCount -gt 0) {
                if (++$SpawnAndForget -eq 1) {
                    Write-Verbose "Performing regex -replace on all dates in property/header/column `$t.$DateName"
                    # Keep it in mind anyway!
                    if ($SpawnAndForget -ge ([System.Int32]::MaxValue - 5)) {
                        $SpawnAndForget = 1
                    }
                }
                $CurrentDate = [DateTime] ($t.$DateName -replace $DateReplace)
            }
            else {
                $CurrentDate = [DateTime] $t.$DateName
            }
        
            if (-not $StartDone -and $CurrentDate -ge $StartDate) {
            
                $StartDone = $True
                $UsedStartDate = $CurrentDate
            
                Write-Verbose "Found start date as $($CurrentDate.ToString('yyyy\-MM\-dd')) (close: $($t.$RateName))."
                $StartClose = [Decimal] $t.$RateName

            }
            if (-not $EndDone -and $CurrentDate -ge $EndDate) {
        
                $EndDone = $True
                $UsedEndDate = $CurrentDate

                Write-Verbose "Found end date as $($CurrentDate.ToString('yyyy\-MM\-dd')) (close: $($t.$RateName))."
                $EndClose = [Decimal] $t.$RateName
                break
            }

        }

        # Calculate development as a percentage.

        if ($null -eq $EndClose) {
            Write-Warning "End close not found for end date: $EndDate"
            return
        }
        if ($null -eq $StartClose) {
            Write-Warning "Start close not found for start date: $StartDate"
            return
        }

        [PSCustomObject] @{
            UsedStartDate = $UsedStartDate
            UsedEndDate = $UsedEndDate
            PercentDevelopment = [Math]::Round(((($EndClose - $StartClose) / $EndClose) * 100), 4)
        }
    }
}
