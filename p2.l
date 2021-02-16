%{
#include <stdlib.h>
#include <string.h>
//#include "y.tab.h"
%}

%option noyywrap
%option yylineno

letra			([a-zA-ZáéíóúüÁÉÍÓÚÜñÑ])
digito			([0-9])
alfanumerico	[a-zA-ZáéíóúüÁÉÍÓÚÜñÑ_0-9]
identificador	{letra}+{alfanumerico}*
entero			{digito}+
decimal 		{entero}+.{entero}+
cadena			(\"[^\"]*\")
real			{entero}*[.]{entero}+
caracter		(\'[^\']\')
comillas		(\")
unicom			(\')
otros			.

%%

"PRINCIPAL"				{
							return CABECPROG;
						}
"{"						{
							yylval.valor = strdup(yytext);
							return INILLAVE;
						}
"}"						{
							yylval.valor = strdup(yytext);
							return FINLLAVE;
						}
"INIVAR"				{
							return MARCAINI;
						}
"FINVAR"				{
							return MARCAFIN;
						}
"ENTERO"				{
							yylval.tipo = entero;
							return TIPOVAR;
						}
"REAL"					{
							yylval.tipo = real;
							return TIPOVAR;
						}
"CARACTER"				{
							yylval.tipo = caracter;
							return TIPOVAR;
						}
"BOOLEANO"				{
							yylval.tipo = booleano;
							return TIPOVAR;
						}
";"						{
							yylval.valor = strdup(yytext);
							return FINLINEA;
						}
","						{
							yylval.valor = strdup(yytext);
							return COMA;
						}
"["						{
							yylval.valor = strdup(yytext);
							return INICOR;
						}
"]"						{
							yylval.valor = strdup(yytext);
							return FINCOR;
						}
"("						{
							yylval.valor = strdup(yytext);
							return INIPAR;
						}
")"						{
							yylval.valor = strdup(yytext);
							return FINPAR;
						} 
"SI"					{
							yylval.valor = strdup(yytext);
							return CONDIF;
						}
"SINO"					{
							yylval.valor = strdup(yytext);
							return CONDELSE;
						}
"MIENTRAS"				{
							yylval.valor = strdup(yytext);
							return CONDWHILE;
						}
"LEER"					{
							yylval.valor = strdup(yytext);
							return ENTRADA;
						}
"IMPRIMIR"				{
							yylval.valor = strdup(yytext);
							return SALIDA;
						}
"DEVOLVER"				{
							yylval.valor = strdup(yytext);
							return RETORNO;
						}
"SEGUN"					{
							yylval.valor = strdup(yytext);
							return CONDSWITCH;
						}
"CASO"					{
							yylval.valor = strdup(yytext);
							return CASOSWITCH;
						}
"PORDEFECTO"			{
							yylval.valor = strdup(yytext);
							return DEFECTOSWITCH;
						}
"FINCASO"				{
							yylval.valor = strdup(yytext);
							return FINSWITCH;
						}
":"						{
							yylval.valor = strdup(yytext);
							return SENTSWITCH;
						}
{cadena}				{
							yylval.tipo = caracter;
							yylval.valor = strdup(yytext);
							return CADENA;
						}
{caracter}				{
							yylval.tipo = caracter;
							yylval.valor = strdup(yytext);
							return CARACTER;
						}
"++"					{
							yylval.valor = strdup(yytext);
							return OPSIG;
						}
"--"					{
							yylval.valor = strdup(yytext);
							return OPSIG;
						}
"+"						{
							yylval.valor = strdup(yytext);
							return OPBINARITM;
						}
"**"					{
							yylval.valor = strdup(yytext);
							return OPBINARRAY;
						}
"*"						{
							yylval.valor = strdup(yytext);
							return OPBINARITM;
						}
"/"						{
							yylval.valor = strdup(yytext);
							return OPBINARITM;
						}
"<="					{
							yylval.valor = strdup(yytext);
							return OPBINCOMP;
						}
">="					{
							yylval.valor = strdup(yytext);
							return OPBINCOMP;
						}
"<"						{
							yylval.valor = strdup(yytext);
							return OPBINCOMP;
						}
">"						{
							yylval.valor = strdup(yytext);
							return OPBINCOMP;
						}
"=="					{
							yylval.valor = strdup(yytext);
							return OPBINCOMP;
						}
"!="					{
							yylval.valor = strdup(yytext);
							return OPBINCOMP;
						}
"!"						{
							yylval.valor = strdup(yytext);
							return OPUN;
						}
"="						{
							yylval.valor = strdup(yytext);
							return IGUAL;
						}
"&&"					{
							yylval.valor = strdup(yytext);
							return OPBINLOGIC;
						}
"||"					{
							yylval.valor = strdup(yytext);
							return OPBINLOGIC;
						}
"|"						{
							yylval.valor = strdup(yytext);
							return DELARRAY2D;
						}
"-"						{
							yylval.valor = strdup(yytext);
							return OPMENOS;
						}
{entero}				{
							yylval.tipo = entero;
							yylval.valor = strdup(yytext);
							return ENTERO;
						}
"."						{
							yylval.valor = strdup(yytext);
							return DECIMAL;
						}
{real}					{
							yylval.tipo = real;
							yylval.valor = strdup(yytext);
							return REAL;
						}
"VERDADERO"				{
							yylval.tipo = booleano;
							yylval.valor = strdup(yytext);
							return VALBOOLEANO;
						}
"FALSO"					{
							yylval.tipo = booleano;
							yylval.valor = strdup(yytext);
							return VALBOOLEANO;
						}
"ARRAY1D"				{
							yylval.tipo = array1d;
							return TIPOARRAY1D;
						}
"ARRAY2D"				{
							yylval.tipo = array2d;
							return TIPOARRAY2D;
						}
{identificador} 		{
							yylval.nombre = strdup(yytext);
							yylval.valor = strdup(yytext);
							return IDENTIFICADOR;
						}
[ \t]					{
							;
						}
"\n"					{
							numLinea++;
						}
{otros}					{
							printf("(Linea %d) Error lexico: Caracter no reconocido: %s\n", yylineno, yytext);
						}

%%
