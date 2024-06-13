
#-------------- Declaracion de variables --------------
.data 
saltoLinea: .asciiz "\n"
zero: .float 0.0
uno: .float 1.0
var_0: .float 3.000
var_2: .float 2.000
var_3: .float 1.000
var_8: .float 1.000

#--------------------- Ejecuciones ---------------------
.text
lwc1 $f31, zero
lwc1 $f0, var_0
l.s $f29, zero
lwc1 $f2, var_2
etiqueta0:
c.lt.s $f29, $f2
  bc1f fin_bucle0
    nop
lwc1 $f3, var_3
sub.s $f4, $f0, $f3
mov.s $f0, $f4
l.s $f30, uno
add.s $f29, $f29, $f30
j etiqueta0
fin_bucle0:
l.s $f29, zero
lwc1 $f8, var_8
add.s $f9, $f4, $f8
li $v0, 2
add.s $f12, $f31, $f9
mov.s $f30, $f12  #Movemos el registro 12 al 30 iniciado a false
syscall #Llamada al sistema
li $v0, 4
la $a0, saltoLinea
syscall #Llamada al sistema
