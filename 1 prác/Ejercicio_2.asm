# Ejercicio 2 - Vectores y Bucles
# Práctica realizada por Carla Calvache y Rubén Pedroso

# Código a traducir:

#  int main(){
#       int A[5]; //Región de la memoria para almacenar 5 elemenos
#       int B[6] = {0,1,2,3,4,5};
#       int i;
#
#	for(i=0; i<5; i++){
#		A[i] = B[i] + B[i+1];
#	}
#
#	i--;
#	while(i >= 0){
#		A[i] = A[i] * 2;
#		i--;
#	}
#	return 0;
#  }

.data
	A: .space 20 # Creamos el array A[5]
	B: .word 0,1,2,3,4,5 # Creamo el array B[6], con los valores B[0] = 0, B[1] = 1, B[2] = 2, B[3] = 3, B[4] = 4, B[5] = 5
	# la viariable int i no sera necesario crearla de inicio, dado a que solo funcionaba de iterador, y para ello podemos usar $t0 directamente en lugar de cargar, sumar y guardar cada vez

.text

main: # Aquí empeza la funcion main
	li $t0, 0  # Guardamos el valor 0 en $t0, y este será<el que usaremos como i.

for_loop: # Aquí empieza el bucle for
	bge $t0, 5, for_end # Esto sirve como condicional para dectecar si $t0 es mayor o igual que cinco, y en caso de ser true, sale del bucle

	# Cargamos B[i], o en este caso, B[$t0]
	la $t2, B # Ponemos $t2 como dirección base de B.
	sll $t3, $t0, 2 # Nos desplazamos en bytes hasta la posición del array correspondiente
	add $t4, $t2, $t3 # Obtenemos el valor de B[i] y lo guardamos en $t4
	lw $t1, 0($t4) # Cargamos en $t1 el valor de B[i]
	
	# Cargamos B[i+1], o en este caso, B[$t0+1]
	addi $t3, $t3, 4 # Nos movemos al byte siguiente, para pasar de B[i] a B[i+1]
	add $t4, $t2, $t3 # Obtenemos el valor de B[i+1] y lo guardamos en $t4
	lw $t5, 0($t4) # Cargamos en $t5 el valor de B[i+1]

	add $t6, $t1, $t5 # Aquí sumamos ambos valores (B[i) y B[i+1])

	# Guardamos A[i] con el valor de B[i] + B[i+1]
	la $t7, A # Ponemos $t7 como dirección base de A.
	sll $t3, $t0, 2 # Nos desplazamos en bytes hasta la posición del array correspondiente
	add $t8, $t7, $t3 # Ponemos $t8 como la direccion de A[i]
	sw $t6, 0($t8) # Guardamos en A[i] el valor de B[i] + B[i+1]

	# Aquí hacemos que se repita el bucle de nuevo
	addi $t0, $t0, 1 # Le sumamos 1 al valor de $t0
	j for_loop # Llama de nuevo a la funcion del bucle for
	
for_end:
	addi $t0, $t0, -1 # Cuando se termine el bucle for, le restamos uno a $t0
	

while_loop: # Aquí empieza el bucle while
	bltz $t0, while_end #Condicion para salir del bucle que detecta si $t0 es menor a 0.
	
	# Aquí cargamos el valor de A[i]
	la $t7, A # Establecemos $t7 como dirección base de A
	sll $t3, $t0, 2 # Nos desplazamos en bytes hasta la posición del array correspondiente
	add $t8, $t7, $t3 # Obtenemos el valor de A[i], y lo guardamos es $t8
	lw $t9, 0($t8) # Cargamos en $t9 el valor de A[i]
	
	sll $t9, $t9, 1 # Multiplicamos A[i] * 2
	
	sw $t9, 0($t8) # Guardamos en A[i] el valor de A[i] * 2
	
	# Aquí hacemos que se repita el bucle de nuevo
	addi $t0, $t0, -1 # Le restamos 1 a $t0
	j while_loop # Llamamos de nuevo a la función del bucle while

while_end:
	li $v0, 10
	syscall # Cuando se termina el bucle while, todos los valores ya están guardados correctamente, y hacemos que el porgrama termine de ejecutarse.
