# Ejercicio 1 – Direccionamiento y condiciones if-else
# Práctica realizada por Carla Calvache y Rubén Pedroso

#Código a traducir:

#int main()
#{
 #int A=15; // Cambiar los valores de A, B y C para comprobar
 #int B=10; // que entra en las distintas condiciones if-else
 #int C=5;
 #int D=2;
 #int Z=0;
 #if((A > B) || ((C+1) == 7)){
 #Z = Z - 3;
 #}
 #else if((A < B) && (C > 5)){
 #Z = 2;
 #}
 #else{
 #Z = (A-B) * (C+D) - (A/C);
 #}
 #return 0;
#}

	.data
A: 	.word 15
B: 	.word 10
C: 	.word 5
D: 	.word 2
Z: 	.word 0
	.text
	lw $t0, A      # A -> $t0
 	lw $t1, B      # B -> $t1
	lw $t2, C      # C -> $t2
	lw $t3, D      # D -> $t3
	lw $t4, Z      # Z -> $t4

main:
    	# Cargar valores de memoria en registros
    	lw $t0, A      # $t0 = A
    	lw $t1, B      # $t1 = B
    	lw $t2, C      # $t2 = C
   	lw $t3, D      # $t3 = D
   	lw $t4, Z      # $t4 = Z 

  	# if ((A > B) || ((C + 1) == 7))
  	# Evaluamos A > B usando BLE (menor o igual)
   	ble $t0, $t1, segunda  # Si A <= B, no se cumple la primera condición, así que revisamos la segunda
   	j if                            # Si A > B, cumplimos la condición, saltamos al bloque IF directamente

segunda:
  	# Segunda parte: (C + 1 == 7)
   	addi $t5, $t2, 1      # $t5 = C + 1
   	li $t6, 7             # Cargar 7 en $t6
    	bne $t5, $t6, else_if  # (utilizamos bne: distinto) Si C + 1 != 7, no se cumple, vamos al else if
   	j if                    # Si C + 1 == 7, condición cumplida, vamos al bloque IF

if:
   	# Ejecutamos: Z = Z - 3
   	lw $t4, Z
    	addi $t4, $t4, -3
    	sw $t4, Z
   	j end_if     #saltamos al final del if-else para NO ejecutar los otros bloques

# Else if: (A < B) && (C > 5)
else_if:
   	bge $t0, $t1, else    # (utilizamos bge: mayor o igual) Si A >= B, no se cumple (A < B es falso), salta al else
    	li $t7, 5
    	ble $t2, $t7, else    # (utilizamos ble: menor o igual)Si C <= 5, no se cumple (C > 5 es falso), salta al else

   	# Si llegamos aquí, ambas condiciones se cumplen
    	li $t4, 2                   # Z = 2
    	sw $t4, Z
    	j end_if                   # Saltamos al final para no ejecutar el else

# Else: ninguna condición se cumplió
else:
   	# Z = (A - B) * (C + D) - (A / C)

   	sub $t5, $t0, $t1    # $t5 = A - B
   	add $t6, $t2, $t3    # $t6 = C + D
    	mult $t5, $t6
   	mflo $t7             # $t7 = (A - B) * (C + D)

   	div $t0, $t2         # A / C
    	mflo $t8             # $t8 = resultado de división

    	sub $t4, $t7, $t8    # $t4 = (A - B)*(C + D) - (A / C)
    	sw $t4, Z

# Final del IF-ELSE
end_if:
    	li $v0, 17      # código para salir del programa
    	li $a0, 0       # return 0
    	syscall
