

setwd(baseWD)

##Function to process X data files
readRecord2<-function(x){na.exclude(as.double(unlist(strsplit(x," +"))))}

##Read in Training Set
x_train_raw <- read.delim("X_train.txt", header=FALSE)
x_train_p<-x_train_raw[1:5,1]
x_train <- as.data.frame(do.call(rbind,lapply(x_train_raw[,1],readRecord2)))
y_train <- read.delim("y_train.txt", sep=" ", header=FALSE, col.names = c("y"))
s_train <- read.delim("subject_train.txt", sep=" ", header=FALSE, col.names = c("subject"))

##Read in Test Set
x_test_raw <- read.delim("X_test.txt", header = FALSE)
x_test <- as.data.frame(do.call(rbind,lapply(x_test_raw[,1],readRecord2)))
y_test <- read.delim("y_test.txt", sep=" ", header=FALSE, col.names = c("y"))
s_test <- read.delim("subject_test.txt", sep=" ", header=FALSE, col.names = c("subject"))

##Read in Features
features_Raw <- read.delim("features.txt", header=FALSE)
readFeature2<-function(x){
  t<-(strsplit(x," +"))
  t[[1]][1]<-paste("V",t[[1]][1], sep="")
  unlist(t)
}
features <- as.data.frame(do.call(rbind,lapply(features_Raw[,1],readFeature2)))
colnames(features)<-c("Index", "Name")
colnames(x_train)<-features$Name
colnames(x_test)<-features$Name

##Combine training & test sets across all variables
test<-cbind(s_test,x_test[, grep(("mean|std"), tolower(names(x_test)))],y_test)
train<-cbind(s_train,x_train[, grep(("mean|std"), tolower(names(x_train)))],y_train)
DF1<-rbind(train,test)

##Add activity labels in addition to codes
activities_Raw <- read.delim("activity_labels.txt", header=FALSE)
readRecordChar<-function(x){((unlist(strsplit(x," +"))))}
activities <- as.data.frame(do.call(rbind,lapply(activities_Raw[,1],readRecordChar)))
colnames(activities)<-c("y", "Activity")
DF<-merge(DF1,activities, by="y", all.x = TRUE, all.y=FALSE)

library(stringr)

##Rename variable names to be human readable
RenameCols<-function(cn){
  res = ""
  if(cn=="y"){
    res="ActivityCode"
  }else if (cn=="subject"){
    res = "Subject"
  }else if (cn=="Activity"){
    res = "Activity"
  }else if(length(grep("tbody", tolower(cn)))>0){
    res = "Time of Body"
  }else if(length(grep("fbody", tolower(cn)))>0){
    res = "Frequency of Body "
  }else if(length(grep("tgravity", tolower(cn)))>0){
    res = "Time of Gravity "
  }else if(length(grep("gravity", tolower(cn)))>0){
    res = "Gravity "
  }else{
    res = "ERROR"
  }
  if(length(grep("angle", tolower(cn)))>0){
    res = paste(res,"Angle",sep="")
  }
  if(length(grep("Z|X|Y",cn))>0){
    axis=""
    if(length(grep("Z",cn))>0){axis="Z"}
    if(length(grep("Y",cn))>0){axis="Y"}
    if(length(grep("X",cn))>0){axis="X"}
    res = paste(axis,res,sep="-")
  }
  if(length(grep("mean|std",tolower(cn)))>0){
    measure=""
    if(length(grep("mean",tolower(cn)))>0){measure="Mean"}
    if(length(grep("meanFreq",tolower(cn)))>0){measure="MeanFreq"}
    if(length(grep("std",tolower(cn)))>0){measure="StandardDeviation"}
    res = paste(measure,res,sep = " of ")
  }
  vname1 = substr(cn,str_locate(tolower(cn),"body")[1]+4,str_locate(tolower(cn),"-")[1]-1)
  if(!is.na(vname1)){res = paste(res,vname1,sep="")}
  vname2 = substr(cn,str_locate(tolower(cn),"gravity")[1]+7,str_locate(tolower(cn),"-")[1]-1)
  if(!is.na(vname2)){res = paste(res,vname2,sep="")}
  vname3 = substr(cn,str_locate(tolower(cn),"tbody")[1]+7,str_locate(tolower(cn),"mean")[1]-1)
  if(!is.na(vname3) & is.na(vname1) & is.na(vname2)){res = paste(res,vname3,sep="")}
  ##print(substr(cn,str_locate(tolower(cn),"body")[1]+5,str_locate(tolower(cn),"-")[1]+1),sep="")
  res
}

colnames(DF)<-as.character(lapply(names(DF),RenameCols))

##Get averages of each activity and each subject for each variable into a dataframe
getMeans<-function(df){
  as.data.frame(tapply(df[,1], list(as.factor(df$Subject), as.factor(df$Activity)), mean))
}

library(reshape)

##Create a dataframe with the averages of each activity and each subject for all variables
AveragesDataSet<-list()
Step5tidyDataSet<-unique(DF[,c("Activity", "Subject")])
for(nm in names(DF)){
  if(!(nm=="Activity" | nm=="Subject" | nm=="ActivityCode")){
    temp<-as.data.frame(tapply(DF[,nm], list( as.factor(DF$Subject), as.factor(DF$Activity)), mean))
    temp<-melt(cbind(temp,row.names(temp)))
    colnames(temp)<-c("Subject", "Activity", paste("Average of ", nm, sep=""))
    AveragesDataSet[[nm]]<-temp
    Step5tidyDataSet<-merge(Step5tidyDataSet, temp, by=c("Activity", "Subject"),  All = TRUE)
  }
}


write.table(Step5tidyDataSet, "Step5TidyDataset", row.names = FALSE)

