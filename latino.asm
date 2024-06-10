      
#-------------- Declaracion de variables --------------
.data 
saltoLinea: .asciiz "\n"
zero: .float 0.0
var_0: .asciiz "holaa jolieee"
var_1: .float 5.000
var_2: .float 6.000

#--------------------- Ejecuciones ---------------------
.text
lwc1 $f31, zero
la $a0, var_0
li $v0, 2
la $a0, var_0
addi $v0, $0, 4  #Movemos el registro 12 al 30 iniciado a false
syscall #Llamada al sistema
li $v0, 4
la $a0, saltoLinea
syscall #Llamada al sistema
lwc1 $f4, var_1
lwc1 $f5, var_2
add.s $f6, $f4, $f5
li $v0, 2
add.s $f12, $f31, $f6
mov.s $f30, $f12  #Movemos el registro 12 al 30 iniciado a false
syscall #Llamada al sistema
li $v0, 4
la $a0, saltoLinea
syscall #Llamada al sistema
