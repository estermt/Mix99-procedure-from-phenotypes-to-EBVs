## Estimation of Variance Components with solver from mix99

- The MC REML is not implemented for ssGBLUP, it has to be estimated using a BLUP o GBLUP model.
- In the PARFILE command of .clm for PREPROCESSOR, change the use of H matrix for A matrix.
- Then use the VC obtained to implement in ssGBLUP.
- Check the convergence parameters.  
