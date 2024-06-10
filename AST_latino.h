// ----------------------------- GLOSARIO DE IMPORTS -------------------------------------------
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h> 

// ----------------------------- DECLARACION DE VARIABLES Y ESTRUCTURAS --------------------------------------------
extern FILE *yyout;
int contadorEtiqueta = 0;         // Variable para el control de las etiquetas 
int numMaxRegistros = 32;         // Variable que indica el numero maximo de registros disponibles
int nombreVariable = 0;           // Almacena el entero que se asociará al nombre de la variable


//Por defecto, tenemos 32 registros de tipo f para controlar los registros libres (true) o ocupados (false)
bool registros[32] = {[0 ... 29] = true, [30 ... 31] = true}; // Los registros 30 y 31 están reservados por defecto para imprimir por pantalla

// Estructura variable, se hará uso de la misma para almacenar y imprimir las variables del codigo latino
struct variable {
    float dato;
    char *texto;
    int nombre; //limite de caracteres de la variable
    bool disponible;
};

struct variable variables[64]; // Declaramos el array de variables usando la estructura definida


union astValor {
    double valorDouble;
    char *valorString;
};

struct valorNodoRetorno {
    double valor;
    char *texto;
};


// Estructura AST, se define la estructura de los nodos del arbol
struct ast
{
  struct ast *izq;     // Nodo izquierdo del arbol
  struct ast *dcha;    // Nodo derecho del arbol
  int tipoNodo;        // Almacena el tipo de nodo
  //double valor;        // Almacena el valor del nodo
  union astValor valorNodo; // Almacena el valor del nodo
  char *tipo;          // El tipo de dato que almacena: numericoDecimal, numerico o string
  int resultado;       // Registro donde está el resultado
  int nombreVar;       // Indica el nombre de la variable
};

//-----------------------------------------------  METODOS -------------------------------------------------------

// METODO "crearNombreVariable", incremente el valor de la variable "nombreVariable"
int crearNombreVariable(){
  return nombreVariable++; //retorna la variable y luego la incrementa
}

// METODO "comprobarValorNodo", se escribe el lenguaje máquina (por tipo de nodo) desde árbol completo generado al nivel del axioma de la gramática
struct valorNodoRetorno comprobarValorNodo(struct ast *n, int contadorEtiquetaLocal)
{
  struct valorNodoRetorno dato;

  printf("Tipo del nodo a evaluar %s\n", n->tipo);

  //TIPO NODO 1 - Nueva hoja en el arbol
  if (n->tipoNodo == 1) {
    printf("\nSe crea una nueva hoja en el arbol\n");

    if (n->valorNodo.valorString != NULL) {
      printf("Tipo de la variable: %s\n", n->tipo);
      dato.texto = n->valorNodo.valorString;
      fprintf(yyout, "la $a%d, var_%d\n", n->resultado, n->nombreVar);
    } else {
      dato.valor = n->valorNodo.valorDouble;
      fprintf(yyout, "lwc1 $f%d, var_%d\n", n->resultado, n->nombreVar);
    }
    

  //TIPO NODO 3 - Nueva suma
  }  else if (n->tipoNodo == 2) {
    dato.valor = comprobarValorNodo(n->izq, contadorEtiquetaLocal).valor + comprobarValorNodo(n->dcha, contadorEtiquetaLocal).valor;
    fprintf(yyout, "add.s $f%d, $f%d, $f%d\n", n->resultado, n->izq->resultado, n->dcha->resultado); //se utiliza add.s para + en ASM
    borrarReg(n->izq, n->dcha); //borrado de registros (se ponen a true)

  //TIPO NODO 4 - Nueva resta
  } else if (n->tipoNodo == 3) {
    dato.valor = comprobarValorNodo(n->izq, contadorEtiquetaLocal).valor - comprobarValorNodo(n->dcha, contadorEtiquetaLocal).valor;
    fprintf(yyout, "sub.s $f%d, $f%d, $f%d\n", n->resultado, n->izq->resultado, n->dcha->resultado); //se utiliza sub.s para - en ASM
    borrarReg(n->izq, n->dcha); //borrado de registros (se ponen a true)
  
  //TIPO NODO 18 - Nuevo imprimir
  } else if (n->tipoNodo == 4) {
    comprobarValorNodo(n->izq, contadorEtiquetaLocal);
    funcionImprimir(n->izq);
    

  

  //TIPO NODO 19 - Nueva asignación 
  }else if (n->tipoNodo == 5) {
    dato = comprobarValorNodo(n->izq, contadorEtiquetaLocal);

  //TIPO NODO 20 - Nueva variable
  } else if (n->tipoNodo == 6) {
    printf("\nSe crea una nueva variable\n");

    if (n->valorNodo.valorString != NULL) {
      printf("Entra dentro del if\n");
      dato.texto = n->valorNodo.valorString;
    } else {
      dato.valor = n->valorNodo.valorDouble;
    }
    
  //TIPO NODO 22 - Lista de sentencias
  } else if (n->tipoNodo == 7) {
    dato = comprobarValorNodo(n->izq, contadorEtiquetaLocal); 
    comprobarValorNodo(n->dcha, contadorEtiquetaLocal);   
  }
  return dato; //Devolvemos el valor
}

