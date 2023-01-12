library(stringr)
library(tidyr)
library(dplyr)
library(magrittr)
library(tibble)

# Clean the environment
rm(list = ls())

# Todos:
##
## Improve the description and move to readme
##
## Fix numeric factor columns not sorting according to numeric order
##
## Replace NA empty indices with NULL or 0
##
## Fix the column names (currently starts at Var2...)
##
## Account for the case (A; B; C)(a; b1, b2), i.e., when we want b1, b2 to
## be applied B and C as they would in the case (B; C)(b1, b2).

# Prompt
##
## The syntax is as follows:
##
## Each parameter in the experiment (e.g., treatment, time, concentration, etc)
## should be enclosed within parentheses "(myparam1)(myparam2)(myparam3)(etc..)"
## within each parameter, you can have several values - these should be ";"
## separated like so "(param_val_1; param_val_2)". When computing combinations
## of parameters, the script looks from left to right, so
## in "(param1_val_1; param1_val_2)(param2_val_1; param2_val_2)", param1_val_1
## gets paired with param2_val_1, etc. Values can be further subdivided in to
## comma separated subvalues. This is useful when different ranges of
## conditions in one parameter apply to different values in another.
## For example, you might test two drugs using two different dosing schemes:
## (DrugA, DrugB)(1mg/kg, 3mg/kg; 10mg/kg, 100mg/kg) will apply 1mg/kg and
## 3mg/kg for DrugA and 10mg/kg and 100mg/kg for DrugB. To add experimental
## replicates, just put a number anywhere between the brackets to indicate
## your n number. Sometimes you might have an experiment that mixes different
## numbers of replicates (a positive control in singlicate for example) -
## you can handle these mixed designs by separating them with a "+" symbol,
## e.g., 2(drugA)(1mg/kg, 3mg/kg) + 3(DrugB)(10mg/kg, 100mg/kg)

s <- "(Control; KO)(SubCA, SubCB; SubKA, SubKB)(untreated, treated)"

subexpts <- unlist(strsplit(s, split = "\\+"))

final <- as_tibble(data.frame(matrix(nrow = 0, ncol = 1)))
colnames(final) <- "Var1"
for (s in subexpts) {

  # Extract the replicate index (discard all but the first number encountered)
  n_replicates <- s %>%
    str_extract_all("\\)\\d+|\\d+\\(") %>%
    unlist() %>%
    .[1] %>%
    str_replace_all("\\(|\\)", "")

  if (is.na(n_replicates)) {
    n_replicates <- 1
  }

  # Extract the multiplicands
  contents <- s %>%
    str_extract_all("\\([^\\(\\)]*\\)") %>%
    unlist() %>%
    str_replace_all("\\(|\\)", "")

  # Create a list of lists to store the values for each multiplicand
  values <- list()

  for (i in contents) {
    # Split the string around the semicolons, then commas, then trim whitespace
    elements <- i %>%
      str_split(";") %>%
      unlist() %>%
      lapply(function(x) unlist(str_split(x, ","))) %>%
      lapply(trimws)

    # Nest the elements list within the values list
    values <- c(values, list(elements))
  }

  # Compute cartesian products of correspondant elements of all of the lists
  # nested within the values list

  result <- data.frame(matrix(nrow = 0, ncol = 1))
  colnames(result) <- "Var1"
  # loop over the *inner* list indices
  for (i in 1:length(values[[1]])) {
    # apply expand.grid to the ith inner list elements
    ## note lapply will generate a new list of elements, e.g.,
    ## newlist = { values[[1]][[2]], values[[2]][[1]], values[[3]][[2]] }
    ## assuming i = 2 and the second list only had one element. Then
    ## expand.grid is applied over these elements
    p <- do.call(expand.grid, c(list(1:n_replicates), lapply(
      values,
      function(x) {
        if (i <= length(x)) {
          x[[i]]
        } else {
          x[[1]]
        }
      }
    )))
    result <- rbind(result, p) # we don't need to replicates column
  }

  final <- full_join(final, result)
}

final %<>% select(-1) %>% arrange(across(everything()))
