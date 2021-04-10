      module tables
        implicit none
        ! constants
        ! do i = 0, ITERATIONS
        !   i*STEP
        ! goes from 0 to 2.5
        integer, parameter :: ITERATIONS = 2500
        real, parameter :: STEP = 2.5/real(ITERATIONS)
        ! Usage example declaring type(table) :: tableType
        ! tableType%x(2) = 3
        ! print *, tableType%x(2)
        type table
          real, dimension(ITERATIONS) :: x, y
        end type
        contains
        function stringToReal(x)
          character(len=*) :: x
          real :: stringToReal
          read(x, *) stringToReal
        end function
      end module tables