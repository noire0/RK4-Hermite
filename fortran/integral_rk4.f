      module functions
        implicit none
        contains

! I'm repeating the code again here (from library.fortran),
! but it's useful to use bigger variables for integrating infinites

        function Dv(n,x,v)
          real(16), intent(in) :: n, x, v(2)
          real(16) :: Dv(2)
          Dv(1) = v(2)
          Dv(2) = 2*x*v(2)-2*n*v(1)
        end function Dv

        function RK4(n,x,v,del)
          real(16), intent(in) :: del, n, x
          real(16), intent(in) :: v(2)
          real(16) :: k(4,2), RK4(2)
          k(1,:) = Dv(n,x,v)
          k(2,:) = Dv(n,x+del/2,v+k(1,:)*del/2)
          k(3,:) = Dv(n,x+del/2,v+k(2,:)*del/2)
          k(4,:) = Dv(n,x+del,v+k(3,:)*del)
          RK4 = v+del*(k(1,:)+2*k(2,:)+2*k(3,:)+k(4,:))/6
        end function RK4
      end module functions

      module auxiliar
        use functions
        implicit none
        type parameters
          real(16) :: n, x0, H0, DH0
        end type
        real(16), parameter :: pi = 3.1415926535
        contains
        function hermite(n,x)
          type(parameters), intent(in) :: n
          real(16), intent(in) :: x
          real(16) :: v(2), t, newstep, hermite
          v(1) = n%H0
          v(2) = n%DH0
          t = n%x0
          newstep = (x-t)
          v = RK4(n%n,t,v,newstep)
          t = t + newstep
          !print *, t, v(1)
          hermite = v(1) 
        end function hermite

! change of variables inf -> 1, -inf -> -1
! exp(-x**2)*H_n(x)*H_m(x) dx := f(x) dx ->
! f(t/(1-t²))*(1+t²)/(1-t²)² dt

        function integrating4(n,m,x)
          type(parameters), intent(in) :: n,m
          real(16) :: x, integrating4
          integrating4 = hermite(n,x/(1-x**2))*hermite(m,x/(1-x**2))
          integrating4 = integrating4*exp(-(x/(1-x**2))**2)
          integrating4 = integrating4*((1+x**2)/(1-x**2)**2)
        end function

! actual sum (trapezoidal rule)
        subroutine integralHermite4(n,m)
          type(parameters), intent(in) ::  n,m
          integer :: i, ITERATIONS = 1000
          real(16) :: total, STEP
          total = 0
          STEP = 1./ITERATIONS
          do i=1,ITERATIONS-1
            total = total
     &      + integrating4(n,m,i*STEP)
     &      + integrating4(n,m,-i*STEP)
          end do
          total = (total+integrating4(n,m,n%x0))*STEP
          total = total+integrating4(n,m,ITERATIONS*STEP)*STEP/2
          total = total+integrating4(n,m,-ITERATIONS*STEP)*STEP/2
          print*, 'Orthogonality:'
          print*, 'n =',floor(n%n),'m =',floor(m%n),':',total
        end subroutine integralHermite4

! integrating
        function integrating5(n,x)
          type(parameters), intent(in) :: n
          real(16) :: x, integrating5
          integrating5 = hermite(n,x/(1-x**2))**2
     &    /exp((x/(1-x**2))**2)
     &    *((1+x**2)/(1-x**2)**2)
        end function

! actual sum (trapezoidal rule)
        subroutine integralHermite5(n)
          type(parameters), intent(in) :: n
          real(16) :: total, STEP
          integer :: i, ITERATIONS = 1E5
          total = 0
          STEP = 0.9/ITERATIONS
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
          print*, 'Norm:'
          print*, 'n =', floor(n%n),':', total
        end subroutine
         
      end module auxiliar
 
      program main
        use auxiliar
        type(parameters) :: n, m !definido en m3

! Initial values from WolframAlpha

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

