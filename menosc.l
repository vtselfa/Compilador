%{
#include <stdio.h>
#include "cabecera.h"
#include "asin.h"
#include "libtds.h"

void creaNombre();
void creaCEntera();
void truncCReal();

%}

letra [a-zA-Z]+
digito [0-9]+
delimitador [ \t\n]+

%option yylineno



%%

int                  {return INT_;}
read                 {return READ_;}
print                {return PRINT_;}
struct			{return STRUCT_;}
for			{return FOR_;}
if			{return IF_;}
else			{return ELSE_;}
return			{return RETURN_;}
{delimitador}        {}    
"{"                {return LLAVABR_;}
"}"                {return LLAVCER_;}
"["                {return CORABR_;}
"]"                {return CORCER_;}
"("                {return PARABR_;}
")"                {return PARCER_;}
","		   {return COMA_;}
";"                {return PUNTOYCOMA_;}
"."		   {return PUNTO_;}
"+"                         {return MAS_;}
"-"			  	{return MENOS_;}
"*"                         {return POR_;}
"/"				{return DIV_;}
"="                         {return IGUAL_;}
">"				{return MAYOR_;}
"<"				{return MENOR_;}
">="				{return MAYORIGUAL_;}
"<="				{return MENORIGUAL_;}
"+="				{return MASIGUAL_;}
"-="				{return MENOSIGUAL_;}
"=="				{return IGUALIGUAL_;}
"!="				{return DISTINTO_;}
"++"				{return MASMAS_;}
"--"				{return MENOSMENOS_;}
{digito}         		        {creaCEntera(); return ENTERO_;}
{digito}.{digito}			{truncCReal(); return ENTERO_;}	/* A toquitear en el análisis semántico */
{letra}({letra}|{digito}|"_")*		{creaNombre(); return ID_;}
"//"[^\n]*\n         	  	       {}
.                    		       {yyerror("Caracter Desconocido");}            

%%

/*****************************************************************************/
void creaNombre()
/* Comprueba que el identificador no exceda la talla máxima (14); en ese */
/* caso, lo trunca. */
{ char *t;
  if (yyleng > MAX_LENGTH) {
    if ( verbosidad ) 
      fprintf(stdout, "Warning at line %d: identificador truncado a longitud %d\n", yylineno, MAX_LENGTH);
    yyleng=MAX_LENGTH;
  }
  t = (char *)malloc(yyleng+1); strncpy(t, yytext, yyleng);
  t[yyleng] = '\0';
  yylval.ident = t;
}

/*****************************************************************************/
void creaCEntera()
/* Transforma una subcadena a la constante entera que representa */
{ 
  yylval.cent = atoi(yytext);
}

/*****************************************************************************/
void truncCReal()
/* Transforma una subcadena, que representa una constante real, a una */
/* constante entera truncándola. */
{ 
  char *t;
  if (verbosidad)
    fprintf(stdout, "Warning at line %d: constante real truncada a entera\n", yylineno);
  yyleng = strcspn(yytext,".");
  t = (char *)malloc(yyleng+1); strncpy(t, yytext, yyleng);
  t[yyleng] = '\0'; 
  yylval.cent = atoi(t);
}
/*****************************************************************************/



/* Programa principal: gestiona la linea de comandos e invoca al
analizador sintactico-semantico.*/
int main (int argc, char **argv){ 
    int i, n = 0;
    char* nom_fich;
    for (i=0; i<argc; ++i) {
        if (strcmp(argv[i], "-v")==0){
            verbosidad = TRUE;
            n++;
        }else if (strcmp(argv[i], "-t")==0){
            verTDS = TRUE;
            n++;
        }
    }
    --argc;
    n++;
    if (argc == n) {
        if ((yyin = fopen (argv[argc], "r")) == NULL){
            fprintf (stderr, "Fichero no valido %s\n", argv[argc]);
        }else{
            if (verbosidad == TRUE)
                fprintf(stdout,"%3d.- ", yylineno);
            yyparse ();
            nom_fich = argv[argc];
            if (numErrores > 0)
                fprintf(stdout,"\nNumero de errores:%d\n", numErrores);
            else
                vuelcaCodigo(nom_fich);
        }
    } else {
        fprintf (stderr, "Uso: cmc [-v] [-t] fichero\n");
    }
    
    return 0;
}



