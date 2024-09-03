
# Clear the workspace
rm(list=ls())

# Load necessary libraries
library(tidyverse)
# library(tidymodels)
library(limma)
library(ChAMP)
library(minfi)
library(parallel)

# Set working directory
# setwd(".../dream_challenge/SubChallenge2")

# Note: This script is an example of preprocessing and normalization.
# Participants are encouraged to devise their own preprocessing and normalization strategies.

# Read the probe annotation file
# This file contains information about the probes used in the methylation array
epic_annotation <- read_csv("Probe_annotation.csv", col_select = -1) %>% as.data.frame()
rownames(epic_annotation) <- epic_annotation$Name

# Read the methylation beta values
# These values represent the methylation level at each probe
df_train <- read_csv("Beta_raw_subchallenge2.csv") %>% as.data.frame()
rownames(df_train) <- df_train[,1]
df_train[,1] <- NULL

# Read the detection p-values
# These p-values assess the reliability of the methylation signals
detp <- read_csv("DetectionP_subchallenge2.csv") %>% as.data.frame()
rownames(detp) <- detp[,1]
detp[,1] <- NULL

# Read the sample annotation file
# This file contains metadata about the samples
ano <- read.csv("Sample_annotation.csv")
rownames(ano) <- ano$Sample_ID

# Sort the data to match the order of the sample annotations
df_train <- df_train[, rownames(ano)]
detp <- detp[rownames(df_train), rownames(ano)]

# Preprocess the data

# 1) Filter out probes that fall near SNPs, align to multiple locations, or target locations on X and Y chromosomes
# Participants may use different filtering criteria as per their strategies
beta_train_filter <- champ.filter(
  beta = df_train,
  pd = ano,
  filterDetP = FALSE,
  detP = NULL,
  autoimpute = FALSE,
  filterBeads = FALSE,
  arraytype = "EPIC",  # Set this argument to "450K" for sub-challenge 1
  fixOutlier = FALSE,
  filterNoCG = TRUE,
  filterSNPs = TRUE,
  filterMultiHit = TRUE,
  filterXY = TRUE
)$beta

# 2) Filter probes based on detection p-values
# Keep probes that are reliably detected in all samples (p-value < 0.01)
# Participants may choose different detection p-value thresholds or criteria
p_vals <- apply(detp, 1, function(x) {
  sum(x < 0.01, na.rm = TRUE) / length(na.omit(x))  # Proportion of samples with p-value < 0.01
})
keep <- names(p_vals)[p_vals == 1]  # Keep probes detected in all samples
beta_train_filter_detp <- beta_train_filter[rownames(beta_train_filter) %in% keep, ]

# Normalize the filtered beta values using the BMIQ method
# Participants are encouraged to explore different normalization methods
beta_norm_BMIQ <- champ.norm(
  beta = beta_train_filter_detp,
  arraytype = "EPIC",
  method = "BMIQ",
  cores = 7
)
