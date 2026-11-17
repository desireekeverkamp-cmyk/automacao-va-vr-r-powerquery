library(tidyverse)
library(lubridate)

set.seed(123) # Garante que a simulação gere sempre os mesmos números

# ==============================================================================
# 1. TABELA DE CADASTRO DO RH (25 colaboradores: 5 Gerentes e 20 Analistas)
# ==============================================================================
cadastro_rh <- tibble(
  matricula = sprintf("MAT%03d", 1:25),
  cpf = sprintf("000.000.%03d-00", 1:25),
  funcao = c(rep("Gerente", 5), rep("Analista", 20)),
  data_admissao = sample(seq(as.Date("2020-01-01"), as.Date("2025-10-01"), by = "day"), 25),
  dias_ferias_mes = c(0, 15, 0, 0, 0, rep(0, 18), 10, 0), # 1 gerente e 1 analista de férias
  valor_diario = if_else(funcao == "Gerente", 45.00, 35.00)
)

# ==============================================================================
# 2. TABELA DE PONTO ELETRÔNICO (22 dias úteis para cada um = 550 linhas)
# ==============================================================================
ponto_eletronico <- expand_grid(
  matricula = cadastro_rh$matricula,
  dia = 1:22
) %>%
  mutate(
    # Simula horários (em formato decimal para facilitar: ex 8.5 = 08h30)
    entrada = 8.0,
    saida_almoco = 12.0,
    volta_almoco = 13.0,
    # Alguns dias têm saída mais tarde (hora extra) ou mais cedo (meio período)
    saida = sample(c(17.0, 17.0, 17.0, 19.5, 13.0), n(), replace = TRUE),
    # Simula 2% de chance de falta no dia
    faltou = rbinom(n(), 1, 0.02)
  )

# ==============================================================================
# 3. O SEU MOTOR DE CÁLCULO (JOIN + REGRAS DE NEGÓCIO + AGRUPAMENTO)
# ==============================================================================

# Passo A: Juntar as tabelas e calcular dia a dia
tabela_gigante <- ponto_eletronico %>%
  left_join(cadastro_rh, by = "matricula") %>%
  mutate(
    # Calcula horas trabalhadas descontando o almoço (se não faltou)
    horas_trabalhadas = if_else(
      faltou == 1, 
      0, 
      (saida_almoco - entrada) + (saida - volta_almoco)
    ),
    # Regra 1: Ganha VR no dia se trabalhou mais de 6h
    direito_vr_dia = if_else(horas_trabalhadas > 6, 1, 0),
    # Regra 2: Hora extra (acima de 8h normais). Se > 2h extras, ganha +1 VR
    horas_extras = pmax(0, horas_trabalhadas - 8),
    vr_extra_dia = if_else(horas_extras > 2, 1, 0)
  )

# Passo B: Resumir 1 linha por colaborador para o pedido final
pedido_final_va_vr <- tabela_gigante %>%
  group_by(matricula, cpf, funcao, data_admissao, dias_ferias_mes, valor_diario) %>%
  summarise(
    dias_trabalhados_validos = sum(direito_vr_dia),
    faltas_no_mes = sum(faltou),
    qtd_vr_extras = sum(vr_extra_dia),
    .groups = "drop"
  ) %>%
  mutate(
    # Desconta os dias de férias do total de dias válidos
    dias_liquidos_pagar = pmax(0, dias_trabalhados_validos - dias_ferias_mes) + qtd_vr_extras,
    valor_total_beneficio = dias_liquidos_pagar * valor_diario
  )

# Visualizar os primeiros resultados (Gerentes e primeiros Analistas)
print(pedido_final_va_vr, n = 10)

# Ver as colunas finais de pagamento
pedido_final_va_vr %>%
  select(matricula, funcao, dias_ferias_mes, faltas_no_mes, qtd_vr_extras, dias_liquidos_pagar, valor_total_beneficio) %>%
  print(n = 25)

# Resumo executivo por cargo (O que vai para o Power BI!)
resumo_bi <- pedido_final_va_vr %>%
  group_by(funcao) %>%
  summarise(
    total_colaboradores = n(),
    total_dias_pagos = sum(dias_liquidos_pagar),
    total_extras = sum(qtd_vr_extras),
    custo_total_rs = sum(valor_total_beneficio),
    custo_medio_pessoa = mean(valor_total_beneficio)
  )

print(resumo_bi)


library(writexl)

write_xlsx(
  list(
    "Pedido_Operadora" = pedido_final_va_vr,
    "Resumo_Indicadores_BI" = resumo_bi
  ),
  "Entrega_Automacao_VA_VR.xlsx"
)


O que ele prova: Que você sabe gerar dados sintéticos do zero (tibble, expand_grid, set.seed, distribuições probabilísticas com rbinom e sample) para testar regras de negócio antes mesmo de ter acesso aos dados reais da empresa. Isso mostra forte bagagem acadêmica e de modelagem (seu perfil de doutoranda brilha aqui).
