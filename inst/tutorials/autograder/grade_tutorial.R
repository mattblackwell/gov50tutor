#######################################################
# gov50tutor Tutorial Autograder
# Fall 2022
# Author: Matthew Blackwell
# Adapted from R assignment for Gradescope
#   example by Michael Guerzhoy guerzhoy@princeton.edu.
#   with additions from Tyler Simko
#######################################################


#######################################################




#######################################################
# START FILE SETUP
# This segment sets up the files needed for Gradescope.


filename <- Sys.getenv("SUBMIT_FILE")
assignment_title_env_var = Sys.getenv(c("ASSIGNMENT_TITLE"))
# Check for the existence of an environment variable called "ASSIGNMENT_TITLE"

if (assignment_title_env_var != "") {
  # If the environment variable is not empty, we're in Gradescope,
  # so set the output correctly for Gradescope to find it
  json.filename <- "/autograder/results/results.json"
  subjson.filename <- "/autograder/submission_metadata.json"
} else {
  # If the environment variable is empty, we're working locally,
  # so just put the output in this same directory.
  filename <- "report.pdf"
  json.filename <- "results.json"
  subjson.filename <- "submission_metadata.json"
}

# END FILE SETUP
#######################################################

#######################################################
# START ASSIGNMENT7 SETUP
# This section is for things needed to assess the submitted
# file(s) that aren't the actual tests. This is a good place
# to load sample data and set up structures needed for testing.

# Loading necessary libraries.
library(jsonlite)

my.toString <- function(obj) toString(obj)

metadata <- jsonlite::read_json(subjson.filename)
gs_name <- metadata$users[[1L]]$name
tutorial_name <- metadata$assignment$title

txt <- lapply(
  strsplit(pdftools::pdf_text(filename), "\n"),
  trimws
)

test_submission <- function() {
  tut_name_correct <- grepl(tutorial_name, txt[[1L]][1])
  ## name_correct <- length(
  ##   agrep(
  ##     txt[[1L]][3],
  ##     gs_name,
  ##     ignore.case = TRUE,
  ##     max = 3
  ##   )
  ## )

  if (tut_name_correct) {
    return("Looks good!")
  } else {
    return("Either the tutorial name or the student name is incorrect.")
  }
}

#######################################################
# This section is where a list of tests is created. Each
# test in the list has several parts:
# name: the name of the evaluation criterion shown to students
# fun: the function to be run, as a text string
# args: the arguments provided to that function, as a list of objects
# expect: the expected output of `fun`, as an R object
# visibility: whether this criterion will be shown to students. Accepted values are "visible" and "hidden"
# weight: the number of points possible for this criterion

test.cases <- list(
  list(
    name = "Submission Test: PDF from the right tutorial number and has your name.",
    fun = "test_submission",
    args = list(),
    expect = "Looks good!",
    visibility = "visible",
    weight = 1
  )
)

# END TEST SETUP
#######################################################

#######################################################
# START RUN TESTS
# The rest of the code runs the tests, then prepares the JSON output appropriately.
# You probably don't want to edit it unless you have to.



# This used to be a check for `visible` in the `ret` object, but now it's a check
# for "message" because that should be in the message returned by knitting the markdown

tests <- list()
tests[["stdout_visibility"]] <- "visible"
tests[["tests"]] <- list()
for(i in 1:length(test.cases)){
  cur.name <- test.cases[[i]][["name"]]
  cur.fun <- test.cases[[i]][["fun"]]
  cur.args <- test.cases[[i]][["args"]]
  cur.expect <- test.cases[[i]][["expect"]]
  cur.vis <- test.cases[[i]][["visibility"]]
  cur.weight <- test.cases[[i]][["weight"]]
  ret.val <- tryCatch(do.call(cur.fun, cur.args), error = function(c) c, warning = function(c) c ,message = function(c) c)

  cur.output <- ""


  if(my.toString(ret.val) == my.toString(cur.expect)){
    cur.score <-  cur.weight
    cur.output <- "Test passed!\n"
  }else{
    cur.score <- 0
    cur.output <- paste(
      "Test failed!\n",
      #"\n\nExpected:", my.toString(cur.expect),
      "\n\nMessage:", my.toString(ret.val))
  }
  tests[["tests"]][[i]] <- list(name = cur.name,
                                score = cur.score,
                                max_score = cur.weight)

  tests[["tests"]][[i]][["output"]] <- cur.output

  if(cur.vis != "visible"){
    tests[["tests"]][[i]][["visibility"]] <- cur.vis
  }
}

cat.tests <- function(tests){
  for(i in 1:length(tests[["tests"]])){
    cur.name <- test.cases[[i]][["name"]]
    cur.fun <- test.cases[[i]][["fun"]]
    cur.args <- test.cases[[i]][["args"]]
    cur.expected <- test.cases[[i]][["expect"]]
    cur.output <- tests[["tests"]][[i]][["output"]]
    score <- tests[["tests"]][[i]][["score"]]
    max_score <- tests[["tests"]][[i]][["max_score"]]



    cat(sprintf("Test %s: %s(%s)\n", cur.name, cur.fun, my.toString(cur.args)))
    cat(sprintf("Expected: %s\n", my.toString(cur.expected)))
    cat(sprintf("Output:\n %s\n", my.toString(cur.output)))
    cat(sprintf("Score: %g/%g\n", score, max_score))
    cat("====================================================\n\n\n")

  }
}
cat.tests(tests)
write(toJSON(tests, auto_unbox = T), file = json.filename)

# END RUN TESTS
#######################################################
