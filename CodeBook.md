# Code Book
*Author: Andreas Renner*  
*Date: January 31, 2018*


## Introduction
### Purpose
The purpose of this Code Book is to document the modifications applied to the UCI HAR Dataset. The ultimate results are a tidy version of the data set as well as a table containing an aggregated form of the tidy data set.

This was done for the "Peer-graded Assignment: Getting and Cleaning Data Course Project" which is part of Course 3 "Getting and Cleaning Data" of the Data Science Specialization by Johns Hopkins University on Coursera.


### UCI HAR Dataset
What follows is a complete listing of the UCI HAR Dataset's contents. Only the files given in bold have been used to construct the tables described further below.

<pre>
.
│
└───UCI HAR Dataset
    │   <b>activity_labels.txt</b>
    │   <b>features.txt</b>
    │   features_info.txt
    │   README.txt
    │
    ├───test
    │   │   <b>subject_test.txt</b>
    │   │   <b>X_test.txt</b>
    │   │   <b>y_test.txt</b>
    │   │
    │   └───Inertial Signals
    │           body_acc_x_test.txt
    │           body_acc_y_test.txt
    │           body_acc_z_test.txt
    │           body_gyro_x_test.txt
    │           body_gyro_y_test.txt
    │           body_gyro_z_test.txt
    │           total_acc_x_test.txt
    │           total_acc_y_test.txt
    │           total_acc_z_test.txt
    │
    └───train
        │   <b>subject_train.txt</b>
        │   <b>X_train.txt</b>
        │   <b>y_train.txt</b>
        │
        └───Inertial Signals
                body_acc_x_train.txt
                body_acc_y_train.txt
                body_acc_z_train.txt
                body_gyro_x_train.txt
                body_gyro_y_train.txt
                body_gyro_z_train.txt
                total_acc_x_train.txt
                total_acc_y_train.txt
                total_acc_z_train.txt
</pre>





## Steps Performed
The following steps have been performed to arrive at the final tables from the original tables. The complete R code can be found in `run_analysis.R`.


### 1. Name Feature Columns
Features from `features.txt` have been renamed; parentheses have been removed, commas and dashes have been replaced by underscores for better readability. The 561 renamed features have been applied to tables from `X_train.txt` and `X_test.txt` as column names in the order top->bottom (features) / left->right (columns).

***QC Note:** Feature names in `features.txt` are not unique! Out of 561 features names only 477 are unique. They do not cause any issues, however, since all of the relevant features containing averages and standard deviations have unique names.*


### 2. Select Relevant Columns
Only the measurements on the mean and standard deviation for each measurement have been extracted from tables `X_train` and `X_test`. These columns have been identified by containing either `-mean()` or `-std()` in their original name. The 66 relevant columns are listed below.

```{r}
 [1] tBodyAcc-mean()-X           tBodyAcc-mean()-Y           tBodyAcc-mean()-Z           tBodyAcc-std()-X
 [5] tBodyAcc-std()-Y            tBodyAcc-std()-Z            tGravityAcc-mean()-X        tGravityAcc-mean()-Y
 [9] tGravityAcc-mean()-Z        tGravityAcc-std()-X         tGravityAcc-std()-Y         tGravityAcc-std()-Z
[13] tBodyAccJerk-mean()-X       tBodyAccJerk-mean()-Y       tBodyAccJerk-mean()-Z       tBodyAccJerk-std()-X
[17] tBodyAccJerk-std()-Y        tBodyAccJerk-std()-Z        tBodyGyro-mean()-X          tBodyGyro-mean()-Y
[21] tBodyGyro-mean()-Z          tBodyGyro-std()-X           tBodyGyro-std()-Y           tBodyGyro-std()-Z
[25] tBodyGyroJerk-mean()-X      tBodyGyroJerk-mean()-Y      tBodyGyroJerk-mean()-Z      tBodyGyroJerk-std()-X
[29] tBodyGyroJerk-std()-Y       tBodyGyroJerk-std()-Z       tBodyAccMag-mean()          tBodyAccMag-std()
[33] tGravityAccMag-mean()       tGravityAccMag-std()        tBodyAccJerkMag-mean()      tBodyAccJerkMag-std()
[37] tBodyGyroMag-mean()         tBodyGyroMag-std()          tBodyGyroJerkMag-mean()     tBodyGyroJerkMag-std()
[41] fBodyAcc-mean()-X           fBodyAcc-mean()-Y           fBodyAcc-mean()-Z           fBodyAcc-std()-X
[45] fBodyAcc-std()-Y            fBodyAcc-std()-Z            fBodyAccJerk-mean()-X       fBodyAccJerk-mean()-Y
[49] fBodyAccJerk-mean()-Z       fBodyAccJerk-std()-X        fBodyAccJerk-std()-Y        fBodyAccJerk-std()-Z
[53] fBodyGyro-mean()-X          fBodyGyro-mean()-Y          fBodyGyro-mean()-Z          fBodyGyro-std()-X
[57] fBodyGyro-std()-Y           fBodyGyro-std()-Z           fBodyAccMag-mean()          fBodyAccMag-std()
[61] fBodyBodyAccJerkMag-mean()  fBodyBodyAccJerkMag-std()   fBodyBodyGyroMag-mean()     fBodyBodyGyroMag-std()
[65] fBodyBodyGyroJerkMag-mean() fBodyBodyGyroJerkMag-std()
```


