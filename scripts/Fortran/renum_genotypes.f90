program Extraer_genotipos
implicit none

integer :: i, io, j, cambios, nani1, nani2, nsnp, nid_genot, nid_lista, nid_nuevo
integer, allocatable :: snp(:)
real :: descarta      !
character (len=150) :: nac, ani_genot
character (len=150), allocatable :: nac1(:), muestra(:)
character (len=150) :: archivo_genot, archivo_lista, archivo_salida
character (len=50)  :: fmt_lec, fmt_esc, fmt_lista
character (len=5000):: linea_raw

! ---------------------------------------------------------------------
! LECTURA INTERACTIVA
! ---------------------------------------------------------------------
write(*,'(a)', advance='no') 'Archivo de genotipos              : '
read(*,'(a)') archivo_genot

write(*,'(a)', advance='no') 'Archivo de lista de animales      : '
read(*,'(a)') archivo_lista

write(*,'(a)', advance='no') 'Archivo de salida                 : '
read(*,'(a)') archivo_salida

write(*,'(a)', advance='no') 'Numero de SNPs                    : '
read(*,*) nsnp

write(*,'(a)', advance='no') 'Longitud ID en archivo genotipos  : '
read(*,*) nid_genot

write(*,'(a)', advance='no') 'Longitud ID en archivo lista      : '
read(*,*) nid_lista

write(*,'(a)', advance='no') 'Longitud nuevo codigo en lista    : '
read(*,*) nid_nuevo

write(*,*)
write(*,*) 'Parametros seleccionados:'
write(*,*) '  Genotipos  : ', trim(archivo_genot)
write(*,*) '  Lista      : ', trim(archivo_lista)
write(*,*) '  Salida     : ', trim(archivo_salida)
write(*,*) '  Num. SNPs  : ', nsnp
write(*,*) '  Long. ID genotipo : ', nid_genot
write(*,*) '  Long. ID lista    : ', nid_lista
write(*,*) '  Long. nuevo cod.  : ', nid_nuevo
write(*,*)

! ---------------------------------------------------------------------
! ALLOCATE
! ---------------------------------------------------------------------
allocate(snp(nsnp))

! ---------------------------------------------------------------------
! FORMATOS DINAMICOS
! ---------------------------------------------------------------------
! Lectura genotipos:  ID snp1 snp2 snp3 ... (separados por espacio)
write(fmt_lec,   '(a,i0,a,i0,a)') '(a', nid_genot, ',', nsnp, '(1x,i1))'

! Lectura lista:      ID nuevocod (separados por espacio)
write(fmt_lista, '(a,i0,a,i0,a)') '(a', nid_lista, ',1x,a', nid_nuevo, ')'

! Escritura salida:   nuevocod snp1 snp2 ... (separados por espacio)
write(fmt_esc,   '(a,i0,a,i0,a)') '(a', nid_nuevo, ',', nsnp, '(1x,i1))'

write(*,*) 'Formato lectura genotipos : ', trim(fmt_lec)
write(*,*) 'Formato lectura lista     : ', trim(fmt_lista)
write(*,*) 'Formato escritura salida  : ', trim(fmt_esc)
write(*,*)

! ---------------------------------------------------------------------
! DIAGNOSTICO: mostrar primeras 3 lineas de cada archivo
! ---------------------------------------------------------------------
write(*,*) '=== PRIMERAS 3 LINEAS: GENOTIPOS ==='
open(12, file=trim(archivo_genot), form='formatted', status='old')
do i = 1, 3
  read(12, '(a)', iostat=io) linea_raw
  if (io /= 0) exit
  write(*,*) '[', trim(linea_raw(1:80)), ']'
end do
rewind(12)

write(*,*) '=== PRIMERAS 3 LINEAS: LISTA ==='
open(11, file=trim(archivo_lista), form='formatted', status='old')
do i = 1, 3
  read(11, '(a)', iostat=io) linea_raw
  if (io /= 0) exit
  write(*,*) '[', trim(linea_raw), ']'
end do
rewind(11)
write(*,*)

! ---------------------------------------------------------------------
! PASO 1: Contar animales en lista
! ---------------------------------------------------------------------
i = 0
do
  read(11, *, iostat=io) nac, ani_genot, descarta
  if (io /= 0) exit
  i = i + 1
end do
nani1 = i
write(*,*) 'Animales en lista     : ', nani1
rewind(11)

! ---------------------------------------------------------------------
! PASO 2: Contar animales en genotipos
! ---------------------------------------------------------------------
i = 0
do
  read(12, *, iostat=io) ani_genot   ! formato libre solo para contar
  if (io /= 0) exit
  i = i + 1
  if (mod(i,10000) == 0) write(*,*) 'Contando genotipos: ', i
end do
nani2 = i
write(*,*) 'Animales en genotipos : ', nani2
rewind(12)

! ---------------------------------------------------------------------
! PASO 3: Cargar lista en memoria
! ---------------------------------------------------------------------
allocate(nac1(nani1), muestra(nani1))

! Variable auxiliar para la tercera columna que no necesitamos

do i = 1, nani1
  read(11, *, iostat=io) nac1(i), muestra(i), descarta
  if (io /= 0) then
    write(*,*) 'Error leyendo lista en linea ', i
    stop
  end if
  if (i <= 5) write(*,*) 'Lista: [', trim(nac1(i)), '] -> [', trim(muestra(i)), ']'
end do

! ---------------------------------------------------------------------
! PASO 4: Recorrer genotipos y extraer los que estan en la lista
! ---------------------------------------------------------------------
cambios = 0
open(14, file=trim(archivo_salida), form='formatted', status='replace')
do j = 1, nani2
  read(12, *, iostat=io) ani_genot, snp(1:nsnp)
  if (io /= 0) then
    write(*,*) 'Error o fin de archivo en genotipo ', j
    exit
  end if

  do i = 1, nani1
    if (trim(ani_genot) == trim(nac1(i))) then
      cambios = cambios + 1
      write(14, fmt_esc) trim(muestra(i)), snp(1:nsnp)
      if (mod(cambios,1000) == 0) write(*,*) cambios, ' extraidos, ultimo: ', &
                                  trim(ani_genot), ' -> ', trim(muestra(i))
      exit
    end if
  end do

end do

write(*,*)
write(*,*) cambios, ' genotipos extraidos de ', nani2, ' totales'

! ---------------------------------------------------------------------
! LIMPIEZA
! ---------------------------------------------------------------------
deallocate(snp, nac1, muestra)
close(11); close(12); close(14)

end program Extraer_genotipos
