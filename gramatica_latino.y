%{

// ----------------------------- GLOSARIO DE IMPORTS -------------------------------------------
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "tabla_simbolos.h"
#include "AST_latino.h"

// ----------------------------- DECLARACION DE VARIABLES Y ESTRUCTURAS -------------------------------------------

//Declaracion de variables "extern" sirve para declararlas como variables globales
FILE *yyout;
extern FILE* yyin;
extern int num_linea; //Almacena el numero de linea durante la ejecucion
extern tSimbolos tabla[256];
extern int indice; //Se almacena el índice de la tabla de tSimbolos
char* tipos[] = {"numerico", "numericoDecimal", "texto", "bool"}; //Para parsear el tipo que se detecta en flex al tipo del nodo

%}

/*Definicion de tipos y estructuras empleadas*/
%union {
  int enteroVal;
  float realVal;
  char* stringVal;
  char* cadenaVal;
  struct atributos{
    int numerico;
    float numericoDecimal;
    char* texto;
    char* tipo;             //Define el tipo que se esta usando
    struct ast *n;          //Para almacenar los nodos del AST
  }tr;
}

/*Declaración de los TOKENS*/
%token SUMA RESTA MULTIPLICACION DIVISION IGUAL APERTURAPARENTESIS CIERREPARENTESIS IMPRIMIR MAYOR_QUE MENOR_QUE MAYOR_IGUAL_QUE MENOR_IGUAL_QUE IGUAL_IGUAL NO_IGUAL

/*Declaración de los TOKENS que provienen de FLEX con su respectivo tipo*/
%token <enteroVal> NUMERICO 
%token <realVal> NUMERICODECIMAL 
%token <stringVal> IDENTIFICADOR
%token <cadenaVal> CADENA

/*Declaración de los TOKENS NO TERMINALES con su estructura*/
%type <tr> sentencias sentencia tipos expresion asignacion imprimir  

/*Declaración de la precedencia siendo menor la del primero y mayor la del último*/
%left SUMA RESTA MULTIPLICACION DIVISION MAYOR_QUE MENOR_QUE MAYOR_IGUAL_QUE MENOR_IGUAL_QUE


%start codigo
%%

//GRAMATICA
//X --> S
//S --> D | S D
//D --> A | I 
//A --> id = E 
//E --> E op T | T
//T --> id | num | numdecimal
//I --> imprimir ( E )

//-----------------------------------------------  PRODUCCIONES  -------------------------------------------------------

//PRODUCCION "codigo", formado por sentencias
//X --> S
codigo:
    sentencias  {
        comprobarAST($1.n); 
        printf("\n[FINALIZADO]\n");     
    }
;

//PRODUCCION "sentencias", puede estar formado por una sentencia o un grupo de sentencias
//S --> D | S D
sentencias:
    sentencia
    | sentencias sentencia { //para hacerlo recursivo
        $$.n = crearNodoNoTerminal($1.n, $2.n, 7);
    }
;

//PRODUCCION "sentencia", puede estar formado por asignaciones, condicionales, bucles whiles, imprimir
//D --> A | I 
sentencia:   //Por defecto bison, asigna $1 a $$ por lo que no es obligatoria realizar la asignacion
    asignacion              
    | imprimir       
;

