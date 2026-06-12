This program estimates \(G^{-1}\) and matrices and writes the lower diagonal format required for use in Mix99 programs.

The first step is to use Relax2 to construct the \(A\) matrix based on the pedigree file. (A22matrix)

The program then uses this matrix together with genotype data to blend the genomic matrix with a customizable percentage of the \(A\) matrix.

The following command computes the lower inverse of the \(G\) matrix blended with 10% of the \(A\) matrix:

```bash
hginv -lower -m PvR1 -w 0.10 -A amatrix.amat  genotypes_recod iGL_w10.bin > out_hginv_g.txt
```

While the following command computes the lower inverse of the \(G\) matrix for ssGBLUP.

```bash
hginv -lower -m ost -w 0.10 -a freq.dat_allelef -A amatrix.amat genotypes_recod iGL_w10.bin > out_hginv_gssgblup.txt 
```
