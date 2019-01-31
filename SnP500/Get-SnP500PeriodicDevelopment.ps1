function Get-SnP500PeriodicDevelopment {
    <#
        .SYNOPSIS
            Get the development of the SnP500 index between given dates, as a percentage.

        .EXAMPLE
            $JanuarySnP500 = 1951..2019 | %{
                $Year = $_
                $Development = Get-SnP500PeriodicDevelopment -StartDate (Get-Date -Year $_ -Month 1 -Day 2) `
                                                -EndDate (Get-Date -Year $_ -Month 1 -Day 29)
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
        Month = $_; PercentDevelopment = Get-SnP500PeriodicDevelopment -StartDate (Get-Date -Year 2009 -Month $_ -Day 1 -Hour 0 -Minute 0 -Sec 0) `
              -EndDate (Get-Date -Year 2009 -Month $_ -Day 30 -Hour 0 -Minute 0 -Second 0) } }
        
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

    #>
    [CmdletBinding()]
    Param(
        [DateTime] $StartDate = (Get-Date).AddDays(-21),
        [DateTime] $EndDate = (Get-Date).AddDays(-1),
        [String] $FilePath = "C:\temp\^GSPC.csv"
        )

    
    ## 2019-01-31. beta version...
    
    $SnPCSV = Import-Csv -LiteralPath $FilePath
    [Bool] $StartDone = $False
    [Bool] $EndDone = $False
    $SnPCSV | ForEach-Object {
    
        if ((($CsvNow = [DateTime] $_.Date) -eq $StartDate -or `
            $CsvNow -gt $StartDate) -and -not $StartDone) {
            
            $StartDone = $True
            
            Write-Verbose "Found start date as $CsvNow (close: $($_.Close))."
            $StartClose = [Decimal] $_.Close

        }
        if ((($CsvNow = [DateTime] $_.Date) -eq $EndDate -or `
            $CsvNow -gt $EndDate) -and -not $EndDone) {
        
            $EndDone = $True

            Write-Verbose "Found end date as $CsvNow (close: $($_.Close))."
            $EndClose = [Decimal] $_.Close

        }

    }

    # Calculate development as a percentage.

    if ($null -eq $EndClose) {
        Write-Verbose "End close not found for end date: $EndDate"
        return
    }
    if ($null -eq $StartClose) {
        Write-Verbose "Start close not found for start date: $StartDate"
        return
    }

    (($EndClose - $StartClose) / $EndClose) * 100

}