//-------------------------------------------------------- ASIGNACION --------------------------------------------------------
//PRODUCCION "asignacion", formado por un identificador, un igual y una expresion
//A --> id = E 
asignacion:
    IDENTIFICADOR IGUAL expresion {
        printf("> [SENTENCIA] - Asignacion\n");

        //Para crear un nuevo simbolo de tipo numerico
        if(strcmp($3.tipo, tipos[0]) == 0){ //comprobacion si es numerico
        printf("Asignado el valor %d a la variable\n",$3.numerico);
        tabla[indice].nombre = $1; 
        tabla[indice].tipo = tipos[0]; 
        tabla[indice].numerico = $3.numerico;
        tabla[indice].registro = $3.n->resultado;
        
        indice++; //incrementamos el valor del inidice para pasar a la siguiente posicion y dejar la anterior guardada


        }
        //Para crear un nuevo simbolo de tipo numericoDecimal
        else if(strcmp($3.tipo, tipos[1]) == 0){ //comprobacion si es numericoDecimal
        printf("Asignado el valor %d a la variable\n",$3.numericoDecimal);
        tabla[indice].nombre = $1; 
        tabla[indice].tipo = tipos[1]; 
        tabla[indice].numericoDecimal = $3.numericoDecimal; 
        tabla[indice].registro = $3.n->resultado;

        indice++; //incrementamos el valor del inidice para pasar a la siguiente posicion y dejar la anterior guardada

        }
        
        //Para crear un nuevo simbolo de tipo texto
        else if (strcmp($3.tipo, tipos[2]) == 0){ //comprobacion si es texto
        printf("Asignado el valor %s a la variable\n",$3.texto);
        tabla[indice].nombre = $1; 
        tabla[indice].tipo = tipos[2];
        tabla[indice].texto = $3.texto;
        tabla[indice].registro = $3.n->resultado;

        indice++;
        }
        printf("Contenido de cadenaaa: %s\n", $3.tipo);
        $$.n=crearNodoNoTerminal($3.n, crearNodoVacio(), 5);
    }
;


