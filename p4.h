typedef int bool; //C no tiene bool así que lo definimos

int debug=0;

#define TRUE 1
#define FALSE 0
#define MAX_SYMBOL 2000

typedef enum {marca, variable, funcion, parametro} tipoEntrada ;

typedef enum {desconocido, entero, real, caracter, booleano, array1d, array2d, cadena} tipoDato ;

typedef struct {
char* EtiquetaEntrada ;
char* EtiquetaSalida ;
char* EtiquetaElse ;
char* NombreVarControl ;
char* EtiquetaCase;
char* EtiquetaFinal;
} etiquetaFlujo ;

typedef struct {
	tipoEntrada 	entrada ;
	char*			nombre ;
	char* 			valor;
	tipoDato 		tipo ;
	tipoDato		tipoArray ;
	unsigned int 	parametros ;
	unsigned int 	numfilas ;
	unsigned int 	numcolumnas ;
	etiquetaFlujo	ef ;
} entradaTabla;

int TOPEFLUJO = 0;
char* tabs = NULL;
etiquetaFlujo TF[MAX_SYMBOL];

entradaTabla TS[MAX_SYMBOL];	/*Pila de la tabla de símbolos*/
int TOPE = 0;
unsigned int Subprog ;     /*Indicador de comienzo de bloque de un subprog*/
FILE* file;
FILE* file_std;
FILE* file_fun;
char* argumento;


#define YYSTYPE entradaTabla  /*A partir de ahora, cada símbolo tiene*/
							/*una estructura de tipo atributos*/


char* toStringEntrada();
char* toStringTipo();

// Inserta una entrada en la pila
void insertar (entradaTabla s){
	if(debug) printf("Inserto la %s %s\n", toStringEntrada(s.entrada), s.nombre);

   if (TOPE >= MAX_SYMBOL) {
		printf("\nError: tamanio maximo alcanzado\n");
		exit(-1);
   } else {
		TS[TOPE].nombre=s.nombre;
		TS[TOPE].valor=s.valor;
		TS[TOPE].tipo=s.tipo;
		TS[TOPE].tipoArray=s.tipoArray;
		TS[TOPE].parametros=s.parametros;
		TS[TOPE].entrada=s.entrada;
		TS[TOPE].numcolumnas=s.numcolumnas;
		TS[TOPE].numfilas=s.numfilas;
		++TOPE;
   }
}

void insertarFlujo (etiquetaFlujo s){
	if (TOPEFLUJO == MAX_SYMBOL) {
		printf("\nError: tamanio maximo alcanzado\n");
		exit(-1);
	} else {
		TF[TOPEFLUJO].EtiquetaEntrada=s.EtiquetaEntrada;
		TF[TOPEFLUJO].EtiquetaSalida=s.EtiquetaSalida;
		TF[TOPEFLUJO].EtiquetaElse=s.EtiquetaElse;
		TF[TOPEFLUJO].NombreVarControl=s.NombreVarControl;
		++TOPEFLUJO;
	}
}

char *strdup(const char *src) {
    char *dst = malloc(strlen (src) + 1);  // Space for length plus nul
    if (dst == NULL) return NULL;          // No memory
    strcpy(dst, src);                      // Copy the characters
    return dst;                            // Return the new string
}

void copiarEF(etiquetaFlujo *dest, etiquetaFlujo *source){
	if (source->EtiquetaEntrada != NULL) 	dest->EtiquetaEntrada = strdup(source->EtiquetaEntrada) ;
	if (source->EtiquetaSalida != NULL)		dest->EtiquetaSalida = strdup(source->EtiquetaSalida) ;
	if (source->EtiquetaElse != NULL)		dest->EtiquetaElse = strdup(source->EtiquetaElse) ;
	if (source->NombreVarControl != NULL)	dest->NombreVarControl = strdup(source->NombreVarControl) ;
}

//Busca en la tabla de simbolos el nombre de una función. Devuelve posición y -1 si no la encuentra
int buscarFuncion (char* nom) {
	if(debug) printf("buscarFuncion( %s )\n", nom );
	if( nom != 0 ){
		for (int i = TOPE-1; i > 0; --i){
			if(TS[i].nombre != 0 ){
				if(TS[i].entrada == funcion && strcmp(TS[i].nombre, nom)==0)
					return i;
			}
		}
		return -1;
	}
	return -1;
}

