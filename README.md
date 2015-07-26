### Introduction

The goal of the Course Project is to write an R script which prepares tidy data set that can be used for later analysis.

The R script should do the following:

1.  Merges the training and the test sets to create one data set.
2.  Extracts only the measurements on the mean and standard deviation for each measurement. 
3.  Uses descriptive activity names to name the activities in the data set
4.  Appropriately labels the data set with descriptive variable names. 
5.  From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.



### R script description

     library(plyr)


On the first step we just load package plyr and download necessary .zip data.

Before starting to download we check whether it has already been downloaded not to do the work twice. 
Data is downloaded into working directory, which should be assigned (instead of "...")


     fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
     
     work_dir <- "..."

     setwd(work_dir)
     if (!file.exists("UCI HAR Dataset.zip")) download.file(fileurl, destfile<-"UCI HAR Dataset.zip",  method = "libcurl")

Unpack .zip file (if it weren't) 

     if (!file.exists("UCI HAR Dataset")) unzip("UCI HAR Dataset.zip")

Get into directory of unpacked file

     setwd("./UCI HAR Dataset")


Start reading files:


     activity_labels<-read.table("activity_labels.txt")
     names(activity_labels)<-c("activity.id", "activity")


     features<-read.table("features.txt")
     #dim(features)

     
In step  4 it is told to appropriately label the data set with descriptive variable names. 
Part of step 4 I do here  - IMO, labels of the variables in the features dataframe are quite descriptive (especially in the presence of the codebook), 
the only thing I wanted to change - is to remove symbols ")", "(", ",", "-". I don't do all of them in lower case, because they lose readability in this case.


     features$V2<-gsub("[(),-]", "", features$V2)



Further we start readind files from test folder and train folder, combining them into one dataset - dataset_merged - with proper names of the variables (step 1 of the task):

At the same time we assign activity names to the activitiy ids in the data set (step 3 of the task)

Remark: on this stage I should have written a function in order not to write the same script twice for test and train data, but cause there are only 2 datasets I haven't
done that. In case of 3 or more datsets I would have written a function.


     #----------------------test----------------------
     #---reading test data---

     data_subj_test <- read.table("test/subject_test.txt")

     y_test <- read.table("test/y_test.txt")
     #dim(y_test)

     x_test <- read.table("test/X_test.txt")
     #dim(x_test)

     #---combining test files---

     test_data <- data.frame(data_subj_test, y_test,x_test)

     #---assigning names
     names(test_data) <- c("subject.id", "activity.id",as.matrix(features)[,2])

     #---getting activity names
     test_data_fin <- merge(activity_labels, test_data, by.x = "activity.id", by.y = "activity.id")


     #cleaning memory
     rm(data_subj_test)
     rm(y_test)
     rm(x_test)
     rm(test_data)
     #----------------------test----------------------


     #---------------------train----------------------
     #---reading train data---
     data_subj_train <- read.table("train/subject_train.txt")

     y_train <- read.table("train/y_train.txt")
     #dim(y_train)
 
     x_train <- read.table("train/X_train.txt")
     #dim(x_train)

     #---combining train files---

     train_data <- data.frame(data_subj_train, y_train,x_train)

     #---assigning names
     names(train_data) <- c("subject.id", "activity.id",as.matrix(features)[,2])

     #---getting activity names
     train_data_fin <- merge(activity_labels, train_data, by.x = "activity.id", by.y = "activity.id")

     #clean the memory
     rm(data_subj_train)
     rm(y_train)
     rm(x_train)
     rm(train_data)
     #---------------------train----------------------

     #clean the memory
     rm(activity_labels)
     rm(features)



    #--step 1 result - dataset_merged
    dataset_merged <- rbind(test_data_fin, train_data_fin)

    rm(test_data_fin)
    rm(train_data_fin)
    #dim(dataset_merged)


In step 4 it is demanded to extract only the measurements on the mean and standard deviation. I understood that as getting variables including "mean" or "std" in the name:


    dataset_fin <- dataset_merged[,c("activity.id", "activity", "subject.id", c(subset(names(dataset_merged), as.logical(grepl("mean",names(dataset_merged))+grepl("std",names(dataset_merged))))))]


In step 5 it is demanded to  create a second, independent tidy data set with the average of each variable for each activity and each subject. 
I haven't found any R fucntions to do it quickly, that why I used ddply function and "for" cycle.



     for (i in c(1:(length(names(dataset_fin))-3)))

     {

     if (i == 1)   {
                       dataset <- ddply(dataset_fin, .(activity, subject.id), here(summarize), mean = mean(get(names(dataset_fin)[4])))
                       names(dataset)[3] <- names(dataset_fin)[4]  
                   }
     else          {

    	  	       dataset_temp <- ddply(dataset_fin, .(activity, subject.id),here(summarise),mean = mean(get(names(dataset_fin)[3+i])))
	               dataset <- data.frame(dataset, dataset_temp[3])
		       names(dataset)[2+i] <- names(dataset_fin)[3+i]
                    } 
      }


moving to directory up
     setwd("..")

Writing final file

     write.table(dataset, file = "dataset.txt",row.name=FALSE)




