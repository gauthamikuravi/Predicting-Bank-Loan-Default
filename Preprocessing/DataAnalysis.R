setwd("C:/OR568/Final_Project/data")

library(plyr)
library(tidyverse)
library(caret)
library(questionr)
library(dplyr)
library(caret)
library(stringr)

load_csv = function(filename){
  temp = read.csv2(filename, skip = 1, header = TRUE)
  col_names = str_split(colnames(temp), "\\.")[[1]]
  df = read.csv2(filename, skip = 2, header = FALSE, sep = ",")
  colnames(df) = col_names
  return(df)
} 

loans18Q1 = load_csv("LoanStats_securev1_2018Q1.csv")
loans18Q2 = load_csv("LoanStats_securev1_2018Q2.csv")
loans18Q3 = load_csv("LoanStats_securev1_2018Q3.csv")
loans18Q4 = load_csv("LoanStats_securev1_2018Q4.csv")

loans19Q1 = load_csv("LoanStats_securev1_2019Q1.csv")
loans19Q2 = load_csv("LoanStats_securev1_2019Q2.csv")
loans19Q3 = load_csv("LoanStats_securev1_2019Q3.csv")
loans19Q4 = load_csv("LoanStats_securev1_2019Q4.csv")


str(loansQ1)
 

loansQ1 %>% group_by(loan_status) %>% summarise(count = n())
loansQ2 %>% group_by(loan_status) %>% summarise(count = n())
loansQ3 %>% group_by(loan_status) %>% summarise(count = n())
loansQ4 %>% group_by(loan_status) %>% summarise(count = n())

finaldf = rbind(loans18Q1,loans18Q2,loans18Q3,loans18Q4,loans19Q1,loans19Q2,loans19Q3,loans19Q4)
head(finaldf)

nrow(finaldf)

write.csv(finaldf, "C:/OR568/Final_Project/data/master.csv")

finaldf %>% group_by(loan_status) %>% summarise(count = n())


finaldf %>%
  group_by(loan_status) %>%
  summarize(count = n(), rel_count = count/nrow(finaldf))


write.csv(finaldf, "C:/OR568/data/master.csv")


finaldf %>%
  group_by(loan_status) %>%
  summarize(count = n(), rel_count = count/nrow(finaldf)) 
## Check for missing or NA values
freq.na(loans)

loans <- loans[, which(colMeans(!is.na(loans)) > 0.5)]

freq.na(loans)

#df1 <- loans %>%
 # group_by(loans$loan_status) %>% 
  #tally()gtwrt

drop_cols <- c('acc_now_delinq', 'acc_open_past_24mths', 'avg_cur_bal', 'bc_open_to_buy', 'bc_util', 'chargeoff_within_12_mths', 'collection_recovery_fee', 'collections_12_mths_ex_med', 'debt_settlement_flag', 'delinq_2yrs', 'delinq_amnt', 'disbursement_method', 'funded_amnt', 'funded_amnt_inv', 'hardship_flag', 'inq_last_6mths', 'last_credit_pull_d', 'last_fico_range_high', 'last_fico_range_low', 'last_pymnt_amnt', 'last_pymnt_d', 'mo_sin_rcnt_rev_tl_op', 'mo_sin_rcnt_tl', 'mths_since_recent_bc', 'mths_since_recent_inq', 'num_accts_ever_120_pd', 'num_actv_bc_tl', 'num_actv_rev_tl', 'num_bc_sats', 'num_bc_tl', 'num_il_tl', 'num_op_rev_tl', 'num_rev_accts', 'num_rev_tl_bal_gt_0', 'num_sats', 'num_tl_120dpd_2m', 'num_tl_30dpd', 'num_tl_90g_dpd_24m', 'num_tl_op_past_12m',  'out_prncp', 'out_prncp_inv', 'pct_tl_nvr_dlq', 'percent_bc_gt_75', 'pymnt_plan', 'recoveries', 'tax_liens', 'tot_coll_amt', 'tot_cur_bal', 'tot_hi_cred_lim', 'total_bal_ex_mort', 'total_bc_limit', 'total_il_high_credit_limit', 'total_pymnt', 'total_pymnt_inv', 'total_rec_int', 'total_rec_late_fee', 'total_rec_prncp', 'total_rev_hi_lim')

loans <- loans[ , !(names(loans) %in% drop_cols)]

ncol(loans)

view(loans$issue_d)

# 1. Convert Interest Rate to numeric variable
loans$int_rate <-as.numeric(gsub("%","",loans$int_rate))

# 2. Convert Loan Length to numeric variable
loans$term <- as.numeric(gsub("months","",loans$term))

# 3. Factorize Loan Length (One of the most important uses of factors is in statistical modeling; 
##since categorical variables enter into statistical models differently 
##than continuous variables, storing data as factors insures 

loans$term.Fac <- as.factor(loans$term)

# 4. Factorize Loan Purpose
loans$purpose <- as.factor(loans$purpose)

# 5. Factorize State
loans$addr_state <- as.factor(loans$addr_state)

# 6. Factorize Home Ownership
loans$home_ownership <- as.factor(loans$home_ownership)

view(loans$dti)

  

