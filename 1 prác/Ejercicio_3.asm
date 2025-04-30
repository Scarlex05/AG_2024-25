#Ejercicio 3 – Cadenas de caracteres y entrada/salida 
# Practica realizada por Carla Calvache y Ruben Pedroso

#Codigo a traducir:
#int main() 
#{ 
#char cadena[10]; 
#int i=0; 
#char *result = NULL; // En binario, NULL es cero 
#Leemos una cadena introducida por el usuario 
#printf("Introduzca una cadena: "); 
#scanf("%s", cadena); 
#Buscamos en la cadena la letra 'm'. 
#El resultado será un puntero a la primera m que haya 
#o NULL si no hay 
#while(cadena[i] != '\0') { 
#if(cadena[i] == 'm') { 
#result = &cadena[i];  
#break; // Dejamos de buscar al encontrar la primera m 
#} 
#i++; 
#} 
#if(result != NULL) 
#printf("La primera m está en la dirección %d\n", result); 
#else 
#printf("La cadena no contiene la letra m\n"); 
#return 0; 
#}


	.data
cadena:.space 10                # Espacio para 10 caracteres
result:.word 0                  # Espacio para guardar el puntero result
tira1: .asciiz "Introduzca una cadena: "
tira2: .asciiz "La primera m está en la dirección "
tira3: .asciiz "La cadena no contiene la letra m\n"

	.text

main:
    li $t0, 0  # i = 0

    # printf
    li $v0, 4
    la $a0, tira1
    syscall

    # scanf("%s", cadena);
    la $a0, cadena   # Dirección donde guardar la cadena
    li $a1, 10   # Longitud máxima
    li $v0, 8
    syscall

while_loop:
    add $t1, $t0, $zero  # t1 = i
    la $t3, cadena
    add $t4, $t3, $t1     # Dirección cadena[i]
    lb  $t2, 0($t4)   # cargar cadena[i] en t2

    beq $t2, $zero, while_end  # Si cadena[i] == '\0', salir del bucle

    li $t5, 'm'    # Cargar el carácter 'm'
    beq $t2, $t5, if_while  # Si es 'm', ir al if

    addi $t0, $t0, 1   # i++
    j while_loop  # repetir el bucle

if_while:
    # Guardar dirección de cadena[i] en result
    sw $t4, result

    j while_end  # Salir del bucle

while_end:
    lw $t6, result  # Cargar result
    beq $t6, $zero, else    # Si result == NULL (0), ir al else

    # printf("La primera m está en la dirección ");
    li $v0, 4
    la $a0, tira2
    syscall

    # printf dirección (entero)
    move $a0, $t6
    li $v0, 1
    syscall
    j fin

else:
    # printf("La cadena no contiene la letra m\n");
    li $v0, 4
    la $a0, tira3
    syscall

fin:
    li $v0, 10  # Salir del programa
    syscall

	
	
	


