      ! LIBRARY OF FUNCTIONS
      module polynomial
        implicit none
        contains
        function factorial(x)
          real, intent(in) :: x
          real :: factorial
          factorial = gamma(x+1)
        end function factorial
! hermite polynomial
        function hermitePoly(n, x)
          real, intent(in) :: n, x
          real :: hermitePoly
          integer :: s

          hermitePoly = 0
          do s=0,floor(n/2)
            hermitePoly =
     &      hermitePoly+
     &      ((((-1)**s)*factorial(n))/
     &      (factorial(real(n-2*s))*factorial(real(s))))*
     &      ((2*x)**(real(n-2*s)))
          end do
        end function hermitePoly
      end module polynomial