//Busca una funcion y si la encuentra la introduce en la tabla y luego vuelve a insertarla en la pila
void insertarPreEntrada(char* nom, int numArgumentos){
	if(debug) printf("insertarPreEntrada( %s , %d )\n", nom, numArgumentos);

	int index = buscarFuncion(nom);
	if(debug) printf("Indice de la funcion %s: %d\n", nom, index);

	if( index > 0 ){
		for(int i = numArgumentos; i > 0; --i) {
			entradaTabla aux;
			aux.nombre = TS[index-i].nombre;
			aux.valor = TS[index-i].valor;
			aux.tipo = TS[index-i].tipo;
			aux.tipoArray = TS[index-i].tipoArray;
			aux.parametros = TS[index-i].parametros;
			aux.entrada = variable;
			insertar(aux);
		}
	}
}


//Vacia la pila poniendo el tope en 0 y asignando TS a una vacía
void vaciar(){
	if(debug) printf("vaciar()\n");
	TOPE=0;
}

//Busca el indice del bloque y pone el tope en él, borrando así el bloque
void eliminarBloque(){
	if(debug) printf("eliminarBloque()\n");

	bool encontrada = FALSE;
	int i;
	for (i=TOPE-1; i>0 && !encontrada; --i) {
		if(TS[i].entrada == marca) {
			TOPE = i;
			encontrada = TRUE;
		}
	}
	if(encontrada == FALSE)
		vaciar();

	if(strlen(tabs) > 0)
		tabs[strlen(tabs)-1] = '\0';
}


//Introduce una entrada en la pila de tipo marca de inicio de bloque
void insertarMarca(){
	if(debug) printf("insertarMarca()\n");

	if (TOPE >= MAX_SYMBOL) {
		printf("\nError: tamano maximo alcanzado\n");
		exit(-1);
	} else {
		TS[TOPE].entrada = marca;
		++TOPE;

		if( tabs == NULL ){
			tabs = (char*) malloc(50);
			tabs[0] = '\0';
		}
		if (contBloques > 0)	concatenarStrings1(tabs, "\t");
	}
}

//Elimina el elemento del tope de la pila
void eliminaTope(){
	if(debug) printf("eliminaTope()\n");
	if (TOPE > 0) {
	  --TOPE;
	}
}

void sacarTF(){
	if(debug) printf("sacar()\n");
   if (TOPEFLUJO > 0) {
      --TOPEFLUJO;
   }
}

//Comprueba si la variable se ha declarado anteriormente en el mismo bloque
bool existeVariableEnBloque(entradaTabla ts){
	if(debug) printf("existeVariableEnBloque( %s )\n", ts.nombre);
	if( ts.nombre != 0 ){
		bool encontrada = FALSE;
		
		for(int i=TOPE-1; i>=0 && !encontrada; --i){
				if( (TS[i].entrada == variable || TS[i].entrada == funcion) && TS[i].nombre != 0 && strcmp(TS[i].nombre, ts.nombre) == 0)
					encontrada = TRUE;		
				if(TS[i].entrada==marca)
					return encontrada;
		}
		return encontrada;
	}
	return FALSE;
}

//Comprueba si la variable ha sido ya declarada
bool existeVariable(entradaTabla ts){
	if(debug) printf("existeVariable( %s )\n", ts.nombre);
	if( ts.nombre != 0 ){
		bool encontrada = FALSE;
		for(int i=TOPE-1; i>=0 && !encontrada; --i){
			if( (TS[i].entrada == variable || TS[i].entrada == funcion) && TS[i].nombre != 0 && strcmp(TS[i].nombre, ts.nombre) == 0 ){
				encontrada = TRUE;
			}
		}
		return encontrada;
	}
	return FALSE;
}

//Comprueba si hay otro parámetro en la misma función con el mismo nombre 
bool existeParametro(entradaTabla ts){
	if(debug) printf("existeParametro( %s )\n", ts.nombre);
	if( ts.nombre != 0 ){
		int i = TOPE-1;

		while( TS[i].entrada == parametro ){
			if( TS[i].nombre != 0 && strcmp(TS[i].nombre, ts.nombre) == 0 )
				return TRUE;
			--i;
		}
		return FALSE;
	}
	return FALSE;
}

