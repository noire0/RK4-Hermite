! Compares the rk4 algorithm to the polynomial solution
      program main
        use ratioTables
! Initial values of Hermite from WolframAlpha
        call ratioTable('2.7', 0., -1.57386, -7.85963)
        call ratioTable('5.6', 0., -59.4076, 151.008)
        call ratioTable('9.8', 0., -21332.9, 31478.4)
      end program main