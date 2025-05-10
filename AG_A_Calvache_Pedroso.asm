#####################################################################
#
# Proyecto de Arquitecturas Gr谩ficas - URJC
#
# Autores:
# - Calvache Amador, Carla
# - Pedroso Praena, Rub閚
#
# Bitmap Display:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 128
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# M谩ximo objetivo alcanzado en el proyecto:
# - Juego base + 3 ampliaciones
#
# Ampliaciones implementadas:
# - 6 (Modo multijugador completo)
#
# Instrucciones del juego:
# - Jugador 1 (izquierda): teclas 'w' (arriba) y 's' (abajo)
# - Jugador 2 (derecha): teclas 'o' (arriba) y 'l' (abajo)
# - Evita que la pelota entre en tu porter铆a
# - El primero en alcanzar 3 goles gana
#
#####################################################################

.data
# Mensajes del juego
frase_inicio:    .asciiz "縌uieres comenzar el juego?"
victoria1:       .asciiz "ugador 1 gana con 3 goles!"
victoria2:       .asciiz "ugador 2 gana con 3 goles!"

# Colores
color_fondo:     .word 0x3d9f08 #para el campo (verde)
color_bordes:    .word 0xFFFFFF #para los bordes de gol
color_j1:      .word 0xFF0000   #para la barra de j1
color_j2:      .word 0x0000FF   #para la barra de j2
color_bola:     .word 0x000000  #para la pelota

# Configuraci贸n del juego
ancho_pantalla:  .word 256
alto_pantalla:   .word 512
displayAddress:    .word 0x10008000

# Posiciones y estados
pos_pala1:       .word 50        # Posici贸n Y pala jugador 1
pos_pala2:       .word 50        # Posici贸n Y pala jugador 2
pos_pelota_x:    .word 64        # Posici贸n X pelota
pos_pelota_y:    .word 128       # Posici贸n Y pelota
goles_j1:        .word 0         # Goles jugador 1
goles_j2:        .word 0         # Goles jugador 2
tam_pala:        .word 20        # Tama帽o de las palas
tam_pelota:      .word 3         # Tama帽o de la pelota

.text
main:
	# Mostrar menu de inicio
	li	$v0,50
	la	$a0, frase_inicio
	syscall				# Ensena la frase junto a unas opciones

	beq	$a0, $zero, init_game	# Si le da a si, se inicia el juego
	li	$v0, 10			# Si no, no se ejecuta
	syscall

init_game:
	# Dibujar fondo
	jal draw_background
	jal draw_top
	li	$v0, 10			# Si no, no se ejecuta
	syscall
	
	

draw_background:
    # Cargar direccion base del display en $t0
    lw   $t0, displayAddress      # $t0 = base address del display (0x10008000)
    la   $t1, color_fondo         # Cargar direcci贸n de color_fondo
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
    # Cargar direcci贸n base del display en $t0
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
    li   $t5, 32                 # 16 bloques por fila
    mul  $t4, $t4, $t5            # t4 = 31 * 16
    sll  $t4, $t4, 2              # multiplicar por 4 (tama駉 de palabra)
    add  $t0, $t0, $t4            # direccion de inicio de ultima fila

    li   $t3, 32                  # Numero total de bloques por fila (16 bloques)

draw_loop_bottom:
    sw   $t2, 0($t0)              # Pintar el bloque con el color de bordes (blanco)
    addi $t0, $t0, 4              # Avanzar a la siguiente direccion de palabra
    subi $t3, $t3, 1              # Decrementar contador
    bgtz $t3, draw_loop_bottom    # Si quedan bloques, repetir
    jr   $ra                      # Volver
