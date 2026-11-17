library(tidyverse)
library(readxl)
library(writexl)
library(lubridate)

# 1. Leitura direta da raiz do projeto
ponto_bruto <- read_excel("Extrato_Ponto_Outubro_2026_v2.xlsx", skip = 4) %>%
  filter(!is.na(matricula))

cadastro_rh <- read_excel("Base_Interna_RH_e_Glossario_v2.xlsx", sheet = "Base_Colaboradores_RH") %>%
  filter(!is.na(matricula)) %>%
  select(matricula, cpf, nome, cargo, faixa, centro_custo, data_admissao, valor_diario_va, dias_ferias_mes)

glossario <- read_excel("Base_Interna_RH_e_Glossario_v2.xlsx", sheet = "Glossario_Matematico")

# 2. Base Unificada (Join)
base_unificada <- ponto_bruto %>%
  left_join(cadastro_rh, by = c("matricula", "cpf"))

# 3. Cálculos do Glossário Matemático e Consolidação
fechamento_final <- base_unificada %>%
  mutate(
    t_ent1   = period_to_seconds(hm(entrada_1)) / 60,
    t_sai_al = period_to_seconds(hm(saida_almoco)) / 60,
    t_ret_al = period_to_seconds(hm(retorno_almoco)) / 60,
    t_sai2   = period_to_seconds(hm(saida_2)) / 60,
    H_dia_R  = replace_na((t_sai_al - t_ent1) / 60, 0) + replace_na((t_sai2 - t_ret_al) / 60, 0),
    E_dia_R    = if_else(H_dia_R >= 6.0, 1, 0),
    HE_dia_R   = pmax(0, H_dia_R - 8.0),
    VA_extra_R = if_else(HE_dia_R >= 2.0, 1, 0)
  ) %>%
  group_by(matricula, cpf, nome, cargo, faixa, centro_custo, data_admissao, valor_diario_va, dias_ferias_mes) %>%
  summarise(
    dias_falta_atestado = sum(ocorrencia %in% c("Falta Injustificada", "Atestado Médico"), na.rm = TRUE),
    D_liq               = sum(E_dia_R, na.rm = TRUE),
    total_VA_extra      = sum(VA_extra_R, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    V_total  = (D_liq + total_VA_extra) * valor_diario_va,
    Taxa_Abs = round((dias_falta_atestado / 21) * 100, 2)
  )

# 4. Resumo Executivo e Exportação para a sua pasta saídas_bi (com acento, igual à foto!)
resumo_executivo_bi <- fechamento_final %>%
  group_by(centro_custo, faixa) %>%
  summarise(
    N_Colaboradores         = n(),
    Total_Dias_Pagos        = sum(D_liq),
    Total_Creditos_Extras   = sum(total_VA_extra),
    Orcamento_Total_VA      = sum(V_total),
    Custo_Medio_Colaborador = round(Orcamento_Total_VA / N_Colaboradores, 2),
    .groups = "drop"
  )

write_xlsx(
  list(
    "Fechamento_VA_Colaborador" = fechamento_final,
    "Resumo_Gerencial_BI"       = resumo_executivo_bi,
    "Glossario_Matematico"      = glossario
  ),
  "saídas_bi/Base_Consolidada_PowerBI.xlsx"
)
