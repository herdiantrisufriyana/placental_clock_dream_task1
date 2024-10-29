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

detp_filtered_probes <-
  file.path(opt$data, "beta_train_filter_detp_rownames.rds") |>
  readRDS()

test_data <-
  file.path(opt$input, "Leaderboard_beta_subchallenge1.csv") |>
  vroom(show_col_types = FALSE) |>
  rename(probe_id = 1) |>
  filter(probe_id %in% detp_filtered_probes) |>
  slice(match(detp_filtered_probes, probe_id)) |>
  column_to_rownames(var = "probe_id")

Sample_IDs <- colnames(test_data)
saveRDS(Sample_IDs, file.path(opt$intermediate, "Sample_IDs.rds"))

test_data_norm <-
  1:ncol(test_data) |>
  pblapply(
    bmiq_norm_progress
    ,data = test_data
    ,arraytype = "450K"
    ,cores = 1
  ) |>
  reduce(cbind) |>
  t() |>
  as.data.frame()

var_ga <- c("ga_res_cpg_pr")

features <-
  c("ga", var_ga) |>
  `names<-`(c("ga", var_ga)) |>
  imap(~ file.path(opt$data, paste0(.x, "_dmp.rds"))) |>
  lapply(readRDS) |>
  imap(~ .x[[1]]) |>
  lapply(rownames)

ga_est_set <-
  test_data_norm[, features$ga, drop = FALSE] |>
  write_csv(file.path(opt$intermediate, "ga_est_set.csv"))

non_ga_est_sets <-
  features[names(features) != "ga"] |>
  imap(
    ~ test_data_norm[, .x, drop = FALSE] |>
      write_csv(file.path(opt$intermediate, paste0(.y, "_est_set.csv")))
  )