//-----------------------------------------------  EXPRESION ---------------------------------------------
//PRODUCCION "expresion", en esta gramática se representa la suma, resta y otros terminos
//E --> E op T | T
expresion:
    
    //SUMA
    expresion SUMA tipos {

        //Suma de numerico + numerico
        if (strcmp($1.tipo, tipos[0]) == 0 && strcmp($3.tipo, tipos[0]) == 0) { //comprobacion del tipo
            printf("> [OPERACION] - SUMA {numerico / numerico}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 2); 
            $$.tipo = tipos[0]; 
            $$.numerico = $1.numerico + $3.numerico;  
        }

        //Suma de numericoDecimal + numericoDecimal
        else if (strcmp($1.tipo, tipos[1]) == 0 && strcmp($3.tipo, tipos[1]) == 0){  //comprobacion del tipo
            printf("> [OPERACION] - SUMA {numericoDecimal / numericoDecimal}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 2);
            $$.tipo = tipos[1]; 
            $$.numericoDecimal = $1.numericoDecimal + $3.numericoDecimal;
        }  
    }
    //RESTA
    | expresion RESTA tipos {
        
        //Resta de numerico - numerico
        if (strcmp($1.tipo, tipos[0]) == 0 && strcmp($3.tipo, tipos[0]) == 0) {  //comprobacion del tipo
            printf("> [OPERACION] - RESTA {numerico / numerico}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 3);
            $$.tipo = tipos[0]; 
            $$.numerico = $1.numerico - $3.numerico;
        }
        //Resta de numericoDecimal - numericoDecimal
        else if (strcmp($1.tipo, tipos[1]) == 0 && strcmp($3.tipo, tipos[1]) == 0){  //comprobacion del tipo
            printf("> [OPERACION] - RESTA {numericoDecimal / numericoDecimal}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 3);
            $$.tipo = tipos[1]; 
            $$.numericoDecimal = $1.numericoDecimal - $3.numericoDecimal;
        }

    }
    //MULTIPLICACION
    | expresion MULTIPLICACION tipos {
        
        //Multiplicación de numerico * numerico
        if (strcmp($1.tipo, tipos[0]) == 0 && strcmp($3.tipo, tipos[0]) == 0) {  //comprobacion del tipo
            printf("> [OPERACION] - MULTIPLICACION {numerico / numerico}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 9);
            $$.tipo = tipos[0]; 
            $$.numerico = $1.numerico * $3.numerico;
        }
        //Multiplicación de numericoDecimal * numericoDecimal
        else if (strcmp($1.tipo, tipos[1]) == 0 && strcmp($3.tipo, tipos[1]) == 0){  //comprobacion del tipo
            printf("> [OPERACION] - MULTIPLICACION {numericoDecimal / numericoDecimal}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 9);
            $$.tipo = tipos[1]; 
            $$.numericoDecimal = $1.numericoDecimal * $3.numericoDecimal;
        }

    }
    //DIVISION
    | expresion DIVISION tipos {
        
        //DIVISION de numerico * numerico
        if (strcmp($1.tipo, tipos[0]) == 0 && strcmp($3.tipo, tipos[0]) == 0) {  //comprobacion del tipo
            printf("> [OPERACION] - DIVISION {numerico / numerico}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 8);
            $$.tipo = tipos[0]; 
            $$.numerico = $1.numerico / $3.numerico;
             printf("El valor de la operacion es: %d\n",  $1.numerico);
            printf("El valor de la operacion es: %d\n",  $3.numerico);
            printf("El valor de la operacion es: %d\n", $$.numerico); 
        }
        //DIVISION de numericoDecimal * numericoDecimal
        else if (strcmp($1.tipo, tipos[1]) == 0 && strcmp($3.tipo, tipos[1]) == 0){  //comprobacion del tipo
            printf("> [OPERACION] - DIVISION {numericoDecimal / numericoDecimal}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 8);
            $$.tipo = tipos[1]; 
            $$.numericoDecimal = $1.numericoDecimal / $3.numericoDecimal;
        }

    }
    //MAYOR_QUE
    | expresion MAYOR_QUE tipos {
        
        //MAYOR_QUE de numerico > numerico
        if (strcmp($1.tipo, tipos[0]) == 0 && strcmp($3.tipo, tipos[0]) == 0) {  //comprobacion del tipo
            printf("> [OPERACION] - MAYOR_QUE {numerico / numerico}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 10);
            $$.tipo = tipos[0]; 
            $$.numerico = $1.numerico > $3.numerico;
        }
        //MAYOR_QUE de numericoDecimal > numericoDecimal
        else if (strcmp($1.tipo, tipos[1]) == 0 && strcmp($3.tipo, tipos[1]) == 0){  //comprobacion del tipo
            printf("> [OPERACION] - MAYOR_QUE {numericoDecimal / numericoDecimal}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 10);
            $$.tipo = tipos[1]; 
            $$.numericoDecimal = $1.numericoDecimal > $3.numericoDecimal;
        }

    }
    //MAYOR_IGUAL_QUE
    | expresion MAYOR_IGUAL_QUE tipos {
        
        //MAYOR_IGUAL_QUE de numerico > numerico
        if (strcmp($1.tipo, tipos[0]) == 0 && strcmp($3.tipo, tipos[0]) == 0) {  //comprobacion del tipo
            printf("> [OPERACION] - MAYOR_IGUAL_QUE {numerico / numerico}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 11);
            $$.tipo = tipos[0]; 
            $$.numerico = $1.numerico >= $3.numerico;
        }
        //MAYOR_IGUAL_QUE de numericoDecimal > numericoDecimal
        else if (strcmp($1.tipo, tipos[1]) == 0 && strcmp($3.tipo, tipos[1]) == 0){  //comprobacion del tipo
            printf("> [OPERACION] - MAYOR_IGUAL_QUE {numericoDecimal / numericoDecimal}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 11);
            $$.tipo = tipos[1]; 
            $$.numericoDecimal = $1.numericoDecimal >= $3.numericoDecimal;
        }

    }
    //MENOR_QUE
    | expresion MENOR_QUE tipos {
        
        //MENOR_QUE de numerico > numerico
        if (strcmp($1.tipo, tipos[0]) == 0 && strcmp($3.tipo, tipos[0]) == 0) {  //comprobacion del tipo
            printf("> [OPERACION] - MENOR_QUE {numerico / numerico}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 12);
            $$.tipo = tipos[0]; 
            $$.numerico = $1.numerico < $3.numerico;
        }
        //MENOR_QUE de numericoDecimal > numericoDecimal
        else if (strcmp($1.tipo, tipos[1]) == 0 && strcmp($3.tipo, tipos[1]) == 0){  //comprobacion del tipo
            printf("> [OPERACION] - MENOR_QUE {numericoDecimal / numericoDecimal}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 12);
            $$.tipo = tipos[1]; 
            $$.numericoDecimal = $1.numericoDecimal < $3.numericoDecimal;
        }

    }
    //MENOR_IGUAL_QUE
    | expresion MENOR_IGUAL_QUE tipos {
        
        //MENOR_IGUAL_QUE de numerico > numerico
        if (strcmp($1.tipo, tipos[0]) == 0 && strcmp($3.tipo, tipos[0]) == 0) {  //comprobacion del tipo
            printf("> [OPERACION] - MENOR_IGUAL_QUE {numerico / numerico}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 13);
            $$.tipo = tipos[0]; 
            $$.numerico = $1.numerico <= $3.numerico;
        }
        //MENOR_IGUAL_QUE de numericoDecimal > numericoDecimal
        else if (strcmp($1.tipo, tipos[1]) == 0 && strcmp($3.tipo, tipos[1]) == 0){  //comprobacion del tipo
            printf("> [OPERACION] - MENOR_IGUAL_QUE {numericoDecimal / numericoDecimal}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 13);
            $$.tipo = tipos[1]; 
            $$.numericoDecimal = $1.numericoDecimal <= $3.numericoDecimal;
        }

    }//IGUAL_IGUAL
    | expresion IGUAL_IGUAL tipos {
        
        //IGUAL_IGUAL de numerico == numerico
        if (strcmp($1.tipo, tipos[0]) == 0 && strcmp($3.tipo, tipos[0]) == 0) {  //comprobacion del tipo
            printf("> [OPERACION] - IGUAL_IGUAL {numerico / numerico}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 14);
            $$.tipo = tipos[0]; 
            $$.numerico = $1.numerico == $3.numerico;
        }
        //IGUAL_IGUAL de numericoDecimal == numericoDecimal
        else if (strcmp($1.tipo, tipos[1]) == 0 && strcmp($3.tipo, tipos[1]) == 0){  //comprobacion del tipo
            printf("> [OPERACION] - IGUAL_IGUAL {numericoDecimal / numericoDecimal}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 14);
            $$.tipo = tipos[1]; 
            $$.numericoDecimal = $1.numericoDecimal == $3.numericoDecimal;
        }

    }//NO_IGUAL
    | expresion NO_IGUAL tipos {
        
        //NO_IGUAL de numerico != numerico
        if (strcmp($1.tipo, tipos[0]) == 0 && strcmp($3.tipo, tipos[0]) == 0) {  //comprobacion del tipo
            printf("> [OPERACION] - NO_IGUAL {numerico / numerico}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 15);
            $$.tipo = tipos[0]; 
            $$.numerico = $1.numerico != $3.numerico;
        }
        //NO_IGUAL de numericoDecimal != numericoDecimal
        else if (strcmp($1.tipo, tipos[1]) == 0 && strcmp($3.tipo, tipos[1]) == 0){  //comprobacion del tipo
            printf("> [OPERACION] - NO_IGUAL {numericoDecimal / numericoDecimal}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 15);
            $$.tipo = tipos[1]; 
            $$.numericoDecimal = $1.numericoDecimal != $3.numericoDecimal;
        }
        //NO_IGUAL de string != string (texto)
        else if (strcmp($1.tipo, tipos[2]) == 0 && strcmp($3.tipo, tipos[2]) == 0){  //comprobacion del tipo
            printf("> [OPERACION] - NO_IGUAL {texto / texto}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 15);
            $$.tipo = tipos[2]; 
            $$.texto = $1.texto != $3.texto;
        }
    }
    | tipos {$$ = $1;} //la produccion operacion puede ser tipos, un subnivel para realizar la jerarquia de operaciones
;

//-----------------------------------------------  TIPOS  ---------------------------------------------
/*PRODUCCION "tipos", en esta gramática se represetan los tipos de datos:
- identificadores (variables) - numeros enteros o decimales positivos o negativos
- cadenas de texto - estructura parentesis
T --> id | num | numdecimal */
tipos:

    //Identificador
    IDENTIFICADOR {
        printf(" IDENTIFICADOR %s\n",$1);
        //Buscamos en la tabla el identificador
        if(buscarTabla(indice, $1, tabla) != -1){     //En este IF entra si buscarTabla devuelve la posicion
            int pos = buscarTabla(indice, $1, tabla);
            //Para si es de tipo numerico
            if(tabla[pos].tipo==tipos[0]){
                $$.tipo = tabla[pos].tipo; 
                $$.numerico=tabla[pos].numerico; 
                $$.n = crearVariableTerminal(tabla[pos].numerico, tabla[pos].registro, tabla[pos].tipo);  //Creamos un nodo terminal con los numeros   
            }
            //Para si es de tipo numericoDecimal
            else if(tabla[pos].tipo==tipos[1]){
                $$.tipo = tabla[pos].tipo; $$.numericoDecimal=tabla[pos].numericoDecimal;
                $$.n = crearVariableTerminal(tabla[pos].numericoDecimal, tabla[pos].registro, tabla[pos].tipo); //Creamos un nodo terminal con los numeros        
            }
            //Para si es de tipo texto
            else if (tabla[pos].tipo==tipos[2]){
                $$.tipo = tabla[pos].tipo; 
                $$.n = crearVariableTerminalString(tabla[pos].texto, tabla[pos].registro, tabla[pos].tipo); //Creamos un nodo terminal con las cadenas{

            }
        }
    }

    //Numero entero normal
    | NUMERICO {
        $$.numerico = $1;
        printf("\n> [TIPO] - Numerico Positivo: %d\n", $$.numerico);
        
        $$.tipo = tipos[0];

        $$.n = crearNodoTerminal($1, tipos[0]);
        
    }

    //Numero decimal normal
    | NUMERICODECIMAL {
        $$.numericoDecimal = $1;
        printf("\n> [TIPO] - NumericoDecimal: %.3f\n", $$.numericoDecimal); 

        $$.tipo = tipos[1];

        $$.n = crearNodoTerminal($1, tipos[1]); 
    }

    //Cadena de texto
    | CADENA {
        $$.texto = $1;
        printf("\n> [TIPO] - Cadena de texto: %s\n", $1);

        $$.tipo = tipos[2];

        $$.n = crearNodoTerminalString($1, tipos[2]); 
    }
;

//-----------------------------------------------  IMPRIMIR  ---------------------------------------------
//Representa la estructura del print en lenguaje latino
//I --> imprimir ( E ) 
imprimir: 
    IMPRIMIR APERTURAPARENTESIS expresion CIERREPARENTESIS { 
        printf("> [SENTENCIA] - Imprimir\n");
        $$.n = crearNodoNoTerminal($3.n, crearNodoVacio(), 4);        
    }
;

%% 

//--------------------------------------------------- METODO MAIN -----------------------------------------------
int main(int argc, char** argv) {
    yyin = fopen(argv[1], "rt");            //Apertura del archivo codigo.latino
    yyout = fopen( "./latino.asm", "wt" );  //Para el archivo .ASM con nombre "latino.asm"
	yyparse();
    fclose(yyin);
    return 0;
}

//Metodo yyerror, generado por defecto
void yyerror(const char* s) {
    fprintf(stderr, "%s\n", s);
}