# README
*Author: Andreas Renner*  
*Date: January 31, 2018*

## Contents

| File           | Description
| -------------- | ---
| README.md      | This file.
| CodeBook.md    | Code book describing result tables and the variables, the data, and any transformations that was performed to clean up the data.
| run_analysis.R | R script that transforms the "UCI HAR Dataset" into a tidy data set with the average of each variable for each activity and each subject.
| tidy_mean.txt  | The result of running `run_analysis.R`.


## Purpose
The R script performs the following steps on the "UCI HAR Dataset", as per *"Peer-graded Assignment: Getting and Cleaning Data Course Project"*:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


## Usage
Please make sure that the "UCI HAR Dataset" is present in the current working directory in a sub-directory called "UCI HAR Dataset". Running the R script will produce a data.frame containing tidy and aggregated data as requested by task 5 of the peer-graded assignment. Please refer to `CodeBook.md` and the source code comments in `run_analysis.R` for details on which transformations are performed.

***Note:** The script does not perform the steps in the order given. Therefore, tags in the form of `[Step <i>]` mark the instructions in the source code that perform a given step.*

