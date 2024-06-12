
#-------------- Declaracion de variables --------------
.data 
saltoLinea: .asciiz "\n"
zero: .float 0.0
uno: .float 1.0
var_0: .asciiz "Hola"
var_1: .asciiz "amigos"
var_2: .asciiz "Holaamigos"
var_6: .asciiz "Buenas"
var_9: .asciiz " tardes"
var_12: .asciiz "Buenas tardes"

#--------------------- Ejecuciones ---------------------
.text
lwc1 $f31, zero
la $t0, var_0
la $t1, var_1
li $v0, 4
la $a0, var_2
addi $v0, $0, 4  #Movemos el registro 12 al 30 iniciado a false
syscall #Llamada al sistema
li $v0, 4
la $a0, saltoLinea
syscall #Llamada al sistema
la $t2, var_6
la $t3, var_9
li $v0, 4
la $a0, var_12
addi $v0, $0, 4  #Movemos el registro 12 al 30 iniciado a false
syscall #Llamada al sistema
li $v0, 4
la $a0, saltoLinea
syscall #Llamada al sistema
