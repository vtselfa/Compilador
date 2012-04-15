%{
#include <stdio.h>
#include <string.h>
#include "cabecera.h"
extern int yylineno;

%}

%error-verbose

%token <ident> ID_
%token <cent> ENTERO_ 
%token INT_
%token PARABR_ PARCER_ LLAVABR_ LLAVCER_ CORABR_ CORCER_
%token RETURN_ IF_ ELSE_ FOR_ STRUCT_ READ_ PRINT_
%token PUNTO_ COMA_ PUNTOYCOMA_
%token IGUAL_ MASIGUAL_ MENOSIGUAL_ IGUALIGUAL_ DISTINTO_ MAYOR_ MENOR_ MAYORIGUAL_ MENORIGUAL_
%token MAS_ MENOS_ POR_ DIV_ MASMAS_ MENOSMENOS_

%union{
   int cent;
   char* ident;
   TIPO tipo;
   TIPONOM tiponom;
   int aux;
}

%type <tiponom> declaracionVariable;
%type <tipo> parametrosFormales;
%type <tipo> tipo;
%type <tipo>  listaCampos;
%type <tipo> listaParametrosFormales;
%type <tipo>  expresion;
%type <tipo>  expresionIgualdad;
%type <tipo>  expresionSufija;
%type <tipo>  expresionAditiva;
%type <tipo>  expresionRelacional;
%type <tipo>  expresionMultiplicativa;
%type <tipo>  expresionUnaria;
%type <tipo> listaParametrosActuales;
%type <tipo> parametrosActuales;

%type <cent> operadorUnario;
%type <cent> operadorIncremento;
%type <cent> operadorIgualdad;
%type <cent> operadorRelacional;
%type <cent> operadorMultiplicativo;
%type <cent> operadorAditivo;
%type <cent> operadorAsignacion;
%%

programa :
            {nivel=0;
            cargaContexto(nivel);
            dvar=0; //Desp en seg. de dades
            si=0; //Desp. en seg. de codi

            esPrimeraFunc = TRUE;
            tamVarGlobal = 0;
            posVarGlobal = creaLans(si);
            emite(INCTOP, crArgNulo(), crArgNulo(), crArgNulo()); //Desplaça el tope un nombre igual al tamany del segment de variables globals

            posMain = creaLans(si);
            emite(GOTOS, crArgNulo(), crArgNulo(), crArgNulo()); //Saltem a main()
            }
        secuenciaDeclaraciones
            {simbolo = obtenerSimbolo("main"); //Comprovem que la funció main existeix
            if(simbolo.categoria != FUNCION)
                yyerror("No se encuentra la función main");
            else{
                INF infoFunc = obtenerInfoFuncion(simbolo.ref);
                if(infoFunc.tparam != 0)
                    yyerror("La funcion main no ha de recibir ningún parámetro");
            }
	        emite(FIN, crArgNulo(), crArgNulo(), crArgNulo() );
            descargaContexto(nivel);   
            }
;



secuenciaDeclaraciones : declaracion

	| secuenciaDeclaraciones declaracion
;



declaracion : declaracionVariable 
            {if(!insertaSimbolo($1.nombre,VARIABLE,$1.tipo,dvar,nivel,$1.ref)) 
                yyerror("Identificador repetido");
            mostrarTDS(0); 
	        dvar+=$1.talla;
                tamVarGlobal+=$1.talla;}
		        
	| declaracionFuncion {if(esPrimeraFunc==TRUE)
                                   completaLans(posVarGlobal, crArgEntero(tamVarGlobal));
                              esPrimeraFunc = FALSE;}
;



declaracionVariable : tipo ID_  PUNTOYCOMA_
            {$$.nombre=$2;
            $$.tipo=$1.tipo;
            $$.talla=$1.talla;
            $$.ref=$1.ref;}
            
	| tipo ID_ CORABR_ ENTERO_ CORCER_ PUNTOYCOMA_
            {if(! $4 > 0)
                yyerror("La talla tiene que ser mayor que cero");
            $$.nombre=$2;
            $$.tipo=T_ARRAY;
            $$.ref=insertaInfoArray($1.tipo,$4);
            $$.talla=$4*$1.talla;}
;



tipo : INT_ 
            {$$.tipo=T_ENTERO;
            $$.talla=TALLA_ENTERO;
            $$.ref=-1;}
            
	| STRUCT_ LLAVABR_ listaCampos LLAVCER_
	        {$$.tipo=T_RECORD;
	        $$.talla=$3.talla;
	        $$.ref=$3.ref;}
