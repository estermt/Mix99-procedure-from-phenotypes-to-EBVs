## Format for data files
# Phenotypic data set
- It should be a text file with columns separated by one or more spaces
- It must contain only numeric traits ==> use relax2 to renumber ids and groups (link to parameter file to relax2)
- The order of traits should be the same as that claimed in the parameter file for mix99i, random at the end in the model

# Pedigree
- It should be a text file with columnd separated by one or more spaces
- The order of columns is usually ID SIRE DAM, but it can be different as well as it being stated in the parameter file for relax2.
- In Relax2, there are four ways to give the location information in the record statement:
1. record id sire dam; if it is integer
2. record id 1 sire 2 dam 3; if it is integer
3. record id 1:4 sire 6:9 dam 11:14; if they are integer values within the character positions
4. record id $ 1:4 sire $ 6:9 dam $ 11:14; if it is alpha-numerical text
- The fourth column could be the group (genetic group, family group, farm) and it is useful for speeding up the process of solving equations in Mix99 (optional).

# Genotypes
- The format has to have ID + space+ genotype(0 1 2), separated by space

