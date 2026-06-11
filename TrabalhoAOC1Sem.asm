.data
    msg_input:   .asciiz "Digite o valor de N (inteiro entre 3 e 19): "
    msg_erro1:   .asciiz "Erro: N deve ser maior que 2 e menor que 20. Tente novamente.\n\n"
    msg_erro2:   .asciiz "Erro: entrada invalida. Digite um numero inteiro.\n\n"
    msg_seq:     .asciiz "\nPrimeiros "
    msg_seq2:    .asciiz " termos de Fibonacci:\n"
    msg_prod:    .asciiz "\nProduto acumulado: "
    msg_sep:     .asciiz " x "
    msg_newline: .asciiz "\n"

    fibonacci:   .word 0:20      # array para armazenar os termos de Fibonacci
    n_val:       .word 0         # valor de N

.text
.globl main

# ─────────────────────────────────────────────
# ler_n_valido: lê N e valida (2 < N < 20)
# ─────────────────────────────────────────────
ler_n_valido:
    li   $v0, 4
    la   $a0, msg_input
    syscall                      # imprime mensagem de entrada

    li   $v0, 5
    syscall                      # lê inteiro digitado pelo usuário
    move $t0, $v0                # t0 = N lido

    bgt  $t0, 2,  checa_max      # se N > 2, verifica máximo
    j    erro_range              # senão, erro de intervalo

checa_max:
    blt  $t0, 20, n_valido       # se N < 20, N é válido
    j    erro_range              # senão, erro de intervalo

erro_range:
    li   $v0, 4
    la   $a0, msg_erro1
    syscall
    j    ler_n_valido            # solicita novamente

n_valido:
    sw   $t0, n_val              # salva N validado
    jr   $ra


# ─────────────────────────────────────────────
# gerar_fibonacci: preenche array fibonacci[0..N-1]
# ─────────────────────────────────────────────
gerar_fibonacci:
    la   $t0, fibonacci
    lw   $t1, n_val              # t1 = N

    li   $t2, 1
    sw   $t2, 0($t0)             # fibonacci[0] = 1
    sw   $t2, 4($t0)             # fibonacci[1] = 1

    li   $t3, 2                  # t3 = índice i (começa em 2)

loop_fib:
    bge  $t3, $t1, fim_fib       # se i >= N, termina

    sll  $t4, $t3, 2             # t4 = i * 4 (offset em bytes)
    add  $t5, $t0, $t4           # t5 = &fibonacci[i]

    lw   $t6, -4($t5)            # t6 = fibonacci[i-1]
    lw   $t7, -8($t5)            # t7 = fibonacci[i-2]
    add  $t6, $t6, $t7           # t6 = fibonacci[i-1] + fibonacci[i-2]
    sw   $t6, 0($t5)             # fibonacci[i] = t6

    addi $t3, $t3, 1             # i++
    j    loop_fib

fim_fib:
    jr   $ra


# ─────────────────────────────────────────────
# calcular_produto: multiplica todos os termos
# retorna resultado em $v0
# ─────────────────────────────────────────────
calcular_produto:
    la   $t0, fibonacci
    lw   $t1, n_val              # t1 = N

    li   $t2, 0                  # t2 = índice i
    li   $v0, 1                  # v0 = produto acumulado (inicia em 1)

loop_prod:
    bge  $t2, $t1, fim_prod      # se i >= N, termina

    sll  $t3, $t2, 2             # offset = i * 4
    add  $t3, $t0, $t3
    lw   $t4, 0($t3)             # t4 = fibonacci[i]

    mul  $v0, $v0, $t4           # produto *= fibonacci[i]

    addi $t2, $t2, 1             # i++
    j    loop_prod

fim_prod:
    jr   $ra


# ─────────────────────────────────────────────
# imprimir_sequencia: imprime os termos com " x "
# ─────────────────────────────────────────────
imprimir_sequencia:
    la   $t0, fibonacci
    lw   $t1, n_val              # t1 = N
    li   $t2, 0                  # t2 = índice i

loop_print:
    bge  $t2, $t1, fim_print

    sll  $t3, $t2, 2
    add  $t3, $t0, $t3
    lw   $a0, 0($t3)             # a0 = fibonacci[i]
    li   $v0, 1
    syscall                      # imprime o número

    addi $t3, $t2, 1
    bge  $t3, $t1, fim_print     # se for o último, não imprime " x "

    li   $v0, 4
    la   $a0, msg_sep
    syscall                      # imprime " x "

    addi $t2, $t2, 1
    j    loop_print

fim_print:
    jr   $ra


# ─────────────────────────────────────────────
# main
# ─────────────────────────────────────────────
main:
    # 1. ler e validar N
    jal  ler_n_valido

    # 2. gerar sequência de Fibonacci
    jal  gerar_fibonacci

    # 3. imprimir cabeçalho da sequência
    li   $v0, 4
    la   $a0, msg_seq
    syscall

    lw   $a0, n_val
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, msg_seq2
    syscall

    # 4. imprimir os termos
    jal  imprimir_sequencia

    # 5. calcular produto
    jal  calcular_produto
    move $s0, $v0                # salva produto em s0

    # 6. imprimir produto
    li   $v0, 4
    la   $a0, msg_prod
    syscall

    move $a0, $s0
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, msg_newline
    syscall

    # 7. encerrar programa
    li   $v0, 10
    syscall
