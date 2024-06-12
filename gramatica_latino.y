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
%token SUMA RESTA MULTIPLICACION DIVISION IGUAL APERTURAPARENTESIS CIERREPARENTESIS IMPRIMIR MAYOR_QUE MENOR_QUE MAYOR_IGUAL_QUE MENOR_IGUAL_QUE IGUAL_IGUAL NO_IGUAL AND OR WHILE FIN_BUCLE DOSPUNTOS FOR_BUCLE FIN_FOR IN RANGE COMA IF_CONDICION ELIF_CONDICION ELSE_CONDICION FIN_CONDICION

/*Declaración de los TOKENS que provienen de FLEX con su respectivo tipo*/
%token <enteroVal> NUMERICO 
%token <realVal> NUMERICODECIMAL 
%token <stringVal> IDENTIFICADOR
%token <cadenaVal> CADENA

/*Declaración de los TOKENS NO TERMINALES con su estructura*/
%type <tr> sentencias sentencia tipos expresion asignacion bucle_w bucle_f condicion_if elif_clauses else_clause imprimir  

/*Declaración de la precedencia siendo menor la del primero y mayor la del último*/
%left SUMA RESTA MULTIPLICACION DIVISION MAYOR_QUE MENOR_QUE MAYOR_IGUAL_QUE MENOR_IGUAL_QUE AND OR IGUAL_IGUAL NO_IGUAL


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
    | bucle_w
    | bucle_f
    | condicion_if        
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
            printf("\nNombre de la variable gramatica_latino: %s\n", $1);
            tabla[indice].nombre = $1; 
            tabla[indice].tipo = tipos[2];
            tabla[indice].texto = $3.texto;
            printf("\nEl registro que es donde esta guardado su dato es: %d\n", $3.n->resultado);
            tabla[indice].registro = $3.n->resultado;

            indice++;
        }
        // Control de errores
        else{
            yyerror("*** ERROR No es ninguno de los tipos definidos ***");
        }



        printf("\n------------ANTES DE CREAR NODO NO TERMINAL ASIGNACION----------------\n");
        printf("parte izq latino %s\n", $3.tipo);
        
        $$.n=crearNodoNoTerminal($3.n, crearNodoVacio(), 5);
        printf("\nNodo creado despues: Nombre: var_%d y Registro: %d\n", $$.n->nombreVar, $$.n->resultado);
        //printf("\nValor del nodo: %s\n", $$.n->valorNodo.valorString);

        printf("\n------------DESPUES DE CREAR NODO NO TERMINAL ASIGNACION----------------\n");

        

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
            printf("Tipo del nodo numerico fa: %s\n", $$.tipo);
            $$.numerico = $1.numerico + $3.numerico;
            $$.n->tipo = tipos[0];
            printf("Nodo final thtr %s\n", $$.n->izq->tipo);
        }

        //Suma de numericoDecimal + numericoDecimal
        else if (strcmp($1.tipo, tipos[1]) == 0 && strcmp($3.tipo, tipos[1]) == 0){  //comprobacion del tipo
            printf("> [OPERACION] - SUMA {numericoDecimal / numericoDecimal}\n");
            $$.n = crearNodoNoTerminal($1.n, $3.n, 2);
            $$.tipo = tipos[1];
            $$.n->tipo = tipos[1];
            $$.numericoDecimal = $1.numericoDecimal + $3.numericoDecimal;
        }

        //Suma de texto + texto
        else if (strcmp($1.tipo, tipos[2]) == 0 && strcmp($3.tipo, tipos[2]) == 0) {  //comprobacion del tipo
            printf("> [OPERACION] - CONCATENACION {texto / texto}\n");


            char *cadenaUnificada = malloc(strlen($1.n->valorNodo.valorString) + strlen($3.n->valorNodo.valorString) + 2);

            strcpy(cadenaUnificada, $1.n->valorNodo.valorString);
            strcat(cadenaUnificada, "");
            strcat(cadenaUnificada, $3.n->valorNodo.valorString);
            
            $$.n = crearNodoNoTerminal($1.n, $3.n, 2);
            $$.n->tipo = tipos[2];
            $$.tipo = tipos[2];

            variables[$$.n->resultado].texto = cadenaUnificada;
            variables[$$.n->resultado].nombre = $$.n->nombreVar;
            variables[$$.n->resultado].registro = $$.n->resultado;
            variables[$$.n->resultado].disponible = true;

            
            

            printf("\nREGISTRO ENCONTRADO PARA LA CADENA UNIFICADA %d\n", $$.n->resultado);

            // for (int i = 0; i < 64; i++){
            //     printf("\nValor de las variable en la posicion %d: %s\n", i, variables[i].texto);
            // }

        }
        // Control de errores
        else{
            yyerror("*** ERROR en la operacion SUMA ***");
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
        // Control de errores
        else{
            yyerror("*** ERROR en la operacion RESTA ***");
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
        // Control de errores
        else{
            yyerror("*** ERROR en la operacion MULTIPLICACION ***");
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
        // Control de errores
        else{
            yyerror("*** ERROR en la operacion division ***");
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
        // Control de errores
        else{
            yyerror("*** ERROR en la operacion MAYOR QUE ***");
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
        // Control de errores
        else{
            yyerror("*** ERROR en la operacion MAYOR O IGUAL QUE ***");
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
        // Control de errores
        else{
            yyerror("*** ERROR en la operacion MENOR QUE ***");}
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
        // Control de errores
        else{
            yyerror("*** ERROR en la operacion MENOR O IGUAL QUE ***");
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
        // Control de errores
        else{
            yyerror("*** ERROR en la operacion IGUAL IGUAL ***");
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
        // Control de errores
        else{
            yyerror("*** ERROR en la operacion DISTINTO DE ***");
        }
    }
        //AND
    | expresion AND tipos {
            
            //AND de numerico > numerico
            if (strcmp($1.tipo, tipos[0]) == 0 && strcmp($3.tipo, tipos[0]) == 0) {  //comprobacion del tipo
                printf("> [OPERACION] - AND {numerico / numerico}\n");
                $$.n = crearNodoNoTerminal($1.n, $3.n, 16);
                $$.tipo = tipos[0]; $$.numerico = $1.numerico && $3.numerico;
            }
            //AND de numericoDecimal > numericoDecimal
            else if (strcmp($1.tipo, tipos[1]) == 0 && strcmp($3.tipo, tipos[1]) == 0){  //comprobacion del tipo
                printf("> [OPERACION] - AND {numericoDecimal / numericoDecimal}\n");
                $$.n = crearNodoNoTerminal($1.n, $3.n, 16);
                $$.tipo = tipos[1]; $$.numericoDecimal = $1.numericoDecimal && $3.numericoDecimal;
            }

        
    }
    //OR
    | expresion OR tipos {
            
            //OR de numerico > numerico
            if (strcmp($1.tipo, tipos[0]) == 0 && strcmp($3.tipo, tipos[0]) == 0) {  //comprobacion del tipo
                printf("> [OPERACION] - OR {numerico / numerico}\n");
                $$.n = crearNodoNoTerminal($1.n, $3.n, 17);
                $$.tipo = tipos[0]; 
                $$.numerico = $1.numerico || $3.numerico;
            }
            //OR de numericoDecimal > numericoDecimal
            else if (strcmp($1.tipo, tipos[1]) == 0 && strcmp($3.tipo, tipos[1]) == 0){  //comprobacion del tipo
                printf("> [OPERACION] - OR {numericoDecimal / numericoDecimal}\n");
                $$.n = crearNodoNoTerminal($1.n, $3.n, 17);
                $$.tipo = tipos[1]; $$.numericoDecimal = $1.numericoDecimal || $3.numericoDecimal;
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
                printf("\n----------Informacion del id guardado en la tabla de simbolos----------\n");
                printf("Nombre: %s\n", tabla[pos].nombre);
                printf("Texto: %s\n", tabla[pos].texto);
                printf("Registro: %d\n", tabla[pos].registro);
                printf("Tipo: %s\n", tabla[pos].tipo);
                printf("\n----------Fin de la informacion del id guardado en la tabla de simbolos----------\n");
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
        printf("TIPO EN TIPOS %s\n", $$.n->tipo);
        
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


//-----------------------------------------------  BUCLE WHILE ---------------------------------------------
//Representa la estructura del bucle while en lenguaje latino
//W --> while ( E ): S 'fin_bucle'
bucle_w:
    WHILE APERTURAPARENTESIS expresion CIERREPARENTESIS DOSPUNTOS sentencias FIN_BUCLE {
        printf("> [SENTENCIA] - Bucle While\n");
        $$.n = crearNodoNoTerminal($3.n, $6.n, 21); // 21 es el numero del while
    }

;

//-----------------------------------------------  BUCLE FOR ---------------------------------------------
//Representa la estructura del bucle for en lenguaje PYTHON
//F --> for E in range ( E ): S 'fin_bucle'
bucle_f:
    FOR_BUCLE IDENTIFICADOR IN RANGE APERTURAPARENTESIS expresion CIERREPARENTESIS DOSPUNTOS sentencias FIN_FOR {
        printf("> [SENTENCIA] - Bucle For\n");
        $$.n = crearNodoNoTerminal($6.n, $9.n, 22); // 22 es el numero del for
    }

;

//-----------------------------------------------  CONDICION IF ---------------------------------------------
//Representa la estructura de la condicion if en lenguaje latino
//IF_CONDICION --> if ( E ): S else: S 'fin_conndicion'
condicion_if:
    IF_CONDICION APERTURAPARENTESIS expresion CIERREPARENTESIS DOSPUNTOS sentencias elif_clauses else_clause FIN_CONDICION {
        printf("> [SENTENCIA] - Condicion If\n");
        printf("El resultado es: %d\n", $3.numerico);
        if($3.numerico == 1){
            $$.n = crearNodoNoTerminal($6.n, crearNodoVacio(), 7); // 7 is the number for if
        } else if ($7.numerico == 1) {
            $$.n = crearNodoNoTerminal($7.n, crearNodoVacio(), 7); // 7 is the number for elif
        } else {
            $$.n = crearNodoNoTerminal($8.n, crearNodoVacio(), 7); // 7 is the number for else
        }
    }
    ;

elif_clauses:
    /* empty */ {
        $$.numerico = 0;
    }
    | elif_clauses ELIF_CONDICION APERTURAPARENTESIS expresion CIERREPARENTESIS DOSPUNTOS sentencias {
        printf("> [SENTENCIA] - Condicion Elif\n");
        printf("El resultado es: %d\n", $4.numerico);
        if($4.numerico == 1){
            $$.numerico = 1;
            $$.n = crearNodoNoTerminal($7.n, crearNodoVacio(), 7); // 7 is the number for elif
        }
    }
    ;

else_clause:
    ELSE_CONDICION DOSPUNTOS sentencias {
        $$.n = $3.n;
    }
    | /* empty */ {
        $$.n = crearNodoVacio();
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


#define RED     "\x1b[31m"
#define RESET   "\x1b[0m"
//Metodo yyerror, generado por defecto
void yyerror(const char* s) {
    fprintf(stderr, "\n--------------------------------------------------------\n");
    fprintf(stderr, "%s", s);
    fprintf(stderr, "\n--------------------------------------------------------\n\n");
}