//Devuelve la ultima entrada de la pila asociada a la función o variable "nombre"
entradaTabla getUltimaEntrada(char* nombre){
	if(debug) printf("getUltimaEntrada( %s )\n", nombre);
	entradaTabla ret = { 0, 0, 0, 0, 0, 0};
	if( nombre != 0 ){
		int i;
		bool encontrada=FALSE;
		
		for(i=TOPE-1; i>=0 && !encontrada; --i){
			if( (TS[i].entrada == variable || TS[i].entrada == funcion ) && TS[i].nombre != 0
					&& strcmp(TS[i].nombre, nombre) == 0){
				encontrada = TRUE;
				ret=TS[i];
			}
		}
		return ret;	
	}
	return ret;
}

//Devuelve la entrada de la pila asociada al argumento número "numPar" de la funcion con nombre "nombreFun"
entradaTabla getSimboloParametro(char* nombreFun, int numPar){
	if(debug) printf("getSimboloParametro( %s , %d )\n", nombreFun, numPar);
	entradaTabla ret;
	ret.parametros=-1;

	if( nombreFun != 0 ){
		int indiceFun = -1;
		bool encontrada=FALSE;
			
		for(int i=TOPE-1; i>=0 && !encontrada; --i){
			if( TS[i].entrada == funcion && TS[i].nombre != 0 && strcmp(TS[i].nombre, nombreFun) == 0){
				encontrada = TRUE;
				indiceFun=i;
			}
		}
		
		if( indiceFun >0 && numPar > TS[indiceFun].parametros){
			return ret;
		}
		
		return TS[indiceFun-TS[indiceFun].parametros+numPar-1];
	}
	return ret;
}

/****************************		FUNCIONES AUXILIARES		**************************/

void concatenarStrings1(char* destination, char* source1){
	if( destination == NULL)
		destination = (char *) malloc(200);
	sprintf(destination, "%s", source1);
}

void concatenarStrings2(char* destination, char* source1, char* source2){
	if( destination == NULL)
		destination = (char *) malloc(200);
	sprintf(destination, "%s%s", source1, source2);
}

void concatenarStrings3(char* destination, char* source1, char* source2, char* source3){
	if( destination == NULL)
		destination = (char *) malloc(200);
	sprintf(destination, "%s%s%s", source1, source2, source3);
}

void concatenarStrings4(char* destination, char* s1, char* s2, char* s3, char* s4){
	if( destination == NULL)
		destination = (char *) malloc(200);
	sprintf(destination, "%s%s%s%s", s1, s2, s3, s4);
}

void concatenarStrings5(char* destination, char* s1, char* s2, char* s3, char* s4, char* s5){
	if( destination == NULL)
		destination = (char *) malloc(200);
	sprintf(destination, "%s%s%s%s%s", s1, s2, s3, s4, s5);
}

void concatenarStrings6(char* destination, char* s1, char* s2, char* s3, char* s4, char* s5, char* s6){
	if( destination == NULL)
		destination = (char *) malloc(200);
	sprintf(destination, "%s%s%s%s%s%s", s1, s2, s3, s4, s5, s6);
}

void concatenarStrings7(char* destination, char* s1, char* s2, char* s3, char* s4, char* s5, char* s6, char* s7){
	if( destination == NULL)
		destination = (char *) malloc(500);
	sprintf(destination, "%s%s%s%s%s%s%s", s1, s2, s3, s4, s5, s6, s7);
}

void concatenarStrings8(char* destination, char* s1, char* s2, char* s3, char* s4, char* s5, char* s6, char* s7, char* s8){
	if( destination == NULL)
		destination = (char *) malloc(500);
	sprintf(destination, "%s%s%s%s%s%s%s%s", s1, s2, s3, s4, s5, s6, s7, s8);
}

void concatenarStrings9(char* destination, char* s1, char* s2, char* s3, char* s4, char* s5, char* s6, char* s7, char* s8, char* s9){
	if( destination == NULL)
		destination = (char *) malloc(500);
	sprintf(destination, "%s%s%s%s%s%s%s%s%s", s1, s2, s3, s4, s5, s6, s7, s8, s9);
}

