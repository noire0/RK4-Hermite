      module functions
        !constantes
        !cubren el intervalo [0,2.5] iterando
        integer, parameter :: ITERATIONS = 2500
        real, parameter :: STEP = 2.5/real(ITERATIONS)

        contains

!Sistema acoplado de ecuaciones
!v = (H,H'), ej: v(2) = H'
!Dv = (H',H''), donde H'' viene dado de la ec. de Hermite
        function Dv(n,x,v) 
          real, intent(in) :: n, x, v(2)
          real :: Dv(2)
          Dv(1) = v(2)
          Dv(2) = 2*x*v(2)-2*n*v(1)
        end function Dv

        function factorial(x)
          real, intent(in) :: x
          real :: factorial
          factorial = gamma(x+1)
        end function factorial

!Solucion aproximada polinomial
        function hermitePoly(n,x)
          real, intent(in) :: n, x
          real :: hermitePoly
          integer :: s
          hermitePoly = 0
          do s=0,floor(n/2)
            hermitePoly =
     &      hermitePoly+
     &      ((((-1)**s)*factorial(n+1))/
     &      (factorial(real(n-2*s)+1)*factorial(real(s)+1)))
     &      *((2*x)**(real(n-2*s)))
          end do 
        end function hermitePoly
      end module functions

      module rungeKutta
        use functions
        contains
!v_i+1 = RK4(n,x_i,v_i,stepSize)
        function RK4(n,x,v,stepSize)
          real, intent(in) :: n, x, v(2), stepSize
          real :: k(4,2), RK4(2)
          k(1,:) = Dv(n,x,v)
          k(2,:) = Dv(n,x+stepSize/2,v+k(1,:)*stepSize/2)
          k(3,:) = Dv(n,x+stepSize/2,v+k(2,:)*stepSize/2)
          k(4,:) = Dv(n,x+stepSize,v+k(3,:)*stepSize)
          RK4 = v+stepSize*(k(1,:)+2*k(2,:)+2*k(3,:)+k(4,:))/6
        end function RK4
      end module rungeKutta

      module hermite
        use rungeKutta
        implicit none

        !para guardar los datos a graficar
        !H%x(1) contiene el primer valor de x
        type graph
          real, dimension(ITERATIONS) :: x, y
        end type

        contains

        function hermiteRK4Graph(n,x0,H0,DH0) result(H)
          real, intent(in) :: n, x0, H0, DH0
          type(graph) :: H
          real :: v(2)
          integer :: i
          H%x(1) = x0
          H%y(1) = H0
          v(1) = H0
          v(2) = DH0
          do i=1,ITERATIONS-1
            H%x(i+1) = H%x(i)+STEP
            v = RK4(n,H%x(i),v,STEP)
            H%y(i+1) = v(1)
          end do
        end function hermiteRK4Graph

        function hermitePolyGraph(n) result(H)
          real, intent(in) :: n
          type(graph) :: H
          !arreglo a graficar H%x(:),H%y(:)
          integer :: i
          H%x(1) = 0
          H%y(1) = hermitePoly(n,H%x(1))
          do i=2,ITERATIONS
            H%x(i) = H%x(i-1)+STEP
            H%y(i) = hermitePoly(n,H%x(i))
          end do
        end function hermitePolyGraph

!stringReal('3.2') = real(3.2)
        function stringReal(x)
          character(len=*) :: x
          real :: stringReal
          read(x,*) stringReal
        end function

      end module hermite

