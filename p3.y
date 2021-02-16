%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	/** Aqui incluimos el fichero generado por el ’lex’
	 *	que implementa la funcion ’yylex’
	 **/
	int yydebug = 1;	

	int yylex();  // Para evitar warning al compilar
	void yyerror(const char * msg); //Para que se pueda invocar desde el .l
	unsigned int contBloquesPrimeraFun = 0;
	unsigned int contBloques = 0;
	unsigned int numLinea = 1; //Conocer el numero de linea que se esta leyendo
	char* etiqCase;
	char* etiqFinal;
	#include "p4.h"
%}

%define parse.error verbose	/* Hace que bison (yacc) de mensajes de error dando el token que se esperaba en cada momento */


%token CABECPROG
%token INILLAVE
%token FINLLAVE		
%token MARCAINI		
%token MARCAFIN		
%token TIPOVAR			
%token FINLINEA		
%token COMA			
%token IGUAL			
%token INICOR			
%token FINCOR			
%token INIPAR	
%token FINPAR			
%token IDENTIFICADOR	
%token CONDIF			
%token CONDELSE	
%token CONDWHILE		
%token ENTRADA			
%token SALIDA		
%token RETORNO			
%token CONDSWITCH		
%token CASOSWITCH		
%token DEFECTOSWITCH	
%token FINSWITCH		
%token SENTSWITCH		
%token CADENA		
%token CARACTER					
%token OPSIG			
%token OPUN			
%token OPBINARITM
%token OPBINCOMP
%token OPBINARRAY
%token OPBINLOGIC			
%token OPMENOS			
%token ENTERO			
%token DECIMAL			
%token REAL			
%token VALBOOLEANO		
%token TIPOARRAY1D		
%token TIPOARRAY2D	
%token DELARRAY2D	

%left COMA
%left OPBINLOGIC
%left OPBINCOMP
%left OPBINARITM
%left OPMENOS
%left OPBINARRAY
%right OPUN
%left OPSIG
%left INIPAR
%left FINPAR
%left INICOR
%left FINCOR
%left INILLAVE
%left FINLLAVE
%left DEFECTOSWITCH



%start programa		/* Simbolo inicial de la gramatica */

%%

programa						: {generarFichero();} CABECPROG {fputs("int main()", file);} bloque {cerrarFichero();};

bloque							: INILLAVE {insertarMarca();
											if($0.parametros > 0) insertarPreEntrada($0.nombre, $0.parametros); 
											char* sent = (char*) malloc(200);
											contBloques++;
											char * aux= (char*) malloc(50);
											strncpy(aux,numTabs(),50);
											eliminaPrimerValor(aux);
											sprintf(sent, "%s{\n", aux);
											fputs(sent, file);
											}
					 			  declarar_variables_locales
					 			  declarar_subprogs
							 	  sentencias
							 	  FINLLAVE{
							 	  	contBloques--;
							 	  	eliminarBloque();
							 	  	char* sent = (char*) malloc(200);
									sprintf(sent, "%s}\n", numTabs());
									fputs(sent, file);
									if (contBloquesPrimeraFun == contBloques){
										file = file_std;
										contBloquesPrimeraFun = 0;
									}
							 	  };

declarar_subprogs				: declarar_subprogs declarar_subprog
								| /* vacío */ ;

declarar_subprog				: cabecera_subprograma bloque;

declarar_variables_locales		: MARCAINI
								  variables_locales
								  MARCAFIN
								| /* vacio */;

variables_locales 				: variables_locales cuerpo_declarar_variables
								| /* vacio */;

cuerpo_declarar_variables		: tipo lista_identificadores FINLINEA {		
																			char* sent = (char*) malloc(200);
																			if(tipoDeDato($1.tipo)!="array1d" && tipoDeDato($1.tipo)!="array2d"){
																				sprintf(sent, "%s%s %s;\n", numTabs(), tipoDeDato($1.tipo), $2.valor);
																				fputs(sent, file);
																			}else{
																				sprintf(sent, "%s%s %s;\n", numTabs(), tipoDeDato($1.tipoArray), $2.valor);
																				fputs(sent, file);
																			}
																		}
								| error;

lista_identificadores			: lista_identificadores COMA IDENTIFICADOR IGUAL expresion{
																				$3.tipo = $0.tipo;
																				$3.tipoArray = $0.tipoArray;
																				$3.numcolumnas = $0.numcolumnas;
																				$3.numfilas = $0.numfilas;
																				$3.entrada = variable;
																				if(!existeVariableEnBloque($3)) insertar($3);
																				else mensajeErrorDeclaradaBloque($3);
																				entradaTabla aux = getUltimaEntrada($3.nombre);
																				if($5.tipo != aux.tipo)
																					mensajeErrorAsignacion($5, aux);
																				else if($5.tipoArray != aux.tipoArray)
																					mensajeErrorTipoArray(aux, $5.tipoArray);
																				else if($5.tipo==array1d || $5.tipo == array2d){
																					if($5.numcolumnas!=$3.numcolumnas || $5.numfilas != $3.numfilas)
																						mensajeErrorAsignarTamano($3,$5);
																				}
																				if( $0.tipo != array1d && $0.tipo != array2d ){
																					concatenarStrings5($$.valor, $1.valor, $2.valor, $3.valor, $4.valor, $5.valor);
																				}else if($0.tipo==array1d){
																					char colstr[10];
																					sprintf(colstr, "%d", $3.numcolumnas);
																					concatenarStrings8($$.valor, $1.valor, $2.valor, $3.valor, "[", colstr, "]", $4.valor, $5.valor);
																				}else if($0.tipo==array2d){
																					char colstr[10];
																					char filstr[10];
																					sprintf(colstr, "%d", $3.numcolumnas);
																					sprintf(filstr, "%d", $3.numfilas);
																					concatenarStrings10($$.valor, $1.valor, $2.valor, $3.valor, "[", filstr, "][", colstr, "]", $4.valor, $5.valor);
																				}else{
																					concatenarStrings5($$.valor, $1.valor, $2.valor, $3.valor, $4.valor, $5.valor);
																				}

																			}
								| lista_identificadores COMA IDENTIFICADOR{
																				$3.tipo = $0.tipo;
																				$3.tipoArray = $0.tipoArray;
																				$3.numcolumnas = $0.numcolumnas;
																				$3.numfilas = $0.numfilas;
																				$3.entrada = variable;
																				if(!existeVariableEnBloque($3)) insertar($3);
																				else mensajeErrorDeclaradaBloque($3);
																				if( $0.tipo != array1d && $0.tipo != array2d ){
																					concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);
																				}else if($0.tipo==array1d){
																					char colstr[10];
																					sprintf(colstr, "%d", $3.numcolumnas);
																					concatenarStrings6($$.valor, $1.valor, $2.valor, $3.valor, "[", colstr, "]");
																				}else if($0.tipo==array2d){
																					char colstr[10];
																					char filstr[10];
																					sprintf(colstr, "%d", $3.numcolumnas);
																					sprintf(filstr, "%d", $3.numfilas);
																					concatenarStrings8($$.valor, $1.valor, $2.valor, $3.valor, "[", filstr, "][", colstr, "]");
																				}else{
																					concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);
																				}
																			}
								| IDENTIFICADOR IGUAL expresion{				$1.tipo = $0.tipo;
																				$1.tipoArray = $0.tipoArray;
																				$1.numcolumnas = $0.numcolumnas;
																				$1.numfilas = $0.numfilas;
																				$1.entrada = variable;

																				if(!existeVariableEnBloque($1)) insertar($1);
																				else mensajeErrorDeclaradaBloque($1);
																				entradaTabla aux = getUltimaEntrada($1.nombre);
																				if($3.tipo != aux.tipo){
																					mensajeErrorAsignacion($3, aux);
																				}
																				else if($3.tipoArray != aux.tipoArray)
																					mensajeErrorTipoArray(aux, $3.tipoArray);
																				else if($3.tipo==array1d || $3.tipo == array2d){
																					if($3.numcolumnas!=$1.numcolumnas || $3.numfilas != $1.numfilas)
																						mensajeErrorAsignarTamano($1,$3);
																				}
																				if( $0.tipo != array1d && $0.tipo != array2d ){
																					concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);
																				}else if($0.tipo==array1d){
																					char colstr[10];
																					sprintf(colstr, "%d", $3.numcolumnas);
																					concatenarStrings6($$.valor, $1.valor, "[", colstr, "]", $2.valor, $3.valor);
																				}else if($0.tipo==array2d){
																					char colstr[10];
																					char filstr[10];
																					sprintf(colstr, "%d", $3.numcolumnas);
																					sprintf(filstr, "%d", $3.numfilas);
																					concatenarStrings8($$.valor,$1.valor, "[", filstr, "][", colstr, "]",  $2.valor, $3.valor);
																				}else{
																					concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);
																				}
																			}
								| IDENTIFICADOR{									
																				$1.tipo = $0.tipo;
																				$1.tipoArray = $0.tipoArray;
																				$1.numcolumnas = $0.numcolumnas;
																				$1.numfilas = $0.numfilas;
																				$1.entrada = variable;
																				if(!existeVariableEnBloque($1)) insertar($1);
																				else mensajeErrorDeclaradaBloque($1);
																				if( $0.tipo != array1d && $0.tipo != array2d ){
																					concatenarStrings1($$.valor, $1.valor);
																				}else if($0.tipo==array1d){
																					char colstr[10];
																					sprintf(colstr, "%d", $1.numcolumnas);
																					concatenarStrings4($$.valor, $1.valor, "[", colstr, "]");
																				}else if($0.tipo==array2d){
																					char colstr[10];
																					char filstr[10];
																					sprintf(colstr, "%d", $1.numcolumnas);
																					sprintf(filstr, "%d", $1.numfilas);
																					concatenarStrings6($$.valor, $1.valor, "[", filstr, "][", colstr, "]");
																				}else{
																					concatenarStrings1($$.valor, $1.valor);
																				}
																			};

