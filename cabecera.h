#ifndef CABECERA_H

#include "libtds.h"
#include "libgci.h"

#define TALLA_SEGENLACES 2
#define MAX_LENGTH 14
#define TRUE 1
#define FALSE 0
#define TALLA_ENTERO 1

typedef struct TIPO{
	int tipo;
	int talla;
	int ref;
	int pos;
}TIPO;

typedef struct TIPONOM{
	char* nombre;
	int tipo;
	int talla;
	int ref;
}TIPONOM;

/*typedef struct simb Elementos de la TDS 
{
int categoria; / Categoría del objeto /
int tipo; / Tipo del objeto /
int desp; / Desplazamiento relativo en memoria /
int nivel; / Nivel del bloque /
int ref; / Campo de referencia de usos múltiples /
}SIMB; 
*/

SIMB simbolo;
REG registro;

/*typedef struct dim /* Elementos de la Tabla de Array 
{
int telem; /* Tipo de los elementos 
int nelem; /* Número de elementos del array
}DIM;*/

DIM array;

int verbosidad;
int numErrores;
int verTDS;
//int desp; //Ara usem dvar, definit a libgci.h
int nivel;
int ro;

#define CABECERA_H
#endif
