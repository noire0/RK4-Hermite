#SUGERENCIA
Para evitar llenar de archivos la carpeta principal, compilar y correr en otra
carpeta, por ejemplo:

cd rk4; gfortran ../rk4.f && ./a.out

#ADVERTENCIA
Algunos fallarán si no se tiene almenos gfortran compatible con f2008.
La razón pues, que f2008 introduce la función gamma.
