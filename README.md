# GettingandCleaningDataCourseProject

This repository contains a script "run_analysis.R" which creates a new tidy dataset from wearable computing data. The analysis does this by:
1. First, training data from the dataset is read into the file, including the subject list, the activity codes, and all X variables
2. The X variable data is cleaned using a function called "ReadRecord2" which splits character values into separate variable columns
3. Then, repeat steps 1 & 2 for the test set.
4. Next, the analysis reads in the features names, and uses a function called readFeature2 to format it properly. With the feature names, X variable data column names are renamed with these features
5. Now that we have our column names, the training & test sets are combined into one dataframe, DF1
6. Next, the activities are read in from the original dataset, formatted using a function called readRecordChar, and merged into the dataframe
7. In order to make the dataset 'tidy', we rename all of the variables by reformatting them with the function RenameCols, in order to make them descriptive to humans
8. Finally, a for loop goes through every variable in the data frame and calculates the average for each Activity and each subject. These averages are stored in a final dataframe called "Step5tidyDataSet" by merging them together on Activity & Subject

The end result is a text file called "Step5tidyDataset" which contains the tidy dataset of averages of the descriptive variables for each activity & subject
