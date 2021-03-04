#setwd("C:/OR568/Final_Project/data")
setwd("C:/OR568/Final_Project/New folder")

install.packages("caret", dependencies = TRUE)


library(plyr)
library(tidyverse)
library(caret)
library(questionr)
library(dplyr)
library(stringr)
library(outliers)
library(ggplot2)
library(corrplot)
library(zoo)
library(lubridate)
library(magrittr)
library(ROSE)
library(caTools)
library(ROCR)
library(randomForest)
library(funModeling) 
library(fastDummies)

df <- read.csv("master.csv")
df1 <- read.csv("InputData.csv")

df1$loan_status

dim(df1)

num_vars <- 
  df1 %>% 
  sapply(is.numeric) %>% 
  which() %>% 
  names()

num_vars





df$int_rate


give_count <- 
  stat_summary(fun.data = function(x) return(c(y = median(x)*1.06,
                                               label = length(x))),
               geom = "text")

# see http://stackoverflow.com/questions/19876505/boxplot-show-the-value-of-mean
give_mean <- 
  stat_summary(fun = mean, colour = "darkgreen", geom = "point", 
               shape = 18, size = 3, show.legend = FALSE)

df %>%
  ggplot(aes(home_ownership, int_rate)) +
  geom_boxplot(fill = "white", colour = "darkblue", 
               outlier.colour = "red", outlier.shape = 1) +
  give_count +
  give_mean +
  scale_y_continuous() +
  facet_wrap(~ loan_status) +
  labs(title="Interest Rate by Home Ownership", x = "Home Ownership", y = "Interest Rate \n")



subset_1=df[1:100,]
subset_2=df1[1:100,]

dim(subset_1)

dim(df1)


setdiff(subset_1, df1) 

df$home_ownership
df1$


library(compareDF)
ctable_student = compare_df(df, df1, c("home_ownership"))



ctable_student$comparison_df


df$id



dim(df)

df$X

df <- df[, which(colMeans(!is.na(df)) > 0.5)]

df <- df[-grep("Fully Paid",df$loan_status),]

df <- df[!is.na(df$loan_status), ]

##Label target variable Loan Status
defaulted <-   c("Default", 
                 "Charged Off", 
                 "In Grace Period", 
                 "Late (16-30 days)", 
                 "Late (31-120 days)")

df1 <-  df1 %>%
  mutate(loan_status = ifelse(!(loan_status %in% defaulted), FALSE, TRUE))

df1 %>% group_by(loan_status) %>% summarise(count = n())

chr_to_num <- c("inq_fi","inq_last_12m")

df <- df %>%
  mutate_at(.funs = funs(as.numeric), .vars = chr_to_num)

details <- df_status(df$inq_last_12m, print_results = FALSE)
details

##Compute mean fico range

df$avg_fico_range <- rowMeans(df[c('fico_range_high', 'fico_range_low')], na.rm=TRUE)
df <- subset( df, select = -c(fico_range_high, fico_range_low ) )


##Delete NA rows for columns with less % of NA values

df1 <- df1 %>% drop_na(annual_inc, avg_cur_bal,bc_open_to_buy,bc_util,delinq_2yrs,dti)

##Check for correlation among numeric variables
num_vars <- 
  df %>% select(annual_inc)

num_vars

##Correlation matrix
pearsoncor <- cor(df1[num_vars], use="complete.obs")
corrplot(pearsoncor)

#findCorrelation(cor(df[, num_vars], use = "complete.obs"), 
               # names = TRUE, cutoff = .7)

## Remove variables with larger mean abs error

drop_features <- c("tot_hi_cred_lim","tot_cur_bal", "total_rev_hi_lim","total_pymnt",
                   "total_bal_ex_mort","total_il_high_credit_limit","total_bc_limit", "il_util")
num_vars < - 

df1 <- df1 %>% select(annual_inc)

ncol(df)

##Handling outliers
win_outlier <- function(x, cutoff = .95, na.rm = TRUE){
  quantiles <- quantile(x, cutoff, na.rm = na.rm)
  x[x > quantiles] <- quantiles
  x
}

df1 %>%
  select_(.dots = num_vars) %>%
  mutate_all(.funs = winsor_outlier, cutoff = .95, na.rm = TRUE) %>%
  gather(measure, value) %>%
  mutate(default = factor(rep(x = df1$loan_status, 
                              length.out = length(num_vars)*dim(train)[1]), 
                          levels = c("TRUE", "FALSE"))) %>%
  ggplot(data = ., aes(x = value, fill = loan_status, 
                       color = default, order = -default)) +
  geom_density(alpha = 0.3, size = 0.5) +
  scale_fill_brewer(palette = "Set1") +
  scale_color_brewer(palette = "Set1") +
  facet_wrap( ~ measure, scales = "free", ncol = 3)

plotVal <- function(dat, argX, argY){
  ggplot(dat, aes(x=argX))+
    geom_histogram(color="darkblue", fill="lightblue")
  
  
  ggplot(aes(y = argY, x = argX, fill = argY), data = dat) + 
    geom_boxplot()
}

##annual_inc
summary(df1$annual_inc)

df1$annual_inc <- win_outlier(df1$annual_inc)

plotVal(df1, df1$annual_inc, df1$loan_status)

##avg_cur_bal
summary(df$avg_cur_bal)

df$avg_cur_bal <- win_outlier(df$avg_cur_bal)

plotVal(df, df$avg_cur_bal, df$loan_status)

##bc_open_to_buy
summary(df$bc_open_to_buy)

df$bc_open_to_buy <- win_outlier(df$bc_open_to_buy)

plotVal(df, df$bc_open_to_buy, df$loan_status)

##bc_util
summary(df$bc_util)
plotVal(df, df$bc_util, df$loan_status)

##dti
summary(df$dti)
df$dti <- win_outlier(df$dti)

plotVal(df,df$dti,df$loan_status)

##avg_fico_range
summary(df$avg_fico_range)

plotVal(df, df$avg_fico_range, df$loan_status)

##installment

summary(df$installment)

plotVal(df, df$installment, df$loan_status)

##total_acc
summary(df$total_acc)
plotVal(df, df$installment, df$loan_status)

##total_bal_il
summary(df$total_bal_il)

df$total_bal_il <- win_outlier(df$total_bal_il)

plotVal(df, df$total_bal_il,df$loan_status)

##total_cu_tl
summary(df$total_cu_tl)

plotVal(df, df$total_bal_il,df$loan_status)

##total_rec_int
summary(df$total_rec_int)

plotVal(df, df$total_rec_int,df$loan_status)


levels(df$home_ownership)

df$home_ownership

df$home_ownership1 = ifelse(df$home_ownership == "NONE", "OTHER", df$home_ownership)
df$home_ownership1

##Handling factor vars
df1 <- df %>%
  mutate(emplengthgiven = ifelse(emp_length == "n/a", 1, 0),
         emp_length = ifelse(emp_length == "< 1 year" | emp_length == "n/a", 0, emp_length),
         emp_length = as.numeric(gsub("\\D", "", emp_length)),
         home_ownership = ifelse(home_ownership == "NONE", "OTHER", home_ownership))


df$home_ownership

df <- fastDummies::dummy_cols(df, select_columns = "application_type")
head(df)

##handling date variable

df$earliest_cr_line <- as.numeric(difftime(Sys.Date(), as.Date(paste("01-",df$earliest_cr_line,sep=''), format = "%d-%b-%Y")),units = 'days')/365

head(df, nrow=10)

##Write in to csv
write.csv(df, "C:/OR568/Final_Project/data/loanData.csv")



