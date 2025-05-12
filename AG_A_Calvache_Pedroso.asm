#####################################################################
#
# Proyecto de Arquitecturas Gráficas - URJC
#
# Autores:
# - Calvache Amador, Carla
# - Pedroso Praena, Ruben
#
# Bitmap Display:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 128
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Máximo objetivo alcanzado en el proyecto:
# - Juego base + 3 ampliaciones
#
# Ampliaciones implementadas:
# - 6 (Modo multijugador completo)
#
# Instrucciones del juego:
# - Jugador 1 (amarillo): "a" izquierda "d" dereha
# - Jugador 2 (rosa): "j" izquierda "l" dereha
# - Evita que la pelota entre en tu portería
#
#####################################################################

.data
# Mensajes del juego
frase_inicio:    .asciiz "Quieres comenzar el juego?"
victoria1:       .asciiz "Jugador 1 gana con 3 goles!"
victoria2:       .asciiz "Jugador 2 gana con 3 goles!"

# Colores
color_fondo:     .word 0x3d9f08 #para el campo (verde)
color_bordes:    .word 0xFFFFFF #para los bordes de gol
color_j1:        .word 0xFFC000   #para la barra de j1
color_j2:        .word 0xFF00FF   #para la barra de j2
color_pelota:    .word 0x000000  #para la pelota

# Configuración del juego
ancho_pantalla:  .word 256
alto_pantalla:   .word 512
displayAddress:  .word 0x10008000

# Posiciones y estados
pos_j1:          .word 16           # Posición Y pala jugador 1
pos_j2:          .word 16           # Posición Y pala jugador 2
pos_pelota_x:    .word 16        # Posición X pelota
pos_pelota_y:    .word 32       # Posición Y pelota
velocidad_x:     .word 1
velocidad_y:     .word 1		#el juego empieza con la pelota para j1
tam_pala:        .word 5        # Tamaño de las palas
tam_pelota:      .word 1         # Tamaño de la pelota

.text
main:
	# Mostrar menu de inicio
	#li	$v0,50
	#la	$a0, frase_inicio
	#syscall				# Ensena la frase junto a unas opciones

	#beq	$a0, $zero, init_game	# Si le da a si, se inicia el juego
	#li	$v0, 10			# Si no, no se ejecuta
	#syscall

init_game:
	# Dibujar fondo
	jal draw_background

update:
	li	$v0, 32
	li	$a0, 48
	syscall

	jal movimiento_j1
	jal movimiento_pelota
	
	jal draw_top
	jal j1
	jal j2
	jal pelota
	
	b update

draw_background:
    # Cargar direccion base del display en $t0
    lw   $t0, displayAddress      # $t0 = base address del display (0x10008000)
    la   $t1, color_fondo         # Cargar dirección de color_fondo
    lw   $t2, 0($t1)              # $t2 = valor del color verde

    li   $t3, 2048           # Numero total de bloques a pintar

draw_loop:
    
    sw   $t2, 0($t0)              # Pintar el bloque con el color de fondo
    addi $t0, $t0, 4              # Avanzar a la siguiente direccion de palabra
    subi $t3, $t3, 1              # Decrementar contador
    bgtz $t3, draw_loop           # Si quedan bloques, repetir
    
    jr   $ra                      # Volver de la subrutina
    
    
# Subrutina para dibujar la linea superior e inferior (bordes blancos)
draw_top:
    # Cargar dirección base del display en $t0
    lw   $t0, displayAddress      # Base address del display
    la   $t1, color_bordes        # Direccion del color de bordes
    lw   $t2, 0($t1)              # $t2

    li   $t3, 32                # 16 bloques por fila (256px / 8px = 32 bloques)

    # Dibujar linea superior (en la fila 0)