void concatenarStrings10(char* destination, char* s1, char* s2, char* s3, char* s4, char* s5, char* s6, char* s7, char* s8, char* s9, char* s10){
	if( destination == NULL)
		destination = (char *) malloc(1000);
	sprintf(destination, "%s%s%s%s%s%s%s%s%s%s", s1, s2, s3, s4, s5, s6, s7, s8, s9, s10);
}


void eliminaPrimerValor(char* c){
	if(c!=NULL){
		memmove(c,c+1,strlen(c));
	}
}

char* toStringTipo(tipoDato td){
	if(td == entero) 	return "entero";		
	if(td == booleano) 	return "booleano";	
	if(td == real) 		return "real";
	if(td == caracter)	return "caracter";
	if(td == array1d)	return "array1d";
	if(td == array2d)	return "array2d";
	return "";
}

char* toStringEntrada(tipoEntrada te){
	if(te == marca) 			return "marca";		
	if(te == funcion) 			return "funcion";	
	if(te == variable) 			return "variable";
	if(te == parametro)			return "parametro";
	return "";
}

//Imprime el contenido de la pila 
void imprimirTablaSimbolos(){
	int i;
	char tabs[50] = "\0";
	
	for(i=0; i < TOPE ; ++i){
		if(TS[i].entrada == marca)
			printf("\nINICIO DE BLOQUE\n");
		else{
			if( TS[i].parametros > 0 && TS[i].tipoArray != desconocido )
				printf("%s%s\t%s\t%s\t%s\t%d\n", tabs, toStringEntrada(TS[i].entrada), TS[i].nombre, 
						toStringTipo(TS[i].tipo), toStringTipo(TS[i].tipoArray) ,TS[i].parametros );
			else if( TS[i].parametros > 0 )
				printf("%s%s\t%s\t%s\t%d\n", tabs, toStringEntrada(TS[i].entrada), TS[i].nombre, 
						toStringTipo(TS[i].tipo) ,TS[i].parametros );
			else printf("%s%s\t%s\t%s\n", tabs, toStringEntrada(TS[i].entrada), TS[i].nombre, toStringTipo(TS[i].tipo));
		}
	}
	printf("**********************************************************************************\n\n\n");
}

//Error si la variable ya esta declarada en ese bloque
void mensajeErrorDeclaradaBloque(entradaTabla ts){
	if (ts.tipo != desconocido)
		printf("Error semantico en la linea %d: La %s %s ya esta declarada en este bloque\n", numLinea, toStringEntrada(ts.entrada), ts.nombre);
}

//Error cuando la variable no esta declarada
void mensajeErrorNoDeclarada(entradaTabla ts){
	if (ts.tipo != desconocido)
		printf("Error semantico en la linea %d: La %s %s no ha sido declarada\n", numLinea, toStringEntrada(ts.entrada), ts.nombre);
}

//Error en los parametros de la funcion
void mensajeErrorParametro(entradaTabla ts){
	if (ts.tipo != desconocido)
		printf("Error semantico en la linea %d: Hay mas de un parametro con el mismo nombre \"%s\"\n", numLinea, ts.nombre);
}

//Error cuando no es una variable
void mensajeErrorNoVariable(entradaTabla ts){
	if (ts.tipo != desconocido)
		printf("Error semantico en la linea %d: La %s %s no es una variable\n", numLinea, toStringEntrada(ts.entrada), ts.nombre);
}

//Error en los tipos de una asignacion
void mensajeErrorAsignacion(entradaTabla ts1, entradaTabla ts2){
	if (ts1.tipo != desconocido && ts2.tipo != desconocido )
		printf("Error semantico en la linea %d: Los tipos de la asignacion %s y %s no coinciden\n", numLinea, toStringTipo(ts1.tipo),
				toStringTipo(ts2.tipo));
}

