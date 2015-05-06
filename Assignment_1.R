##Peer assignment 1 
Sys.setlocale("LC_TIME", "English") ##set Days name in english
library(dplyr)
library(lubridate)
library(xtable)
library(ggplot2)
library(scales)
## Loading and preprocessing the data
dataUrl<-"https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
if (!file.exists("activity.zip")) {
        download.file(url = dataUrl, destfile ="activity.zip", mode='wb', cacheOK=FALSE)
}
raw_data<-read.csv(file = unzip(zipfile="activity.zip"))
raw_data$date <- as.Date(raw_data$date, "%Y-%m-%d")
#Total Number of step per day
Total_Step1 <-aggregate(steps ~ date, data = raw_data, sum, na.rm = TRUE)
hist(Total_Step1$steps,xlab = "Steps",col = "blue")
mean1 <-mean(Total_Step1$steps)
median1 <- median(Total_Step1$steps)

##What is the average daily activity pattern?
raw_data$interval <- as.POSIXct(strptime(sprintf("%04d", raw_data$interval), "%H%M"))

step_int<-aggregate(steps ~ interval, data = raw_data,FUN = mean, na.rm = TRUE)

plot(step_int$interval,step_int$steps,type="n",
     xlim = c(min(step_int$interval),max(step_int$interval)),
     ylab = "Average number of steps",
     xlab="5-minute interval")
lines(step_int$interval,step_int$steps, col = "black" )

max(step_int$steps)

##Imputing missing values
table(is.na(raw_data))
table(raw_data$date,is.na(raw_data$steps))

proc_data <-raw_data %>%
            mutate(flag= is.na(steps)) %>%
            mutate(new_steps=ifelse(flag==FALSE,steps,0)) %>%
            select(date,interval,new_steps)
table(is.na(proc_data))

Total_Step2 <-aggregate(new_steps ~ date, data = proc_data, sum)
hist(Total_Step2$new_steps,xlab = "Steps",col = "green")
mean2 <-mean(Total_Step2$new_steps)
        median2 <- median(Total_Step2$new_steps)

m<-data.frame(Case=c("No NA","Filled NA","Difference"),
              Mean=c(mean1,mean2,mean1-mean2),
              Median=c(median1,median2,median1-median2))

g<-data.frame(steps=c(Total_Step1$steps,Total_Step2$new_steps),
              Type=c(rep("No NA",length(Total_Step1$steps)),
                rep("Filled NA",length(Total_Step2$new_steps))))
r<-ggplot(g, aes(x=steps, fill=Type)) 
r + geom_histogram(position="dodge", binwidth=1500)

by_days<-proc_data %>%
         mutate(day_name=weekdays(date)) %>%
         mutate(week=factor(ifelse(is.na(match(day_name,c("Saturday","Sunday")))==FALSE,
                            "Weekend","Weekday"))) %>%
         select(date,interval,new_steps,week,day_name)%>%
         group_by(interval,week)

ggplot(by_days, aes(x=interval, y=avg)) + 
        geom_line(color="blue") + 
        facet_wrap(~ week, nrow=2, ncol=1) +
        labs(x="Interval", y="Number of steps") +
        ggtitle("Average of 5 min intervals for Weekday and Weekend")
        theme_bw()

by_days<-summarize(by_days,avg=mean(new_steps))
ggplot(by_days, aes(x=interval, y=avg)) + 
        geom_line(color="blue") + 
        facet_wrap(~ week, nrow=2, ncol=1) +
        labs(x="Interval", y="Number of steps") +
        ggtitle("Average of 5 min intervals for Weekday and Weekend")+
        theme_bw()+
        theme(axis.text.x=element_text(angle=270,hjust=1,vjust=0.5, size = 10)) + 
        scale_x_datetime(breaks = date_breaks("90 mins"),
                         labels = date_format("%H:%M"),
                         limits = c(min(by_days$interval),max(by_days$interval)))