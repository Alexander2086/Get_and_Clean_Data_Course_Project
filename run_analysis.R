
library(plyr)

#---------------------------------------------------


##!!!!!! write your workdir instead of "..."


fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
work_dir <- "..."
setwd(work_dir)


# check whether file is already downloaded and download if not
if (!file.exists("UCI HAR Dataset.zip")) download.file(fileurl, destfile<-"UCI HAR Dataset.zip",  method = "libcurl")

#unpack
if (!file.exists("UCI HAR Dataset")) unzip("UCI HAR Dataset.zip")

setwd("./UCI HAR Dataset")

#starting reading files
activity_labels <- read.table("activity_labels.txt")
names(activity_labels)<-c("activity.id", "activity")


features <- read.table("features.txt")
#dim(features)

features$V2<-gsub("[(),-]", "", features$V2)



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


rm(data_subj_train)
rm(y_train)
rm(x_train)
rm(train_data)

#---------------------train----------------------


rm(activity_labels)
rm(features)


dataset_merged <- rbind(test_data_fin, train_data_fin)

rm(test_data_fin)
rm(train_data_fin)
#dim(dataset_merged)



dataset_fin <- dataset_merged[,c("activity.id", "activity", "subject.id", c(subset(names(dataset_merged), as.logical(grepl("mean",names(dataset_merged))+grepl("std",names(dataset_merged))))))]

for (i in c(1:(length(names(dataset_fin))-3)))

{

if (i == 1)  {
                 dataset <- ddply(dataset_fin, .(activity, subject.id), here(summarize), mean = mean(get(names(dataset_fin)[4])))
                 names(dataset)[3] <- names(dataset_fin)[4]  
              }
else          {

		dataset_temp <- ddply(dataset_fin, .(activity, subject.id),here(summarise),mean = mean(get(names(dataset_fin)[3+i])))
		dataset <- data.frame(dataset, dataset_temp[3])
		names(dataset)[2+i] <- names(dataset_fin)[3+i]
              }
}


setwd("..")


write.table(dataset, file = "dataset.txt",row.name=FALSE)