      module rungeKutta
        implicit none
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
! in my case Dv takes 3 variables, n, x and a vector v(2)
! vector v contains the known values f(x, n) and f'(x, n)
! calculates f(x+stepSize), but notice that stepSize has
! to be small.
! Usage example:
! v_i+1 = RK4(n, x_i, v_i, stepSize)
! remove n if Dv doesn't use n
        function RK4(n, x, v, stepSize)
          real, intent(in) :: n, x, v(2), stepSize
          real :: k(4, 2), RK4(2)

          k(1, :) = Dv(n, x, v)
          k(2, :) = Dv(n, x + stepSize/2, v + k(1, :)*stepSize/2)
          k(3, :) = Dv(n, x + stepSize/2, v + k(2, :)*stepSize/2)
          k(4, :) = Dv(n, x + stepSize, v + k(3, :)*stepSize)

          RK4 = v + stepSize*(k(1, :) + 2*k(2, :) + 2*k(3, :) +
     &                        k(4, :))/6
        end function RK4
        ! calculates f(x, n) given f(x_old, n) and f'(x_old, n)
        ! vector is [f(x_old, n), f'(x_old, n)]
        ! here unlike RK4, it doesn't matter if x is far from x_old
        ! as it goes through small steps.
        ! The efficacy or efficiency of using a step size of 0.001
        ! is not proven. For that a real adaptive step size
        ! must be implemented which I may do in the future
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
      end module rungeKutta