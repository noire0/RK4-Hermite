      module tables_ratio
        use tables_rk4
        use tables_poly
        implicit none
        contains
        subroutine ratioTable(n, x0, H0, DH0)
          real,  intent(in) ::  x0, H0, DH0
          character(len=*),  intent(in) :: n
          character(len=:), allocatable :: filename
          type(table), target :: R, P
          integer :: i
          filename = 'ratio_hermite_'//n//'_rk4_polynomial.txt'
          P = hermitePolyTable(stringToReal(n))
          R = hermiteRK4Table(stringToReal(n), x0, H0, DH0)
          open(1, file=filename)
          do i=1, ITERATIONS
            write(1, *) P%x(i), R%y(i)/P%y(i)
          end do
          close(1)
        end subroutine ratioTable
      end module tables_ratio