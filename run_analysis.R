# Load packages
library(dplyr)
library(data.table)

#downlaod file and put in the 'data' folder - if doesnt exist create one
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

# unzip folder and save into 'data'folder'
unzip(zipfile="./data/Dataset.zip",exdir="./data")


# read train data 
x_train   <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train   <- read.table("./data/UCI HAR Dataset/train/Y_train.txt") 
sub_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

# read test data 
x_test   <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test   <- read.table("./data/UCI HAR Dataset/test/Y_test.txt") 
sub_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# read features description 
features <- read.table("./data/UCI HAR Dataset/features.txt")

# read activity lables description 
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")

# merging test and train data sets by rows 
Subject <- rbind(sub_train, sub_test)
X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)

# Extracts the rows from the features data set measurements only for mean and standard deviation 
sel_features <- features[grep(".*mean\\(\\)|std\\(\\)", features[,2]),]

# set variable names for the merged data sets
names(Subject) <- c("subject")
names(Y) <- c("activity")
X <- X[, sel_features[, 1]]

# Combine all 3 data sets together
Merged_data <- cbind(Subject, Y, X)

#rename lables appropriately
names(Merged_data) <-gsub("Acc", "Accelerometer", names(Merged_data))
names(Merged_data) <-gsub("Gyro", "Gyroscope", names(Merged_data))
names(Merged_data) <-gsub("BodyBody", "Body", names(Merged_data))
names(Merged_data) <-gsub("Mag", "Magnitude", names(Merged_data))
names(Merged_data) <-gsub("^t", "Time", names(Merged_data))
names(Merged_data) <-gsub("^f", "Frequency", names(Merged_data))
names(Merged_data) <-gsub("tBody", "TimeBody", names(Merged_data))
names(Merged_data) <-gsub("-mean()", "Mean", names(Merged_data), ignore.case = TRUE)
names(Merged_data) <-gsub("-std()", "STD", names(Merged_data), ignore.case = TRUE)
names(Merged_data) <-gsub("-freq()", "Frequency", names(Merged_data), ignore.case = TRUE)
names(Merged_data) <-gsub("angle", "Angle", names(Merged_data))
names(Merged_data) <-gsub("gravity", "Gravity", names(Merged_data))


# From the Merged Data set create a indenpendent tidy data set with the average for each variable for each activity and subject
TidyData <- Merged_data %>%
  group_by(subject, activity) %>%
  summarise_all(funs(mean)) %>%
  write.table("TidyData.txt", row.name=FALSE) 
