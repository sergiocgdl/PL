.SUFFIXES:

p3: main.o y.tab.o
	gcc -o p3 main.o y.tab.o -g

y.tab.o: y.tab.c
	gcc -c y.tab.c -std=c11 -g

main.o: main.c
	gcc -c main.c -g

y.tab.c: p3.y lex.yy.c p4.h
	bison -o y.tab.c p3.y -v

lex.yy.c: p2.l
	flex p2.l

simp: p3 simple p3.y p4.h
	./p3 simple
	gcc -o p5 codigoGenerado.c -std=c99 -g

prim: p3 primos p3.y p4.h
	./p3 primos
	gcc -o p5 codigoGenerado.c -std=c99 -g

compl: p3 complex p3.y p4.h
	./p3 complex
	gcc -o p5 codigoGenerado.c -std=c99 -g

matx: p3 complexMatrix p3.y p4.h
	./p3 complexMatrix
	gcc -o p5 codigoGenerado.c -std=c99 -g

ex: p3 examen p3.y p4.h
	./p3 examen
	gcc -o p5 codigoGenerado.c -std=c99 -g

clean:
	rm -f p3 p5 prueba1 test_list prueba1.exe p3.exe main.o y.tab.o y.tab.c lex.yy.c y.output codigoGenerado.c p5.exe dec_fun.h

all:
	make clean
	make p3
