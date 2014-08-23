# Getting and cleaning data Project
  
# download the data and load it into R  

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
download.file(fileUrl,destfile="dataset.zip")
dateDownloaded <- date() # make a note of date downloaded
unzip("dataset.zip") # unzip the file

# read in the column/variable names:
colNames <- read.table("UCI HAR Dataset/features.txt")
# read in the training/testing data with column names attached, using check.names so that the column names aren't altered
train <- read.table("UCI HAR Dataset/train/X_train.txt",col.names=colNames[,2], check.names=FALSE)
trainLabels <- read.table("UCI HAR Dataset/train/y_train.txt")
trainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt")
test <- read.table("UCI HAR Dataset/test/X_test.txt",col.names=colNames[,2], check.names=FALSE)
testLabels <- read.table("UCI HAR Dataset/test/y_test.txt")
testSubject <- read.table("UCI HAR Dataset/test/subject_test.txt")


# Add the activity labels to the data
trainL <- cbind(train,trainLabels)
testL <- cbind(test,testLabels)
# add in the subject labels
trainL <- cbind(trainLabels,trainL)
testL <- cbind(testLabels,testL)
# merge the training and testing datasets:
allData <- rbind(trainL,testL)


# Sort out the column names:
# name the subject column
colnames(allData)[1] <- "subject"
allData$subject <- factor(allData$subject) # factorise subject
# name the labels column:
colnames(allData)[563] <- "activity"
# convert the activity labels to descriptive names (factors)
allData$activity <- factor(allData$activity,labels=c("walking","walkingUpstairs","walkingDownstairs","sitting","standing","laying"))

# removing dashes, brackets and commas from all variable names to make them more appropriate
colnames(allData) <- gsub("-|,|\\(|\\)", "", colnames(allData))


# extract the columns that contain the means and standard deviations
meanStdData <- allData[,grepl( "mean|Mean|std" , names( allData ) )]
# attach the subject and activity labels to the extracted data
meanStdData <- cbind(allData[,c(1,563)], meanStdData)

# melt the data
dataMelt <- melt(meanStdData,id=c("subject","activity"))

# finally create the tidy dataset by calculating the average of each variable for each activity and each subject
library(plyr)
tidy <- ddply(meanStdMelt, c("activity", "subject", "variable"), summarise,mean = mean(value))

# save to txt file
write.table(tidy, "tidyDataset.txt", sep="\t", row.name=FALSE) 
