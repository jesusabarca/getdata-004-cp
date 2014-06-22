run_analysis.R
========================================================

The purpose of this script is to obtain and process data from the "Human Activity Recognition Using Smartphones Data Set" (http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) to get a tidy dataset as the output.

The script is structured as follows:

1) Looks for the file at the current working directory, if the file does not exists, the script will download a copy of it and un compress it.

2) The result will be a new directory with data in simple text format. The script will read each file into the following variables:

    xTrain - 70% of all data, has no lables
    yTrain - Activity codes for the xTrain data
    xTest - 30% of all data, has no lables
    yTest - Activity codes for the xTest data
    features - Description for each variable in the datasets.
    activityLabels - Activity labels for each code in the yTest and yTrain datasets.
    subjectTrain - List of subjects for each observation in the Train group.
    subjectTest - List of subjects for each observation in the Test group.
    
3) Merges the xTrain and the xTrest sets to create one data set. This corresponds to the instruction number 1.

4) Gets the names for each column in the previously merged dataset and looks for the "-mean()" and "-std()" strings in the new vector containing the column names and creates two logical vectors for each comparison. Then takes the two logical vectors and creates one consolidated logical vector which turns TRUE if the column name has the "-mean()" OR the "-std()" strings in it with the following code:

    meanLogical <- grepl("-mean()", features[,2], fixed = TRUE)
    stdLogical <- grepl("-std()", features[,2], fixed = TRUE)
    columnsLogical <- (meanLogical + stdLogical) > 0
    
5) Using the logical vector created in the last step, extracts only the measurements on the mean and standard deviation for each measurement. This corresponds to the instruction number 2.

6) Merges the subjectTrain and subjectTest dataframes which have the codes for each activity. Then looks for the description for the activity codes in the activityLabels dataframe. Uses descriptive activity names to name the activities in the data set. This corresponds to the instruction number 3.

    activityCodes <- rbind(yTrain, yTest)
    colnames(activityCodes) <- "actCodes"
    colnames(activityLabels) <- c("actCodes", "actDesc")
    activityDesc <- join(activityCodes, activityLabels)
    procData <- cbind(activityDesc[,2], procData)

7) Appropriately labels the data set with descriptive variable names. This corresponds to the instruction number 4.

8) Adds a column to the procData dataset which contains the subject code for each observation.

9) Melts the data into a long version of it and then re-arrenge it by subject and activityDesc, including the mean for each variable.

    dataMelt <- melt(procData, id=c("subject", "activityDesc"))
    newData <- dcast(dataMelt, subject + activityDesc ~ variable, mean)
    
10) Writes the new dataset into a file called tidyData.txt.