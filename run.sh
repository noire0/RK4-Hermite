cd fortran
mkdir rk4 poly
cd rk4
for i in ../bin/*rk4.f; do
	${i}
done
cd ../poly
for i in ../bin/*poly.f; do
	${i}
done
cd ../..
