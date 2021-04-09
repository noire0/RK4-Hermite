include "../lib/lib.f90"

module auxiliar
  use hermite
  implicit none
  contains
  subroutine writeArray(n, x0, H0, DH0)
    real,  intent(in) ::  x0, H0, DH0
    character(len=*), intent(in) :: n
    character(len=:), allocatable :: filename
    type(table), target :: H
    integer :: i
    filename = "hermite_"//n//"_rk4.txt"
    H = hermiteRK4Table(stringReal(n), x0, H0, DH0)
    open(1, file=filename)
    do i=1, ITERATIONS
      write(1, *) H%x(i), H%y(i)
    end do
    close(1)
  end subroutine writeArray
end module auxiliar

program main
  use auxiliar
  real :: x0 = 0

!Initial values of Hermite equation from WolframAlpha

  call writeArray('3.6', x0, 6.45735, -13.4829)
  call writeArray('6.7', x0, -132.771, -4.999)
  call writeArray('11.5', x0, 213599.496, -1.046871881605E6)

  call writeArray('2.7', x0, -1.57386, -7.85963)
  call writeArray('5.6', x0, -59.4076, 151.008)
  call writeArray('9.8', x0, -21332.9, 31478.4)

end program main

