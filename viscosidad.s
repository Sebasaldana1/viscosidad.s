Suma_vect:  ! w = u + v
% i0  ! # de elementos del vector 
% i1  ! dirección de memoria del vector u
% i2  ! dirección de memoria del vector v
% i3  ! dirección de memoria del resultado w

Escala_vect:  ! w = k * u
% i0  ! # de elementos del vector 
% i1  ! dirección de memoria del vector u
% i2  ! escalar k
% i3  ! dirección de memoria del vector w

Vector_sobre_escalar:  ! w = u / k
% i0  ! # de elementos del vector 
% i1  ! dirección de memoria del vector u
% i2  ! escalar k
% i3  ! dirección de memoria del vector w

Acumula_pasos:
% i0  ! # de elementos de los vectores
% i1  ! dirección memoria Pos_i
% i2  ! dirección memoria V_i
% i3  ! escalar Kv
% i4  ! escalar paso
% i5  ! escalar t
% o0  ! # de elementos de vector
% o1  ! # de vectores retornados
% o2  ! dirección de memoria de la lista de posiciones

    Sub %g0, %i3, %i3   ! kv negativo
    Mov %i1, %l1        ! Copiar Pos_i en %l1
    Mov %i2, %l2        ! Copiar V_i en %l2
    Mov %i4, %l0        ! Inicializar contador de pasos

Ciclo:
    Subcc %l0, 1, %l0   ! Decrementar pasos
    Be Fin              ! Si pasos == 0, salir
    Nop

    ! Calcular la fuerza de viscosidad: F = -kv * V
    Mov %l2, %i1        ! Dirección de V
    Mov %i3, %i2        ! Constante kv
    Call Escala_vect    ! Multiplica F = kv * V
    Nop
    Mov %o3, %l4        ! Guardar F

    ! Calcular delta_pos = (V * t) + (a * t*t / 2)
    Mov %l2, %i1        ! Dirección de V
    Mov %i5, %i2        ! Escalar t
    Call Escala_vect    ! Multiplica V * t
    Nop
    Mov %o3, %l5        ! Guardar V * t

    Mov %l4, %i1        ! Dirección de F (Aceleración)
    Mov %i5, %i2        ! Escalar t
    Call Escala_vect    ! Multiplica A * t
    Nop
    Mov %o3, %l6        ! Guardar A * t

    Mov %l6, %i1        ! Dirección de A * t
    Mov %i5, %i2        ! Escalar t
    Call Escala_vect    ! Multiplica (A * t) * t
    Nop
    Mov %o3, %l7        ! Guardar (A * t * t)

    Mov %l7, %i1        ! Dirección de (A * t * t)
    Set 2, %i2          ! Dividir por 2
    Call Vector_sobre_escalar
    Nop
    Mov %o3, %l8        ! Guardar (A * t * t) / 2

    ! Sumar (V * t) + (A * t * t / 2)
    Mov %l5, %i1
    Mov %l8, %i2
    Call Suma_vect
    Nop
    Mov %o3, %l9        ! Guardar delta_pos

    ! Actualizar posición: Pos = Pos + delta_pos
    Mov %l1, %i1
    Mov %l9, %i2
    Call Suma_vect
    Nop
    Mov %o3, %l1        ! Guardar nueva posición

    ! Guardar en la lista de posiciones
    St %l1, [%o2 + %l0] 

    ! Repetir el ciclo
    Ba Ciclo
    Nop

Fin:
    Mov %o2, %o1  ! Devolver la lista de posiciones
    Retl
    Nop
