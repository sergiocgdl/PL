#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin ;
int yyparse(void) ;

FILE *abrir_entrada( int argc, char *argv[] ){
    FILE *f= NULL ;
    if ( argc > 1 ){
        f= fopen(argv[1],"r");
        if (f==NULL){
            fprintf(stderr,"fichero '%s' no encontrado\n",argv[1]);
            exit(1);
        }
        else
            printf("leyendo fichero '%s'.\n",argv[1]);
    }
    else
        printf("leyendo entrada estándar.\n");

    return f ;
}
/*
void parse (const int aux, char ret[]) {
	switch (aux) {
		case 257: strcpy(ret, "CABECPROG\0");		break;
		case 258: strcpy(ret, "INILLAVE\0");		break;
		case 259: strcpy(ret, "FINLLAVE\0");		break;
		case 260: strcpy(ret, "MARCAINI\0");		break;
		case 261: strcpy(ret, "MARCAFIN\0");		break;
		case 262: strcpy(ret, "TIPOVAR\0");			break;
		case 263: strcpy(ret, "FINLINEA\0");		break;
		case 264: strcpy(ret, "COMA\0");			break;
		case 265: strcpy(ret, "IGUAL\0");			break;
		case 266: strcpy(ret, "INICOR\0");			break;
		case 267: strcpy(ret, "FINCOR\0");			break;
		case 268: strcpy(ret, "INIPAR\0");			break;
		case 269: strcpy(ret, "FINPAR\0");			break;
		case 270: strcpy(ret, "IDENTIFICADOR\0");	break;
		case 271: strcpy(ret, "CONDIF\0");			break;
		case 272: strcpy(ret, "CONDELSE\0");		break;
		case 273: strcpy(ret, "CONDWHILE\0");		break;
		case 274: strcpy(ret, "ENTRADA\0");			break;
		case 275: strcpy(ret, "SALIDA\0");			break;
		case 276: strcpy(ret, "RETORNO\0");			break;
		case 277: strcpy(ret, "CONDSWITCH\0");		break;
		case 278: strcpy(ret, "CASOSWITCH\0");		break;
		case 279: strcpy(ret, "DEFECTOSWITCH\0");	break;
		case 280: strcpy(ret, "FINSWITCH\0");		break;
		case 281: strcpy(ret, "SENTSWITCH\0");		break;
		case 282: strcpy(ret, "CADENA\0");			break;
		case 283: strcpy(ret, "CARACTER\0");		break;
		case 284: strcpy(ret, "OPSIG\0");			break;
		case 285: strcpy(ret, "OPUN\0");			break;
		case 286: strcpy(ret, "OPBIN\0");			break;
		case 287: strcpy(ret, "OPMENOS\0");			break;
		case 288: strcpy(ret, "ENTERO\0");			break;
		case 289: strcpy(ret, "DECIMAL\0");			break;
		case 290: strcpy(ret, "REAL\0");			break;
		case 291: strcpy(ret, "VALBOOLEANO\0");		break;
		case 292: strcpy(ret, "TIPOARRAY1D\0");		break;
		case 293: strcpy(ret, "TIPOARRAY2D\0");		break;
	}
}*/

/************************************************************/
int main( int argc, char *argv[] ){
    yyin = abrir_entrada(argc,argv) ;
	int ret = yyparse();
	//printf("***** Valor devuelto por yyparse(): %d\n",ret);
    return ret ;
}
