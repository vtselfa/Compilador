/* A Bison parser, made by GNU Bison 2.5.  */

/* Bison interface for Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2011 Free Software Foundation, Inc.
   
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
     ID_ = 258,
     ENTERO_ = 259,
     INT_ = 260,
     PARABR_ = 261,
     PARCER_ = 262,
     LLAVABR_ = 263,
     LLAVCER_ = 264,
     CORABR_ = 265,
     CORCER_ = 266,
     RETURN_ = 267,
     IF_ = 268,
     ELSE_ = 269,
     FOR_ = 270,
     STRUCT_ = 271,
     READ_ = 272,
     PRINT_ = 273,
     PUNTO_ = 274,
     COMA_ = 275,
     PUNTOYCOMA_ = 276,
     IGUAL_ = 277,
     MASIGUAL_ = 278,
     MENOSIGUAL_ = 279,
     IGUALIGUAL_ = 280,
     DISTINTO_ = 281,
     MAYOR_ = 282,
     MENOR_ = 283,
     MAYORIGUAL_ = 284,
     MENORIGUAL_ = 285,
     MAS_ = 286,
     MENOS_ = 287,
     POR_ = 288,
     DIV_ = 289,
     MASMAS_ = 290,
     MENOSMENOS_ = 291
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 2068 of yacc.c  */
#line 19 "menosc.y"

   int cent;
   char* ident;
   TIPO tipo;
   TIPONOM tiponom;
   int aux;



/* Line 2068 of yacc.c  */
#line 96 "asin.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