;



listaCampos : declaracionVariable
            {if($1.tipo!=T_ENTERO) 
                yyerror("El tipo de los campos de un registro debe ser entero");
			$$.ref=insertaInfoCampo(-1,$1.nombre,$1.tipo,0);
			$$.talla=$1.talla;}

	| listaCampos declaracionVariable
	        {if($2.tipo!=T_ENTERO) 
			    yyerror("El tipo de los campos de un registro debe ser entero"); 
			$$.ref=insertaInfoCampo($1.ref,$2.nombre,$2.tipo,$1.talla);
		    if($$.ref==-1)
				yyerror("Identificador repetido"); 
			$$.talla=$1.talla + $2.talla;}
;



declaracionFuncion :
        cabeceraFuncion
            {$<aux>$ = dvar;
            dvar = 0;
            dvarMax = 0;
            mostrarTDS(0);}

	    {hayReturn = FALSE;
            emite(PUSHFP, crArgNulo(), crArgNulo(), crArgNulo()); //Apilem el fp
            emite(FPTOP, crArgNulo(), crArgNulo(), crArgNulo()); //Ara fp apunta al top de la pila
            $<aux>$ = creaLans(si); //Volem completar despres el pròxim emite
            emite(INCTOP,crArgNulo(),crArgNulo(),crArgNulo());} //Resevem espai per a les variables locals i temporals (dvar o dvarmax). Com no sabem la talla total, hem fet un crealans.
        bloque
            {TIPO_ARG tipo_arg;
            if(dvar >= dvarMax)
                  tipo_arg = crArgEntero(dvar);      
            else
                  tipo_arg = crArgEntero(dvarMax);
            completaLans($<aux>3,tipo_arg);

            if(strcmp(obtenerInfoFuncion(-1).nombre,"main") !=0 )
                  completaLans(posReturn, crArgEtiqueta(si));        //Si no es main, ha d'haver-hi un return

            emite(TOPFP, crArgNulo(), crArgNulo(), crArgNulo()); //El top de la pila ara apunta al mateix lloc que el fp
            emite(FPPOP, crArgNulo(), crArgNulo(), crArgNulo()); //Recuperem el fp antic
            if(strcmp(obtenerInfoFuncion(-1).nombre,"main") !=0 ) //Sols fem return si la funció no és main
                 emite(RET, crArgNulo(), crArgNulo(), crArgNulo());
	    descargaContexto(nivel);
            nivel--;
            dvar = $<aux>2;}
;



cabeceraFuncion :
        tipo ID_
            {nivel++;
            cargaContexto(nivel);
            ro = TALLA_SEGENLACES;}
        PARABR_
        parametrosFormales
        PARCER_ 
            {if($1.tipo!=T_ENTERO)
		        yyerror("El tipo del valor de retorno de una función debe ser entero");
	     if(!insertaSimbolo($2,FUNCION,$1.tipo,si,nivel-1,$5.ref))
		        yyerror("Identificador repetido");
             if(strcmp($2,"main")==0)
                    completaLans(posMain, crArgEtiqueta(si));}
;



parametrosFormales :
            {$$.ref=insertaInfoDominio(-1,T_VACIO);}
            
	| listaParametrosFormales
	        {$$.ref=$1.ref;}
;
	
	

listaParametrosFormales : tipo ID_
            {ro = ro + $1.talla;
			if($1.tipo!=T_ENTERO)
				yyerror("El tipo de los parámetros de una función debe ser entero");
			if(!insertaSimbolo($2,PARAMETRO,$1.tipo,-ro,nivel,-1))
				yyerror("Identificador repetido");
			$$.ref=insertaInfoDominio(-1,$1.tipo);}

	| tipo ID_ COMA_ listaParametrosFormales
	        {ro = ro + $1.talla; 
			if($1.tipo!=T_ENTERO)
				yyerror("El tipo de los parámetros de una función debe ser entero");
			if(!insertaSimbolo($2,PARAMETRO,$1.tipo,-ro,nivel,-1)) 
				yyerror("Identificador repetido"); 
			$$.ref =insertaInfoDominio($4.ref,$1.tipo);}
;



bloque :  LLAVABR_ declaracionVariableLocal listaInstrucciones LLAVCER_
;