//Error cuando no coinciden los tipos
void mensajeErrorTiposInternosNoCoinciden(entradaTabla ts1, entradaTabla ts2){
	if (ts1.tipoArray != desconocido && ts2.tipoArray != desconocido )
		printf("Error semantico en la linea %d: Los tipos %s y %s no coinciden\n", numLinea, toStringTipo(ts1.tipoArray),
				toStringTipo(ts2.tipoArray));
	else
		printf("Error semantico en la linea %d: Alguno de los tipos de los arrays es desconocido\n", numLinea);
}

//Error si no se pueden comparar dos tipos
void mensajeErrorComparacion(entradaTabla ts1, entradaTabla ts2){
	if (ts1.tipo != desconocido && ts2.tipo != desconocido )
		printf("Error semantico en la linea %d: No se pueden comparar los tipos %s y %s\n", 
										numLinea, 		toStringTipo(ts1.tipo), toStringTipo(ts2.tipo));
}

//Error cuando el argumento no es del tipo del parametro
void mensajeErrorTipoArgumento(char * nombre, int nParam, tipoDato tipo){
	printf("Error semantico en la linea %d: Se esperaba que el argumento %d de la funcion %s fuera de tipo %s\n", 
										numLinea, 		nParam, nombre, toStringTipo(tipo));
}

//Error cuando el tipo de dato no es el esperado
void mensajeErrorTipo(entradaTabla ts, tipoDato esperado){
	if (ts.tipo != desconocido && esperado != desconocido){
		if( ts.entrada == variable )
			printf("Error semantico en la linea %d: La variable %s no es de tipo %s\n", numLinea, ts.nombre, toStringTipo(esperado));
		else if( ts.entrada == funcion )
			printf("Error semantico en la linea %d: La funcion %s no devuelve valores de tipo %s\n", numLinea, ts.nombre,
						toStringTipo(esperado));
		else printf("Error semantico en la linea %d: La expresion %s no es de tipo %s\n", numLinea, ts.valor, toStringTipo(esperado));
	}
}

//Error cuando el tipo de dato no es el esperado
void mensajeErrorTipoArray(entradaTabla ts, tipoDato esperado){
	if ((ts.tipo == array1d || ts.tipo == array2d) && esperado != desconocido){
		if( ts.entrada == variable )
			printf("Error semantico en la linea %d: El array %s no es de tipo %s\n", numLinea, ts.nombre, toStringTipo(esperado));
		else if( ts.entrada == funcion )
			printf("Error semantico en la linea %d: La funcion %s no devuelve un array de tipo %s\n", numLinea, ts.nombre,
						toStringTipo(esperado));
		else printf("Error semantico en la linea %d: La expresion %s no es un array de tipo %s\n", numLinea, ts.valor, toStringTipo(esperado));
	}
}

//Error en las operaciones con tipos incompatibles
void mensajeErrorOperarTipos(entradaTabla ts1, entradaTabla ts2){
	if (ts1.tipo != desconocido && ts2.tipo != desconocido){
		if (ts1.tipo == array1d || ts1.tipo == array2d )
			printf("Error semantico en la linea %d: No se pueden operar los arrays de tipos %s de %s y %s\n", numLinea, 
						toStringTipo(ts1.tipo), toStringTipo(ts1.tipoArray), toStringTipo(ts2.tipo));
		else if (ts2.tipo == array1d || ts2.tipo == array2d)
			printf("Error semantico en la linea %d: No se pueden operar los arrays de tipos %s y %s de %s\n", numLinea, 
						toStringTipo(ts1.tipo), toStringTipo(ts2.tipo), toStringTipo(ts2.tipoArray));
		else printf("Error semantico en la linea %d: No se pueden operar los tipos %s (%s) y %s (%s)\n", numLinea, 
						toStringTipo(ts1.tipo), ts1.valor , toStringTipo(ts2.tipo), ts2.valor);
	}
}

//Error cuando el tamaño de los arrays operados no coincide
void mensajeErrorOperarTamano(entradaTabla ts1, entradaTabla ts2){
	if((ts1.tipo == array1d || ts1.tipo == array2d) && (ts2.tipo == array1d || ts2.tipo == array2d))
		printf("Error semantico en la linea %d: No se pueden operar los arrays de tamaños (%d, %d) y (%d, %d)\n", numLinea, 
						ts1.numfilas, ts1.numcolumnas, ts2.numfilas, ts2.numcolumnas);
	
}

