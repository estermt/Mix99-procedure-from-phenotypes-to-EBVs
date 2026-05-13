## Mix99
Pipeline to use mix99 softwares to estimate GEBVs and the reliability of methane emissions
# Genetic Evaluation Pipeline for Methane Emissions

## Overview

This repository contains a fully automated pipeline for the estimation of genomic breeding values (GEBVs) and their reliability for methane emissions.

The workflow integrates data preprocessing in R, pedigree and genotype processing, Fortran-based tools, and genetic evaluation using Mix99 softwares under a ssGBLUP framework.

The pipeline is designed to be modular, reproducible, and adaptable to future evaluations.

---

## Pipeline Structure

The workflow consists of the following steps:

### 1. Data Preparation
- Phenotypic data (numeric traits only)
- Pedigree data (ordered and pruned)
- Genotype data (coded as 0, 1, 2, separated by White Spaces)

### 2. Pre-processing
- Renumbering of individuals (Relax2)
- Pedigree pruning

- Recoding of genotype IDs (Fortran)

### 3. Matrix Construction
- Generation of A22 matrix using Relax2 in a 2nd round, using renumbered ped
- Computation of G⁻¹ and H⁻¹ matrices using hginv from mix99

### 4. Genetic Evaluation (Mix99)
- Preprocessor: mix99i
- Solver: mix99s
- Estimation of variance components using REML method (mix99s)

### 5. Reliability Estimation
- Reliability : apax99

### 6. Post-processing
- Extraction and formatting of EBVs
- Data transformation and output generation (R)

### 7. Validation (ongoing)
Due to current data limitations, full external validation is not yet implemented. Planned validation includes:
- Correlation with future official evaluations
- Correlations with EBVs from GreenFeed
- Temporal validation using new data
- Distribution and consistency checks of EBVs

---

## Workflow Diagram

```mermaid
graph TD
A[Raw Data] --> B[Cleaning & Formatting - R]
B --> C[Relax2 Processing]
C --> D[Genotype Recoding - Fortran]
D --> E[Matrix Construction - hginv]
E --> F[Mix99 Preprocessor]
F --> G[Mix99 Solver]
G --> H[EBVs Output]
H --> I[Reliability - APAX]
I --> J[Post-processing - R]
J --> K[Validation]
