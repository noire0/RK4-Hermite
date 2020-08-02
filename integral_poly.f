      include 'library.fortran'
      module auxiliar
        use functions
        implicit none
        type parameters
          real :: n, x0, H0, DH0
        end type
        real, parameter :: pi = 3.1415926535
        contains

! change of variables inf -> 1, -inf -> -1
! exp(-x**2)*H_n(x)*H_m(x) dx := f(x) dx ->
! f(t/(1-t²))*(1+t²)/(1-t²)² dt

        function integrating4(n,m,x)
          type(parameters), intent(in) :: n,m
          real :: x, integrating4
          integrating4 = hermitePoly(n%n,x/(1-x**2))
     &    *hermitePoly(m%n,x/(1-x**2))
     &    *((1+x**2)/(1-x**2)**2)
     &    *exp(-(x/(1-x**2))**2)
        end function


! trapezoidal rule

        subroutine integralHermite4(n,m)
          type(parameters), intent(in) ::  n,m
          integer :: i, ITERATIONS = 1000
          real :: total, STEP
          total = 0
          STEP = 0.95/ITERATIONS
          do i=1,ITERATIONS
            total = total+
     &      (integrating4(n,m,i*STEP)
     &      +integrating4(n,m,(i-1)*STEP))
     &      *STEP/2
            ! print *, 'total:', total
            total = total+
     &      (integrating4(n,m,-i*STEP)
     &      +integrating4(n,m,-(i-1)*STEP))
     &      *STEP/2
            ! print *, 'total:', total
          end do
          print*, "Orthogonality:"
          print*, 'total (4), n =',floor(n%n),'m =',floor(m%n),':',total
        end subroutine integralHermite4

! expresión (5)
        function integrating5(n,x)
          type(parameters), intent(in) :: n
          real :: x, integrating5
          integrating5 = hermitePoly(n%n,x/(1-x**2))**2
     &    /exp((x/(1-x**2))**2)
     &    *((1+x**2)/(1-x**2)**2)
        end function

        subroutine integralHermite5(n)
          type(parameters), intent(in) :: n
          real :: total, STEP
          integer :: i, ITERATIONS = 1E4
          total = 0
          STEP = 0.95/ITERATIONS
          do i=1,ITERATIONS-1
            total = total+
     &      integrating5(n,i*STEP)
            total = total+
     &      integrating5(n,-i*STEP)
          end do
          total = (total+n%H0)*STEP
          total = total+(integrating5(n,-ITERATIONS*STEP)
     &    +integrating5(n,ITERATIONS*STEP))*STEP/2
          total = total/((2.**(n%n))*sqrt(pi)*gamma((n%n)+1))
          print*, "Norm:"
          print*, 'total (5), n =', floor(n%n),':', total
        end subroutine

      end module auxiliar
 
      program main
        use auxiliar
        type(parameters) :: n, m ! defined in auxiliar

        m%n = 4
        m%x0 = 0
        m%H0 = 12
        m%DH0 = 0
        n%n = m%n + 1
        n%x0 = 0
        n%H0 = 0
        n%DH0 = 120
        call integralHermite4(n,m)
        m%n = 7
        m%x0 = 0
        m%H0 = 0
        m%DH0 = -1680
        n%n = m%n + 1
        n%x0 = 0
        n%H0 = 1680
        n%DH0 = 0
        call integralHermite4(n,m)
        m%n = 9
        m%x0 = 0
        m%H0 = 0
        m%DH0 = 30240
        n%n = m%n + 1
        n%x0 = 0
        n%H0 = -30240
        n%DH0 = 0
        call integralHermite4(n,m)

        n%n = 1
        n%x0 = 0
        n%H0 = 0
        n%DH0 = 2
        call integralHermite5(n)
        n%n = 5
        n%x0 = 0
        n%H0 = 0
        n%DH0 = 120
        call integralHermite5(n)
        n%n = 6
        n%x0 = 0
        n%H0 = -120
        n%DH0 = 0
        call integralHermite5(n)

      end program main

