/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

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

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    CABECPROG = 258,
    INILLAVE = 259,
    FINLLAVE = 260,
    MARCAINI = 261,
    MARCAFIN = 262,
    TIPOVAR = 263,
    FINLINEA = 264,
    COMA = 265,
    IGUAL = 266,
    INICOR = 267,
    FINCOR = 268,
    INIPAR = 269,
    FINPAR = 270,
    IDENTIFICADOR = 271,
    CONDIF = 272,
    CONDELSE = 273,
    CONDWHILE = 274,
    ENTRADA = 275,
    SALIDA = 276,
    RETORNO = 277,
    CONDSWITCH = 278,
    CASOSWITCH = 279,
    DEFECTOSWITCH = 280,
    FINSWITCH = 281,
    SENTSWITCH = 282,
    CADENA = 283,
    CARACTER = 284,
    OPSIG = 285,
    OPUN = 286,
    OPBINARITM = 287,
    OPBINCOMP = 288,
    OPBINARRAY = 289,
    OPBINLOGIC = 290,
    OPMENOS = 291,
    ENTERO = 292,
    DECIMAL = 293,
    REAL = 294,
    VALBOOLEANO = 295,
    TIPOARRAY1D = 296,
    TIPOARRAY2D = 297,
    DELARRAY2D = 298
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
