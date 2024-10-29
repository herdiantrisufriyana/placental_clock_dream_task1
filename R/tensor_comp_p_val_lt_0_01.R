# Create an iterator
batch_size <-
  as.numeric((10 * 10^9) / object.size(detp[1,,drop=F])) |>
  floor()

batch <-
  ceiling(seq(nrow(detp)) / batch_size)

iterator <-
  detp |>
  nrow() |>
  seq() |>
  split(batch)

names(iterator) <-
  iterator |>
  names() |>
  str_pad(2, "left", "0")

# Check if running on macOS with ARM architecture (Apple Silicon)
is_macos_arm64 =
  all(
    Sys.info()[['sysname']] == 'Darwin'
    ,grepl('arm', Sys.info()[['machine']], fixed = TRUE)
  )

# Determine the device
if(is_macos_arm64) {
  device <- "mps"
}else if(cuda_is_available()) {
  device <- "cuda"
}else{
  device <- "cpu"
}

# Set progress bar
pb <-
  txtProgressBar(min = 1, max = length(iterator), style = 3)

# Run the codes per batch
for(i in seq(length(iterator))){
  Sys.sleep(0.1)
  
  # Convert data frame to a tensor
  detp_tensor <-
    detp[iterator[[i]],] |>
    as.matrix() |>
    torch_tensor(
      dtype = torch_float32()
      ,device = device
    )
  
  # Identify values less than 0.01
  p_vals_lt_0_01 <-
    detp_tensor$lt(0.01)
  
  # Create a mask of non-NaN values in the original tensor
  detp_tensor_not_nan <- !torch_isnan(detp_tensor)
  
  # Sum non-NaN values for normalization
  total_non_nan_values <- detp_tensor_not_nan$sum(dim = 2L)
  
  # Consider <0.01-valuesthat correspond to the non-NaN values
  valid_lt_0_01_counts <- (p_vals_lt_0_01 & detp_tensor_not_nan)$sum(dim = 2L)
  
  # Calculate the proportion of values less than 0.01
  p_vals0 <- valid_lt_0_01_counts / total_non_nan_values
  
  # Move the result back to R as a vector
  p_vals <-
    p_vals0$cpu()$detach() |>
    as.numeric()
  
  # Save the result for reproducibility
  saveRDS(p_vals, paste0("data/p_vals", names(iterator)[i], ".rds"))
  
  setTxtProgressBar(pb, i)
}

# Stop progress bar
close(pb)

# Merge the results
p_vals_files <-
  list.files("data/", pattern = "p_vals", full.names = TRUE)

p_vals <-
  p_vals_files |>
  lapply(readRDS) |>
  reduce(c)

# Save the merged results for reproducibility
saveRDS(p_vals, "data/p_vals.rds")

# Remove batch-processed results
p_vals_files[!str_detect(p_vals_files, "p_vals\\.rds")] |>
  lapply(file.remove)