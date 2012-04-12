#ifndef CABECERA_H

#include "libtds.h"

#define TALLA_SEGENLACES 2
#define MAX_LENGTH 14
#define TRUE 1
#define FALSE 0
#define TALLA_ENTERO 1

typedef struct TIPO{
	int tipo;
	int talla;
	int ref;
}TIPO;

typedef struct TIPONOM{
	char* nombre;
	int tipo;
	int talla;
	int ref;
}TIPONOM;

/*typedef struct simb Elementos de la TDS 
{
int categoria; / Categora del objeto /
int tipo; / Tipo del objeto /
int desp; / Desplazamiento relativo en memoria /
int nivel; / Nivel del bloque /
int ref; / Campo de referencia de usos multiples /
}SIMB; 
*/

SIMB simbolo;
REG registro;

/*typedef struct dim /* Elementos de la Tabla de Array 
{
int telem; /* Tipo de los elementos 
int nelem; /* Numero de elementos del array
}DIM;*/

DIM array;

int verbosidad;
int numErrores;
int verTDS;
int desp;
int nivel;
int ro;

#define CABECERA_H
#endif
