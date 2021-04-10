      program main
        use tables_poly
!Initial values of Hermite from WolframAlpha
        call writePolyTable('2.7')
        call writePolyTable('5.6')
        call writePolyTable('9.8')
        call ratioTable('2.7', 0., -1.57386, -7.85963)
        call ratioTable('5.6', 0., -59.4076, 151.008)
        call ratioTable('9.8', 0., -21332.9, 31478.4)
      end program main