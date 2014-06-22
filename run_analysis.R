library(reshape2)
library(plyr)

## If the file does not exist, then downloads the file from the remote server.
destfile <- "./getdata-projectfiles-UCI HAR Dataset.zip"
if(!file.exists(destfile)) {
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl, destfile = destfile, method = "curl")
}

## If there is already a directory called "UCI HAR Dataset" then renames that directory as backup so it can be unziped 
## again and start working with a fresh copy of the data.
dataFolder <- "UCI HAR Dataset"
if(file.exists(dataFolder)) file.rename(dataFolder, paste(dataFolder, " - Backup", sample(1:200, 1), sep=""))

## Unzips dataset
unzip(destfile)

## Reads the data into the following variables:
## xTrain - 70% of all data, has no lables
## yTrain - Activity codes for the xTrain data
## xTest - 30% of all data, has no lables
## yTest - Activity codes for the xTest data
## features - Description for each variable in the datasets.
## activityLabels - Activity labels for each code in the yTest and yTrain datasets.
## subjectTrain - List of subjects for each observation in the Train group.
## subjectTest - List of subjects for each observation in the Test group.
xTrain <- read.table(paste("./", dataFolder, "/train/X_train.txt", sep = ""))
yTrain <- read.table(paste("./", dataFolder, "/train/y_train.txt", sep = ""))
xTest <- read.table(paste("./", dataFolder, "/test/X_test.txt", sep = ""))
yTest <- read.table(paste("./", dataFolder, "/test/y_test.txt", sep = ""))
features <- read.table(paste("./", dataFolder, "/features.txt", sep = ""))
activityLabels <- read.table(paste("./", dataFolder, "/activity_labels.txt", sep = ""))
subjectTrain <- read.table(paste("./", dataFolder, "/train/subject_train.txt", sep = ""))
subjectTest <- read.table(paste("./", dataFolder, "/test/subject_test.txt", sep = ""))

## Merges the training and the test sets to create one data set. This corresponds to the instruction number 1.
rawData <- rbind(xTrain, xTest)

## Gets the names for each column in the previously merged dataset and looks for the "-mean()" and "-std()" strings in the new vector containing
## the column names and creates two logical vectors for each comparison. Then takes the two logical vectors and creates one
## consolidated logical vector which turns TRUE if the column name has the "-mean()" OR the "-std()" strings in it.
meanLogical <- grepl("-mean()", features[,2], fixed = TRUE)
stdLogical <- grepl("-std()", features[,2], fixed = TRUE)
columnsLogical <- (meanLogical + stdLogical) > 0

## Extracts only the measurements on the mean and standard deviation for each measurement. This corresponds to the instruction
## number 2.
procData <- rawData[,columnsLogical]

## Uses descriptive activity names to name the activities in the data set. This corresponds to the instruction number 3.
activityCodes <- rbind(yTrain, yTest)
colnames(activityCodes) <- "actCodes"
colnames(activityLabels) <- c("actCodes", "actDesc")
activityDesc <- join(activityCodes, activityLabels)
procData <- cbind(activityDesc[,2], procData)

## Appropriately labels the data set with descriptive variable names. This corresponds to the instruction number 4.
labels <- as.character(features[columnsLogical, 2])
labels <- append("activityDesc", labels)
colnames(procData) <- labels

## Adds a column to the procData dataset which contains the subject code for each observation.
subjects <- rbind(subjectTrain, subjectTest)
colnames(subjects) <- "subject"
procData <- cbind(subjects, procData)

## Melts the data into a long version of it and then re-arrenge it by subject and activityDesc, including the mean
## for each variable.
dataMelt <- melt(procData, id=c("subject", "activityDesc"))
newData <- dcast(dataMelt, subject + activityDesc ~ variable, mean)

## Writes the new dataset into a file called tidyData.txt.
write.csv(newData, "tidyData.txt")
