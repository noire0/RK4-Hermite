      include 'library.fortran'
      module auxiliar1
        use rungeKutta
        implicit none
        contains
        
        function iterativeRK4(n,vector,x_old,x) result(v)
          real, intent(in) :: n, x, x_old, vector(2)
          real :: t, newstep
          real :: v(2)
          v = vector
          t = x_old
          if (abs(x-t) > 0.001) then
            newstep = (x-t)/abs(x-t)*0.001
            do
              if (abs(t+newstep) >= abs(x)) then
                newstep = x-t
                exit
              end if
              v = RK4(n,t,v,newstep)
              t = t+newstep
            end do
          else
            newstep = x-t
          end if
          v = RK4(n,t,v,newstep)
          t = t + newstep
        end function iterativeRK4

      end module auxiliar1

      module auxiliar
        use auxiliar1
        implicit none

        type parameters
          real :: n, x0, H0, DH0
        end type

        real, parameter :: pi = 3.1415926535
        type helper4
          real :: n(2), m(2), n_old(2), m_old(2), partial_sum
        end type

        type helper5
          real :: n(2), n_old(2), partial_sum
        end type

        contains

! change of variables inf-> 1, -inf-> -1
! exp(-x**2)*H_n(x)*H_m(x) dx := f(x) dx ->
! f(t/(1-t²))*(1+t²)/(1-t²)² dt

        subroutine integrating4(n,m,vector,x_old,x)
          type(parameters), intent(in) :: n,m
          real, intent(in) :: x_old, x
          type(helper4) :: vector
          vector%n_old = vector%n
          vector%m_old = vector%m
          vector%n = iterativeRK4(n%n,vector%n,x_old,x/(1-x**2))
          vector%m = iterativeRK4(m%n,vector%m,x_old,x/(1-x**2))
          vector%partial_sum = vector%n(1)*vector%m(1)
     &    *exp(-(x/(1-x**2))**2)
     &    *((1+x**2)/(1-x**2)**2)
          vector%n = iterativeRK4(n%n,vector%n_old,x_old,x)
          vector%m = iterativeRK4(m%n,vector%m_old,x_old,x)
        end subroutine

        subroutine integralHermite4(n,m)
          type(parameters), intent(in) ::  n,m
          integer :: i, ITERATIONS = 5000
          real :: total, STEP
          type(helper4) :: positive, negative, zero
          total = 0
          STEP = 0.9/ITERATIONS
          positive%n = (/n%H0,n%DH0/)
          positive%m = (/m%H0,m%DH0/)
          negative = positive
          zero = negative
          do i=1,ITERATIONS-1
            call integrating4(n,m,positive,(i-1)*STEP,i*STEP)
            call integrating4(n,m,negative,-(i-1)*STEP,-i*STEP)
            if (log(abs(positive%partial_sum)) > log(huge(total))) exit
            if (positive%partial_sum /= positive%partial_sum) exit
            total = total
     &      + (positive%partial_sum
     &      + negative%partial_sum)*STEP
!            print*, 'integrando:', negative%partial_sum
!            print*, 'integrando:', positive%partial_sum
!            print*, 't, suma parcial:'
!            print*, i*step, total
          end do
          i = i+1
          call integrating4(n,m,zero,n%x0,n%x0)
          total = total+zero%partial_sum*STEP
          call integrating4(n,m,positive,(i-1)*STEP,i*STEP)
          call integrating4(n,m,negative,-(i-1)*STEP,-i*STEP)
          if (log(abs(positive%partial_sum)) > log(huge(total))) goto 1
          if (positive%partial_sum /= positive%partial_sum) goto 1
          total = total+negative%partial_sum*STEP/2
          total = total+positive%partial_sum*STEP/2
          print*, 'Orthogonality:'
1         print*, 'total (4), n =',floor(n%n),'m =',floor(m%n),':',total
        end subroutine integralHermite4

! The previous "goto"s are to handle when the integrating area gets too
! big

        subroutine integrating5(n,vector,x_old,x)
          type(parameters), intent(in) :: n
          real, intent(in) :: x_old, x
          type(helper5) :: vector
          vector%n_old = vector%n
          vector%n = iterativeRK4(n%n,vector%n,x_old,x/(1-x**2))
          vector%partial_sum = vector%n(1)**2
     &    *exp(-(x/(1-x**2))**2)
     &    *((1+x**2)/(1-x**2)**2)
          vector%n = iterativeRK4(n%n,vector%n_old,x_old,x)
        end subroutine

        subroutine integralHermite5(n)
          type(parameters), intent(in) ::  n
          integer :: i, ITERATIONS = 5000
          real :: total, STEP
          type(helper5) :: positive, negative, zero
          total = 0
          STEP = 0.9/ITERATIONS
          positive%n = (/n%H0,n%DH0/)
          negative = positive
          zero = negative
          do i=1,ITERATIONS-1
            call integrating5(n,positive,(i-1)*STEP,i*STEP)
            call integrating5(n,negative,-(i-1)*STEP,-i*STEP)
            if (log(abs(positive%partial_sum)) > log(huge(total))) exit
            if (positive%partial_sum /= positive%partial_sum) exit
            total = total
     &      + (positive%partial_sum
     &      + negative%partial_sum)*STEP
!            print*, 'H(t)', positive%partial_sum
!            print*, 'H(-t)', negative%partial_sum
!            print*, 't', i*STEP
!            print*, 'total', total
          end do
          i = i+1
          call integrating5(n,zero,n%x0,n%x0)
          total = total+zero%partial_sum*STEP
          call integrating5(n,positive,(i-1)*STEP,i*STEP)
          call integrating5(n,negative,-(i-1)*STEP,-i*STEP)
          if (log(abs(positive%partial_sum)) > log(huge(total))) goto 2
          if (positive%partial_sum /= positive%partial_sum) goto 2
          total = total+negative%partial_sum*STEP/2
          total = total+positive%partial_sum*STEP/2
2         total = total/((2.**(n%n))*sqrt(pi)*gamma((n%n)+1))
          print*, 'Norm:'
          print*, 'total (5), n =', floor(n%n),':', total
        end subroutine

      end module auxiliar
 
      program main
        use auxiliar
        type(parameters) :: n, m ! definido en auxiliar
        real :: v(2)

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
!        v = (/n%H0,n%DH0/)
!        print *, iterativeRK4(n%n,v,n%x0,real(10))

      end program main

