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
## Fix the column names (currently starts at Var2...)
##

design_table <- function(s) {
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
      # Split the string around the semicolons,
      # then commas, then trim whitespace
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
      ## for i = 2 where the second list only had one element. Then
      ## expand.grid is applied over these elements
      p <- do.call(expand.grid, c(list(1:n_replicates), lapply(
        values,
        function(x) {
          if (i <= length(x)) {
            x[[i]]
          } else {
            # if the list is shorter than the others, just use the last element
            x[[length(x)]]
          }
        }
      )))
      result <- rbind(result, p)
    }

    final <- full_join(final, result)
  }

  final %<>% select(-1) %>% arrange(across(everything()))

  # convert purely numeric variables to numeric
  for (col in names(final)) {
    if (!any(is.na(as.numeric(as.vector(pull(final, col)))))) {
      final[, col] <- as.numeric(as.vector(pull(final, col)))
    }
  }

  return(final)
}