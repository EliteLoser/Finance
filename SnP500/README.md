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
            back in time, and omitting the present, rather than predicting from, say January 1982
            to February 1982, to see if it matches. The assumed need for this is in less demand
            than the present becoming future, since the latter is where life takes place, but it's
            on the to do list.