declaracionVariableLocal :

	| declaracionVariableLocal declaracionVariable 
            {if(!insertaSimbolo($2.nombre,VARIABLE,$2.tipo,dvar,nivel,$2.ref))
                yyerror("Identificador repetido"); 
	        dvar=dvar+$2.talla;
	        mostrarTDS(nivel);}
;
							
							
							
listaInstrucciones :

	| listaInstrucciones instruccion
;



instruccion :
            {nivel++;
            cargaContexto(nivel);
            $<aux>$=dvar;}
        LLAVABR_
        declaracionVariableLocal
        listaInstrucciones
        LLAVCER_
            {descargaContexto(nivel);
	        if(dvar > dvarMax)
                dvarMax = dvar;
            nivel--;
            dvar=$<aux>1;}
            
	| instruccionExpresion
	
	| instruccionEntradaSalida
	
	| instruccionSeleccion
	 
	| instruccionIteracion
	
	| instruccionSalto
;



instruccionExpresion : PUNTOYCOMA_

	| expresion PUNTOYCOMA_
;



instruccionEntradaSalida : READ_ PARABR_ ID_ PARCER_ PUNTOYCOMA_
            {simbolo = obtenerSimbolo($3);
			if (simbolo.categoria==NULO)
			    yyerror("La variable no está en la tabla de símbolos",$3); 
			if( simbolo.tipo!=T_ERROR && simbolo.tipo!=T_ENTERO )
			    yyerror("La instrucción read ha de recibir un parámetro de tipo entero");
                        
                        emite(EREAD, crArgNulo(), crArgNulo(), crArgPosicion(simbolo.nivel,simbolo.desp));
			}

	| PRINT_ PARABR_ expresion PARCER_ PUNTOYCOMA_ 
               {if($3.tipo!=T_ERROR && $3.tipo != T_ENTERO)
                       yyerror("La instrucción print ha de recibir una expresión de tipo entero");
                emite(EWRITE, crArgNulo(), crArgNulo(), $3.pos);}
;
            


instruccionSeleccion :
        IF_
        PARABR_
        expresion
        PARCER_
            {if($3.tipo!=T_LOGICO) //Per a que el test b03.c mostre els errors que toca no comprovem si el tipo és T_ERROR
                yyerror("La expresión de dentro del IF ha de ser de tipo lógico");
             $<aux>$ = creaLans(si);
             emite(EIGUAL,$3.pos, crArgEntero(0), crArgNulo());}
        instruccion
            {$<aux>$ = creaLans(si);
             emite(GOTOS, crArgNulo(), crArgNulo(), crArgNulo());
             completaLans($<aux>5, crArgEtiqueta(si));} 
        ELSE_
        instruccion
            {completaLans($<aux>7, crArgEtiqueta(si));}
;



instruccionIteracion :
        FOR_
        PARABR_
        expresionOpcional
            {$<aux>$ = si;} 
        PUNTOYCOMA_
        expresion
            {if($6.tipo!=T_LOGICO)
                yyerror("La expresión de la condición de parada del bucle FOR ha de ser de tipo lógico");}
            {$<aux>$ = creaLans(si); 
             emite(EIGUAL, $6.pos, crArgEntero(1), crArgNulo())} //Salt si condició certa, al cos del bucle
            {$<aux>$ = creaLans(si); 
             emite(GOTOS, crArgNulo(), crArgNulo(), crArgNulo())} //Salt si condició falsa, fora del bucle
            {$<aux>$ = si;}
        PUNTOYCOMA_
        expresionOpcional
            {emite(GOTOS, crArgNulo(), crArgNulo(), crArgEtiqueta($<aux>4)); //Bot incondicional a la condició
             completaLans($<aux>8, crArgEtiqueta(si));}
        PARCER_
        instruccion
            {emite(GOTOS, crArgNulo(), crArgNulo(), crArgEtiqueta($<aux>10)); //Bot incondicional al increment
             completaLans($<aux>9, crArgEtiqueta(si));}
;



expresionOpcional : 

	| expresion
;



