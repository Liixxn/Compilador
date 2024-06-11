        
#-------------- Declaracion de variables --------------
.data 
saltoLinea: .asciiz "\n"
zero: .float 0.0
uno: .float 1.0
var_0: .float 3.000
var_1: .float 3.000
var_2: .float 5.000
var_3: .float 8.000

#--------------------- Ejecuciones ---------------------
.text
lwc1 $f31, zero
lwc1 $f0, var_0
lwc1 $f1, var_1
add.s $f2, $f0, $f1
l.s $f29, zero
lwc1 $f4, var_2
etiqueta0:
c.lt.s $f29, $f4
  bc1f fin_bucle0
    nop
lwc1 $f5, var_3
li $v0, 2
add.s $f12, $f31, $f5
mov.s $f30, $f12  #Movemos el registro 12 al 30 iniciado a false
syscall #Llamada al sistema
li $v0, 4
la $a0, saltoLinea
syscall #Llamada al sistema
l.s $f30, uno
add.s $f29, $f29, $f30
j etiqueta0
fin_bucle0:
