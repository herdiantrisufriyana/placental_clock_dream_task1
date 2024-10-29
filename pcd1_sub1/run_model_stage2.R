library(readr)
library(optparse)
library(vroom)
library(tibble)
library(purrr)
library(dplyr)
library(RPMM)
library(pbapply)
library(tidyr)
library(stringr)
source(file.path("utils.R"))

option_list <-
  list(
    make_option(
      "--input"
      ,type = "character"
      ,default = "/input"
      ,help = "Input directory [default=/input]"
      ,metavar="character"
    )
    ,make_option(
      "--output"
      ,type = "character"
      ,default = "/output"
      ,help = "Output directory [default=/output]"
      ,metavar = "character"
    )
    ,make_option(
      "--data"
      ,type = "character"
      ,default = "data"
      ,help = "Data directory [default=data]"
      ,metavar = "character"
    )
    ,make_option(
      "--extdata"
      ,type = "character"
      ,default = "inst/extdata"
      ,help = "Extension data directory [default=inst/extdata]"
      ,metavar = "character"
    )
    ,make_option(
      "--intermediate"
      ,type = "character"
      ,default = "intermediate"
      ,help = "Intermediate data directory [default=intermediate]"
      ,metavar = "character"
    )
  )

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

var_ga <- readRDS(file.path(opt$data, "var_ga.rds"))
Sample_IDs <- readRDS(file.path(opt$intermediate, "Sample_IDs.rds"))

ga_res_cr_est_train_set <-
  file.path(opt$intermediate, paste0(var_ga, "_imp_prob.csv")) |>
  `names<-`(var_ga) |>
  imap(
    ~ .x |>
      read_csv(show_col_types = FALSE) |>
      mutate(rowname = Sample_IDs) |>
      column_to_rownames(var = "rowname") |>
      rename_at("predicted_probability", \(x) .y)
  ) |>
  reduce(cbind) |>
  select_at(var_ga) |>
  rownames_to_column(var = "Sample_accession")

ga_res_cr_est_train_set <-
  ga_res_cr_est_train_set |>
  gather(cond, prob, -Sample_accession) |>
  mutate_at(c("Sample_accession", "cond"), \(x) factor(x, unique(x))) |>
  group_by(Sample_accession) |>
  mutate(
    hi_prob = ifelse(prob == max(prob), "Yes", "No")
    ,hi_cond =
      ifelse(hi_prob == "Yes", cond, NA) |>
      setdiff(NA) |>
      sapply(\(x) paste0("^", x, "$")) |>
      paste0(collapse = "|")
  ) |>
  mutate(
    comp_risk =
      ifelse(
        str_detect(hi_cond, "\\^miscarriage\\$")
        ,"^miscarriage$|^subfertility$"
        ,ifelse(
          str_detect(
            hi_cond
            ,c("\\^anencephaly\\$"
               ,"\\^spina_bifida\\$"
               ,"\\^diandric_triploid\\$"
            ) |>
              paste0(collapse = "|")
          )
          ,c("^anencephaly$"
             ,"^spina_bifida$"
             ,"^diandric_triploid$"
             ,"^miscarriage$"
             ,"^subfertility$"
          ) |>
            paste0(collapse = "|")
          ,"^[:graph:]*$"
        )
      )
    ,prob_comp_risk =
      ifelse(
        str_detect(cond, comp_risk)
        ,prob
        ,0
      )
  ) |>
  select(Sample_accession, cond, prob_comp_risk) |>
  spread(cond, prob_comp_risk, fill = 0) |>
  arrange(Sample_accession) |>
  
  mutate(
    pe_onset = pe * pe_onset
    ,hellp = pe * hellp
    ,fgr = fgr + pe * fgr
    ,lga = lga + gdm * lga
    ,preterm = preterm + pe_onset + hellp + chorioamnionitis
  )

ga_res_cr_est_train_set <-
  ga_res_cr_est_train_set |>
  column_to_rownames(var = "Sample_accession")

ga_res_cr_est_train_set |>
  write_csv(file.path(opt$intermediate, "ga_res_cr_rf_est_set.csv"))