draw_loop_top:
    
    sw   $t2, 0($t0)              # Pintar el bloque superior
    addi $t0, $t0, 4              # Avanzar a la siguiente direccion
    subi $t3, $t3, 1              # Decrementar contador
    bgtz $t3, draw_loop_top       # Repetir hasta pintar 16 bloques (una fila)
    
    # Ahora pintar la linea inferior
    # La pantalla tiene 32 filas (256 pixeles alto / 8)
    # Asi que ultima fila empieza en: base + (31 * 16 * 4) bytes
    lw   $t0, displayAddress      # Volver a cargar base
    li   $t4, 63                  # fila 31
    li   $t5, 32                  # 16 bloques por fila
    mul  $t4, $t4, $t5            # t4 = 31 * 16
    sll  $t4, $t4, 2              # multiplicar por 4 (tamano de palabra)
    add  $t0, $t0, $t4            # direccion de inicio de ultima fila

    li   $t3, 32                  # Numero total de bloques por fila (16 bloques)

draw_loop_bottom:
    sw   $t2, 0($t0)              # Pintar el bloque con el color de bordes (blanco)
    addi $t0, $t0, 4              # Avanzar a la siguiente direccion de palabra
    subi $t3, $t3, 1              # Decrementar contador
    bgtz $t3, draw_loop_bottom    # Si quedan bloques, repetir
    jr   $ra                      # Volver

j1: 
    lw   $t0, displayAddress      # Volver a cargar base
    li   $t4, 58   		     # distancia de 5px para j1
    mul  $t4, $t4, 32            
    lw   $t5, pos_j1
    add  $t4, $t5, $t4
    sub  $t4, $t4, 4              #se resta 3 paar centrar
    mul  $t4, $t4, 4              # x4 para pasarlo a bytes 
    add $t0, $t0, $t4
    
    lw   $t2, color_fondo
    sw   $t2, 0($t0)              # Pintar el j1
    addi $t0, $t0, 4
    
    lw   $t2, color_j1
    li   $t3, 7
    
draw_loop_j1:
    sw   $t2, 0($t0)              # Pintar el j1
    addi $t0, $t0, 4              # Avanzar a la siguiente direccion de palabra
    subi $t3, $t3, 1              # Decrementar contador
    bgtz $t3, draw_loop_j1        # Si quedan bloques, repetir
    
    lw   $t2, color_fondo
    sw   $t2, 0($t0)              # Pintar el j1
    
    jr   $ra
    
    
j2: 
    lw   $t0, displayAddress      # Volver a cargar base
    li   $t4, 5   		     # distancia de 5px para j1
    mul  $t4, $t4, 32            
    lw   $t5, pos_j2
    add  $t4, $t5, $t4
    sub  $t4, $t4, 4              #se resta 3 para centrar
    mul  $t4, $t4, 4              # x4 para pasarlo a bytes 
    add $t0, $t0, $t4
    
    lw   $t2, color_fondo
    sw   $t2, 0($t0)              # Pintar el j1
    addi $t0, $t0, 4
    
    lw   $t2, color_j2
    li   $t3, 7
    
draw_loop_j2:
    sw   $t2, 0($t0)              # Pintar el j1
    addi $t0, $t0, 4              # Avanzar a la siguiente direccion de palabra
    subi $t3, $t3, 1              # Decrementar contador
    bgtz $t3, draw_loop_j2        # Si quedan bloques, repetir
    
    lw   $t2, color_fondo
    sw   $t2, 0($t0)
    
    jr   $ra
    
pelota: 
    lw   $t0, displayAddress
    lw   $t4, pos_pelota_y   		     # distancia de 5px para j1
    subi $t4, $t4, 1
    mul  $t4, $t4, 32            
    lw   $t5, pos_pelota_x
    subi  $t5, $t5, 1
    add  $t4, $t4, $t5
    mul  $t4, $t4, 4              # x4 para pasarlo a bytes 
    add  $t0, $t0, $t4
    
    lw $t1, color_fondo
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    sw $t1, 0($t0)
    addi $t0, $t0, 120
    
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    lw $t1, color_pelota
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    lw $t1, color_fondo
    sw $t1, 0($t0)
    addi $t0, $t0, 120
    
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    sw $t1, 0($t0)
    
    jr   $ra

