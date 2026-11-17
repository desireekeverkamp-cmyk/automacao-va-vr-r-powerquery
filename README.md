# automacao-va-vr-r-powerquery
# 📊 Automação do Fechamento de VA/VR e Inteligência de RH (R + Power Query + Excel)

![R](https://shields.io)
![Excel](https://shields.io)
![Power Query](https://shields.io)

> **Pipeline reprodutível de dados e Business Intelligence para eliminação de erros operacionais, rastreabilidade de regras trabalhistas e apoio à tomada de decisão na gestão de benefícios corporativos.**

---

## 🎯 Problema de Negócio

O fechamento mensal de **Vale-Alimentação e Vale-Refeição (VA/VR)** frequentemente depende de cruzamentos manuais entre extratos de ponto eletrônico e planilhas cadastrais de RH. Esse processo manual gera:
* **Alto risco de erro humano** na apuração de dias elegíveis, faltas e horas extras.
* **Retrabalho operacional** a cada ciclo de fechamento.
* **Falta de visibilidade gerencial** sobre a distribuição de custos por centro de custo e indicadores preventivos de absenteísmo.

---

## 🏗️ Arquitetura da Solução

Para resolver esse gargalo na empresa fictícia **TechSolutions Brasil Ltda** (15 colaboradores distribuídos em 4 faixas de benefício e 5 centros de custo), desenvolvi uma arquitetura híbrida dividida em três camadas:

```text
[Bases Brutas (.xlsx)] ──▶ [Pipeline ETL & Regras em R] ──▶ [Base Consolidada] ──▶ [Power Query + Dashboard Excel]
```

1. **Ingestão e Simulação (`01_simulacao_dados_sinteticos.R`):** Geração de dados realistas contendo batidas diárias de entrada, intervalo de almoço, saída, faltas e atestados (`Extrato_Ponto_Outubro_2026_v2.xlsx`), além do cadastro funcional e glossário matemático (`Base_Interna_RH_e_Glossario_v2.xlsx`).
2. **Processamento e Regras de Negócio (`02_pipeline_producao_excel_bi.R`):** Script em R utilizando `readxl` e `dplyr` para cruzar as bases (315 registros diários), aplicar as regras matemáticas de elegibilidade e exportar a tabela tratada (`saidas_bi/Base_Consolidada_PowerBI.xlsx`).
3. **Camada Analítica (`Dashboard_Automacao_VA.xlsx`):** Conexão automatizada via **Power Query** alimentando um painel executivo interativo com segmentação dinâmica por **Centro de Custo** e **Faixa de Benefício**.

---

## 📐 Regras de Negócio e Modelagem Matemática

Todas as premissas operacionais foram padronizadas e documentadas no pipeline:

| Indicador | Sigla | Regra de Cálculo Aplicada |
| :--- | :---: | :--- |
| **Horas Líquidas Diárias** | `H_dia` | Diferença entre entrada e saída, descontando o intervalo intrajornada. |
| **Elegibilidade Diária** | `E_dia` | Concessão de 1 benefício diário condicionada a `H_dia >= 6h`. |
| **Horas Extras** | `HE_dia` | Excedente da jornada padrão diária contratada. |
| **VA Adicional** | `VA_extra` | Concessão de benefício extra quando `HE_dia >= 2h`. |
| **Dias Líquidos & Valor Total** | `D_liq` / `V_total` | Soma dos dias elegíveis e adicionais multiplicada pelo valor unitário da faixa (A, B, C ou D). |
| **Taxa de Absenteísmo** | `Taxa_Abs` | Proporção de dias não trabalhados (faltas/atestados) sobre o total de dias úteis do período. |

---

## 📈 Dashboard Executivo e Principais Insights

![Dashboard Automação VA/VR](dashboard_print.png)

O painel permite filtrar instantaneamente os indicadores por departamento e faixa salarial, revelando insights estratégicos para a diretoria e o RH:

* **Concentração Orçamentária:** A área de **Tecnologia** lidera o orçamento mensal de benefícios, impulsionada pelo volume de colaboradores alocados na **Faixa C**.
* **Alerta Preventivo de Gestão:** O setor de **Recursos Humanos** apresenta o menor custo financeiro total, porém registra a **maior Taxa Média de Absenteísmo (>14%)**, sinalizando a necessidade de investigação sobre sobrecarga ou clima organizacional.
* **Auditabilidade Total:** Cada centavo calculado no fechamento possui rastreabilidade diária por matrícula e CPF.

---

## 📂 Estrutura do Repositório

```text
├── 01_simulacao_dados_sinteticos.R      # Script para geração das bases sintéticas de ponto e RH
├── 02_pipeline_producao_excel_bi.R      # Pipeline principal de ETL, cruzamento e regras de negócio
├── Extrato_Ponto_Outubro_2026_v2.xlsx   # Base bruta de registros de ponto eletrônico
├── Base_Interna_RH_e_Glossario_v2.xlsx  # Cadastro de colaboradores, faixas e glossário técnico
├── Dashboard_Automacao_VA.xlsx          # Painel interativo conectado via Power Query
├── Estudo_de_Caso_Portfolio_Automacao_VA_RH.docx # Documentação executiva completa do projeto
└── dashboard_print.png                  # Captura de tela do painel final
```

---

## 🚀 Como Executar o Projeto

1. Clone este repositório ou baixe os arquivos para uma pasta local.
2. Certifique-se de ter o **R** instalado com os pacotes `readxl`, `dplyr`, `lubridate` e `writexl`.
3. Execute o script `02_pipeline_producao_excel_bi.R` para gerar a base consolidada na pasta `saidas_bi/`.
4. Abra o arquivo `Dashboard_Automacao_VA.xlsx` e clique em **Dados > Atualizar Tudo** para refletir os novos cálculos via Power Query.

---

## 👩‍💻 Autoria

Desenvolvido como projeto de portfólio aplicado à **Análise de Dados, Automação de Processos e People Analytics**.  
📫 *Conecte-se comigo no [LinkedIn](https://linkedin.com) para trocar ideias sobre dados e eficiência operacional!*