// METODO "comprobarAST", imprime el codigo .asm y generas sus respectivos pasos
comprobarAST(struct ast *n)
{
  imprimirVariables(); //Metodo que realiza la impresion de la parte de variables para Mips
  fprintf(yyout, "\n#--------------------- Ejecuciones ---------------------");
  fprintf(yyout, "\n.text\n");
  fprintf(yyout, "lwc1 $f31, zero\n");
  comprobarValorNodo(n, contadorEtiqueta); //Comprueba el valor del nodo
}

// METODO "imprimir", imprime el codigo .asm que hace referencia a la funcion imprimir de latino
funcionImprimir(struct ast *n)
{
  fprintf(yyout, "li $v0, 2\n"); //entero
  fprintf(yyout, "add.s $f12, $f31, $f%d\n", n->resultado); // Mover del registro n al registro 30 (es el que empleamos para imprimir)
  fprintf(yyout, "mov.s $f30, $f12  #Movemos el registro 12 al 30 iniciado a false\n");
  fprintf(yyout, "syscall #Llamada al sistema\n");
  saltoLinea(); //Introducimos un salto de linea
}

funcionImprimirString(struct ast *n)
{
  fprintf(yyout, "li $v0, 2\n");
  fprintf(yyout, "la $a0, var_%d\n", n->resultado); // Mover del registro n al registro 30 (es el que empleamos para imprimir)
  fprintf(yyout, "addi $v0, $0, 4  #Movemos el registro 12 al 30 iniciado a false\n");
  fprintf(yyout, "syscall #Llamada al sistema\n");
  saltoLinea(); //Introducimos un salto de linea
}

// METODO "imprimirVariables", imprime el archivo .asm la estructura del .data
// Recorrer los registros y devolver la posicion del primero que esté libre
imprimirVariables(){
  fprintf(yyout, "\n#-------------- Declaracion de variables --------------"); 
  fprintf(yyout, "\n.data \n");
  fprintf(yyout, "saltoLinea: .asciiz \"\\n\"\n"); //Variable salto de linea
  fprintf(yyout, "zero: .float 0.0\n"); //Se inserta una variable auxiliar var_0 con valor 0.000
  //Bucle que recorre el array de variables y las imprime en el archivo .asm
  for (int i = 0; i < 64; i++) {
      if(variables[i].disponible == true){
        if (variables[i].texto != NULL) {
          fprintf(yyout, "var_%d: .asciiz %s\n", variables[i].nombre, variables[i].texto);
        } else {
        fprintf(yyout, "var_%d: .float %.3f\n", variables[i].nombre, variables[i].dato);
      }
      }
  }
}

// METODO "saltoLinea", incorpora un salto de linea en la salida de nuestro codigo
saltoLinea(){
	fprintf(yyout, "li $v0, 4\n");                      //especifica al registro $v0 que va a imprimir una cadena de caracteres
	fprintf(yyout, "la $a0, saltoLinea\n");             //carga en $a0 el valor del salto de linea
	fprintf(yyout, "syscall #Llamada al sistema\n");
}

// METODO "encontrarReg", comprueba si el registro está libre y devuelve su posicion
// Recorrer los registros y devolver la posicion del primero que esté libre
encontrarReg()
{
  int posicion = 0;
  while (posicion <= (numMaxRegistros - 1) && registros[posicion] == 0) {  // registros[posicion] == 0, evita recorrer todo el array
    posicion++;
  }
  registros[posicion] = 0;
  printf("\nEl registro libre es: %d\n", posicion); //Imprime la posicion libre
  return posicion; //retorna la posicion donde se encuentra el registro libre
}