//Error cuando el tamaño de los arrays operados no coincide
void mensajeErrorAsignarTamano(entradaTabla ts1, entradaTabla ts2){
	if((ts1.tipo == array1d || ts1.tipo == array2d) && (ts2.tipo == array1d || ts2.tipo == array2d))
		printf("Error semantico en la linea %d: No se pueden asignar los arrays de tamaños (%d, %d) y (%d, %d)\n", numLinea, 
						ts1.numfilas, ts1.numcolumnas, ts2.numfilas, ts2.numcolumnas);
	
}

//Error cuando el tamaño de los arrays operados no coincide
void mensajeErrorAccesoArray(entradaTabla ts1){
	if(ts1.tipo == array1d || ts1.tipo == array2d)
		printf("Error semantico en la linea %d: Intentando acceder a una posicion invalida del array %s\n", numLinea, ts1.nombre);
	
}

//Error cuando el tamaño de los arrays operados no coincide
void mensajeErrorNoSeEsperaArray(){
		printf("Error semantico en la linea %d: No se esperaba un array\n", numLinea);
	
}

//Error cuando se encuentra algo que no es una funcion
void mensajeErrorSeEsperabaFuncion(entradaTabla ts){
	if (ts.tipo != desconocido){
		printf("Error semantico en la linea %d: Se ha encontrado %s y se esperaba una funcion\n", numLinea, toStringEntrada(ts.entrada));
	}
}

//Error en el numero de parametros
void mensajeErrorNumParametros(entradaTabla ts1, entradaTabla ts2){
	if (ts1.tipo != desconocido && ts2.tipo != desconocido )
		printf("Error semantico en la linea %d: La %s %s esperaba %d argumentos y se han encontrado %d\n", 
				numLinea, toStringEntrada(ts1.entrada), ts1.nombre, ts1.parametros, ts2.parametros);
}

//Comprueba que un parametro es de un tipo determinado
bool comprobarParametro(char* nombre, int nParam, tipoDato dato) {
	if(debug) printf("comprobarParametro( %s, %d, %s )\n", nombre, nParam, toStringTipo(dato) );
	bool esIgual = FALSE;
	int index = buscarFuncion(nombre);
	int nArgs = getUltimaEntrada(nombre).parametros;
	if (nParam > nArgs) return TRUE;
	if(TS[index-nArgs+nParam-1].tipo == dato)
		esIgual = TRUE;
	return esIgual;
}

/* PRÁCTICA 5 */

int temp = -1;
int etiqueta = -1;

char* numTabs(){
	char* aux = (char*) malloc(50);
	sprintf(aux, "");
	for( int i=0; i<contBloques-contBloquesPrimeraFun; ++i )
		sprintf(aux, "%s\t", aux);
	tabs=aux;
	return aux;
}

char* tipoDeDato (tipoDato td) {
	if(td == entero)	return "int";
	if(td == booleano)	return "bool";
	if(td == real)		return "float";
	if(td == caracter)	return "char";
	if(td == array1d)	return "array1d";
	if(td == array2d)	return "array2d";
	return "Error de tipo";
}

char* generarTemp(tipoDato tipo){
	char* cadena = (char*) malloc(30);
	++temp;
	sprintf(cadena, "%s temp%d;\n%stemp%d", tipoDeDato(tipo), temp, numTabs(), temp);
	return cadena;
}

char* generarTemp2d(tipoDato tipo){
	char* cadena = (char*) malloc(30);
	++temp;
	sprintf(cadena, "%s temp%d", tipoDeDato(tipo), temp);
	return cadena;
}

char* getTemp(){
	char* cadena = (char*) malloc(30);
	sprintf(cadena, "temp%d", temp);
	return cadena;
}

char* generarTempArray(tipoDato tipo, tipoDato tipoArray){
	char* cadena = (char*) malloc(30);
	++temp;
	if(tipo == array1d)
		sprintf(cadena, "%s* temp%d = NULL;\n%stemp%d", tipoDeDato(tipoArray), temp, numTabs(), temp);
	else if(tipo == array2d)
		sprintf(cadena, "%s** temp%d = NULL;\n%stemp%d", tipoDeDato(tipoArray), temp, numTabs(), temp);
	return cadena;
}

