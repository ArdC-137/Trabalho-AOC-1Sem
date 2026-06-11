.data
    msg_input:   .asciiz "Digite o valor de N (inteiro entre 3 e 19): "
    msg_erro1:   .asciiz "Erro: N deve ser maior que 2 e menor que 20. Tente novamente.\n\n"
    msg_seq:     .asciiz "\nPrimeiros "
    msg_seq2:    .asciiz " termos de Fibonacci:\n"
    msg_prod:    .asciiz "\nProduto acumulado: "
    msg_sep:     .asciiz " x "
    msg_newline: .asciiz "\n"

    fibonacci:   .word 0:20
    n_val:       .word 0

.text
.globl main

ler_n_valido:
    li   $v0, 4
    la   $a0, msg_input
    syscall

    li   $v0, 5
    syscall
    move $t0, $v0

    bgt  $t0, 2,  checa_max
    j    erro_range

checa_max:
    blt  $t0, 20, n_valido
    j    erro_range

erro_range:
    li   $v0, 4
    la   $a0, msg_erro1
    syscall
    j    ler_n_valido

n_valido:
    sw   $t0, n_val
    jr   $ra


gerar_fibonacci:
    la   $t0, fibonacci
    lw   $t1, n_val

    li   $t2, 1
    sw   $t2, 0($t0)
    sw   $t2, 4($t0)

    li   $t3, 2

loop_fib:
    bge  $t3, $t1, fim_fib

    sll  $t4, $t3, 2
    add  $t5, $t0, $t4

    lw   $t6, -4($t5)
    lw   $t7, -8($t5)
    add  $t6, $t6, $t7
    sw   $t6, 0($t5)

    addi $t3, $t3, 1
    j    loop_fib

fim_fib:
    jr   $ra


calcular_produto:
    la   $t0, fibonacci
    lw   $t1, n_val

    li   $t2, 0
    li   $v0, 1

loop_prod:
    bge  $t2, $t1, fim_prod

    sll  $t3, $t2, 2
    add  $t3, $t0, $t3
    lw   $t4, 0($t3)

    mul  $v0, $v0, $t4

    addi $t2, $t2, 1
    j    loop_prod

fim_prod:
    jr   $ra


imprimir_sequencia:
    la   $t0, fibonacci
    lw   $t1, n_val
    li   $t2, 0

loop_print:
    bge  $t2, $t1, fim_print

    sll  $t3, $t2, 2
    add  $t3, $t0, $t3
    lw   $a0, 0($t3)
    li   $v0, 1
    syscall

    addi $t3, $t2, 1
    bge  $t3, $t1, fim_print

    li   $v0, 4
    la   $a0, msg_sep
    syscall

    addi $t2, $t2, 1
    j    loop_print

fim_print:
    jr   $ra


main:
    jal  ler_n_valido

    jal  gerar_fibonacci

    li   $v0, 4
    la   $a0, msg_seq
    syscall

    lw   $a0, n_val
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, msg_seq2
    syscall

    jal  imprimir_sequencia

    jal  calcular_produto
    move $s0, $v0

    li   $v0, 4
    la   $a0, msg_prod
    syscall

    move $a0, $s0
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, msg_newline
    syscall

    li   $v0, 10
    syscall
