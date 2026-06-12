This program estimates \(G^{-1}\) and \(H^{-1}\) matrices and writes the lower diagonal format required for use in Mix99 programs.

The first step is to use Relax2 to construct the \(A\) matrix based on the pedigree file. (save as LOWER)

The program then uses this matrix together with genotype data to blend the genomic matrix with a customizable percentage of the \(A\) matrix.

The following command computes the lower inverse of the \(G\) matrix blended with 10% of the \(A\) matrix:

```bash
hginv -lower -w 0.10 -A amatrix.amat -m PvR1 genotypes_recod iGL_w10.bin > out_hginv_g.txt
