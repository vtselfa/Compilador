LIB=lib$(shell getconf LONG_BIT)

all: cmc

cmc: alex.o asin.o
	gcc -o cmc alex.o asin.o -L./${LIB} -I./include -lfl -ltds -lgci
asin.o: asin.c
	gcc -c asin.c -I./include
alex.o: alex.c asin.c
	gcc -c alex.c -I./include
asin.c: menosc.y
	bison -o asin.c -d menosc.y
	mv asin.h ./include
alex.c: menosc.l
	flex -o alex.c menosc.l
clean:
	rm -f asin.o alex.o asin.c alex.c include/asin.h
	rm -f programes_exemple/*.c3d
	rm -f cmc
