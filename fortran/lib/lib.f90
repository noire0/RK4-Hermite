! LIBRARY OF MODULES

module functions
  ! constants
  ! do i = 0, ITERATIONS
  !   i*STEP
  ! goes from 0 to 2.5
  integer, parameter :: ITERATIONS = 2500
  real, parameter :: STEP = 2.5/real(ITERATIONS)

  contains

  ! MODIFY DV
  ! Dv is the system of equations
  ! You can modify this part to match a desired equations
  ! could be multiple multivariable of first order, or a higher order single
  ! variable
  ! If you change Dv, make sure to also modify the code in the RK4 code
  function Dv(n, x, v) 
    real, intent(in) :: n, x, v(2)
    real :: Dv(2)
    Dv(1) = v(2)
    Dv(2) = 2*x*v(2) - 2*n*v(1)
  end function Dv

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
      hermitePoly = hermitePoly + &
      ((((-1)**s)*factorial(n))/ &
      (factorial(real(n-2*s))*factorial(real(s))))* &
      (2*x)**(real(n-2*s))
    end do

  end function hermitePoly
end module functions

module rungeKutta
  use functions
  contains

! function Dv has to match function in module functions
! in my case Dv takes 3 variables, n, x and a vector v(2)
! usage example
! v_i+1 = RK4(n,x_i,v_i,stepSize)
!
! remove n if Dv doesn't use n

  function RK4(n, x, v, stepSize)
    real, intent(in) :: n, x, v(2), stepSize
    real :: k(4, 2), RK4(2)

    k(1, :) = Dv(n, x, v)
    k(2, :) = Dv(n, x + stepSize/2, v + k(1, :)*stepSize/2)
    k(3, :) = Dv(n, x + stepSize/2, v + k(2, :)*stepSize/2)
    k(4, :) = Dv(n, x + stepSize, v + k(3, :)*stepSize)

    RK4 = v + stepSize*(k(1, :) + 2*k(2, :) + 2*k(3, :) + k(4, :))/6

  end function RK4
end module rungeKutta

module moduleIterativeRK4
  use rungeKutta
  implicit none
  contains

  function iterativeRK4(n, vector, x_old, x) result(v)
    real, intent(in) :: n, x, x_old, vector(2)
    real :: t, newstep
    real :: v(2)

    v = vector
    t = x_old

    if (abs(x-t) > 0.001) then
      ! keep direction but change size of step to 0.001 for
      ! precision
      newstep = (x-t)/abs(x-t)*0.001
      do
        if (abs(t + newstep) >= abs(x)) then
          newstep = x-t
          exit
        end if
        v = RK4(n, t, v, newstep)
        t = t+newstep
      end do
    else
      newstep = x-t
    end if

    v = RK4(n, t, v, newstep)
    t = t + newstep
  end function iterativeRK4

end module moduleIterativeRK4

module hermite
  use rungeKutta
  implicit none

! Usage example declaring type(table) :: tableType
! tableType%x(2) = 3
! print *, tableType%x(2)

  type table
    real, dimension(ITERATIONS) :: x, y
  end type

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

  function hermitePolyTable(n) result(H)
    real, intent(in) :: n
    type(table) :: H
    ! arreglo a graficar H%x(:),H%y(:)
    integer :: i
    H%x(1) = 0
    H%y(1) = hermitePoly(n,H%x(1))
    do i=2,ITERATIONS
      H%x(i) = H%x(i-1)+STEP
      H%y(i) = hermitePoly(n, H%x(i))
    end do
  end function hermitePolyTable

! stringReal('3.2') = real(3.2)
  function stringReal(x)
    character(len=*) :: x
    real :: stringReal
    read(x,*) stringReal
  end function

end module hermite