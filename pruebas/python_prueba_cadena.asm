
#-------------- Declaracion de variables --------------
.data 
saltoLinea: .asciiz "\n"
zero: .float 0.0
uno: .float 1.0
resultado: .space 100
var_0: .asciiz "Hola"
var_1: .asciiz "amigos"
var_6: .asciiz "Buenas"
var_9: .asciiz " tardes"

#--------------------- Ejecuciones ---------------------
.text
lwc1 $f31, zero
la $t0, var_0
la $t1, var_1
la $s0, resultado
cadena_0: 
  lb $s1, 0($t0)
  beqz $s1, finCadena_0
  sb $s1, 0($s0)
  addi $s0, $s0, 1
  addi $t0, $t0, 1
  j cadena_0
finCadena_0: 
  la $t1, var_1
cadena_1: 
  lb $s1, 0($t1)
  beqz $s1, fin_1
  sb $s1, 0($s0)
  addi $s0, $s0, 1
  addi $t1, $t1, 1
  j cadena_1
fin_1: 
  sb $zero, 0($s0)
li $v0, 4
la $a0, resultado
addi $v0, $0, 4  #Movemos el registro 12 al 30 iniciado a false
syscall #Llamada al sistema
li $v0, 4
la $a0, saltoLinea
syscall #Llamada al sistema
la $t6, var_6
la $t9, var_9
la $s0, resultado
cadena_6: 
  lb $s1, 0($t6)
  beqz $s1, finCadena_6
  sb $s1, 0($s0)
  addi $s0, $s0, 1
  addi $t6, $t6, 1
  j cadena_6
finCadena_6: 
  la $t9, var_9
cadena_9: 
  lb $s1, 0($t9)
  beqz $s1, fin_9
  sb $s1, 0($s0)
  addi $s0, $s0, 1
  addi $t9, $t9, 1
  j cadena_9
fin_9: 
  sb $zero, 0($s0)
li $v0, 4
la $a0, resultado
addi $v0, $0, 4  #Movemos el registro 12 al 30 iniciado a false
syscall #Llamada al sistema
li $v0, 4
la $a0, saltoLinea
syscall #Llamada al sistema