instruccionSalto : RETURN_ expresion PUNTOYCOMA_
            {if($2.tipo != T_ENTERO) //Per a que el test b03.c mostre els errors que toca no comprovem si el tipo és T_ERROR
                yyerror("El valor de retorno de la función ha de ser de tipo entero");
             INF infoFunc = obtenerInfoFuncion(-1);
             emite(EASIG, $2.pos, crArgNulo(), crArgPosicion(nivel, - (infoFunc.tparam + TALLA_SEGENLACES + TALLA_ENTERO))); //Falta sumar el FP?
             if(hayReturn == FALSE){             
                   posReturn = creaLans(si);
                   hayReturn = TRUE;
             }else
                   posReturn = fusionaLans(creaLans(si), posReturn);
             emite(GOTOS, crArgNulo(), crArgNulo(), crArgNulo());} 
;



expresion : expresionIgualdad //GCI
            {$$.tipo=$1.tipo;
            $$.pos = $1.pos;}

	| ID_ operadorAsignacion expresion //GCI
	        {simbolo = obtenerSimbolo($1);
			if (simbolo.categoria==NULO)
			    yyerror("Variable no declarada"); 
			if( simbolo.tipo==$3.tipo && simbolo.tipo==T_ENTERO )
			    $$.tipo=T_ENTERO;
			else{
			    if( $3.tipo!=T_ERROR && simbolo.tipo!=T_ERROR )
					yyerror("Error de tipos en la asignacion");
				$$.tipo=T_ERROR;
			}
			TIPO_ARG id = crArgPosicion(simbolo.nivel, simbolo.desp);
			if($2!=EASIG) //Tenim un '+=' o un '-='
			    emite($2, id, $3.pos, id);
			else //Tenim un '='
			    emite(EASIG, $3.pos, crArgNulo(), id); 
                        $$.pos = id;} //A modificar, pot ser es deuria crear una var temp per fer-ho tot homogeni
							
	| ID_ CORABR_ expresion CORCER_ operadorAsignacion expresion //id[expr] [+- ]= expr //GCI
	        {simbolo = obtenerSimbolo($1); 
			if(simbolo.categoria==NULO){
			    yyerror("Variable no declarada");
			    $$.tipo=T_ERROR;
			} else if (simbolo.tipo!=T_ARRAY){
			    yyerror("La variable no es un array");
			    $$.tipo=T_ERROR;
			} else {
    			array = obtenerInfoArray(simbolo.ref);
				if($3.tipo!=T_ENTERO)
				    yyerror("El índice debe ser un entero");
				else if (array.telem==$6.tipo && array.telem==T_ENTERO )
				    $$.tipo=T_ENTERO;
				else {
					if ( $3.tipo!=T_ERROR && array.telem!=T_ERROR )
						yyerror("Error de tipos en la asignacion");
					$$.tipo=T_ERROR;
				}
			}
			TIPO_ARG vec = crArgPosicion(simbolo.nivel, simbolo.desp);
		        $$.pos = crArgPosicion(nivel, creaVarTemp());
			if($5!=EASIG){ //Tenim un '+=' o un '-='
			    emite( EAV, vec, $3.pos, $$.pos); //array -> tmp
			    emite( $5, $$.pos , $6.pos, $$.pos); //tmp = tmp [+-] expr 
			    emite( EVA, vec, $3.pos, $$.pos); //tmp -> array
			}else{ //Tenim un '='
			    emite( EVA, vec, $3.pos, $6.pos);
                            emite (EASIG, $6.pos, crArgNulo(), $$.pos);
			}}
												
	| ID_ PUNTO_ ID_ operadorAsignacion expresion  //id.id = expr //GCI
	        {simbolo = obtenerSimbolo($1);
			if(simbolo.categoria==NULO)
			    yyerror("Variable no declarada");
			else if(simbolo.tipo!=T_RECORD)
			    yyerror("La variable no es un registro");
			else {
				registro = obtenerInfoCampo(simbolo.ref, $3);
				if(registro.tipo == T_ERROR){
				    yyerror("El campo del registro no existe");
				    $$.tipo=T_ERROR;
				}
				else if( registro.tipo == $5.tipo && registro.tipo == T_ENTERO)
				    $$.tipo=T_ENTERO;
				else {
					if ($5.tipo!=T_ERROR && registro.tipo!=T_ERROR )
						yyerror("Error de tipos en la asignación");
					$$.tipo=T_ERROR;
				}
			}
			TIPO_ARG campo = crArgPosicion(simbolo.nivel, simbolo.desp + registro.desp);
			if($4!=EASIG) //Tenim un '+=' o un '-='
			    emite( $4, campo, $5.pos, campo );
			else //Tenim un '='
			    emite( EASIG, $5.pos, crArgNulo(), campo );
                        $$.pos = campo;} //A modificar, pot ser es deuria crear una var temp per fer-ho tot homogeni
