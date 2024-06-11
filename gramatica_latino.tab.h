/* A Bison parser, made by GNU Bison 2.4.2.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2006, 2009-2010 Free Software
   Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     SUMA = 258,
     RESTA = 259,
     MULTIPLICACION = 260,
     DIVISION = 261,
     IGUAL = 262,
     APERTURAPARENTESIS = 263,
     CIERREPARENTESIS = 264,
     IMPRIMIR = 265,
     MAYOR_QUE = 266,
     MENOR_QUE = 267,
     MAYOR_IGUAL_QUE = 268,
     MENOR_IGUAL_QUE = 269,
     IGUAL_IGUAL = 270,
     NO_IGUAL = 271,
     AND = 272,
     OR = 273,
     WHILE = 274,
     FIN_BUCLE = 275,
     DOSPUNTOS = 276,
     FOR_BUCLE = 277,
     FIN_FOR = 278,
     IN = 279,
     RANGE = 280,
     COMA = 281,
     IF_CONDICION = 282,
     ELSE_CONDICION = 283,
     FIN_CONDICION = 284,
     NUMERICO = 285,
     NUMERICODECIMAL = 286,
     IDENTIFICADOR = 287,
     CADENA = 288
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1685 of yacc.c  */
#line 25 "gramatica_latino.y"

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



/* Line 1685 of yacc.c  */
#line 100 "gramatica_latino.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


