This program estimates \(G^{-1}\) and \(H^{-1}\) matrices and writes the lower diagonal format required for use in Mix99 programs.

The first step is to use Relax2 to construct the \(A\) matrix based on the pedigree file.

The program then uses this matrix together with genotype data to blend the genomic matrix with a customizable percentage of the \(A\) matrix.

The following command computes the lower inverse of the \(G\) matrix blended with 10% of the \(A\) matrix:

```bash
hginv -lower -w 0.10 -A amatrix22_2500_5488.amat -m PvR1 genotipos_recod2500_5488 iGL_w20_5488.bin > out_hginv_g.txt