;



expresionIgualdad : expresionRelacional //GCI
            {$$.tipo=$1.tipo;
            $$.pos=$1.pos;}

	| expresionIgualdad operadorIgualdad expresionRelacional //GCI
	        {if($1.tipo==$3.tipo && $1.tipo==T_ENTERO)
	            $$.tipo=T_LOGICO;
			else{
				if (($1.tipo!=T_ERROR)&&($3.tipo!=T_ERROR))
					yyerror("Error de tipos en la asignación");
				$$.tipo=T_ERROR;
			}
			$$.pos = crArgPosicion(nivel, creaVarTemp());
			emite( EASIG, crArgEntero(1), crArgNulo(), $$.pos);  //Guarda true
			emite( $2, $1.pos, $3.pos, crArgEtiqueta(si+2)); //Si expr1 [!=]= expr2 -> salta la pròxima instrucció
			emite( EASIG, crArgEntero(0), crArgNulo(), $$.pos);} //Guarda false
;



expresionRelacional : expresionAditiva //GCI
            {$$.tipo=$1.tipo;
            $$.pos=$1.pos;}

	| expresionRelacional operadorRelacional expresionAditiva //GCI
	        {if($1.tipo==$3.tipo && $1.tipo==T_ENTERO)
	            $$.tipo=T_LOGICO;
			else{
				if (($1.tipo!=T_ERROR)&&($3.tipo!=T_ERROR))
					yyerror("Error de tipos en la asignación");
				$$.tipo=T_ERROR;
			}
			$$.pos = crArgPosicion(nivel, creaVarTemp());
			emite( EASIG, crArgEntero(1), crArgNulo(), $$.pos);  //Guarda true
			emite( $2, $1.pos, $3.pos, crArgEtiqueta(si+2)); //Si expr1 [!=]= expr2 -> salta la pròxima instrucció
			emite( EASIG, crArgEntero(0), crArgNulo(), $$.pos);} //Guarda false
;



expresionAditiva : expresionMultiplicativa
            {$$.tipo=$1.tipo;
             $$.pos=$1.pos;}

	| expresionAditiva operadorAditivo expresionMultiplicativa
	        {if($1.tipo==$3.tipo && $1.tipo==T_ENTERO)
	               $$.tipo=T_ENTERO;
                 else{
		       if (($1.tipo!=T_ERROR)&&($3.tipo!=T_ERROR))
		             yyerror("Error de tipos en la asignación");
		       $$.tipo=T_ERROR;
		 }
		 $$.pos = crArgPosicion(nivel, creaVarTemp());               
                 emite($2, $1.pos, $3.pos, $$.pos);}
;



expresionMultiplicativa : expresionUnaria 
                          {$$.tipo=$1.tipo; 
                           $$.pos = $1.pos;}

	| expresionMultiplicativa operadorMultiplicativo expresionUnaria
	        {if($1.tipo==$3.tipo && $1.tipo==T_ENTERO)
	            $$.tipo=T_ENTERO;
	         else{
			if (($1.tipo!=T_ERROR)&&($3.tipo!=T_ERROR))
				yyerror("Error de tipos en la asignación");
			$$.tipo=T_ERROR;
		 }
		 $$.pos = crArgPosicion(nivel, creaVarTemp());               
                 emite($2, $1.pos, $3.pos, $$.pos);}
;



expresionUnaria : expresionSufija 
                    {$$.tipo=$1.tipo;
                     $$.pos = $1.pos;}

	| operadorUnario expresionUnaria
	        {$$.tipo=$2.tipo;
                 $$.pos = crArgPosicion(nivel,creaVarTemp());
	         emite($1, crArgEntero(0), $2.pos, $$.pos);
	        }
	
	| operadorIncremento ID_
	        {simbolo = obtenerSimbolo($2); 
			if(simbolo.tipo!=T_ENTERO){
			    yyerror("Error de tipo. La variable no es un entero");
			    $$.tipo=T_ERROR;
			} else
			    $$.tipo=T_ENTERO;
		    TIPO_ARG res = crArgPosicion(simbolo.nivel, simbolo.desp);
		    emite( $1, res, crArgEntero(1), res ); //Sumem 1 a la variable
		    $$.pos = crArgPosicion(nivel, creaVarTemp()); //Cream var temp
		    emite( EASIG, res, crArgNulo(), $$.pos); }; //Asignim la var temp a $$.pos
