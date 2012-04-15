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
	TIPO_ARG pos;
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
int dvarMax;
int nivel;
int ro;
int posMain; //Sempre va a ser 1, però whatever
int posReturn; //Per a botar al final de la funció al fer return
int hayReturn; //Indica si ja hem passat per un return, necessari per completar-los tots

#define CABECERA_H
#endif
