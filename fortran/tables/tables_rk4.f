      program main
        use tables_rk4
        real :: x0 = 0
!Initial values of Hermite equation from WolframAlpha
        call writeTable('3.6', x0, 6.45735, -13.4829)
        call writeTable('6.7', x0, -132.771, -4.999)
        call writeTable('11.5', x0, 213599.496, -1.046871881605E6)

        call writeTable('2.7', x0, -1.57386, -7.85963)
        call writeTable('5.6', x0, -59.4076, 151.008)
        call writeTable('9.8', x0, -21332.9, 31478.4)
      end program main

