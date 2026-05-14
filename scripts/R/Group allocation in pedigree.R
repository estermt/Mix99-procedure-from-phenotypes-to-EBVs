# PEDIGRI AND GENOTYPES FORMATTING FOR MIX99
library(data.table)
library(dplyr)
library(plyr)
library(lubridate)
library(ggplot2)
library(tidyverse)
library(stringr)
# Read ped file

pedigree <- read.table("path/pedigree", quote="\"", comment.char="")

# Read data file

bd=read.table("path/phenotypes.dat", header = F,na="-999.9")
# recod grupo 
colSums(is.na(bd))
# Change the format so that all values are two characters long
bd$group=as.factor(bd$V2)
bd$group = sprintf("%02d", as.numeric(bd$group))
# Reorder dataset by group and save the group code
bd_ordenado <- bd %>%
  arrange(group)
codigo_granja=unique(bd[,c(2,9)])
write.table(codigo_granja,"path/code_granja.dat",col.names = F,row.names = F,quote=F,na="-999.9")
plot(bd_ordenado$V7,bd_ordenado$V8) # visualize the phenotypic relationship between the two traits to evaluate

bd1=bd_ordenado[,c(1,9,3:6,7,8)] # reorder the traits as you preferences, recomended: id group fix effects random effects and dependent variables

write.table(bd1,"path/phenotypes_recoded.dat",col.names = F,row.names = F,quote=F,na="-999.9")
# Check if all the ids are in the pedigree
ids=unique(bd1[,1]) #5340 5488
pedids<- pedigree[pedigree$ID%in%ids,]

# Check the number of ids with sire and dam unknown
sinpadmad=pedids%>%filter(V2=="00000000000000" & V3=="00000000000000") #35

# Join ped with data file to obtain the group in the ped file
id_group=unique(bd[,c(1,9)])
ped=merge(pedigree,id_group,by.x = "ID",by.y = "V1",all.x = T)

pedigree=ped
# =============================================================================
# GROUP ALLOCATION IN PEDIGRI
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Rename columns and save original IDs
# -----------------------------------------------------------------------------
ids_originales <- pedigree$ID
names(pedigree)[3] <- "SIRE"
names(pedigree)[4] <- "DAM"

# -----------------------------------------------------------------------------
# 2. Expand pedigree: add rows for SIRE/DAM not present in ID
# -----------------------------------------------------------------------------
all_ids <- unique(c(pedigree$ID, pedigree$SIRE, pedigree$DAM))
all_ids <- all_ids[!is.na(all_ids)]
pedigree$group <- as.numeric(pedigree$group)
extra_rows <- data.frame(
  ID      = setdiff(all_ids, pedigree$ID),
  SIRE    = NA_character_,
  DAM     = NA_character_,
  ganlact = NA_character_,
  group   = NA_real_,
  stringsAsFactors = FALSE
)
pedigree <- bind_rows(pedigree, extra_rows)
pedigree$group <- as.numeric(pedigree$group)

# -----------------------------------------------------------------------------
# 3. Build COMPLETE lookups (including extra_rows)
#    *** KEY: these must be built AFTER expanding the pedigree ***
# -----------------------------------------------------------------------------
dams   <- setNames(pedigree$DAM,   pedigree$ID)
sires  <- setNames(pedigree$SIRE,  pedigree$ID)
grupos <- setNames(pedigree$group, pedigree$ID)

# -----------------------------------------------------------------------------
# 4. Identify sires (IDs that are in the SIRE column)
# -----------------------------------------------------------------------------
ids_sire <- unique(pedigree$SIRE[!is.na(pedigree$SIRE)])
cat(sprintf("Identified males (listed as SIRE): %d\n", length(ids_sire)))

# -----------------------------------------------------------------------------
# 5. Upstream propagation function along the maternal line
#    - Travels up the DAM from start_id
#    - Only assigns if the ancestor has no group (override = FALSE)
#    - Returns the updated groups vector
# -----------------------------------------------------------------------------
propagar_materna_upstream <- function(id_inicio, grp, dams, grupos,
                                      sobrescribir = FALSE) {
  actual    <- dams[id_inicio]   # primera DAM
  visitados <- character(0)
  
  while (!is.na(actual) && nchar(actual) > 0 && !actual %in% visitados) {
    visitados <- c(visitados, actual)
    
    if (sobrescribir || is.na(grupos[actual])) {
      grupos[actual] <- grp
    }
    # Subir al siguiente nivel
    siguiente <- dams[actual]
    if (is.null(siguiente) || length(siguiente) == 0) break
    actual <- siguiente
  }
  return(grupos)
}

# -----------------------------------------------------------------------------
# 6. Step A– females with the following phenotype: propagate their group upstream
#    - Only females (not in ids_sire) with a group already assigned by a previous merge
#    - Do not overwrite: respect groups already assigned to ancestors
# -----------------------------------------------------------------------------
con_fenotipo <- pedigree$ID[
  !is.na(pedigree$group) &
    !pedigree$ID %in% ids_sire
]
cat(sprintf("Females with a phenotype to be propagated: %d\n", length(con_fenotipo)))

for (animal in con_fenotipo) {
  grp <- grupos[animal]
  if (is.na(grp)) next  # seguridad extra
  
  grupos <- propagar_materna_upstream(
    id_inicio    = animal,
    grp          = grp,
    dams         = dams,
    grupos       = grupos,
    sobrescribir = FALSE
  )
}

# -----------------------------------------------------------------------------
# 7. Step B – Males: assign a unique group and propagate upstream
#    new_group = max(existing_groups) + 1
#    Do not overwrite groups already assigned in the maternal line
# -----------------------------------------------------------------------------
nuevo_grupo <- max(grupos, na.rm = TRUE) + 1
cat(sprintf("Group assigned to males and their maternal lineage: %d\n", nuevo_grupo))

for (macho in ids_sire) {
  # Asignar grupo al macho (solo si no tiene)
  if (is.na(grupos[macho])) {
    grupos[macho] <- nuevo_grupo
  }
  # Propagar hacia arriba por línea materna
  grupos <- propagar_materna_upstream(
    id_inicio    = macho,
    grp          = nuevo_grupo,
    dams         = dams,
    grupos       = grupos,
    sobrescribir = FALSE
  )
}

cat(sprintf(
  "Males + maternal ancestors assigned to the group %d: %d\n",
  nuevo_grupo,
  sum(grupos == nuevo_grupo, na.rm = TRUE)
))

# -----------------------------------------------------------------------------
# 8. Write the results back to the data.frame
# -----------------------------------------------------------------------------
pedigree$group <- grupos[pedigree$ID]

# Diagnóstico final
cat(sprintf("IDs con grupo asignado:    %d\n", sum(!is.na(pedigree$group))))
cat(sprintf("IDs sin grupo asignado:    %d\n", sum( is.na(pedigree$group))))
cat(sprintf("Grupos únicos asignados:   %d\n", length(unique(na.omit(pedigree$group)))))
# ordenar pedigri
pedigree_sorted <- pedigree %>%
  arrange(group)
pedigree_sorted <- pedigree_sorted[!is.na(pedigree_sorted$group), ]
pedigree_sorted1=pedigree_sorted[,c(1,3,4,8)]
pedigree_sorted1$group= sprintf("%02d", as.numeric(pedigree_sorted1$group))
write.table(pedigree_sorted1,"path/pedigree_5488.txt",col.names = F,row.names = F,quote=F)


