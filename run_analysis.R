################################################################################
#                                                                              #
# run_analysis.R                                                               #
#                                                                              #
# Author: Andreas Renner                                                       #
# Date: 2018-01-31                                                             #
#                                                                              #
#                                                                              #
# This R script performs the following steps:                                  #
#                                                                              #
# - Merges the training and the test sets to create one data set.              #
# - Extracts only the measurements on the mean and standard deviation for each #
#   measurement.                                                               #
# - Uses descriptive activity names to name the activities in the data set     #
# - Appropriately labels the data set with descriptive variable names.         #
# - From the data set in step 4, creates a second, independent tidy data set   #
#   with the average of each variable for each activity and each subject.      #
#                                                                              #
# The script assumes that the working directory contains a directory "UCI HAR  #
# Dataset" which contains the unaltered UCI HAR data set.                      #
#                                                                              #
################################################################################

### Load libraries ###
library(dplyr)
library(tidyr)


### Read in tables ###
# Common data
activity_labels <- read.csv(file.path("UCI HAR Dataset", "activity_labels.txt"),
                            sep = " ", header = FALSE, col.names = c("id", "activity"))
features <- read.csv(file.path("UCI HAR Dataset", "features.txt"),
                     sep = " ", header = FALSE, col.names = c("id", "feature"))

# Training data
subject_train <- read.csv(file.path("UCI HAR Dataset", "train", "subject_train.txt"),
                          sep = " ", header = FALSE, col.names = c("subject_id"))
X_train <- read.table(file.path("UCI HAR Dataset", "train", "X_train.txt"),
                      sep = "", header = FALSE)
y_train <- read.csv(file.path("UCI HAR Dataset", "train", "y_train.txt"),
                    sep = " ", header = FALSE, col.names = c("activity_id"))

# Test Data
subject_test <- read.csv(file.path("UCI HAR Dataset", "test", "subject_test.txt"),
                         sep = " ", header = FALSE, col.names = c("subject_id"))
X_test <- read.table(file.path("UCI HAR Dataset", "test", "X_test.txt"),
                     sep = "", header = FALSE)
y_test <- read.csv(file.path("UCI HAR Dataset", "test", "y_test.txt"),
                   sep = " ", header = FALSE, col.names = c("activity_id"))


### Name feature columns ###
# Store column positions of mean() and std() features. This should be done
# before renaming them.
features_meanstd <- grep("-mean\\(\\)|-std\\(\\)", features$feature)

# Remove parentheses from feature names; replace commas and dashes with
# underscores
# Note: I feel variable names this long without underscores (or camel case) are
# unreadable. So sue me! ;-)
features_renamed <- gsub("[()]", "", features$feature)
features_renamed <- gsub("[,-]", "_", features_renamed)

# Add feature names as column names to X-files
# [Step 4] Appropriately labels the data set with descriptive variable names.
names(X_test) <- features_renamed
names(X_train) <- features_renamed


### Combine tables and select relevant columns ###
# Select relevant subset of columns (mean() and std()) in train and test sets
# [Step 2] Extracts only the measurements on the mean and standard deviation for
# each measurement.
X_test_meanstd <- X_test[,features_meanstd]
X_train_meanstd <- X_train[,features_meanstd]

# cbind() tables for training and test sets separately first to prevent row
# reordering (not that that would happen in R)
train_joined <- cbind(X_train_meanstd, y_train, subject_train, source_set = "train")
test_joined <- cbind(X_test_meanstd, y_test, subject_test, source_set = "test")

# Combine train and test sets into one data set
# [Step 1] Merges the training and the test sets to create one data set.
merged_set <- rbind(train_joined, test_joined)

# Add descriptive activity labels
# [Step 3] Uses descriptive activity names to name the activities in the data set
merged_with_activity <- merge(merged_set, activity_labels, by.x = "activity_id", by.y = "id")


### Tidy up and produce result table ###
# [Step 5] From the data set in step 4, creates a second, independent tidy data
# set with the average of each variable for each activity and each subject.

# Gather feature columns
merged_tdf <- tbl_df(merged_with_activity)
tidy <- merged_tdf %>%
        gather(feature, feature_value, tBodyAcc_mean_X:fBodyBodyGyroJerkMag_std) %>%
        select(source_set, subject_id, activity, feature, feature_value) %>%
        arrange(source_set, subject_id, activity, feature, feature_value)

# Group and summarize
tidy_mean <- tidy %>%
        group_by(activity, subject_id, feature) %>%
        summarize(mean_value = mean(feature_value))

# Write out final result to text file
#write.table(tidy_mean, "tidy_mean.txt", row.name=FALSE)

# OUtput result
tidy_mean