char* generarEtiqueta() {
	char* cadena = (char*) malloc(20);
	++etiqueta;
	sprintf(cadena, "etiqueta%d", etiqueta);
	return cadena;
}

void generarFicheroFunciones() {
	file_fun = fopen("dec_fun.h", "w");
	fputs("#include<stdio.h>\n", file_fun);
	fputs("#include \"dec_dat.h\"\n\n", file_fun);
	fputs("typedef int bool;\n", file_fun);
}

void generarFichero() {
	file_std = fopen("codigoGenerado.c", "w");
	file = file_std;
	fputs("#include<stdio.h>\n", file);
	fputs("#include \"dec_fun.h\"\n", file);
	//fputs("#include \"dec_dat.h\"\n\n", file);
	fputs("typedef int bool;\n\n", file);
	generarFicheroFunciones();
}

void cerrarFichero() {
	fclose(file);
	fclose(file_fun);
}


void insertarParametros(char* nom, int numArgumentos){
	int index;

	for(int i=numArgumentos; i>0; --i) {
		if(i!=numArgumentos)
			fputs(",",file);
		index = buscarFuncion(nom);
		char* nombre = TS[index-i].nombre;
		char* midato = tipoDeDato(TS[index-i].tipo);
		char* sent;
		sent = (char*) malloc(200);;
		sprintf(sent, "%s %s", midato, nombre);
		fputs(sent, file);
	}
}

/*
void insertarSubprog(char* nom, tipoDato dato, int numArgumentos){
	char* sent;
	sent = (char*) malloc(200);
	sprintf(sent,"%s %s (", tipoDeDato(dato), nom);
	fputs(sent, file);
	insertarParametros(nom, numArgumentos);
	fputs(")", file);
}


void insertarVariables(tipoDato dato){
	int i;
	bool fin = false;
	bool coma = false;
	char* sent;
	sent = (char*) malloc(200);
	sprintf(sent, "%s%s ", tabs, tipoDeDato(dato));

	for(i=0; i<TOPE && fin==false; ++i){
		if(TS[TOPE-1-i].entrada == 3 && TS[TOPE-1-i].tipoDato == dato){
			if(coma) sprintf(sent,"%s,",sent);
			sprintf(sent, "%s %s", sent, TS[TOPE-1-i].nombre);
			coma = true;
		}
		else{
			fin=true;
		}
	}

	sprintf(sent, "%s;\n", sent);
	fputs(sent, file);
}

*/

void insertarAsignacion(char* nom, char* valor) {
	char* sent = (char*) malloc(200);
	sprintf(sent, "%s%s = %s;\n", tabs, nom, valor);
	fputs(sent, file);
}


void insertarAsignacionArrays(char* nom, char* valor, tipoDato tipoArray, int numcol) {
	char* sent = (char*) malloc(200);
	sprintf(sent, "%smemcpy(%s, %s, sizeof(%s)*%d);\n", tabs, nom, valor, tipoDeDato(tipoArray), numcol);
	fputs(sent, file);
}

void insertarAsignacionArrays2d(char* nom, char* valor, tipoDato tipoArray, int numfil, int numcol) {
	char* sent = (char*) malloc(200);
	sprintf(sent, "%smemcpy(%s, %s, sizeof(%s)*%d*%d);\n", tabs, nom, valor, tipoDeDato(tipoArray), numfil, numcol);
	fputs(sent, file);
}

void insertarCadena(char* cad){
	fputs(cad, file);
}

char tipoAFormato(tipoDato dato) {
	if(dato == desconocido)		return 's';
	else if(dato == real)		return 'f';
	else if(dato == entero)		return 'd';
	else if(dato == caracter)	return 'c';
	else if(dato == cadena )	return 's';
	else if(dato == booleano)	return 'd';
	else 						return 'l';
}

char* tipoAPuntero(tipoDato dato){
	if(dato == desconocido)		return " s";
	else if(dato == real)		return " &";
	else if(dato == entero)		return " &";
	else if(dato == caracter)	return " &";
	else if(dato == cadena )	return " ";
	else if(dato == booleano)	return " &";
	else 						return " ";
}