cabecera_subprograma			: tipo IDENTIFICADOR INIPAR lista_parametros FINPAR{
																						$2.tipo = $1.tipo; 
																						$2.tipoArray = $1.tipoArray;
																						$2.numcolumnas = $1.numcolumnas;
																						$2.numfilas = $1.numfilas;
																						$$.nombre = $2.nombre; 
																						$$.parametros = $4.parametros;	
																						$2.parametros = $4.parametros;
																						$2.entrada = funcion;
																						if(!existeVariableEnBloque($2)) insertar($2);
																						else mensajeErrorDeclaradaBloque($2);
																						if(contBloquesPrimeraFun == 0)
																							contBloquesPrimeraFun = contBloques;
																						char* sent = (char*) malloc(200);
																						sprintf(sent, "%s%s %s(%s)", numTabs(), tipoDeDato($1.tipo), $2.nombre, $4.valor);
																						fputs(sent, file_fun);
																						file = file_fun;
																					}
								| tipo IDENTIFICADOR INIPAR FINPAR{						$2.tipo = $1.tipo; 
																						$2.tipoArray = $1.tipoArray;
																						$2.numcolumnas = $1.numcolumnas;
																						$2.numfilas = $1.numfilas;
																						$$.nombre = $2.nombre; 
																						$$.parametros = 0;
																						$2.entrada = funcion;
																						if(!existeVariableEnBloque($2)) insertar($2);
																						else mensajeErrorDeclaradaBloque($2);
																						if(contBloquesPrimeraFun == 0)
																							contBloquesPrimeraFun = contBloques;
																						char* sent = (char*) malloc(200);
																						sprintf(sent, "%s%s %s()", numTabs(), tipoDeDato($1.tipo), $2.nombre);
																						fputs(sent, file_fun);
																						file = file_fun;};

sentencias						: sentencias sentencia
								| sentencia;

sentencia 						: bloque
								| sentencia_asignacion
								| sentencia_if
								| sentencia_while
								| sentencia_entrada
								| sentencia_salida
								| sentencia_return
								| sentencia_switch
								| error;

sentencia_asignacion			: IDENTIFICADOR IGUAL expresion FINLINEA {	bool error = FALSE;

																				if( existeVariable($1) ){
																					entradaTabla aux = getUltimaEntrada($1.nombre);
																					if( aux.entrada != variable ){
																						mensajeErrorNoVariable(aux);
																						error=TRUE;
																					}
																					else {
																						entradaTabla aux = getUltimaEntrada($1.nombre);
																						if( aux.tipo != $3.tipo ){
																							mensajeErrorAsignacion(aux, $3);
																							error=TRUE;
																						}else if( aux.tipoArray != $3.tipoArray ){
																							mensajeErrorTiposInternosNoCoinciden(aux, $3);
																							error=TRUE;
																						}else if(aux.numcolumnas != $3.numcolumnas || aux.numfilas != $3.numfilas){
																							mensajeErrorAsignarTamano(aux,$3);
																							error=TRUE;
																						}
																						
																					}
																				} else {
																					mensajeErrorNoDeclarada($1);
																					error=TRUE;
																				}

																				if(error){ 
																					$$.tipo = desconocido;
																					$$.tipoArray = desconocido;
																					$$.numcolumnas=0;
																					$$.numfilas=0;
																				}
																				entradaTabla aux = getUltimaEntrada($1.nombre);
																				if(aux.tipo==array1d){

																					insertarAsignacionArrays($1.nombre, $3.valor, aux.tipoArray, aux.numcolumnas);
																				}else if(aux.tipo==array2d){
																					insertarAsignacionArrays2d($1.nombre, $3.valor, aux.tipoArray, aux.numfilas, aux.numcolumnas);
																				}
																				else
																					insertarAsignacion($1.nombre, $3.valor);}
								| IDENTIFICADOR INICOR expresion COMA expresion FINCOR IGUAL expresion FINLINEA{
																				entradaTabla aux = getUltimaEntrada($1.nombre);
																				if(aux.tipo!=array2d){
																					mensajeErrorTipo(aux, array2d);
																					$$.tipo = desconocido;
																					$$.tipoArray = desconocido;
																					$$.numcolumnas=0;
																					$$.numfilas=0;
																				}else if($3.tipo!=entero){
																					mensajeErrorTipo($3, entero);
																					$$.tipo = desconocido;
																					$$.tipoArray = desconocido;
																					$$.numcolumnas=0;
																					$$.numfilas=0;
																				}else if($5.tipo!=entero){
																					mensajeErrorTipo($5, entero);
																					$$.tipo = desconocido;
																					$$.tipoArray = desconocido;
																					$$.numcolumnas=0;
																					$$.numfilas=0;
																				}else if(!(atoi($3.valor)>=0 && atoi($3.valor)<aux.numfilas)){
																					mensajeErrorAccesoArray(aux);
																					$$.tipo = desconocido;
																					$$.tipoArray = desconocido;
																					$$.numcolumnas=0;
																					$$.numfilas=0;
																				}else if(!(atoi($5.valor)>=0 && atoi($5.valor)<aux.numcolumnas)){
																					mensajeErrorAccesoArray(aux);
																					$$.tipo = desconocido;
																					$$.tipoArray = desconocido;
																					$$.numcolumnas=0;
																					$$.numfilas=0;
																				}else if($8.tipo!=aux.tipoArray){
																					mensajeErrorTipo($8, aux.tipoArray);
																					$$.tipo = desconocido;
																					$$.tipoArray = desconocido;
																					$$.numcolumnas=0;
																					$$.numfilas=0;
																				}else{
																					$$.tipo=aux.tipoArray;
																					$$.tipoArray=desconocido;
																					$$.numcolumnas=0;
																					$$.numfilas=0;
																				}
																				concatenarStrings6($$.valor, $1.valor, $2.valor, $3.valor, "][", $5.valor, $6.valor);
																				insertarAsignacion($1.nombre, $3.valor);
																				}
								| IDENTIFICADOR INICOR expresion FINCOR IGUAL expresion FINLINEA{
																		entradaTabla aux = getUltimaEntrada($1.nombre);
																		if(aux.tipo!=array1d){
																			mensajeErrorTipo(aux, array1d);
																			$$.tipo = desconocido;
																			$$.tipoArray = desconocido;
																			$$.numcolumnas=0;
																			$$.numfilas=0;
																		}else if($3.tipo!=entero){
																			mensajeErrorTipo($3, entero);
																			$$.tipo = desconocido;
																			$$.tipoArray = desconocido;
																			$$.numcolumnas=0;
																			$$.numfilas=0;
																		}else if(!(atoi($3.valor)>=0 && atoi($3.valor)<aux.numcolumnas)){
																			mensajeErrorAccesoArray(aux);
																			$$.tipo = desconocido;
																			$$.tipoArray = desconocido;
																			$$.numcolumnas=0;
																			$$.numfilas=0;
																		}else if($6.tipo!=aux.tipoArray){
																				mensajeErrorTipo($6, aux.tipoArray);
																				$$.tipo = desconocido;
																				$$.tipoArray = desconocido;
																				$$.numcolumnas=0;
																				$$.numfilas=0;
																		}else{
																			$$.tipo=aux.tipoArray;
																			$$.tipoArray=desconocido;
																			$$.numcolumnas=0;
																			$$.numfilas=0;
																		}
																		concatenarStrings4($$.valor, $1.valor, $2.valor, $3.valor, $4.valor);

																	};

