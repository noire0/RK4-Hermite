      include "rungekutta.f"
      include "tables.f"
      module tables_rk4
        use rungeKutta
        use tables
        implicit none
        contains
        function hermiteRK4Table(n, x0, H0, DH0) result(H)
          real, intent(in) :: n, x0, H0, DH0
          type(table) :: H
          real :: v(2)
          integer :: i
          H%x(1) = x0
          H%y(1) = H0
          v(1) = H0
          v(2) = DH0
          do i=1,ITERATIONS-1
            H%x(i+1) = H%x(i)+STEP
            v = RK4(n, H%x(i), v, STEP)
            H%y(i+1) = v(1)
          end do
        end function hermiteRK4Table

        subroutine writeTable(n, x0, H0, DH0)
          real,  intent(in) ::  x0, H0, DH0
          character(len=*),  intent(in) :: n
          character(len=:), allocatable :: filename
          type(table), target :: H
          integer :: i
          filename = 'hermite_'//n//'_rk4.txt'
          H = hermiteRK4Table(stringToReal(n), x0, H0, DH0)
          open(1, file=filename)
          do i=1, ITERATIONS
            write(1, *) H%x(i), H%y(i)
          end do
          close(1)
        end subroutine writeTable
      end module tables_rk4