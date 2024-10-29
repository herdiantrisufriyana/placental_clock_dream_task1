save_samp_md5 <- function(data, seed, path){
  set.seed(seed)
  row_samp <-
    sample(seq(nrow(data)), min(100, nrow(data)))
  
  set.seed(seed)
  col_samp <-
    sample(seq(ncol(data)), min(100, ncol(data)))
  
  data[row_samp, col_samp] |>
    digest(algo = "md5") |>
    saveRDS(path)
}