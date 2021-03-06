#----------------------------------------------------------------------------#

#' Load or install R packages (from CRAN or Github (Public or Private Repositories)).
#'
#' Given a list of packages (e.g. list("data.table", "claramarquardt/ehR")) install (where necessary)/load all packages from CRAN/Github as appropriate.
#'
#' @details Maintained by: Clara Marquardt
#'
#' @export
#' @import data.table
#' @import devtools
#'
#' @param package_list List of package names which are to be installed/loaded (list - character).
#' @param custom_lib_path Custom library path (character) [Default: Default library path].
#' @param custom_repo R repository from which to download packages [Default: https://cran.rstudio.com"]
#' @param custom_package_version Whether to take into account version specifications for key packages (data.table, ggplot2) (logical - TRUE/FALSE) [Default: TRUE]. 
#' @param verbose Verbosity (logical - TRUE/FALSE) [Default: TRUE]. 
#' @param github_auth_token Github API Authentication Token (only needed if installing Github repos from a private repository) (string) [Default: NA].
#'
#' @return List of packages which were successfully installed/loaded. 
#'
#' @examples \dontrun{
#' package <- list("data.table", "trinker/plotflow")
#' load_or_install(package_list=package, custom_lib_path=paste0(getwd(), "/test/"), 
#'  quiet=FALSE)
#' }

load_or_install <- function(package_list, custom_lib_path="", 
  custom_repo="https://cran.rstudio.com", custom_package_version=TRUE, 
  quiet=FALSE, github_auth_token=NA) {  

  # Point Person: Clara

  # library path
  # -----------------------------

  ## default
  lib_path     <- .libPaths()[1]

  ## custom 
  if (custom_lib_path!="") {

    if (!dir.exists(custom_lib_path)) {
      dir.create(custom_lib_path)
    }

    lib_path   <- custom_lib_path
    .libPaths(custom_lib_path)

  } 

  print(sprintf("lib_path: %s", lib_path))

  # devtools
  # ----------------------------
  library(devtools)

  # install 
  # ----------------------------
  invisible(lapply(package_list, function(x) if(!gsub("(.*)/(.*)", "\\2", x) %in% c(installed.packages(
       lib.loc=lib_path))) {
  

    # cran package
    if (length(grep("/", x, value=T))==0) {

      if (quiet==FALSE) {

        print(sprintf("Fresh Install (CRAN): %s", x))

      }

      # special case - "data.table" (1.9.6 version)
      if (x=="data.table" & custom_package_version==TRUE) {
    
        suppressMessages(withr::with_libpaths(new = lib_path,
            install_version("data.table", version = "1.9.6",
            repos = custom_repo,
            dependencies=TRUE)))
    
      # special case - "ggplot" (dev version)
      } else if (x=="ggplot2" & custom_package_version==TRUE) {
        
          suppressMessages(withr::with_libpaths(new = lib_path, 
            install_github("hadley/ggplot2")))

       } else {
    
          suppressMessages(install.packages(x,repos=custom_repo, 
              dependencies=TRUE, lib=lib_path))
    
        }

    # github package
    } else {

      if (quiet==FALSE) {

        print(sprintf("Fresh Install (Github): %s", x))

      }

      if (is.na(github_auth_token)) {
        suppressMessages(withr::with_libpaths(new = lib_path, 
           install_github(x)))
      } else {  
        suppressMessages(withr::with_libpaths(new = lib_path, 
           install_github(x, auth_token=github_auth_token)))
     }
   
  }}))

  # load
  # -----------------------------

  package_loaded <- lapply(package_list, function(x) {
    
    if (quiet==FALSE) {
      print(sprintf("Loading: %s", x))
    }

    
    if (length(grep(x, installed.packages(lib.loc=lib_path), value=T))>0) {

      suppressMessages(library(gsub("(.*)/(.*)", "\\2", x),character.only=TRUE, quietly=TRUE,
        verbose=FALSE, lib.loc=lib_path))

    } else {
      
      suppressMessages(library(gsub("(.*)/(.*)", "\\2", x),character.only=TRUE, quietly=TRUE,
        verbose=FALSE))

    }

  })

  # output
  # -----------------------------
  cat("\n\n*****************\n\nThe Following Packages Were Successfully Installed/Loaded:\n\n")
  print(package_loaded[[length(package_list)]])
  cat("\n*****************\n\n")

  rm("package_loaded")

} 

#----------------------------------------------------------------------------#