aux		: {	etiquetaFlujo *aux = malloc(sizeof(etiquetaFlujo));
			aux->EtiquetaElse = generarEtiqueta();
			aux->EtiquetaSalida = generarEtiqueta();
			insertarFlujo(*aux);
			copiarEF(&($$.ef), aux);
			char* sent = (char*) malloc(200);
			sprintf(sent, "%sif(!(%s)) goto %s;\n", numTabs(), $-1.valor, aux->EtiquetaElse);
			fputs(sent, file);
		} ;

sentencia_if					: CONDIF INIPAR expresion FINPAR aux sentencia{
																					char* sent = (char*) malloc(200);
																					sprintf(sent, "%sgoto %s;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaSalida);
																					fputs(sent, file);
																				}
								  CONDELSE{	char* sent = (char*) malloc(200);
														sprintf(sent, "%s%s: ;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaElse);
														fputs(sent, file);
													}
								 sentencia {	if( $3.tipo != booleano ) mensajeErrorTipo($3, booleano);	
								 				char* sent = (char*) malloc(200);
												sprintf(sent, "%s%s: ;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaSalida);
												fputs(sent, file);
												sacarTF();}
								| CONDIF INIPAR expresion FINPAR aux sentencia{	if( $3.tipo != booleano ) mensajeErrorTipo($3, 																					booleano);	
																				char* sent = (char*) malloc(200);
																				sprintf(sent, "%sgoto %s;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaSalida);
																				fputs(sent, file);
																				sprintf(sent, "%s%s: ;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaElse);
																				fputs(sent, file);
																				sprintf(sent, "%s%s: ;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaSalida);
																				fputs(sent, file);
																				sacarTF();};

sentencia_while					: CONDWHILE INIPAR{	etiquetaFlujo *aux = malloc(sizeof(etiquetaFlujo));
													aux->EtiquetaEntrada = generarEtiqueta();
													aux->EtiquetaSalida = generarEtiqueta();
													insertarFlujo(*aux);
													char* sent = (char*) malloc(200);
													sprintf(sent, "%s%s: ;\n", numTabs(), aux->EtiquetaEntrada);
													fputs(sent, file);
												}
								 expresion{		char* sent = (char*) malloc(200);
												sprintf(sent, "%sif (!(%s)) goto %s;\n", numTabs(), $4.valor ,TF[TOPEFLUJO-1].EtiquetaSalida);
												fputs(sent, file);
												}
								 FINPAR sentencia{	if( $4.tipo != booleano ) mensajeErrorTipo($4, booleano);	
								 					char* sent = (char*) malloc(200);
													sprintf(sent, "%sgoto %s;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaEntrada);
													fputs(sent, file);
													sprintf(sent, "%s%s: ;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaSalida);
													fputs(sent, file);
													sacarTF();};

sentencia_entrada				: ENTRADA lista_variables FINLINEA{	char* sent = (char*) malloc(200);
																		sprintf(sent, "\", %s);\n", $2.valor);
																		fputs(sent, file);
																	} ;

sentencia_salida				: SALIDA lista_expresiones_o_cadena FINLINEA{	char* sent = (char*) malloc(1000);
																				sprintf(sent, "\", %s);\n", $2.valor);
																				fputs(sent, file);
																	} ;

sentencia_return				: RETORNO expresion FINLINEA{	char* sent = (char*) malloc(200);
																sprintf(sent, "%sreturn %s;\n", numTabs(), $2.valor);
																fputs(sent, file);
															} ;

aux_switch	: {	etiquetaFlujo *aux = malloc(sizeof(etiquetaFlujo));
			aux->EtiquetaCase = generarEtiqueta();
			aux->EtiquetaFinal = generarEtiqueta();
			etiqCase=aux->EtiquetaCase;
			etiqFinal=aux->EtiquetaFinal;
			insertarFlujo(*aux);
			copiarEF(&($$.ef), aux);
			char* sent = (char*) malloc(200);
			sprintf(sent, "%sif(%s!=%s) goto %s;\n", numTabs(), $-2.valor, $0.valor, aux->EtiquetaCase);
			fputs(sent, file);
		} ;

sentencia_switch				: CONDSWITCH IDENTIFICADOR CASOSWITCH
								  constante aux_switch SENTSWITCH sentencia FINSWITCH FINLINEA{
								 	char* sent = (char*) malloc(200);
									sprintf(sent, "%sgoto %s;\n", numTabs(), etiqFinal);
									fputs(sent, file);
									char* sent2 = (char*) malloc(200);
									sprintf(sent2, "%s%s: ;\n", numTabs(), etiqCase);
									fputs(sent2, file);
								 }
								  mas_casos
								  DEFECTOSWITCH SENTSWITCH sentencia FINSWITCH FINLINEA{
								  	if(!existeVariable($2)) mensajeErrorNoDeclarada($2);
								  	else{
								  		entradaTabla aux = getUltimaEntrada($2.nombre);
									  	if($4.tipo != aux.tipo)
									  		mensajeErrorTipo($4, aux.tipo);								  		
									  	else if($4.tipoArray != aux.tipoArray)
									  		mensajeErrorTipoArray($4, aux.tipoArray);
									  	else if($4.numcolumnas != aux.numcolumnas || $4.numfilas != aux.numfilas)
									  		mensajeErrorOperarTamano($4,aux);
								  	}
								  	char* sent = (char*) malloc(200);
									sprintf(sent, "%s%s: ;\n", numTabs(), etiqFinal);
									fputs(sent, file);

								  };

aux_mas_casos	: {	etiquetaFlujo *aux = malloc(sizeof(etiquetaFlujo));
				aux->EtiquetaCase = generarEtiqueta();
				etiqCase=aux->EtiquetaCase;
				insertarFlujo(*aux);
				copiarEF(&($$.ef), aux);
				char* sent = (char*) malloc(200);
				sprintf(sent, "%sif(%s!=%s) goto %s;\n", numTabs(), $-11.valor, $0.valor, aux->EtiquetaCase);
				fputs(sent, file);
			} ;

mas_casos						: mas_casos CASOSWITCH constante aux_mas_casos SENTSWITCH sentencia
								  FINSWITCH FINLINEA{
							  		entradaTabla aux = getUltimaEntrada($-7.nombre);
								  	if($3.tipo != aux.tipo)
								  		mensajeErrorTipo($3, aux.tipo);								  		
								  	else if($3.tipoArray != aux.tipoArray)
								  		mensajeErrorTipoArray($3, aux.tipoArray);
								  	else if($3.numcolumnas != aux.numcolumnas || $5.numfilas != aux.numfilas)
								  		mensajeErrorOperarTamano($3,aux);
							  		char* sent = (char*) malloc(200);
									sprintf(sent, "%sgoto %s;\n", numTabs(), etiqFinal);
									fputs(sent, file);
									char* sent2 = (char*) malloc(200);
									sprintf(sent2, "%s%s: ;\n", numTabs(), etiqCase);
									fputs(sent2, file);
								  }
								| /* vacio */;

lista_parametros				: lista_parametros COMA tipo IDENTIFICADOR {	$$.parametros++; 
																				$4.tipo = $3.tipo;
																				$4.tipoArray = $3.tipoArray;
																				$4.numcolumnas = $3.numcolumnas;
																				$4.numfilas = $3.numfilas;
																				$4.entrada = parametro;
																				if( !existeParametro($4) ) insertar($4);
																				else mensajeErrorParametro($4);
																				concatenarStrings5($$.valor, $1.valor, $2.valor, tipoDeDato($3.tipo), " ", $4.nombre);}
								| tipo IDENTIFICADOR {	$$.parametros = 1; 
														$2.tipo = $1.tipo; 
														$2.tipoArray = $1.tipoArray;
														$2.numcolumnas = $1.numcolumnas;
														$2.numfilas = $1.numfilas;
														$2.entrada = parametro;
														if( !existeParametro($2) ) insertar($2);
														else mensajeErrorParametro($2);
														concatenarStrings3($$.valor, tipoDeDato($1.tipo), " ", $2.nombre);} ;

lista_variables					: lista_variables COMA IDENTIFICADOR {
																		if( !existeVariable($3) ) mensajeErrorNoDeclarada($3);
																		entradaTabla aux = getUltimaEntrada($3.nombre);
																		if(strcmp($0.valor, "LEER") == 0){
																			char* sent = (char*) malloc(200);
																			sprintf(sent, "%%%c",tipoAFormato(aux.tipo));
																			fputs(sent, file);
																		}
																		concatenarStrings4($$.valor, $1.valor, $2.valor, tipoAPuntero(aux.tipo), $3.nombre);
																	}
								| IDENTIFICADOR{
															if( !existeVariable($1) ) mensajeErrorNoDeclarada($1);
															entradaTabla aux = getUltimaEntrada($1.nombre);
															if(strcmp($0.valor, "LEER") == 0){
																char* sent = (char*) malloc(200);
																sprintf(sent, "%sscanf(\"%%%c", numTabs(), tipoAFormato(aux.tipo));
																fputs(sent, file);
															}
															concatenarStrings2($$.valor, tipoAPuntero(aux.tipo), $1.nombre);
														};

lista_expresiones_o_cadena		: lista_expresiones_o_cadena COMA exp_cad{	$$.parametros++;
																	if (strcmp($0.valor, "(") == 0 ){		// Funcion
																		entradaTabla aux = getUltimaEntrada($-1.nombre);
																		if( !comprobarParametro(aux.nombre, $$.parametros, $3.tipo) )
																			mensajeErrorTipoArgumento(aux.nombre, $$.parametros,
																				getSimboloParametro(aux.nombre, $$.parametros).tipo);
																		concatenarStrings4($$.valor, $1.valor, $2.valor, " ", $3.valor);
																	}
																	else if(strcmp($0.valor, "IMPRIMIR") == 0){
																		char* sent = (char*) malloc(200);
																		if($3.tipo == array1d || $3.tipo == array2d)
																			sprintf(sent, "%%%c", tipoAFormato($3.tipoArray));
																		else
																			sprintf(sent, "%%%c", tipoAFormato($3.tipo));
																		fputs(sent, file);
																		concatenarStrings4($$.valor, $1.valor, $2.valor, " ", $3.valor);
																	}
																}
								| exp_cad{	$$.parametros = 1;
											if (strcmp($0.valor, "(") == 0 ){		// Funcion

												entradaTabla aux = getUltimaEntrada($-1.nombre);
												if( !comprobarParametro(aux.nombre, $$.parametros, $1.tipo) )
													mensajeErrorTipoArgumento(aux.nombre, $$.parametros,
														getSimboloParametro(aux.nombre, $$.parametros).tipo);
												concatenarStrings1($$.valor, $1.valor);
											}else if(strcmp($0.valor, "IMPRIMIR") == 0){

												char* sent = (char*) malloc(200);
												if($1.tipo == array1d || $1.tipo == array2d)
													sprintf(sent, "%sprintf(\"%%%c", numTabs(), tipoAFormato($1.tipoArray));
												else
													sprintf(sent, "%sprintf(\"%%%c", numTabs(), tipoAFormato($1.tipo));
												fputs(sent, file);
												concatenarStrings1($$.valor, $1.valor);
											}
										} ;
exp_cad							: expresion	{	$$.tipo = $1.tipo;
												$$.tipoArray = $1.tipoArray;
												concatenarStrings1($$.valor, $1.valor); }
								| CADENA {	$$.tipo = cadena;
											concatenarStrings1($$.valor, $1.valor); } ;

expresion 						: INIPAR expresion FINPAR {	$$.tipo = $2.tipo;
															$$.tipoArray = $2.tipoArray;
															$$.numcolumnas = $2.numcolumnas;
															$$.numfilas = $2.numfilas;
															concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);}
								| OPUN expresion {			if( $2.tipo != booleano){
																mensajeErrorTipo($2, booleano);
																$$.tipo = desconocido;
															}
															else $$.tipo = $2.tipo;
															$$.tipoArray = $2.tipoArray;
															$$.numcolumnas = $2.numcolumnas;
															$$.numfilas = $2.numfilas;
															concatenarStrings2($$.valor, $1.valor, $2.valor); 
												}
								| OPMENOS expresion {		if( $2.tipo != entero && $2.tipo != real){
																mensajeErrorTipo($2, real);
																$$.tipo = desconocido;
															}
															else $$.tipo = $2.tipo;
															$$.tipoArray = $2.tipoArray;
															$$.numcolumnas = $2.numcolumnas;
															$$.numfilas = $2.numfilas;
															concatenarStrings2($$.valor, $1.valor, $2.valor); 
												}
								| expresion OPSIG{
													if($1.tipo != entero){
														mensajeErrorTipo($1, entero);
														$$.tipo = desconocido;
													}
													else $$.tipo = $1.tipo;
													$$.tipoArray = $1.tipoArray;
													$$.numcolumnas = $1.numcolumnas;
													$$.numfilas = $1.numfilas;
													concatenarStrings2($$.valor, $1.valor, $2.valor);
												}
								| expresion OPBINARITM expresion{	char* sent = (char*) malloc(200);
																	char* aux = (char*) malloc(20);
																	if($1.tipo != $3.tipo){
																		mensajeErrorOperarTipos($1, $3);
																		$$.tipo = desconocido;
																		$$.tipoArray = desconocido;
																	}else if($1.tipo != real && $1.tipo != entero &&
																	$1.tipo != array1d && $1.tipo != array2d){
																		mensajeErrorOperarTipos($1, $3);
																		$$.tipo = desconocido;
																		$$.tipoArray = desconocido;
																	}else if($1.tipo == array1d || $1.tipo == array2d){
																		if($1.tipoArray != $3.tipoArray){
																			mensajeErrorOperarTipos($1, $3);
																			$$.tipoArray = desconocido;
																		}else if($1.tipoArray != entero && $1.tipoArray != real){
																			mensajeErrorOperarTipos($1, $3);
																			$$.tipoArray = desconocido;
																		}else if($1.numcolumnas!=$3.numcolumnas || $1.numfilas!=$3.numfilas){
																			mensajeErrorOperarTamano($1,$3);
																			$$.tipoArray = desconocido;
																			$$.numcolumnas=0;
																			$$.numfilas=0;
																		}else{ 
																			$$.tipo = $1.tipo;
																			$$.tipoArray = $1.tipoArray;
																			$$.numcolumnas=$1.numcolumnas;
																			$$.numfilas=$1.numfilas;
																			char colstr[10];
																			sprintf(colstr, "%d", $3.numcolumnas);
																			char filstr[10];
																			sprintf(filstr, "%d", $3.numfilas);
																			if($1.tipo==array1d){
																				if($1.tipoArray==entero){
																					if (strcmp($2.valor, "+") == 0)
																						sprintf(sent, "%s%s = sumInt1d(%s, %s, %s);\n", numTabs(), generarTempArray(array1d, entero), $1.valor, $3.valor, colstr);
																					else if (strcmp($2.valor, "-") == 0)
																						sprintf(sent, "%s%s = resInt1d(%s, %s, %s);\n", numTabs(), generarTempArray(array1d, entero), $1.valor, $3.valor, colstr);
																					else if (strcmp($2.valor, "*") == 0)
																						sprintf(sent, "%s%s = mulInt1d(%s, %s, %s);\n", numTabs(), generarTempArray(array1d, entero), $1.valor, $3.valor, colstr);
																					else if (strcmp($2.valor, "/") == 0)
																						sprintf(sent, "%s%s = divInt1d(%s, %s, %s);\n", numTabs(), generarTempArray(array1d, entero), $1.valor, $3.valor, colstr);
																				
																				fputs(sent, file);
																				sprintf(aux, "temp%d", temp);
																				concatenarStrings1($$.valor, aux);
																				}else{
																					if (strcmp($2.valor, "+") == 0)
																						sprintf(sent, "%s%s = sumFloat1d(%s, %s, %s);\n", numTabs(), generarTempArray(array1d, real), $1.valor, $3.valor, colstr);
																					else if (strcmp($2.valor, "-") == 0)
																						sprintf(sent, "%s%s = resFloat1d(%s, %s, %s);\n", numTabs(), generarTempArray(array1d, real), $1.valor, $3.valor, colstr);
																					else if (strcmp($2.valor, "*") == 0)
																						sprintf(sent, "%s%s = mulFloat1d(%s, %s, %s);\n", numTabs(), generarTempArray(array1d, real), $1.valor, $3.valor, colstr);
																					else if (strcmp($2.valor, "/") == 0)
																						sprintf(sent, "%s%s = divFloat1d(%s, %s, %s);\n", numTabs(), generarTempArray(array1d, real), $1.valor, $3.valor, colstr);
																				fputs(sent, file);
																				sprintf(aux, "temp%d", temp);
																				concatenarStrings1($$.valor, aux);
																				}
																			}else{
																				
																				if($1.tipoArray==entero){
																					if (strcmp($2.valor, "+") == 0){
																						char* sent2 = (char*) malloc(200);
																						sprintf(sent2, "%s%s [%s][%s];\n", numTabs(), generarTemp2d(entero), filstr, colstr);
																						fputs(sent2, file);
																						sprintf(sent, "%ssumInt2d(%s, %s, %s, %s, %s);\n", numTabs(), $1.valor, $3.valor, getTemp(), filstr, colstr);
																					}
																					else if (strcmp($2.valor, "-") == 0){
																						char* sent2 = (char*) malloc(200);
																						sprintf(sent2, "%s%s [%s][%s];\n", numTabs(), generarTemp2d(entero), filstr, colstr);
																						fputs(sent2, file);
																						sprintf(sent, "%sresInt2d(%s, %s, %s, %s, %s);\n", numTabs(), $1.valor, $3.valor, getTemp(), filstr, colstr);
																					}
																					else if (strcmp($2.valor, "*") == 0){
																						char* sent2 = (char*) malloc(200);
																						sprintf(sent2, "%s%s [%s][%s];\n", numTabs(), generarTemp2d(entero), filstr, colstr);
																						fputs(sent2, file);
																						sprintf(sent, "%smulInt2d(%s, %s, %s, %s, %s);\n", numTabs(), $1.valor, $3.valor, getTemp(), filstr, colstr);
																					}
																					else if (strcmp($2.valor, "/") == 0){
																						char* sent2 = (char*) malloc(200);
																						sprintf(sent2, "%s%s [%s][%s];\n", numTabs(), generarTemp2d(entero), filstr, colstr);
																						fputs(sent2, file);
																						sprintf(sent, "%sdivInt2d(%s, %s, %s, %s, %s);\n", numTabs(), $1.valor, $3.valor, getTemp(), filstr, colstr);
																					}
																				
																				fputs(sent, file);
																				sprintf(aux, "temp%d", temp);
																				concatenarStrings1($$.valor, aux);
																				}else{
																					if (strcmp($2.valor, "+") == 0){
																						char* sent2 = (char*) malloc(200);
																						sprintf(sent2, "%s%s [%s][%s];\n", numTabs(), generarTemp2d(entero), filstr, colstr);
																						fputs(sent2, file);
																						sprintf(sent, "%ssumFloat2d(%s, %s, %s, %s, %s);\n", numTabs(), $1.valor, $3.valor, getTemp(), filstr, colstr);
																					}
																					else if (strcmp($2.valor, "-") == 0){
																						char* sent2 = (char*) malloc(200);
																						sprintf(sent2, "%s%s [%s][%s];\n", numTabs(), generarTemp2d(entero), filstr, colstr);
																						fputs(sent2, file);
																						sprintf(sent, "%sresFloat2d(%s, %s, %s, %s, %s);\n", numTabs(), $1.valor, $3.valor, getTemp(), filstr, colstr);
																					}
																					else if (strcmp($2.valor, "*") == 0){
																						char* sent2 = (char*) malloc(200);
																						sprintf(sent2, "%s%s [%s][%s];\n", numTabs(), generarTemp2d(entero), filstr, colstr);
																						fputs(sent2, file);
																						sprintf(sent, "%smulFloat2d(%s, %s, %s, %s, %s);\n", numTabs(), $1.valor, $3.valor, getTemp(), filstr, colstr);
																					}
																					else if (strcmp($2.valor, "/") == 0){
																						char* sent2 = (char*) malloc(200);
																						sprintf(sent2, "%s%s [%s][%s];\n", numTabs(), generarTemp2d(entero), filstr, colstr);
																						fputs(sent2, file);
																						sprintf(sent, "%sdivFloat2d(%s, %s, %s, %s, %s);\n", numTabs(), $1.valor, $3.valor, getTemp(), filstr, colstr);
																					}
																				fputs(sent, file);
																				sprintf(aux, "temp%d", temp);
																				concatenarStrings1($$.valor, aux);
																				}
																			}
																		}

																	}else{
																		$$.tipo = $1.tipo;
																		$$.tipoArray = $1.tipoArray;
																		$$.numcolumnas=$1.numcolumnas;
																		$$.numfilas=$1.numfilas;
																		concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);
																	}
																	

																}
								| expresion OPMENOS expresion{	char* sent = (char*) malloc(200);
																	char* aux = (char*) malloc(20);
																	if($1.tipo != $3.tipo){
																		mensajeErrorOperarTipos($1, $3);
																		$$.tipo = desconocido;
																		$$.tipoArray = desconocido;
																	}else if($1.tipo != real && $1.tipo != entero &&
																	$1.tipo != array1d && $1.tipo != array2d){
																		mensajeErrorOperarTipos($1, $3);
																		$$.tipo = desconocido;
																		$$.tipoArray = desconocido;
																	}else if($1.tipo == array1d || $1.tipo == array2d){
																		if($1.tipoArray != $3.tipoArray){
																			mensajeErrorOperarTipos($1, $3);
																			$$.tipoArray = desconocido;
																		}else if($1.tipoArray != entero && $1.tipoArray != real){
																			mensajeErrorOperarTipos($1, $3);
																			$$.tipoArray = desconocido;
																		}else if($1.numcolumnas!=$3.numcolumnas || $1.numfilas!=$3.numfilas){
																			mensajeErrorOperarTamano($1,$3);
																			$$.tipoArray = desconocido;
																			$$.numcolumnas=0;
																			$$.numfilas=0;
																		}else{ 
																			$$.tipo = $1.tipo;
																			$$.tipoArray = $1.tipoArray;
																			$$.numcolumnas=$1.numcolumnas;
																			$$.numfilas=$1.numfilas;
																			char colstr[10];
																			sprintf(colstr, "%d", $3.numcolumnas);
																			char filstr[10];
																			sprintf(filstr, "%d", $3.numfilas);
																			if($1.tipo==array1d){
																				if($1.tipoArray==entero){
																					if (strcmp($2.valor, "-") == 0)
																						sprintf(sent, "%s%s = resInt1d(%s, %s, %s);\n", numTabs(), generarTempArray(array1d, entero), $1.valor, $3.valor, colstr);
																				fputs(sent, file);
																				sprintf(aux, "temp%d", temp);
																				concatenarStrings1($$.valor, aux);
																				}else{
																					if (strcmp($2.valor, "-") == 0)
																						sprintf(sent, "%s%s = resFloat1d(%s, %s, %s);\n", numTabs(), generarTempArray(array1d, real), $1.valor, $3.valor,colstr);
																				fputs(sent, file);
																				sprintf(aux, "temp%d", temp);
																				concatenarStrings1($$.valor, aux);
																				}
																			}else{
																				if($1.tipoArray==entero){
																					if (strcmp($2.valor, "-") == 0){
																						char* sent2 = (char*) malloc(200);
																						sprintf(sent2, "%s%s [%s][%s];\n", numTabs(), generarTemp2d(entero), filstr, colstr);
																						fputs(sent2, file);
																						sprintf(sent, "%sresInt2d(%s, %s, %s, %s, %s);\n", numTabs(), $1.valor, $3.valor, getTemp(), filstr, colstr);
																						
																					}
																				
																					fputs(sent, file);
																					sprintf(aux, "temp%d", temp);
																					concatenarStrings1($$.valor, aux);
																				}else{
																					if (strcmp($2.valor, "-") == 0){
																						char* sent2 = (char*) malloc(200);
																						sprintf(sent2, "%s%s [%s][%s];\n", numTabs(), generarTemp2d(entero), filstr, colstr);
																						fputs(sent2, file);
																						sprintf(sent, "%sresFloat2d(%s, %s, %s, %s, %s);\n", numTabs(), $1.valor, $3.valor, getTemp(), filstr, colstr);
																						
																					}
																					fputs(sent, file);
																					sprintf(aux, "temp%d", temp);
																					concatenarStrings1($$.valor, aux);
																				}
																			}
																		}

																	}else{
																		$$.tipo = $1.tipo;
																		$$.tipoArray = $1.tipoArray;
																		$$.numcolumnas=$1.numcolumnas;
																		$$.numfilas=$1.numfilas;
																		concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);
																	}
																	

																}
								| expresion OPBINCOMP expresion{
																	if($1.tipo != $3.tipo){
																		mensajeErrorOperarTipos($1, $3);
																		$$.tipo = desconocido;
																		$$.tipoArray = desconocido;
																	}else if($1.tipo != real && $1.tipo != entero){
																		mensajeErrorOperarTipos($1, $3);
																		$$.tipo = desconocido;
																		$$.tipoArray = desconocido;
																	}else{
																		$$.tipo = booleano;
																		$$.tipoArray = $1.tipoArray;
																		$$.numcolumnas=$1.numcolumnas;
																		$$.numfilas=$1.numfilas;
																	}
																	concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);
																}
								| expresion OPBINLOGIC expresion{
																	if( $1.tipo != booleano){
																		mensajeErrorTipo($1, booleano);
																		$$.tipo = desconocido;
																	}else if($3.tipo != booleano){
																		mensajeErrorTipo($3, booleano);
																		$$.tipo = desconocido;
																	}
																	else $$.tipo = $1.tipo;
																	$$.tipoArray = $1.tipoArray;
																	$$.numcolumnas = $1.numcolumnas;
																	$$.numfilas = $1.numfilas;
																	concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor); 
																	
								}
								| expresion OPBINARRAY expresion{	char* sent = (char*) malloc(200);
																	char* aux = (char*) malloc(20);
																	if($1.tipo != $3.tipo){
																		if($1.tipo!=array1d && $1.tipo!=array2d && $3.tipo!=array1d &&
																		$3.tipo!=array2d){
																			mensajeErrorOperarTipos($1, $3);
																			$$.tipo = desconocido;
																			$$.tipoArray = desconocido;
																		}else if(!(($1.tipo!=array1d || $1.tipo!=array2d) && $3.tipo!=$1.tipoArray && ($3.tipo!=real || $3.tipo!=entero))){
																			$$.tipo = $1.tipo;
																			$$.tipoArray = $1.tipoArray;
																			$$.numcolumnas=$1.numcolumnas;
																			$$.numfilas=$1.numfilas;	
																			char colstr[10];
																			sprintf(colstr, "%d", $1.numcolumnas);
																			char filstr[10];
																			sprintf(filstr, "%d", $1.numfilas);
																			if($3.tipo==entero && $1.tipo==array1d){
																				
																				sprintf(sent, "%s%s = productoExternoInt1d(%s, %s, %s);\n", numTabs(), generarTempArray(array1d, entero), $3.valor, $1.valor, colstr);
																				fputs(sent, file);
																				sprintf(aux, "temp%d", temp);
																				concatenarStrings1($$.valor, aux);
																			}else if($3.tipo==real && $1.tipo==array1d){
																				
																				sprintf(sent, "%s%s = productoExternoFloat1d(%s, %s, %s);\n", numTabs(), generarTempArray(array1d, real), $3.valor, $1.valor, colstr);
																				fputs(sent, file);
																				sprintf(aux, "temp%d", temp);
																				concatenarStrings1($$.valor, aux);
																			}else if($3.tipo==entero && $1.tipo==array2d){
																				char* sent2 = (char*) malloc(200);
																				sprintf(sent2, "%s%s [%s][%s];\n", numTabs(), generarTemp2d(entero), filstr, colstr);
																				fputs(sent2, file);
																				sprintf(sent, "%sproductoExternoInt2d(%s, %s, %s, %s, %s);\n", numTabs(), $3.valor, $1.valor, getTemp(), filstr, colstr);
																				fputs(sent, file);
																				sprintf(aux, "temp%d", temp);
																				concatenarStrings1($$.valor, aux);
																			}else if($3.tipo==real && $1.tipo==array2d){
																				char* sent2 = (char*) malloc(200);
																				sprintf(sent2, "%s%s [%s][%s];\n", numTabs(), generarTemp2d(entero), filstr, colstr);
																				fputs(sent2, file);
																				sprintf(sent, "%sproductoExternoFloat2d(%s, %s, %s, %s, %s);\n", numTabs(), $3.valor, $1.valor, getTemp(), filstr, colstr);
																				fputs(sent, file);
																				sprintf(aux, "temp%d", temp);
																				concatenarStrings1($$.valor, aux);
																			}
																		}else if(!(($3.tipo!=array1d || $3.tipo!=array2d) && $1.tipo!=$3.tipoArray && ($1.tipo!=real || $1.tipo!=entero))){
																			$$.tipo = $3.tipo;
																			$$.tipoArray = $3.tipoArray;
																			$$.numcolumnas=$3.numcolumnas;
																			$$.numfilas=$3.numfilas;
																			char colstr[10];
																			sprintf(colstr, "%d", $3.numcolumnas);
																			char filstr[10];
																			sprintf(filstr, "%d", $3.numcolumnas);
																			if($1.tipo==entero && $3.tipo==array1d){
																				
																				sprintf(sent, "%s%s = productoExternoInt1d(%s, %s, %s);\n", numTabs(), generarTempArray(array1d, entero), $1.valor, $3.valor, colstr);
																				fputs(sent, file);
																				sprintf(aux, "temp%d", temp);
																				concatenarStrings1($$.valor, aux);
																			}else if($1.tipo==real && $3.tipo==array1d){
																				
																				sprintf(sent, "%s%s = productoExternoFloat1d(%s, %s, %s);\n", numTabs(), generarTempArray(array1d, real), $1.valor, $3.valor, colstr);
																				fputs(sent, file);
																				sprintf(aux, "temp%d", temp);
																				concatenarStrings1($$.valor, aux);
																			}else if($1.tipo==entero && $3.tipo==array2d){
																				char* sent2 = (char*) malloc(200);
																				sprintf(sent2, "%s%s [%s][%s];\n", numTabs(), generarTemp2d(entero), filstr, colstr);
																				fputs(sent2, file);
																				sprintf(sent, "%sproductoExternoInt2d(%s, %s, %s, %s, %s);\n", numTabs(), $1.valor, $3.valor, getTemp(), filstr, colstr);
																				fputs(sent, file);
																				sprintf(aux, "temp%d", temp);
																			}else if($1.tipo==real && $3.tipo==array2d){
																				char* sent2 = (char*) malloc(200);
																				sprintf(sent2, "%s%s [%s][%s];\n", numTabs(), generarTemp2d(entero), filstr, colstr);
																				fputs(sent2, file);
																				sprintf(sent, "%sproductoExternoFloat2d(%s, %s, %s, %s, %s);\n", numTabs(), $1.valor, $3.valor, getTemp(), filstr, colstr);
																				fputs(sent, file);
																				sprintf(aux, "temp%d", temp);
																				concatenarStrings1($$.valor, aux);
																			}
																		}else{
																			mensajeErrorOperarTipos($1, $3);
																			$$.tipo = desconocido;
																			$$.tipoArray = desconocido;
																		}
																	}else if($1.tipo!=array2d){
																		mensajeErrorTipo($1, array2d);
																		$$.tipo = desconocido;
																		$$.tipoArray = desconocido;
																	}else if($1.tipoArray != $3.tipoArray){
																		mensajeErrorOperarTipos($1, $3);
																		$$.tipoArray = desconocido;
																	}else if($1.tipoArray!=entero && $1.tipoArray!=real){
																		mensajeErrorOperarTipos($1, $3);
																		$$.tipo = desconocido;
																		$$.tipoArray = desconocido;
																	}else if($1.numcolumnas!=$3.numfilas){
																		mensajeErrorOperarTamano($1,$3);
																		$$.tipo = desconocido;
																		$$.tipoArray = desconocido;
																	}else{
																		$$.tipo = $1.tipo;
																		$$.tipoArray = $1.tipoArray;
																		$$.numcolumnas=$3.numcolumnas;
																		$$.numfilas=$1.numfilas;
																		char fil1str[10];
																		sprintf(fil1str, "%d", $1.numfilas);
																		char comstr[10];
																		sprintf(comstr, "%d", $1.numcolumnas);
																		char col3str[10];
																		sprintf(col3str, "%d", $3.numcolumnas);
																		if($3.tipoArray==entero){
																			char* sent2 = (char*) malloc(200);
																			sprintf(sent2, "%s%s [%s][%s];\n", numTabs(), generarTemp2d(entero), fil1str, col3str);
																			fputs(sent2, file);
																			sprintf(sent, "%sproductoMatricialInt(%s, %s, %s, %s, %s, %s);\n", numTabs(), $1.valor, $3.valor, getTemp(), fil1str, comstr, col3str);
																			
																		}else{
																			char* sent2 = (char*) malloc(200);
																			sprintf(sent2, "%s%s [%s][%s];\n", numTabs(), generarTemp2d(entero), fil1str, col3str);
																			fputs(sent2, file);
																			sprintf(sent, "%sproductoMatricialFloat(%s, %s, %s, %s, %s, %s);\n", numTabs(), $1.valor, $3.valor, getTemp(), fil1str, comstr, col3str);
																		}
																		fputs(sent, file);
																		sprintf(aux, "temp%d", temp);
																		concatenarStrings1($$.valor, aux);

																	}
																	//concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor); 
								}
								| constante{ $$.tipo = $1.tipo;
											$$.tipoArray = $1.tipoArray;
											$$.numcolumnas=$1.numcolumnas;
											$$.numfilas=$1.numfilas;
											concatenarStrings1($$.valor, $1.valor);}
								| IDENTIFICADOR{
																	if( !existeVariable($1) ){
																		mensajeErrorNoDeclarada($1);
																		$$.tipo = desconocido;
																		$$.tipoArray = desconocido;
																	}
																	else{
																		entradaTabla aux = getUltimaEntrada($1.nombre);
																		$$.tipo = aux.tipo;
																		$$.tipoArray = aux.tipoArray;
																		$$.numcolumnas=aux.numcolumnas;
																		$$.numfilas=aux.numfilas;
																	}
																	$$.entrada = variable;
																	concatenarStrings1($$.valor, $1.nombre);
								}
								| funcion{
																	if( !existeVariable($1) ){
																		mensajeErrorNoDeclarada($1);
																		$$.tipo = desconocido;
																		$$.tipoArray = desconocido;
																	}
																	else{
																		entradaTabla aux = getUltimaEntrada($1.nombre);
																		$$.tipo = aux.tipo;
																		$$.tipoArray = aux.tipoArray;
																		$$.numcolumnas=aux.numcolumnas;
																		$$.numfilas=aux.numfilas;
																	}
																	$$.entrada = funcion;
																	concatenarStrings1($$.valor, $1.valor);
								}
								| expresion INICOR expresion COMA expresion FINCOR{
																				if($1.tipo!=array2d){
																					mensajeErrorTipo($1, array2d);
																					$$.tipo = desconocido;
																					$$.tipoArray = desconocido;
																					$$.numcolumnas=0;
																					$$.numfilas=0;
																				}else if($3.tipo!=entero){
																					mensajeErrorTipo($3, entero);
																					$$.tipo = desconocido;
																					$$.tipoArray = desconocido;
																					$$.numcolumnas=0;
																					$$.numfilas=0;
																				}else if($5.tipo!=entero){
																					mensajeErrorTipo($5, entero);
																					$$.tipo = desconocido;
																					$$.tipoArray = desconocido;
																					$$.numcolumnas=0;
																					$$.numfilas=0;
																				}else if(!(atoi($3.valor)>=0 && atoi($3.valor)<$1.numfilas)){
																					mensajeErrorAccesoArray($1);
																					$$.tipo = desconocido;
																					$$.tipoArray = desconocido;
																					$$.numcolumnas=0;
																					$$.numfilas=0;
																				}else if(!(atoi($5.valor)>=0 && atoi($5.valor)<$1.numcolumnas)){
																					mensajeErrorAccesoArray($1);
																					$$.tipo = desconocido;
																					$$.tipoArray = desconocido;
																					$$.numcolumnas=0;
																					$$.numfilas=0;
																				}else{
																					$$.tipo=$1.tipoArray;
																					$$.tipoArray=desconocido;
																					$$.numcolumnas=0;
																					$$.numfilas=0;
																				}
																				concatenarStrings6($$.valor, $1.valor, $2.valor, $3.valor, "][", $5.valor, $6.valor);
																				}
								| expresion INICOR expresion FINCOR{
																		if($1.tipo!=array1d){
																			mensajeErrorTipo($1, array1d);
																			$$.tipo = desconocido;
																			$$.tipoArray = desconocido;
																			$$.numcolumnas=0;
																			$$.numfilas=0;
																		}else if($3.tipo!=entero){
																			mensajeErrorTipo($3, entero);
																			$$.tipo = desconocido;
																			$$.tipoArray = desconocido;
																			$$.numcolumnas=0;
																			$$.numfilas=0;
																		}else if(!(atoi($3.valor)>=0 && atoi($3.valor)<$1.numcolumnas)){
																			mensajeErrorAccesoArray($1);
																			$$.tipo = desconocido;
																			$$.tipoArray = desconocido;
																			$$.numcolumnas=0;
																			$$.numfilas=0;
																		}else{
																			$$.tipo=$1.tipoArray;
																			$$.tipoArray=desconocido;
																			$$.numcolumnas=0;
																			$$.numfilas=0;
																		}
																		concatenarStrings4($$.valor, $1.valor, $2.valor, $3.valor, $4.valor);

																	}
								
								| error ;

constante 						: ENTERO{
												$$.tipo = entero;
												$$.tipoArray = desconocido;
												$$.numcolumnas=0;
												$$.numfilas=0;
												concatenarStrings1($$.valor, $1.valor);	
								}
								| REAL{
												$$.tipo = real;
												$$.tipoArray = desconocido;
												$$.numcolumnas=0;
												$$.numfilas=0;
												concatenarStrings1($$.valor, $1.valor);
								}
								| CARACTER{
												$$.tipo = caracter;
												$$.tipoArray = desconocido;
												$$.numcolumnas=0;
												$$.numfilas=0;
												concatenarStrings1($$.valor, $1.valor);
								}
								| VALBOOLEANO{
												$$.tipo = booleano;
												$$.tipoArray = desconocido;
												$$.numcolumnas=0;
												$$.numfilas=0;
												concatenarStrings1($$.valor, $1.valor);
								}
								| array1d{
												if($1.tipo!=array1d){
													mensajeErrorTipo($1, array1d);
													$$.tipo = desconocido;
													$$.tipoArray = desconocido;
													$$.numcolumnas=0;
													$$.numfilas=0;
												}else{
													$$.tipo = $1.tipo;
													$$.tipoArray = $1.tipoArray;
													$$.numcolumnas=$1.numcolumnas;
													$$.numfilas=$1.numfilas;
													concatenarStrings1($$.valor, $1.valor);
												}
								}
								| array2d{
												if($1.tipo!=array2d){
													mensajeErrorTipo($1, array2d);
													$$.tipo = desconocido;
													$$.tipoArray = desconocido;
													$$.numcolumnas=0;
													$$.numfilas=0;
												}else{
													$$.tipo = $1.tipo;
													$$.tipoArray = $1.tipoArray;
													$$.numcolumnas=$1.numcolumnas;
													$$.numfilas=$1.numfilas;
													concatenarStrings1($$.valor, $1.valor);
												}
								};

array1d							: INILLAVE expresion mas_elementos FINLLAVE{
																				if($2.tipo == array1d || $2.tipo == array2d){
																					mensajeErrorNoSeEsperaArray();
																					$$.tipo = desconocido;
																					$$.tipoArray = desconocido;
																					$$.numcolumnas=0;
																					$$.numfilas=0;
																				}else{
																					$$.tipo = array1d;
																					$$.tipoArray = $2.tipo;
																					$$.numcolumnas=$3.numcolumnas+1;
																					$$.numfilas=1;
																					concatenarStrings4($$.valor, $1.valor, $2.valor, $3.valor, $4.valor);
																				}
																			}
								| INILLAVE FINLLAVE{
																					$$.tipo = array1d;
																					$$.tipoArray = $2.tipo;
																					$$.numcolumnas=0;
																					$$.numfilas=1;
																					concatenarStrings2($$.valor, $1.valor, $2.valor);
								};

mas_elementos					: mas_elementos COMA expresion{
																	if($3.tipo!=$0.tipo){
																		mensajeErrorTipo($3,$0.tipo);
																		$$.tipo = desconocido;
																		$$.tipoArray = desconocido;
																		$$.numcolumnas=0;
																		$$.numfilas=0;
																	}else{
																		$$.tipo = $3.tipo;
																		$$.tipoArray = $3.tipoArray;
																		$$.numcolumnas++;
																		$$.numfilas=1;
																		concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);
																	}
																}
								| /* vacio */{
																	$$.numcolumnas=0;
																	concatenarStrings1($$.valor,"");
																};

array2d							: INICOR array1d mas_arrays FINCOR{
																				if($2.tipo != array1d){						
																					mensajeErrorTipo($2, array1d);
																					$$.tipo = desconocido;
																					$$.tipoArray = desconocido;
																					$$.numcolumnas=0;
																					$$.numfilas=0;
																				}else if($3.tipo!=desconocido){
																					if($2.numcolumnas!=$3.numcolumnas){
																						mensajeErrorAsignarTamano($2,$3);
																						$$.tipo = desconocido;
																						$$.tipoArray = desconocido;
																						$$.numcolumnas=0;
																						$$.numfilas=0;
																					}
																					$$.tipo = array2d;
																					$$.tipoArray = $2.tipoArray;
																					$$.numcolumnas=$2.numcolumnas;
																					$$.numfilas=$3.numfilas+1;
																					concatenarStrings4($$.valor, "{", $2.valor, $3.valor, "}");
																				}else{
																					$$.tipo = array2d;
																					$$.tipoArray = $2.tipoArray;
																					$$.numcolumnas=$2.numcolumnas;
																					$$.numfilas=$3.numfilas+1;
																					concatenarStrings4($$.valor, "{", $2.valor, $3.valor, "}");
																				}
																			};

mas_arrays						: mas_arrays array1d{
														if($2.tipo!=array1d){											
															mensajeErrorTipo($2,array1d);
															$$.tipo = desconocido;
															$$.tipoArray = desconocido;
															$$.numcolumnas=0;
															$$.numfilas=0;
														}else{
															$$.tipo = $2.tipo;
															$$.tipoArray = $2.tipoArray;
															$$.numcolumnas=$2.numcolumnas;
															$$.numfilas++;
															concatenarStrings3($$.valor, $1.valor, ",", $2.valor);
														}
													}
								| /* vacio */{
												$$.numfilas=0;
												concatenarStrings1($$.valor,"");
											};

funcion							: IDENTIFICADOR INIPAR lista_expresiones FINPAR{
										$1.entrada = getUltimaEntrada($1.nombre).entrada;
										if( !existeVariable($1) ){
											mensajeErrorNoDeclarada($1);
											$$.tipo = desconocido;
										}
										else if( getUltimaEntrada($1.nombre).entrada != funcion ){
											mensajeErrorSeEsperabaFuncion($1);
											$$.tipo = desconocido;
										}
										else if( $3.parametros != getUltimaEntrada($1.nombre).parametros ){
											mensajeErrorNumParametros(getUltimaEntrada($1.nombre),$3);
											$$.tipo = desconocido;
										}
										$$.tipo = getUltimaEntrada($1.nombre).tipo;
										$$.tipoArray = getUltimaEntrada($1.nombre).tipoArray;
										char* sent = (char*) malloc(200);
										sprintf(sent, "%s%s = %s(%s);\n", numTabs(), generarTemp($$.tipo), $1.valor, $3.valor);
										fputs(sent, file);
										char* aux = (char*) malloc(20);
										sprintf(aux, "temp%d", temp);
										concatenarStrings1($$.valor, aux);

								};

lista_expresiones 				: lista_expresiones_aux expresion{
																	$$.parametros=$1.parametros+1;
																	if (strcmp($0.valor, "(") == 0 ){
																		entradaTabla aux = getUltimaEntrada($-1.nombre);
																		if( !comprobarParametro(aux.nombre, $$.parametros, $2.tipo) )
																			mensajeErrorTipoArgumento(aux.nombre, $$.parametros,
																				getSimboloParametro(aux.nombre, $$.parametros).tipo); 
																	}
																	concatenarStrings2($$.valor, $1.valor, $2.valor);
																}
								| /* vacio */{
												$$.parametros=0;
												concatenarStrings1($$.valor,"");
											};

lista_expresiones_aux			: lista_expresiones_aux expresion COMA{
													$$.parametros=$1.parametros+1;
													if (strcmp($0.valor, "(") == 0 ){
														entradaTabla aux = getUltimaEntrada($-1.nombre);
														if( !comprobarParametro(aux.nombre, $$.parametros, $2.tipo) )
															mensajeErrorTipoArgumento(aux.nombre, $$.parametros,
																getSimboloParametro(aux.nombre, $$.parametros).tipo);	
													} 
													
													concatenarStrings4($$.valor, $1.valor, $2.valor, " ", $3.valor);

												}
								| /* vacio */{$$.parametros=0;
												concatenarStrings1($$.valor,"");
												};

tipo 							: TIPOARRAY1D INICOR ENTERO FINCOR TIPOVAR{
																			$$.tipo=array1d;
																			$$.tipoArray=$5.tipo;
																			$$.numcolumnas=atoi($3.valor);
																			$$.numfilas=1;
																			}
								| TIPOARRAY2D INICOR ENTERO COMA ENTERO FINCOR TIPOVAR{
																			$$.tipo=array2d;
																			$$.tipoArray=$7.tipo;
																			$$.numcolumnas=atoi($5.valor);
																			$$.numfilas=atoi($3.valor);
																			
																			}
								| TIPOVAR{$$.tipo = $1.tipo;};

%%


#include "lex.yy.c"



void yyerror(const char * msg) {
  printf("[Línea %d]: %s\n", numLinea, msg);
}
