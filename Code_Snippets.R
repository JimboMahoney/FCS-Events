# Very fast method of getting number of events and parameters from FCS files


if (!require("svDialogs")) {
  install.packages("svDialogs", dependencies = TRUE)
  library(svDialogs)
}

if (!require("scales")) {
  install.packages("scales", dependencies = TRUE)
  library(scales)
}

if (!require("tcltk2")) {
  install.packages("tcltk2", dependencies = TRUE)
  library(tcltk2)
}



# Get user input for file
testfile<-dlg_open()
# Convert to string value
testfile <- capture.output(testfile)[7]

#Remove invalid characters from file input location
testfile <- gsub("[\"]","",testfile)
testfile<-substring (testfile,5)

#Set file and directory
file <- basename (testfile)
dir <- dirname (testfile)

# Set working directory accoding to file chosen
setwd(dir)

# List FCS (and fcs!) files in this location
filesToOpenList <- unique(c(list.files(dir,pattern = ".FCS"),list.files(dir,pattern = ".fcs")))

# Ask to open all files
if (length(filesToOpenList)>1){
  OpenAllFiles <- askYesNo("Analyse All FCS Files in this directory?")
}


# Open all FCS files
if (OpenAllFiles==TRUE){
  
  Events <- NULL
  Params <- NULL
  for (i in filesToOpenList){
    # Scan first few lines of FCS file(s)
    temp <- scan(i, what="", n=20)
    
    # Number of Events in FCS file
    # $TOT\f for Aria / Canto
    # $TOT/ for CyTOF
    
    Events <- c(Events, as.numeric(sub(".*\\$TOT/([0-9]+).*|.*\\$TOT\f([0-9]+).*", "\\1", temp[grep("TOT", temp)])))
    
    # Number of parameters
    Params <- c(Params, as.numeric(sub(".*\\$PAR/([0-9]+).*|.*\\$PAR\f([0-9]+).*", "\\1", temp[grep("PAR", temp)])))
  }
}else{
  # Ask which files to open
  filesToOpenList <- tk_select.list(filesToOpenList, multiple=TRUE,title="Select files to use.") 
  
  Events <- NULL
  Params <- NULL
  for (i in filesToOpenList){
    # Scan first few lines of FCS file(s)
    temp <- scan(i, what="", n=20)
    
    # Number of Events in FCS file
    # $TOT\f for Aria / Canto
    # $TOT/ for CyTOF
    
    Events <- c(Events, as.numeric(sub(".*\\$TOT/([0-9]+).*|.*\\$TOT\f([0-9]+).*", "\\1", temp[grep("TOT", temp)])))
    
    # Number of parameters
    Params <- c(Params, as.numeric(sub(".*\\$PAR/([0-9]+).*|.*\\$PAR\f([0-9]+).*", "\\1", temp[grep("PAR", temp)])))
  
  }
}

# Show table
cbind("Files" = filesToOpenList, "Events" = scales::comma(Events), Params)