movimiento_j1: 
	lw	$t0,0xFFFF0000
	lw	$t1,0xFFFF0004
	
	# A
	if_A:
	#hacemos que si no hay ninguna tecla pulsada en este frame se va al end
	beqz $t0, end_A
	bne  $t1, 97, end_A

	lw   $t2, pos_j1
	la   $t3, pos_j1
	beq  $t2, 3, end_A
	
	then_A:
	subi  $t2, $t2, 1
	sw    $t2, 0($t3)
	end_A:
	
	# D
	if_D:
	#hacemos que si no hay ninguna tecla pulsada en este frame se va al end
	beqz $t0, end_D
	bne  $t1, 100, end_D

	lw   $t2, pos_j1
	la   $t3, pos_j1
	beq  $t2, 28, end_D
	
	then_D:
	addi  $t2, $t2, 1
	sw    $t2, 0($t3)
	end_D:

movimiento_j2: 

	# J
	if_J:
	#hacemos que si no hay ninguna tecla pulsada en este frame se va al end
	beqz $t0, end_J
	bne  $t1, 106, end_J

	lw   $t2, pos_j2
	la   $t3, pos_j2
	beq  $t2, 3, end_J
	
	then_J:
	subi  $t2, $t2, 1
	sw    $t2, 0($t3)
	end_J:
	
	# L
	if_L:
	#hacemos que si no hay ninguna tecla pulsada en este frame se va al end
	beqz $t0, end_L
	bne  $t1, 108, end_L

	lw   $t2, pos_j2
	la   $t3, pos_j2
	beq  $t2, 28, end_L
	
	then_L:
	addi  $t2, $t2, 1
	sw    $t2, 0($t3)
	end_L:
   	  
   	jr $ra
   	  
movimiento_pelota:
	lw $t0, pos_pelota_x
	lw $t1, pos_pelota_y
	lw $t2, velocidad_x
	lw $t3, velocidad_y
	add $t0, $t0, $t2
	add $t1, $t1, $t3
	
	
	
	if_p_reb_bordes:
	blez $t0, then_p_reb_bordes
	bge $t0, 31, then_p_reb_bordes
	b end_p_reb_bordes
	
	then_p_reb_bordes:
	neg $t2, $t2
	la  $t4, velocidad_x
	sw  $t2, 0($t4)
	
	end_p_reb_bordes:
	
	
	
	if_p_reb_abj:
	bge $t1, 63, then_p_reb_abj
	b end_p_reb_abj
	
	then_p_reb_abj:
	li $t2, 0
	neg $t3, $t3
	la  $t4, velocidad_x
	la  $t5, velocidad_y
	sw  $t2, 0($t4)
	sw  $t3, 0($t5)
	
	li $t0, 16
	li $t1, 32
	end_p_reb_abj:
	
	
	
	
	
	if_p_reb_arr:
	blez $t1, then_p_reb_arr
	b end_p_reb_arr
	
	then_p_reb_arr:
	li $t2, 0
	neg $t3, $t3
	la  $t4, velocidad_x
	la  $t5, velocidad_y
	sw  $t2, 0($t4)
	sw  $t3, 0($t5)
	
	li $t0, 16
	li $t1, 32
	end_p_reb_arr:
   
   
   	la $t4, pos_pelota_x
	sw $t0, 0($t4)
	la $t4, pos_pelota_y
	sw $t1, 0($t4)
   
   
   	jr $ra


col_j:
	
	if_col:
	lw $t0, pos_pelota_y
	
	beq $t0, 58, then_col
	beq $t0, 59, then_col
	b end_col
	then_col:
	
	lw $t0, pos_pelota_x
	lw $t1, pos_j1
	sub $t2, $t0, $t1
	
	beqz $t2, coll_dist0
	blt $t2, -3, end_col
	bgt $t2, 3, end_col
	b coll_dist
	
	coll_dist0:
	lw $t0, velocidad_y
	neg $t0, $t0
	la $t1, velocidad_y
	sw $t0, 0($t1)
	la $t1, velocidad_x
	li $t2, 0
	sw $t2, 0($t1)
	
	b end_col
	
	coll_dist:
	lw $t0, velocidad_y
	neg $t0, $t0
	la $t1, velocidad_y
	sw $t0, 0($t1)
	
	coll_dist_dir:
	bltz $t2, coll_dist_dir_l
	b coll_dist_dir_r
	coll_dist_dir_l:
	li $t2, -1
	b coll_dist_dir_end
	coll_dist_dir_r:
	li $t2, 1
	coll_dist_dir_end:
	
	la $t1, velocidad_x
	sw $t2, 0($t1)
	
	end_col: 
	
	jr $ra