// METODO "borrarReg", pone a true de nuevo el registro para que pueda volver a usarse
borrarReg(struct ast *izq, struct ast *dcha) { 
  registros[izq->resultado] = true; registros[dcha->resultado] = true; 
}

//METODO "crearNodoVacio", crea un nuevo nodo sin contenido
struct ast *crearNodoVacio()
{
  printf("\nSe crea un nuevo nodo vacio\n");
  struct ast *n = malloc(sizeof(struct ast)); // Asigna memoria dinamicamente para el nuevo nodo
  n->izq = NULL; n->dcha = NULL; n->tipoNodo = NULL;
  return n;
}

// METODO "crearNodoTerminal", crear una nueva hoja en el arbol AST
struct ast *crearNodoTerminal(double valor, char *t)
{ 
  printf("El tipo que se pasa es 1: %s\n", t);
  printf("El valor que se guarda 2 es: %f\n", valor);
  struct ast *n = malloc(sizeof(struct ast)); // Asigna memoria dinamicamente para el nuevo nodo
  n->izq = NULL; n->dcha = NULL; n->tipoNodo = 1; n->valorNodo.valorDouble = valor;
  n->resultado = encontrarReg(); //Hacemos llamada al metodo para buscar un nuevo registro
  n->nombreVar = crearNombreVariable();
  printf("# [AST] - Registro $f%d ocupado para var_%d = %.3f\n", n->resultado, n->nombreVar, n->valorNodo.valorDouble);
  variables[n->resultado].dato = n->valorNodo.valorDouble; variables[n->resultado].nombre = n->nombreVar; variables[n->resultado].disponible = true;
  return n;
}

// METODO "crearNodoTerminalString", crear una nueva hoja en el arbol AST
struct ast *crearNodoTerminalString(char *valor, char *t)
{ 
  printf("El tipo que se pasa es 21: %s\n", t);
  printf("El valor que se guarda 2 es: %s\n", valor);
  struct ast *n = malloc(sizeof(struct ast)); // Asigna memoria dinamicamente para el nuevo nodo
  n->izq = NULL; n->dcha = NULL; n->tipoNodo = 1; n->valorNodo.valorString = valor;
  n->resultado = encontrarReg(); //Hacemos llamada al metodo para buscar un nuevo registro
  n->nombreVar = crearNombreVariable();
  n->tipo = t;
  printf("# [AST] - Registro $f%d ocupado para var_%d = %s\n", n->resultado, n->nombreVar, n->valorNodo.valorString);
  variables[n->resultado].texto = n->valorNodo.valorString; variables[n->resultado].nombre = n->nombreVar; variables[n->resultado].disponible = true;
  return n;
}


// METODO "crearNodoNoTerminal", crea un nuevo nodo, asignamos sus hijos y tipo, y buscamos nuevo registro
struct ast *crearNodoNoTerminal(struct ast *izq, struct ast *dcha, int tipoNodo)
{ 
  printf("\nSe crea un nuveo nodo no terminal");
  struct ast *n = malloc(sizeof(struct ast)); // Crea un nuevo nodo
  printf("Tipo de nodo en crearNodoNoTerminal: %s\n", izq->tipo);
  n->izq = izq; n->dcha = dcha; n->tipoNodo = tipoNodo; // Asignamos al nodo genérico sus hijos y tipo
  n->resultado = encontrarReg(); //Hacemos llamada al metodo para buscar un nuevo registro
  return n;
}



// METODO "crearVariableTerminal", crear el nodo hoja para una variable ya creada
struct ast *crearVariableTerminal(double valor, int registro)
{        
  printf("\nSe crea una nueva variable terminal\n");                                       
  struct ast *n = malloc(sizeof(struct ast)); // Asigna memoria dinamicamente para el nuevo nodo
  n->izq = NULL; n->dcha = NULL; n->tipoNodo = 6; n->valorNodo.valorDouble = valor;
  n->resultado = registro;
  return n;
}


// METODO "crearVariableTerminalString", crear el nodo hoja para una variable ya creada
struct ast *crearVariableTerminalString(char *valor, int registro)
{                                     
  struct ast *n = malloc(sizeof(struct ast)); // Asigna memoria dinamicamente para el nuevo nodo
  n->izq = NULL; n->dcha = NULL; n->tipoNodo = 6; n->valorNodo.valorString = valor;
  n->resultado = registro;
  return n;
}