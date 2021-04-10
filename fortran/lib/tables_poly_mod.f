      module tables_poly
        use polynomial
        use tables
        implicit none
        contains
        function hermitePolyTable(n) result(H)
          real, intent(in) :: n
          type(table) :: H
          integer :: i
          H%x(1) = 0
          H%y(1) = hermitePoly(n, H%x(1))
          do i=2, ITERATIONS
            H%x(i) = H%x(i-1)+STEP
            H%y(i) = hermitePoly(n, H%x(i))
          end do
        end function hermitePolyTable
        
        subroutine writePolyTable(n)
          character(len=*), intent(in) :: n
          character(len=:), allocatable :: filename
          type(table), target :: H
          integer :: i
          filename = 'hermite_'//n//'_polynomial.txt'
          H = hermitePolyTable(stringToReal(n))
          open(1, file=filename)
          do i=1,ITERATIONS
            write(1,*) H%x(i), H%y(i)
          end do
          close(1)
        end subroutine writePolyTable
      end module tables_poly