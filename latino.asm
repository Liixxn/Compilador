  
#-------------- Declaracion de variables --------------
.data 
saltoLinea: .asciiz "\n"
zero: .float 0.0
var_0: .asciiz "hola"

#--------------------- Ejecuciones ---------------------
.text
lwc1 $f31, zero
la $a0, var_0
