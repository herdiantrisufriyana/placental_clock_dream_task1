# Determine the numbers of cluster/batch
cl <- min(3, detectCores() - 1)

batch_n <- ceiling(ncol(beta_train_filter_detp) / (cl * 3))
iterator <-
  matrix(seq(batch_n * (cl * 3)), nrow = cl * 3) |>
  as.data.frame() |>
  lapply(\(x) x[x <= ncol(beta_train_filter_detp)]) |>
  `names<-`(NULL)

names(iterator) <-
  1:length(iterator) |>
  str_pad(3, "left", "0")

# Resume from the last batch if any
batch_completed <-
  list.files("data/beta_norm_bmiq/", pattern = "batch") |>
  str_remove_all("batch|\\.rds") |>
  as.numeric()

i_start <-
  ifelse(
    length(batch_completed) == 0
    ,1
    ,batch_completed[length(batch_completed)] + 1
  )

# Start parallelization
start <- TRUE; source("R/parallel_computing-codes.R")

# Run BMIQ per batch
for(i in i_start:length(iterator)){
  
  # Parallelize BMIQ with progress bar per batch
  cat("Batch", names(iterator)[i], "of", length(iterator), "\n")
  
  beta_norm_bmiq_batch <-
    1:ncol(beta_train_filter_detp[, iterator[[i]]]) |>
    pblapply(
      cl = cl
      ,beta_train_filter_detp = beta_train_filter_detp[, iterator[[i]]]
      ,\(x, beta_train_filter_detp)
        beta_train_filter_detp[, x, drop=F] |>
          champ.norm(
            resultsDir = "data"
            ,arraytype = "450K"
            ,method = "BMIQ"
            ,cores = 1
          )
    )
  
  # Save the result for reproducibilitystart
  resultsDir <- "data/beta_norm_bmiq"
  if (!file.exists(resultsDir)) dir.create(resultsDir)
  
  saveRDS(
    reduce(beta_norm_bmiq_batch, cbind)
    ,paste0(
      resultsDir
      ,"/batch"
      ,names(iterator)[i]
      ,".rds"
    )
  )
  
  cat("\n")
}

# Stop parallelization
start <- FALSE; source("R/parallel_computing-codes.R")