;



expresionSufija : ID_ CORABR_ expresion CORCER_
            {simbolo = obtenerSimbolo($1);
			if(simbolo.categoria==NULO) {
				yyerror("Variable no declarada"); 
				$$.tipo=T_ERROR;
			} else if(simbolo.tipo!=T_ARRAY){
				yyerror("La variable no es un array"); 
				$$.tipo=T_ERROR; 
			} else if($3.tipo!=T_ENTERO){
				if($3.tipo!=T_ERROR) 
					yyerror("El índice debe ser un entero"); 
				$$.tipo=T_ERROR; 
			} else
			    $$.tipo=T_ENTERO;

			$$.pos = crArgPosicion(nivel, creaVarTemp());
			emite( EAV, crArgPosicion(simbolo.nivel, simbolo.desp), $3.pos, $$.pos); 
                      }
							
	| ID_ PUNTO_ ID_
	        {simbolo = obtenerSimbolo($1);
			if(simbolo.categoria==NULO) {
				yyerror("Variable no declarada"); 
				$$.tipo=T_ERROR;
			}else if(simbolo.tipo!=T_RECORD) {
				yyerror("La variable no es un registro"); 
				$$.tipo=T_ERROR; 
			}else{
				registro = obtenerInfoCampo(simbolo.ref,$3);
				if(registro.tipo == T_ERROR){
				    yyerror("El campo del registro no existe");
				    $$.tipo=T_ERROR;
				}
				else if(registro.tipo != T_ENTERO){
					yyerror("El registro debe ser de tipo entero"); 
					$$.tipo=T_ERROR;
				}else 
					$$.tipo=T_ENTERO;

			$$.pos = crArgPosicion(simbolo.nivel, simbolo.desp + registro.desp);
		    }}

	| ID_ operadorIncremento
	        {simbolo=obtenerSimbolo($1);
			if(simbolo.categoria==NULO) {
				yyerror("Variable no declarada"); 
				$$.tipo=T_ERROR;
			}else if(simbolo.tipo!=T_ENTERO){
				yyerror("Los operadores de incremento solo se pueden aplicar a enteros");
				$$.tipo=T_ERROR;
			}else 
				$$.tipo=T_ENTERO;
                        $$.pos = crArgPosicion(nivel, creaVarTemp());
		        TIPO_ARG res = crArgPosicion(simbolo.nivel, simbolo.desp);
                        emite(EASIG, res, crArgNulo(), $$.pos);  //Copia el contingut de la variable a la variable temporal
                        emite($2, res, crArgEntero(1), res);}     //Incrementa/decrementa la variable en 1
					
	|   ID_ 
	    PARABR_ 
		    {emite(INCTOP, crArgNulo(), crArgNulo(), crArgEntero(TALLA_ENTERO));} //Reservem espai per al valor de retorn (que sabem que és un enter)
        parametrosActuales //Ací dins s'apilen els paràmetres de la funció
        PARCER_
            {simbolo=obtenerSimbolo($1);
	        INF infoFunc = obtenerInfoFuncion(simbolo.ref);
            if(simbolo.categoria==NULO) {
	            yyerror("Variable no declarada"); 
	            $$.tipo=T_ERROR;
            }else if(simbolo.categoria!=FUNCION){
	            yyerror("No hay ninguna función declarada con este nombre");
	            $$.tipo=T_ERROR;
            }else if(simbolo.tipo!=T_ENTERO){
	            yyerror("El valor de retorno de una funcion debe ser un entero");
	            $$.tipo=T_ERROR;
	        }else if($4.talla != infoFunc.tparam){
	            yyerror("El número de parámetros de llamada de la función no es correcto");
	            $$.tipo=T_ERROR;
            }else if($4.tipo != T_ERROR && !comparaDominio($4.ref,simbolo.ref)){
	            yyerror("El dominio de la función no es el esperado");
	            $$.tipo=T_ERROR;
            }else 
	            $$.tipo=T_ENTERO;
 //               emite(EPUSH, crArgNulo(), crArgNulo(), crArgEntero(si+2)); //Apilem la dir de retorn
                                                                             // NO l'APILEM, CALL HO FA
                                                                             // sí, és prou estúpid però és aixina
                emite(CALL, crArgNulo(), crArgNulo(), crArgEtiqueta(simbolo.desp)); //Cridem a la funció
                emite(DECTOP, crArgNulo(), crArgNulo(), crArgEntero($4.talla)); //Desapilem els paràmetres
                $$.pos = crArgPosicion(nivel, creaVarTemp());
                emite(EPOP, crArgNulo(), crArgNulo(), $$.pos);} //Desapilem i passem el valor de retorn com a var. temp.
							
	| PARABR_ expresion PARCER_
	        {$$.tipo=$2.tipo;
	        $$.pos=$2.pos;}
	
	| ID_ //CGI
	        {simbolo=obtenerSimbolo($1);
			if(simbolo.categoria==NULO) {
						yyerror("Variable no declarada"); 
						$$.tipo=T_ERROR;
			}else if(simbolo.tipo!=T_ENTERO){
				yyerror("Error de tipo. La variable debe ser un entero");
				$$.tipo=T_ERROR;
			}else 
				$$.tipo=T_ENTERO;
                                $$.pos = crArgPosicion(simbolo.nivel,simbolo.desp);
                  printf("Simb: %s\n",$1);}
				
	| ENTERO_ //Ok
	        {$$.tipo=T_ENTERO;
	        $$.pos = crArgPosicion(nivel, creaVarTemp());
	        emite( EASIG, crArgEntero($1), crArgNulo(), $$.pos );} //Asignem el valor del enter a la var. temp.