### 3. Adding Columns
In the original data set columns of a single table are split across multiple files. Specifically, the subject ID and activity ID are stored in their own files --- `subject_train.txt` / `subject_test.txt` and `y_train.txt` / `y_test.txt` respectively --- separate from the main tables' files `X_train.txt` and `X_test.txt`.

For both sets, training and test, the X, y and subject files have been combined into one table by binding (**not** merging in the R sense or joining in the SQL sense) the columns together. This has been done early to prevent any accidental re-ordering of rows.

Additionally, a column `source_set` has been added to indicate whether any given row came from the training or test set. At this point, the table has 69 columns.


### 4. Merging Training and Test Data
Training and test data have been combined into a single table by rows (rbind in R / UNION in SQL). This was possible as both tables already had the same column structure. The source set name is stored in column `source_set`.


### 5. Adding Activity Label
The activity is given as numerical ID in the original data set's files `y_train` and `y_test` while the human-readable labels are found in a lookup table in `activity_labels.txt`. Thes labels have ben joined to the combined table from the previous step.


### 6. Pivoting features
Each of the 66 relevant features had its own column in the current table. However, each feature is its own observation and should therefore be stored in rows. Using tidyr's gather() function, these columns have been pivoted with the feature name stored in column `feature` and the corresponding value in column `feature_value`.

**The result has been stored in data.frame `tidy`.**


### 7. Calculating Aggregated Means
For each of the 66 features found in `tidy`,  the average for each activity and each subject has been calculated and stored in column `mean_value`.

**The result has been stored in data.frame `tidy_mean` and exported as `tidy_mean.txt`.**


## Code Book
### Table `tidy`
| Column | Type | Description |
| ------ | ---- | ----------  |
| source_set | factor | "train" or "test" depending on whether row was taken from training or test data. |
| subject_id | int | Unaltered subject ID taken from `y` tables identifying the subject who performed the activity for each window sample. Its range is from 1 to 30. |
| activity | factor | Descriptive activity label taken from `activity_labels.txt`, one of "LAYING", "SITTING", "STANDING", "WALKING", "WALKING_DOWNSTAIRS", "WALKING_UPSTAIRS" |
| feature | chr | Measurement name taken from `features.txt` and modified as described in Step 1. Read `features_info.txt` for additional information on the measurements. |
| feature_value | num | Measurement value from `X` tables. |

### Table `tidy_mean`
| Column | Type | Description |
| ------ | ---- | ----------  |
| activity | factor | Descriptive activity label taken from `activity_labels.txt`, one of "LAYING", "SITTING", "STANDING", "WALKING", "WALKING_DOWNSTAIRS", "WALKING_UPSTAIRS" |
| subject_id | int | Unaltered subject ID taken from `y` tables identifying the subject who performed the activity for each window sample. Its range is from 1 to 30. |
| feature | chr | Measurement name taken from `features.txt` and modified as described in Step 1. Read `features_info.txt` for additional information on the measurements. |
| mean_value | num | Average values for each measurement per activity and subject. |

## Counts


| File / Table | Row Count | Column Count |
| ------------ | ---------:| ------------:|
| `activity_labels.txt` | 6       | 2   |
| `features.txt`        | 561     | 2   |
| `subject_test.txt`    | 2,947   | 1   |
| `X_test.txt`          | 2,947   | 561 |
| `y_test.txt`          | 2,947   | 1   |
| `subject_train.txt`   | 7,352   | 1   |
| `X_train.txt`         | 7,352   | 561 |
| `y_train.txt`         | 7,352   | 1   |
| `tidy`                | 679,734 | 5   |
| `tidy_mean`           | 11,880  | 4   |

**Notes**

- `features.txt` has as many rows as `X_test.txt` and `X_train.txt` have columns, 561 that is. That is because `features.txt` can be transposed and used for column headings in the other two tables.
- The three tables making up the training data (`subject_train.txt`, `X_train.txt` and `y_train.txt`) have the same number of rows, as do the three tables making up the test data (`subject_test.txt`, `X_test.txt` and `y_test.txt`) --- 7,352 and 2,947, respectively.
- The row count for `tidy` can be calculated as: (7,352 rows training data + 2,947 rows test data) * 66 relevant features (pivoted) = 679,734 rows.
- The row count for `tidy_mean` can be calculated as: 66 relevant features x 30 subjects x 6 activities = 11,880 rows
