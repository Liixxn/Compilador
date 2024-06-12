               
#-------------- Declaracion de variables --------------
.data 
saltoLinea: .asciiz "\n"
zero: .float 0.0
uno: .float 1.0
var_0: .float 1.000
var_1: .float 3.000
var_2: .float 2.000
var_3: .float 2.000
var_4: .float 4.000
var_5: .float 1.000
var_6: .float 400.000
var_7: .float 1.000
var_8: .float 8.000

#--------------------- Ejecuciones ---------------------
.text
lwc1 $f31, zero
lwc1 $f0, var_0
lwc1 $f12, var_6
li $v0, 2
add.s $f12, $f31, $f12
mov.s $f30, $f12  #Movemos el registro 12 al 30 iniciado a false
syscall #Llamada al sistema
li $v0, 4
la $a0, saltoLinea
syscall #Llamada al sistema
lwc1 $f14, var_7
add.s $f15, $f0, $f14
li $v0, 2
add.s $f12, $f31, $f15
mov.s $f30, $f12  #Movemos el registro 12 al 30 iniciado a false
syscall #Llamada al sistema
li $v0, 4
la $a0, saltoLinea
syscall #Llamada al sistema