;



parametrosActuales :
            {$$.ref=insertaInfoDominio(-1,T_VACIO);
            $$.talla=0;} //La talla dels paràmetres de la funció

	| listaParametrosActuales
	        {$$.ref=$1.ref;
	        $$.talla=$1.talla;} //Passem amunt la talla dels paràmetres de la funció
;



listaParametrosActuales : expresion
            {if($1.tipo == T_ERROR)
                $$.tipo=T_ERROR; //Propaguem l'error amunt per poder informar millor després (no volem que tire un error genèric al comparar dominis)
            else if($1.tipo != T_ENTERO)
                yyerror("Los parámetros de las funciones han de ser de tipo entero");
            else
                $$.tipo=T_VACIO; //Per posar-li algo...
            $$.ref=insertaInfoDominio(-1,$1.tipo);
            $$.talla=TALLA_ENTERO;
            emite(EPUSH, crArgNulo(), crArgNulo(), $1.pos);
            printf("1\n");} //Apilem el paràmetre (el seu valor)

	| expresion COMA_ listaParametrosActuales
            {if($1.tipo == T_ERROR)
                $$.tipo=T_ERROR; //Propaguem l'error amunt per poder informar millor després (no volem que tire un error genèric al comparar dominis)
            else if($1.tipo != T_ENTERO)
                yyerror("Error de tipo. Los parámetros de las funciones han de ser enteros");
            else
                $$.tipo=T_VACIO; //Per posar-li algo...
            $$.ref = insertaInfoDominio($3.ref,$1.tipo);
            $$.talla = $3.talla+TALLA_ENTERO; //Sumem la seua talla
            emite(EPUSH, crArgNulo(), crArgNulo(), $1.pos);
            printf("2\n");} //Més paràmetres a la pila
;



operadorAsignacion : IGUAL_ {$$=EASIG;}

	| MASIGUAL_ {$$=ESUM;}
	 
	| MENOSIGUAL_ {$$=EDIF;}
;



operadorIgualdad : IGUALIGUAL_ {$$=EIGUAL;}

	| DISTINTO_ {$$=EDIST;}
;



operadorRelacional : MAYOR_ {$$=EMAY;}

	| MENOR_ {$$=EMEN;}
	
	| MAYORIGUAL_ {$$=EMAYEQ;}
	
	| MENORIGUAL_ {$$=EMENEQ;}
;



operadorAditivo : MAS_ {$$=ESUM;}

	| MENOS_ {$$=EDIF;}
;



operadorMultiplicativo : POR_ {$$=EMULT;}

	| DIV_ {$$=EDIVI;}
;



operadorIncremento : MASMAS_ {$$=ESUM;}

	| MENOSMENOS_ {$$=EDIF;}
;



operadorUnario : MAS_ {$$=ESUM;}

	| MENOS_ {$$=EDIF;} 
;

%%

/* Llamada por yyparse ante un error */
yyerror (char *s){
	numErrores++;
	printf ("Linea %d: %s\n", yylineno, s);
}


