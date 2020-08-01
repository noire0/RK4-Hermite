      include 'library.f'
      module auxiliar
        use hermite
        implicit none
        contains

        subroutine writeArray(n)
          character(len=*), intent(in) :: n
          character(len=:), allocatable :: filename
          type(graph), target :: H
          integer :: i
          filename = 'Hermite_'//n//' Polynomial.txt' 
          H = hermitePolyGraph(stringReal(n))
          open(1,file=filename)
          do i=1,ITERATIONS
            write(1,*) H%x(i), H%y(i)
          end do
          close(1)
        end subroutine writeArray

        subroutine comparison(n,x0,H0,DH0)
          real, intent(in) ::  x0,H0,DH0
          character(len=*), intent(in) :: n
          character(len=:), allocatable :: filename
          type(graph), target :: R, P
          integer :: i
          filename = 'Cociente Hermite_'//n//' RK4-Polynomial.txt'
          P = hermitePolyGraph(stringReal(n))
          R = hermiteRK4Graph(stringReal(n),x0,H0,DH0)
          open(1,file=filename)
          do i=1,ITERATIONS
            write(1,*) P%x(i), R%y(i)/P%y(i)
          end do
          close(1)
        end subroutine comparison

      end module auxiliar
 
      program main
        use auxiliar

        call writeArray('2.7')
        call writeArray('5.6')
        call writeArray('9.8')
        call comparison('2.7',0.,-1.57386,-7.85963)
        call comparison('5.6',0.,-59.4076,151.008)
        call comparison('9.8',0.,-21332.9,31478.4)

      end program main