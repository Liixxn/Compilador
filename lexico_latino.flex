%option noyywrap

%{
#include "gramatica_latino.tab.h"
extern YYSTYPE yylval;
int num_linea = 1; 

%}

%%

"+"	                                            return SUMA;
"-"	                                            return RESTA;

"/"                                             return DIVISION;
"*"                                             return MULTIPLICACION;
"("	                                            return APERTURAPARENTESIS;
")"	                                            return CIERREPARENTESIS;

">="                                            return MAYOR_IGUAL_QUE;
"<="                                            return MENOR_IGUAL_QUE;
">"                                             return MAYOR_QUE;
"<"                                             return MENOR_QUE;

"=="	                                        return IGUAL_IGUAL;
"!="	                                        return NO_IGUAL;
"="	                                            return IGUAL;

\"([^\"]+)\"                                    {yylval.cadenaVal = strdup(yytext);return CADENA;}

imprimir|escribir|poner                         return IMPRIMIR;
[0-9]+                                          {yylval.enteroVal = atoi(yytext); return NUMERICO;}
[0-9]+.[0-9]+                                   {yylval.realVal   = atof(yytext); return NUMERICODECIMAL;}
_?[a-zA-Z0-9_]+		                            {yylval.stringVal = strdup(yytext); printf(yytext);return IDENTIFICADOR;}
\n

%%
