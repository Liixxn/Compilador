bison -d -v -o src/gramatica_python.tab.c src/gramatica_python.y       
flex -o src/python.lex.c src/lexico_python.flex 
gcc -o ejecutable/COMPILADO src/gramatica_python.tab.c src/python.lex.c
ejecutable/COMPILADO pruebas/codigo.python