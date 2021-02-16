#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {desconocido, entero, real, caracter, booleano, cadena} tipo ;

int* sumInt1d(int* ar1, int* ar2, int longitud){
	if (ar1 == NULL || ar2 == NULL || sizeof(ar1)==0)
		return NULL;
	int* aux= (int*) malloc(longitud);
	for(int i=0; i< longitud; i++){
		aux[i] = ar1[i] + ar2[i];
	}
	return aux;
}

int* resInt1d(int* ar1, int* ar2, int longitud){
	if (ar1 == NULL || ar2 == NULL || sizeof(ar1)==0)
		return NULL;
	
	int* aux= (int*) malloc(longitud);
	for(int i=0; i< longitud; i++){
		aux[i] = ar1[i] - ar2[i];
	}
	return aux;
}

int* mulInt1d(int* ar1, int* ar2, int longitud){
	if (ar1 == NULL || ar2 == NULL || sizeof(ar1)==0)
		return NULL;
	
	int* aux= (int*) malloc(longitud);
	for(int i=0; i< longitud; i++){
		aux[i] = ar1[i] * ar2[i];
	}
	return aux;
}

int* divInt1d(int* ar1, int* ar2, int longitud){
	if (ar1 == NULL || ar2 == NULL || sizeof(ar1)==0)
		return NULL;
	
	int* aux= (int*) malloc(longitud);
	for(int i=0; i< longitud; i++){
		if(ar2[i]!=0)
			aux[i] = ar1[i] / ar2[i];
		else 
			return NULL;
	}
	return aux;
}

int* productoExternoInt1d(int numero, int* ar2, int longitud){
	if (ar2 == NULL || sizeof(ar2)==0)
		return NULL;
	
	int* aux= (int*) malloc(longitud);
	for(int i=0; i< longitud; i++){
		aux[i] = numero * ar2[i];
	}
	return aux;
}

void productoExternoInt2d(int a, int b[], int result[], int dim1,int dim2){
  for (int i = 0; i < dim1; ++i)
    for (int j = 0; j < dim2; ++j)
      result[i*dim2+j]= a*b[i*dim2+j];
}

void productoMatricialInt(int a[],int b[], int result[], int dimA1,int dimA2B1, int dimB2){
  for (int i = 0; i < dimA1; ++i)
    for (int j = 0; j < dimB2; ++j)
      result[i*dimB2+j]= 0;

  for (int k=0;k < dimA1;++k)
    for (int i = 0; i < dimA2B1; ++i)
      for (int j = 0; j < dimB2; ++j)
        result[k*dimB2+j]+= a[k*dimA2B1+i]*b[i*dimB2+j];

}

void sumInt2d(int a[], int b[], int result[], int dim1,int dim2){
  for (int i = 0; i < dim1; ++i)
    for (int j = 0; j < dim2; ++j)
      result[i*dim2+j]= a[i*dim2+j]+b[i*dim2+j];
}

void resInt2d(int a[], int b[], int result[], int dim1,int dim2){
  for (int i = 0; i < dim1; ++i)
    for (int j = 0; j < dim2; ++j)
      result[i*dim2+j]= a[i*dim2+j]-b[i*dim2+j];
}

void mulInt2d(int a[], int b[], int result[], int dim1,int dim2){
  for (int i = 0; i < dim1; ++i)
    for (int j = 0; j < dim2; ++j)
      result[i*dim2+j]= a[i*dim2+j]*b[i*dim2+j];
}
void divInt2d(int a[], int b[], int result[], int dim){
  for (int i = 0; i < dim; ++i){
    result[i]= a[i]/b[i];
	}
}

/////Para float

float* sumFloat1d(float* ar1, float* ar2, int longitud){
	if (ar1 == NULL || ar2 == NULL || sizeof(ar1)==0)
		return NULL;
	
	float* aux= (float*) malloc(longitud);
	for(int i=0; i< longitud; i++){
		aux[i] = ar1[i] + ar2[i];
	}
	return aux;
}

float* resFloat1d(float* ar1, float* ar2, int longitud){
	if (ar1 == NULL || ar2 == NULL || sizeof(ar1)==0)
		return NULL;
	
	float* aux= (float*) malloc(longitud);
	for(int i=0; i< longitud; i++){
		aux[i] = ar1[i] - ar2[i];
	}
	return aux;
}

float* mulFloat1d(float* ar1, float* ar2, int longitud){
	if (ar1 == NULL || ar2 == NULL || sizeof(ar1)==0)
		return NULL;
	
	float* aux= (float*) malloc(longitud);
	for(int i=0; i< longitud; i++){
		aux[i] = ar1[i] * ar2[i];
	}
	return aux;
}

float* divFloat1d(float* ar1, float* ar2, int longitud){
	if (ar1 == NULL || ar2 == NULL || sizeof(ar1)==0)
		return NULL;
	
	float* aux= (float*) malloc(longitud);
	for(int i=0; i< longitud; i++){
		if(ar2[i]!=0)
			aux[i] = ar1[i] / ar2[i];
		else 
			return NULL;
	}
	return aux;
}

float* productoExternoFloat1d(float numero, float* ar2, int longitud){
	if (ar2 == NULL || sizeof(ar2)==0)
		return NULL;
	
	float* aux= (float*) malloc(longitud);
	for(int i=0; i< longitud; i++){
		aux[i] = numero * ar2[i];
	}
	return aux;
}

void productoMatricialFloat(float a[],float b[], float result[], int dimA1,int dimA2B1, int dimB2){
  for (int i = 0; i < dimA1; ++i)
    for (int j = 0; j < dimB2; ++j)
      result[i*dimB2+j]= 0;

  for (int k=0;k < dimA1;++k)
    for (int i = 0; i < dimA2B1; ++i)
      for (int j = 0; j < dimB2; ++j)
        result[k*dimB2+j]+= a[k*dimA2B1+i]*b[i*dimB2+j];

}

void productoExternoFloat2d(float a, float b[], int result[], int dim1,int dim2){
  for (int i = 0; i < dim1; ++i)
    for (int j = 0; j < dim2; ++j)
      result[i*dim2+j]= a*b[i*dim2+j];
}

void sumFloat2d(float a[], float b[], float result[], int dim1,int dim2){
  for (int i = 0; i < dim1; ++i)
    for (int j = 0; j < dim2; ++j)
      result[i*dim2+j]= a[i*dim2+j]+b[i*dim2+j];
}

void resFloat2d(float a[], float b[], float result[], int dim1,int dim2){
  for (int i = 0; i < dim1; ++i)
    for (int j = 0; j < dim2; ++j)
      result[i*dim2+j]= a[i*dim2+j]-b[i*dim2+j];
}

void mulFloat2d(float a[], float b[], float result[], int dim1,int dim2){
  for (int i = 0; i < dim1; ++i)
    for (int j = 0; j < dim2; ++j)
      result[i*dim2+j]= a[i*dim2+j]*b[i*dim2+j];
}

void divFloat2d(float a[], float b[], float result[], int dim1,int dim2){
  for (int i = 0; i < dim1; ++i)
    for (int j = 0; j < dim2; ++j)
      result[i*dim2+j]= a[i*dim2+j]/b[i*dim2+j];
}
