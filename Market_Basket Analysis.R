#final run

# Read the csv file
finaltest <-read.csv("Loantest_1.csv",header=TRUE)
finaltrain <- read.csv("Loantrain_1.csv", header=TRUE)
finaltest = finaltest %>% mutate_if(is.character, as.factor)
finaltrain = finaltrain %>% mutate_if(is.character, as.factor)

###### TEMP
mydata <-read.csv("InputData_6.csv",header=TRUE)
mcsv <- read.csv("mastermay.csv",header=TRUE)
mydata = mydata %>% mutate_if(is.character, as.factor)
mydata = mydata[,-c(1:4)]
names(mydata)
str(mydata)
mydata$loan_status = as.factor(ifelse(mydata$loan_status == TRUE,"Default","Current"))
origdata = read.csv("masterdata.csv", header=TRUE)

summary(mydata$emp_length)
summary(mydata$emplengthgiven)
summary(mydata$loan_status)
mydata %>% group_by(loan_status) %>% summarise(vc=n(), mean_emp_length = mean(emp_length))

ggplot(mydata, aes(x = seq(1:nrow(mydata)),y = emp_length, colour = loan_status)) + geom_point() #best plot

mydata[mydata$emp_length > 1,] %>% group_by(loan_status) %>% summarise(vc=n(), mean_emp_length = mean(emp_length))
mydata[mydata$emp_length == 0,] %>% group_by(loan_status) %>% summarise(vc=n(), mean_emp_length = mean(emp_length))
mydata[mydata$emp_length < 1,] %>% group_by(loan_status) %>% summarise(vc=n(), mean_emp_length = mean(emp_length))
mydata$numstatus = ifelse(mydata$loan_status == FALSE,1,0)
summary(mydata$numstatus)
cor(mydata$emp_length,mydata$annual_inc)




### CODE FOR DECK 

mydata %>% group_by(title) %>% summarise(vc=n())

origdata = origdata[,-1]

table(sapply(origdata, class))

str(origdata$loan_status)
str(origdata)

table_ls <- origdata %>% group_by(loan_status) %>% summarise(vc=n())

ggplot(table_ls, aes(x=loan_status, y=vc)) + geom_bar(stat = "identity") +
  theme(axis.text.x=element_text(angle = -90, hjust = 0)) + labs(title="Loan Status Distribution") + 
  xlab("Loan Status") + ylab("Count") + theme(plot.title = element_text(hjust = 0.5))

ggplot(vmdfinal, aes(x = all_util,y = avg_cur_bal, colour = adj_status)) + geom_point() #best plot

origdata$adj_status = as.factor(sapply(origdata$loan_status,function(x){if(x == "Current"){"Current"} else if (x == "Fully Paid"){"FullyP"} else{"Default"}}))
summary(origdata$adj_status)

origdata %>% group_by(adj_status) %>% summarize(vc=n(), meanemp = mean(mo_sin_old_rev_tl_op))

rint = origdata$int_rate
rint = as.numeric(sub("%", "", rint))
rint
rint = rint / 100
origdata = cbind(origdata,rint)
colintrate = ncol(origdata)
colnames(origdata)[colintrate] = "int_rate_num" 

origdata %>% group_by(adj_status) %>% summarise(vc=n(), meanint = mean(int_rate_num))

loantypet = origdata %>% group_by(adj_status) %>% summarise(vc=n())
loantypet = loantypet[-3,]

ggplot(loantypet, aes(x=adj_status, y=vc)) + geom_bar(stat = "identity") +
  theme(axis.text.x=element_text(angle = -90, hjust = 0)) + labs(title="Loan Status Distribution Adj.") + 
  xlab("Loan Status") + ylab("Count") + theme(plot.title = element_text(hjust = 0.5))

###### END TEMP


finaltest = finaltest %>% mutate_if(is.character, as.factor)
finaltrain = finaltrain %>% mutate_if(is.character, as.factor)
finaltest = finaltest[,-14] #rem avg_fico_range
finaltrain = finaltrain[,-14]

vmdfinal <- finaltrain


#final data preprocess

### BASKET ASSOC EDA ###
masterdata <-read.csv("mastermay.csv",header=TRUE)
m1 = masterdata[,which(colMeans(!is.na(masterdata)) > 0.5)]
m1 = m1[complete.cases(m1),]
m1 = m1[,-1]


vnumcol = ncol(m1)
for(i in 2:vnumcol) {
  vname = colnames(m1)[i]
  
  if(is.numeric(m1[,vname]))
  {
    breaks <- c(-Inf,unique(quantile(m1[,vname])),Inf)
    x1 = cut(m1[,vname], breaks, include.lowest = TRUE)
    m1[,vname] <- x1
  }
}

m1 = m1 %>% mutate_if(is.character, as.factor)
m1 = m1[!(m1$loan_status == "Charged Off"),]

m1$loan_status = ifelse(m1$loan_status == "Current","Current","Default")

#run 1
grocules <- apriori(m1,parameter = list(minlen=2, maxlen = 2,maxtime=30,supp=0.01, conf=0.95), appearance = list(rhs=c("loan_status=Default"), default="lhs"))
#remove certain features 3 in total

inspect(grocules)
rules.sorted <- sort(grocules, by="lift")
inspect(rules.sorted)


#run 2
vnames = c("last_pymnt_d","next_pymnt_d","out_prncp")
vnames = match(vnames,colnames(m1))
vnames
m2 = m1[,-vnames]

grocules <- apriori(m2,parameter = list(minlen=2, maxlen = 3,maxtime=30,supp=0.01, conf=0.80), appearance = list(rhs=c("loan_status=Default"), default="lhs"))

inspect(grocules)
rules.sorted <- sort(grocules, by="lift")
inspect(rules.sorted)

rules.export = DATAFRAME(rules.sorted, setStart='', setEnd='', separate = TRUE)
write.csv(rules.export, file = "rulesexport.csv", row.names = FALSE)

#run 3

vnames = c("out_prncp_inv","last_credit_pull_d")
vnames = match(vnames,colnames(m2))
vnames
m3 = m2[,-vnames]

grocules <- apriori(m3,parameter = list(minlen=2, maxlen = 3,maxtime=30,supp=0.01, conf=0.80), appearance = list(rhs=c("loan_status=Default"), default="lhs"))

inspect(grocules)
rules.sorted <- sort(grocules, by="lift")
inspect(rules.sorted)


#run 4

vnames = c('total_pymnt_inv', 'total_rec_int', 'total_rec_prncp', 'last_pymnt_amnt', 'funded_amnt_inv')
vnames = match(vnames,colnames(m3))
vnames
m4 = m3[,-vnames]

grocules <- apriori(m4,parameter = list(minlen=2, maxlen = 5,maxtime=30,supp=0.01, conf=0.80), appearance = list(rhs=c("loan_status=Default"), default="lhs"))

rules.sorted <- sort(grocules, by="lift")
inspect(rules.sorted)

masterdata %>% group_by(loan_status) %>% summarise(vm = mean(out_prncp), vc =n())

#run 5

vnames = c('funded_amnt','total_pymnt','initial_list_status','policy_code','purpose','pymnt_plan','sub_grade','url','zip_code','debt_settlement_flag','debt_settlement_flag_date','settlement_status','settlement_date')
vnames = match(vnames,colnames(m4))
vnames

m5 = m4[,-vnames]

names(m5)
#revove hardship flags x=f(y), model not running due to complexity
m5 = m5[,-c(89:96)]

names(m5)

grocules <- apriori(m5,parameter = list(minlen=2, maxlen = 5,maxtime=600,supp=0.05, conf=0.40), appearance = list(rhs=c("loan_status=Default"), default="lhs"))

rules.sorted <- sort(grocules, by="lift")
inspect(rules.sorted)

rules.export = DATAFRAME(rules.sorted, setStart='', setEnd='', separate = TRUE)
write.csv(rules.export, file = "rulesexport.csv", row.names = FALSE)

#all_util
xvar = 'all_util'
summary(vmdfinal$all_util)
length(vmdfinal$all_util)
skewness(vmdfinal$all_util, na.rm=T) # normally distro
#some NAs 196, < 1%, set them to mean
vc = match("all_util",names(vmdfinal))
vtest = vmdfinal[,vc]
sum(is.na(vc))

boxplot(vmdfinal$all_util, plot=FALSE)$out
View(vmdfinal[vmdfinal$all_util > 200,]) #view outliers
vmdfinal %>% group_by(adj_status) %>% summarise(n = n(), vmean = mean(all_util), meancurbal = mean(avg_cur_bal, na.rm=T))
# broken out by loan status mean of predictor is fairly close together 54.5/5.3 curr/default 
# not a major predictor on variance of response
# avg cur bal of defualt loans lower at  $12088 vs $13631, but all_util bal higher for defaults
ggplot(vmdfinal, aes(x = all_util,y = avg_cur_bal, colour = adj_status)) + geom_point() #best plot
mean(vmdfinal$avg_cur_bal, na.rm=T)
ggplot(vmdfinal, aes(x = seq(1:length(vtest)),y = all_util/avg_cur_bal, colour = adj_status)) + geom_point() #best plot
#ggplot not very useful, no direct relatinship indicator that the util/cur bal can predict loandefault

#int_rate_num
vc = match("int_rate_num",names(vmdfinal))
summary(vmdfinal$int_rate_num) # no NAS!
length(vmdfinal$int_rate_num)
skewness(vmdfinal$int_rate_num, na.rm=T) # normally distro
vmdfinal %>% group_by(loan_status) %>% summarise(n = n(), vmean = mean(int_rate_num))
#int rate is vitually equal between current and default..makes no sense
hist(vmdfinal[vmdfinal$adj_status == "default",vc])
summary(vmdfinal[vmdfinal$adj_status == "default",vc])
summary(vmdfinal[vmdfinal$adj_status == "current",vc])
View(vmdfinal[vmdfinal$int_rate_num > .30,])
# WEIRD: current loans have int rates> 30% same with default and also low grades
vmdfinal %>% group_by(grade,loan_status) %>% summarise(n=n(),mint = mean(int_rate_num))
# table shows loans F/G grade have higher % defaults but STILL current loans all int rates 30%

#issue_d
vc = match("issue_d",names(vmdfinal))
summary(vmdfinal$issue_d) 
str(vmdfinal$issue_d)
length(vmdfinal$issue_d)
sum(is.na(vmdfinal$issue_d)) # no NAs
#date transform
vdate = as.data.frame(unique(vmdfinal$issue_d))
vdate$one = mdy(vdate$`unique(vmdfinal$issue_d)`)
vdate
vdc = as.Date(c("2018-03-20","2018-02-20","2018-01-20","2018-06-20","2018-05-20","2018-04-20","2018-09-20","2018-08-20","2018-07-20","2018-12-20","2018-11-20","2018-10-20"))
vdate[c(1:12),2] = vdc
colnames(vdate) = c("issue_d","newdate")
vmdfinal$issue_d <- sapply(vmdfinal$issue_d,function(x){vlookup(x,vdate,2,1)})
colnames(vmdfinal)[80] = "newdate_issue_d" #rename new col

vmdfinal$issue_d1 = vlookup(vmdfinal$issue_d,vdate,2,1)
vmdfinal$issue_d = vmdfinal$issue_d1
vmdfinal$issue_d1 = NULL

#last_credit_pulld
vc = match("last_credit_pull_d",names(vmdfinal))
summary(vmdfinal$last_credit_pull_d) 
length(vmdfinal$last_credit_pull_d)
sum(is.na(vmdfinal$last_credit_pull_d)) # no NAs
vtemp = as.data.frame(unique(vmdfinal$last_credit_pull_d))
View(vmdfinal %>% group_by(last_credit_pull_d) %>% summarise(vc = n()))
vmdfinal$last_credit_pull_d = replace(vmdfinal$last_credit_pull_d, vmdfinal$last_credit_pull_d == "", "Jan-2020")
# impute above
vdate = as.data.frame(unique(vmdfinal$last_credit_pull_d))
colnames(vdate) = "primary"
vdate$one = mdy(vdate$primary)
vd1 = vlookup(vmdfinal$last_credit_pull_d,vdate,2,1)
vmdfinal$last_credit_pull_d = vd1


#last fico high adn range low
summary(vmdfinal$last_fico_range_high) 
summary(vmdfinal$last_fico_range_low) 
vmdfinal$mean_last_fico_range = (vmdfinal$last_fico_range_high+vmdfinal$last_fico_range_low)/2

ggplot(vmdfinal, aes(x = out_prncp,y = mean_last_fico_range, colour = adj_status)) + geom_point() #best plot
#if mean fico score low -> high pr(default), but if fico score is high, cannot predict default
vmdfinal[vmdfinal$mean_last_fico_range == 0,1]

#FICO RANG LOW
vmdfinal %>% group_by(grade) %>% summarize(vm = mean(last_fico_range_low)) -> vcm
vcm
for(i in 1:nrow(vmdfinal)){
  if(vmdfinal[i,"last_fico_range_low"] == 0){
    vx = vlookup(vmdfinal[i,"grade"],vcm,2,1)
    vmdfinal[i,"last_fico_range_low"] = vx
  }
}
#HIGH FICO RANGE
vmdfinal %>% group_by(grade) %>% summarize(vm = mean(last_fico_range_high)) -> vcm
for(i in 1:nrow(vmdfinal)){
  if(vmdfinal[i,"last_fico_range_high"] == 0){
    vx = vlookup(vmdfinal[i,"grade"],vcm,2,1)
    vmdfinal[i,"last_fico_range_high"] = vx
  }
}
skewness(vmdfinal$last_fico_range_high)
hist(vmdfinal$last_fico_range_high)

#create mean fico score
vmdfinal$lastficoscore_mean = (vmdfinal$last_fico_range_high+vmdfinal$last_fico_range_low)/2
skewness(vmdfinal$lastficoscore_mean)

vc = match("last_pymnt_d",names(vmdfinal))
summary(vmdfinal$last_pymnt_d) #contains empty values indicating no last payment
length(vmdfinal$last_pymnt_d)
View(vmdfinal[vmdfinal$last_pymnt_d == "",])
vtemp = as.data.frame(unique(vmdfinal$last_pymnt_d))
vtemp$new = mdy(vtemp$`unique(vmdfinal$last_pymnt_d)`)
View(vtemp)

#last_payment_d
vc = match("last_pymnt_d",names(vmdfinal))
summary(vmdfinal$last_pymnt_d) #contains empty values indicating no last payment
length(vmdfinal$last_pymnt_d)
#convert date
vdate = as.data.frame(unique(vmdfinal$last_pymnt_d))
colnames(vdate) = "primary"
vdate$one = mdy(vdate$primary)
vdate[23,2] = "2000-01-01" #set empty last payment date to very old date 2000/1/1
vdate
vd1 = vlookup(vmdfinal$last_pymnt_d,vdate,2,1)
vd1
vmdfinal$last_pymnt_d = vd1

#highly correlated to default if empty --> 100% defaulted
#next_payment_d conversion
vdate = as.data.frame(unique(vmdfinal$next_pymnt_d))
colnames(vdate) = "primary"
vdate$one = mdy(vdate$primary)
vdate[2,2] = "2000-01-01" #set empty next payment date to very old date 2000/1/1
vdate
vd1 = vlookup(vmdfinal$next_pymnt_d,vdate,2,1)
summary(vd1)
vmdfinal$next_pymnt_d = vd1



#loan_amnt
summary(vmdfinal$loan_amnt)
hist(vmdfinal$loan_amnt)

#mo_sin_old_il_acct
summary(vmdfinal$mo_sin_old_il_acct)
hist(vmdfinal$mo_sin_old_il_acct)
vmdfinal$mo_sin_old_il_acct = replace(vmdfinal$mo_sin_old_il_acct,is.na(vmdfinal$mo_sin_old_il_acct),0) # replace NAs with 0 impute
skewness(vmdfinal$mo_sin_old_il_acct)

#mo_sin_rcnt_rev_tl_op
summary(vmdfinal$mo_sin_rcnt_rev_tl_op) #no NAs
hist(vmdfinal$mo_sin_rcnt_rev_tl_op)
skewness(vmdfinal$mo_sin_rcnt_rev_tl_op) #signifcatn positive skew
hist((vmdfinal$mo_sin_rcnt_rev_tl_op)^(1/3))
vmdfinal$mo_sin_rcnt_rev_tl_op  = vmdfinal$mo_sin_rcnt_rev_tl_op^(1/3)

#mo_sin_rcnt_tl
summary(vmdfinal$mo_sin_rcnt_tl)
hist(vmdfinal$mo_sin_rcnt_tl, breaks=100) 
sum(vmdfinal$mo_sin_rcnt_tl == 0) # only 12k

ggplot(vmdfinal, aes(x = seq(1:nrow(vmdfinal)),y = vmdfinal$mo_sin_rcnt_tl, colour = adj_status)) + geom_point() #best plot
skewness(vmdfinal$mo_sin_rcnt_tl)
skewness(vmdfinal$mo_sin_rcnt_tl^(1/3))
vmdfinal$mo_sin_rcnt_tl = vmdfinal$mo_sin_rcnt_tl^(1/3)

#mort_acc
summary(vmdfinal$mort_acc)
skewness(vmdfinal$mort_acc) #significant pos skew 2.83
get_mode(vmdfinal$mort_acc) # 0 is most common

ggplot(vmdfinal, aes(x = seq(1:nrow(vmdfinal)),y = vmdfinal$mort_acc, colour = adj_status)) + geom_point() #best plot
#uniform distro no correl
skewness(vmdfinal$mort_acc^(.5))
vmdfinal$mort_acc = vmdfinal$mort_acc^(1/2)

#rev_util_num
summary(vmdfinal$revol_util_num)
hist(vmdfinal$revol_util_num) # range: [0,1]
sum(vmdfinal$revol_util_num > 1, na.rm=T)
View(vmdfinal[vmdfinal$revol_util_num > .9,])

ggplot(vmdfinal, aes(x = revol_util_num,y = dti, colour = adj_status)) + geom_point() #best plot
cor(vmdfinal$revol_util_num, vmdfinal$dti, use="complete.obs") #corr = .09
#most defaults are occurring with low DTI, doesn't make sense
ggplot(vmdfinal, aes(x = seq(1:nrow(vmdfinal)),y = dti, colour = adj_status)) + geom_point() #best plot

#term
summary(vmdfinal$term)
vmdfinal %>% group_by(term,loan_status) %>% summarize(n=n()) #roughly even distro

ggplot(vmdfinal, aes(x = seq(1:nrow(vmdfinal)),y = term, colour = loan_status)) + geom_point() #best plot
# shows rough even distro

#title
sum(is.na(vmdfinal$title)) #NICE 0
summary(vmdfinal$title)
ggplot(vmdfinal, aes(x=title, fill=adj_status)) + geom_bar(stat = "count") 
# good bar chart plot coloured by loan status, indicates debt consolidation highest defualt rate

#create vector dimensions for each category in title
unique(vmdfinal$title)
title_dummy <-dummy(vmdfinal$title, sep = "_")

vmdfinal = cbind(vmdfinal,title_dummy)

#verification sattus
summary(vmdfinal$verification_status)
vmdfinal %>% group_by(verification_status,loan_status) %>% summarise(n=n())
#breakout by type doesn't indicate good predictor for default

verstatus <-dummy(vmdfinal$verification_status, sep = "_")

vmdfinal = cbind(vmdfinal,verstatus)

#get rid of non-relevant/duplicate features
vmdfinal$verification_status_joint = NULL
vmdfinal$emp_title = NULL
vmdfinal$purpose = NULL
vmdfinal$last_fico_range_high = NULL
vmdfinal$last_fico_range_low = NULL

vremove = c('funded_amnt_inv','initial_list_status','pymnt_plan','total_pymnt_inv','total_rec_prncp','zip_code','debt_settlement_flag','debt_settlement_flag_date','settlement_status','settlement_date')
vremove = match(vremove,names(vmdfinal))
vremove
vmdfinal = vmdfinal[,-vremove]

#date vars subtractions
#subject to high correlation with factor level date data
vmdfinal$days_since_issued = vmdfinal$pullDate - vmdfinal$issue_d
vmdfinal$days_since_creditpull = vmdfinal$pullDate - vmdfinal$last_credit_pull_d
vmdfinal$days_since_lastpayment = vmdfinal$pullDate - vmdfinal$last_pymnt_d
vmdfinal$days_til_nextpayment = vmdfinal$next_pymnt_d - vmdfinal$pullDate
str(vmdfinal)
#general tests before export
vmdfinal %>% group_by(application_type,loan_status) %>% summarise(vc =n())

#FINAL OTPUT
#write.csv(vmdfinal, file = "InputData_5.csv", row.names = FALSE)



#my persdonal additions 222

#vmdfinal= vmdfinal[,-1] #get rid fo X
#drop mydata free up memory


#QUICK additions, skip the rest
vmdfinal$fac_loanstatus = as.factor(sapply(vmdfinal$loan_status,function(x){if(x == TRUE){"Default"}else{"Current"}}))
vmdfinal = vmdfinal[vmdfinal$annual_inc > 10000,]
vmdfinal$installmentperincome = vmdfinal$installment / (vmdfinal$annual_inc/12)
vmdfinal$daystilmaturity = as.numeric(mapply(function(x,y,z){
  cx = as.Date(x) + if(y == " 36 months"){36*30}else{60*30}
  cx = as.numeric(cx - as.Date(z))
  return(cx)
},vmdfinal$issue_d,vmdfinal$term,vmdfinal$pullDate))



#################################################################3

#vmdfinal.bak$fac_loanstatus = as.factor(sapply(vmdfinal.bak$loan_status,function(x){if(x == TRUE){"Default"}else{"Current"}}))

vmdfinal$fac_loanstatus = as.factor(sapply(vmdfinal$loan_status,function(x){if(x == TRUE){"Default"}else{"Current"}}))

defaultprior = (nrow(vmdfinal) - sum(vmdfinal$fac_loanstatus == "Current")) / (nrow(vmdfinal))
defaultprior

# create new var
vmdfinal$outpercent = vmdfinal$out_prncp / vmdfinal$loan_amnt

ggplot(vmdfinal, aes(x = days_since_issued,y = outpercent, colour = fac_loanstatus)) + geom_point() #best plot

vmdfinal[which(vmdfinal$outpercent > .50 & vmdfinal$days_since_issued >= 600),] %>% group_by(adj_loanstatus) %>% summarize(nc=n())
vmdfinal %>% group_by(adj_loanstatus) %>% summarize(vdays = mean(days_since_issued), vper = mean(outpercent))
cor(vmdfinal$days_since_issued,vmdfinal$outpercent)

#analyze last payment amt
vmdfinal %>% group_by(fac_loanstatus) %>% summarize(vlastpay = mean(last_pymnt_amnt), vinstall = mean(last_pymnt_amnt/installment), vinstincome = mean(installment / annual_inc))
vmdfinal[vmdfinal$last_pymnt_amnt < vmdfinal$installment,] %>% group_by(fac_loanstatus) %>% summarise(vc=n())
vmdfinal[vmdfinal$last_pymnt_amnt > vmdfinal$installment,] %>% group_by(fac_loanstatus) %>% summarise(vc=n())
vmdfinal[vmdfinal$last_pymnt_amnt == 0,] %>% group_by(fac_loanstatus) %>% summarise(vc=n())
View(vmdfinal[vmdfinal$last_pymnt_amnt == 0,])

hist(vmdfinal.bak$annual_inc,breaks = 30, xaxt="n")
axis(side=1, at=seq(min(vmdfinal.bak$annual_inc),max(vmdfinal.bak$annual_inc), 30), las=2)
View(vmdfinal.bak[vmdfinal.bak$annual_inc <= 7304,])

vmdfinal.bak[vmdfinal.bak$annual_inc <= 10000,] %>% group_by(fac_loanstatus) %>% summarise(vc = n())
#optimal gain 2532 currents/299 defaults


vmdfinal = vmdfinal[vmdfinal$annual_inc > 10000,]

#model is using installment as a splitting node, but as it stands it makes no sense since installment should be a factor of annual income
#thus crfeate new var installmentperincome = installment/annual income and remove both vars to dim red

#create new var
vmdfinal$installmentperincome = vmdfinal$installment / (vmdfinal$annual_inc/12)

summary(vmdfinal$installmentperincome)

vmdfinal.bak %>% group_by(fac_loanstatus) %>% summarise(vinmean = mean(installmentperincome))

ggplot(vmdfinal.bak, aes(x = seq(1:nrow(vmdfinal.bak)),y = installmentperincome, colour = fac_loanstatus)) + geom_point() #best plot

#analyze outprincipal
hist(vmdfinal.bak[vmdfinal.bak$fac_loanstatus == "Default",24],breaks = 30)
axis(side=1, at=seq(min(vmdfinal.bak$out_prncp),max(vmdfinal.bak$out_prncp), 30), las=2)
View(vmdfinal.bak[which(vmdfinal.bak$out_prncp > 0 & vmdfinal.bak$out_prncp < 500),])

View(vmdfinal.bak[vmdfinal.bak$fac_loanstatus == "default",])

names(vmdfinal.bak)

vmdfinal.bak[vmdfinal.bak$out_prncp <  10,] %>% group_by(fac_loanstatus) %>% summarise(vc=n())

vmdfinal[vmdfinal$out_prncp ==  0,] %>% group_by(fac_loanstatus) %>% summarise(vc=n(), vm = mean(out_prncp))
#45k loans outprincial = 0 -> implies charge off loans, cannot use out_prncp


#create days til maturity
vmdfinal$daystilmaturity = as.numeric(mapply(function(x,y,z){
  cx = as.Date(x) + if(y == " 36 months"){36*30}else{60*30}
  cx = as.numeric(cx - as.Date(z))
  return(cx)
  },vmdfinal$issue_d,vmdfinal$term,vmdfinal$pullDate))

summary(vmdfinal$daystilmaturity)



#review state loan originations address state addy
# loan current in: AK,AZ,CO,DC,DE,GA,IL,KS,ME,MN,MT,ND,NE,NH,NM,NY,OH,OK,OR,RI,SC,SD,VA,VT,WA,WI,WV,WY

vaddy = c('AK','AZ','CO','DC','DE','GA','IL','KS','ME','MN','MT','ND','NE','NH','NM','NY','OH','OK','OR','RI','SC','SD','VA','VT','WA','WI','WV','WY')
vmdaddy = vmdfinal[vmdfinal$addr_state %in% vaddy,]
vmdaddy %>% group_by(fac_loanstatus) %>% summarize(vc = n())
23/(327)

vmaddyp = vmdfinal[!(vmdfinal$addr_state %in% vaddy),]
vmaddyp %>% group_by(fac_loanstatus) %>% summarize(vc = n())
45/(453+45)

summary(vmdaddy)
summary(vmaddyp)

#current states subset default rate is 7% vs shit state subset default rate 9% so 23% lower; but can't discern
#why, --> determine it's noise being captured here, thus elect to exclude

######## DIM RED #########


#remove x=f(y) vars, predictors as a function of response
xfy = c('collection_recovery_fee', 'days_since_lastpayment', 'days_til_nextpayment', 'funded_amnt', 'hardship_flag', 'next_pymnt_d', 'sub_grade', 'total_rec_late_fee', 'last_pymnt_d', 'sec_app_earliest_cr_line')
xfy = match(xfy,names(vmdfinal))
xfy

vmdfinal = vmdfinal[,-xfy]

#remove dup vars
v.dup = c('issue_d','loan_amnt','out_prncp','last_pymnt_amnt','installment','annual_inc','total_rec_int','last_credit_pull_d')
v.dup = match(v.dup,names(vmdfinal))
v.dup

vmdfinal = vmdfinal[,-v.dup]
vmdfinal$outpercent = NULL
vmdfinal$days_since_creditpull = NULL
vmdfinal$int_rate_num = NULL #can be considred x = f(y) since higher default will drive up int...
vmdfinal$grade = NULL
vmdfinal$days_since_issued = NULL

names(vmdfinal)

# FINAL DATA SET AFTER LASSO AND RF 222.5

#vfinalselect = c('application_type','chargeoff_within_12_mths','collections_12_mths_ex_med','emplengthgiven','home_ownership','inq_last_6mths','installmentperincome','lastficoscore_mean','mort_acc','num_actv_bc_tl','open_il_12m','pub_rec','tax_liens','title','verification_status','daystilmaturity','avg_fico_range','earliest_cr_line','mo_sin_old_il_acct','dti','mo_sin_old_rev_tl_op','revol_bal','revol_util_num', 'fac_loanstatus')
#vfinalselect = match(vfinalselect,names(vmdfinal))

#vfinal = vmdfinal[,vfinalselect]


#correlation
#run correlation matrix on numeric vars
mcor = cor(vmdfinal[, sapply(vmdfinal, is.numeric)],
           use = "complete.obs", method = "pearson")
lower<-mcor
lower[lower.tri(mcor, diag=TRUE)]<-""
lower<-as.data.frame(lower)

write.table(lower,"lowerv.csv",col.names=TRUE, sep=",")
#only 1 major collinear relationship mort_acc and early credit line

#PCA vmdfinal
pr.out = prcomp(vmdfinal[, sapply(vmdfinal, is.numeric)], scale=TRUE)
names(pr.out)
pr.out$center
pr.out$scale
pr.out$rotation
pr.out$sdev
str(pr.out)

eig.val <- get_eigenvalue(pr.out)
eig.val

#relevant eigenvectors
# pc1 = months since oldest bank account opened
# pc2 = total debt balance ($s)
# pc3 = # other debt accounts opened (qty, not value)
# pc4 = public inquiries | 
# pc5 = fico score
# pc6 =  debt/income
# pc7 = emp length

#PCA masterdata
#masterdata too large PCA, run on m5 var reduction from market basket assessment
vnames = c("last_pymnt_d","next_pymnt_d","out_prncp","out_prncp_inv","last_credit_pull_d",'total_pymnt_inv', 'total_rec_int', 'total_rec_prncp', 'last_pymnt_amnt', 'funded_amnt_inv','funded_amnt','total_pymnt','initial_list_status','policy_code','purpose','pymnt_plan','sub_grade','url','zip_code','debt_settlement_flag','debt_settlement_flag_date','settlement_status','settlement_date')
vnames <- match(vnames,names(masterdata))
vnames

pca_m <- masterdata[,-vnames]
names(pca_m)
pca_m <- pca_m[,-1]

#tuple reduction
train = sample(1:nrow(pca_m),.50*nrow(pca_m))
pca_m1 <- pca_m[train,]

#remove zero variance
nz = nearZeroVar(pca_m1[,sapply(pca_m1,is.numeric)], saveMetrics = TRUE)
nzr = rownames(nz[which(nz$zeroVar==TRUE | nz$nzv==TRUE),])
nzr = match(nzr, names(pca_m1))
nzr
pca_m1 <- pca_m1[,-nzr]

#use complete obs
pca_m1 = pca_m1[,which(colMeans(!is.na(pca_m1)) > 0.5)]
pca_m1 = pca_m1[complete.cases(pca_m1),]

pr.out = prcomp(pca_m1[, sapply(pca_m1, is.numeric)], scale=TRUE)
names(pr.out)
pr.out$center
pr.out$scale
pr.out$rotation
pr.out$sdev
str(pr.out)

eig.val <- get_eigenvalue(pr.out)
eig.val <- as.data.frame(setDT(eig.val, keep.rownames = TRUE)[])
eig.val$temp = "set"

ggplot(eig.val, aes(x=rn, y=cumulative.variance.percent)) + geom_line(group = 'set') + xlab("Specificity") + ylab("Accuracy")
eig.val[1,1]

write.csv(eig.val, "eigval.csv",row.names = FALSE)


# model processing

#basic tree guess..eeks 333

#only reduce cardinality for RANDOM FOERST
train = sample(1:nrow(vmdfinal.normalize),.50*nrow(vmdfinal.normalize))
vmdfinal.normalize = vmdfinal.normalize[train,]

#vfinal
vmdfinal <- mydata
vmdtree = vmdfinal
#vmdtree$loan_status = as.factor(ifelse(vmdtree$loan_status == TRUE,"Default","Current"))
vntrain = .70

set.seed(1)
train = sample(1:nrow(vmdtree),vntrain*nrow(vmdtree))
vmdtree.train = vmdtree[train,]
vmdtree.test = vmdtree[-train,]


# CART model
rtree.web =  rpart(loan_status~.,data = vmdtree.train,cp=.002,parms=list(split="information", loss=matrix(c(0,4,1,0), nrow=2)))

#rtree.web =  rpart(fac_loanstatus~.,data = vmdtree.train, cp=.001)

prp(rtree.web)
summary(rtree.web)
print(rtree.web)

printcp(rtree.web)

tree.pred = predict(rtree.web,vmdtree.test, type="class")
confusionMatrix(tree.pred,vmdtree.test$loan_status)

#RUN FINALTEST

#our cost matrix
rtree.web =  rpart(loan_status~.,data = finaltrain,cp=.002,parms=list(split="information", loss=matrix(c(0,4,1,0), nrow=2)))

#reg
rtree.web =  rpart(loan_status~.,data = vmdtree,cp=.002)

prp(rtree.web)
print(rtree.web)

tree.pred = predict(rtree.web,finaltest, type="class")
confusionMatrix(tree.pred,finaltest$loan_status)

var(vmdfinal$dti)^.5
vmdfinal %>% group_by(application_type, loan_status) %>% summarise(vc=n())

#AUC Curve Final CART

predict_loan_status_tree = predict(rtree.web,finaltest,type="prob")
prob_tree <- predict_loan_status_tree[,1]

rocCurve_svm = roc(response = finaltest$loan_status,
                   predictor = prob_tree)

auc_curve = auc(rocCurve_svm)
auc_curve


#kfold cross validate on cost parameter and cp
testcost =seq(1, 10, by = 0.5)

collect1 <- data.frame(testcost = numeric(0), cp = numeric(0), accuracy = numeric(0), spec = numeric(0))

set.seed(12345)

for(i in 1:length(testcost)) {
  
caret.control <- trainControl(method = "repeatedcv",
                              number = 5,
                              repeats = 1)

cv.rtree.web <- train(vmdtree.train[,-23],
                      vmdtree.train[,23],
                      method = "rpart",
                      trControl = caret.control,
                      tuneLength = 10,
                      parms=list(split="information", loss=matrix(c(0,testcost[i],1,0), nrow=2)))

cv.rtree.best <-cv.rtree.web$finalModel

collect1[i,1] = testcost[i]
collect1[i,2] = as.numeric(cv.rtree.best$tuneValue)

tree.pred = predict(cv.rtree.best,vmdtree.test, type="class")
v.c <- confusionMatrix(tree.pred,vmdtree.test$loan_status)

collect1[i,3] = as.numeric(v.c$overall[1])
collect1[i,4] = as.numeric(v.c$byClass[2])
}

collect1$sumtotal = collect1$accuracy + collect1$spec
collect1$costfinal = (2*collect1$spec + collect1$accuracy)/3 - (collect1[1,3] - collect1$accuracy)^2
collect1$coll_label = paste("CostParm: ",collect1$testcost," Cost: ",round(collect1$costfinal,3),sep="")

ggplot(collect1, aes(x=spec, y=accuracy)) + geom_line() + xlab("Specificity") + ylab("Accuracy")

#running 5-cv on tree optimal cost is 3.5 for FP and cp = .0028
range(collect1$costfinal)

#RF RANDOMFOREST using all

vmd.rf = randomForest(fac_loanstatus~., type="class", data=vmdtree.train, mtry=5, ntree=100, importance=TRUE, proximity=TRUE)
#final model above NO training subset, train on 100% of data

vmd.rf

yhat.rf = predict(vmd.rf, newdata = vmdtree.test)

vtest= cbind(vmdtree.test,yhat.rf)

confusionMatrix(vtest$yhat.rf,vtest$fac_loanstatus)

varImpPlot(vmd.rf)


#run SVM model

vmd_svm = vmdfinal.normalize

loan_status = vmd_svm$fac_loanstatus
dummy_model = dummyVars(fac_loanstatus ~ .,vmd_svm,fullRank = TRUE)
vmd_svm = as.data.frame(predict(dummy_model,vmd_svm))
vmd_svm$fac_loanstatus = loan_status
rm(loan_status)
vmd_svm$fac_loanstatus = sapply(vmd_svm$fac_loanstatus, function(x){ifelse(x == "Current", 1, -1)})

set.seed(1)
train = sample(1:nrow(vmd_svm),.70*nrow(vmd_svm))
vmdsvm.train = vmd_svm[train,]
vmdsvm.test = vmd_svm[-train,]

svmfit=svm(fac_loanstatus~., data=vmdsvm.train, kernel="linear", cost=1000,scale=TRUE)

plot(svmfit, mdfsvm)




#run LOGIT AND LASSO model
set.seed(12345)


vmdtree.logit.train = vmdtree.train
vmdtree.logit.test = vmdtree.test


vmd.logit <- glm(loan_status~., data=vmdtree.logit.train, family=binomial)

# Summary of the regression
summary(vmd.logit)

# Model coefficients
coef(vmd.logit)

mylogit.probs <- predict(vmd.logit,vmdtree.logit.test,type="response")

mylogit.pred = as.data.frame(vmdtree.logit.test$loan_status)
colnames(mylogit.pred) = "actual"
mylogit.pred = cbind(mylogit.pred,mylogit.probs)
mylogit.pred$predict = as.factor(mapply(function(x){if(x > .20){"Default"}else{"Current"}},mylogit.pred$mylogit.probs))

confusionMatrix(mylogit.pred$predict,mylogit.pred$actual)

#RUN FINALTEST

vmd.logit <- glm(loan_status~., data=vmdtree, family=binomial)
summary(vmd.logit)

mylogit.probs <- predict(vmd.logit,finaltest,type="response")

mylogit.pred = as.data.frame(finaltest$loan_status)
colnames(mylogit.pred) = "actual"
mylogit.pred = cbind(mylogit.pred,mylogit.probs)
mylogit.pred$predict = as.factor(mapply(function(x){if(x > 0.20){"Default"}else{"Current"}},mylogit.pred$mylogit.probs))
#set threshold LOWER to reduce false positives

confusionMatrix(mylogit.pred$predict,mylogit.pred$actual)

mydata %>% group_by(home_ownership,loan_status) %>% summarise(vc=n())

#10 cv fold logit ## ONLY FOR LASSO FEATURE SEL

vmdlasso = vmdtree
dummy_model = dummyVars(loan_status ~ .,vmdlasso,fullRank = TRUE)
vmdlasso.dummy = as.data.frame(predict(dummy_model,vmdlasso))
vmdlasso.dummy$loan_status = vmdlasso$loan_status
vmdlasso = vmdlasso.dummy
rm(vmdlasso.dummy)


x = as.matrix(vmdlasso[,-36])
y_train = vmdlasso[,36]

# Setting alpha = 1 implements lasso regression
lambdas <- 10^seq(2, -3, by = -.1)
lambdas
lasso_reg <- cv.glmnet(x, y_train, alpha = 1, lambda = lambdas, standardize = TRUE, nfolds = 10, family="binomial")


# Best 
lambda_best <- lasso_reg$lambda.min 
lambda_best

lasso_model <- glmnet(x, y_train, alpha = 1, lambda = lambda_best, standardize = TRUE, family="binomial")

lasso_analyize <- coef(lasso_model)
lasso_analyize = lasso_analyize[,1]
lasso_analyize = as.data.frame(cbind(names(lasso_analyize),lasso_analyize))
lasso_analyize$lasso_analyize = as.numeric(lasso_analyize$lasso_analyize)

lasso_analyize = lasso_analyize[order(lasso_analyize),]
lasso_analyize$vabs = abs(as.numeric(lasso_analyize$lasso_analyize))
lasso_analyize = na.omit(lasso_analyize)
lasso_analyize = lasso_analyize[order(lasso_analyize$vabs),]
lasso_final = lasso_analyize[lasso_analyize$vabs >= .015,] # take only that increase odds by 1.5%
lasso_final = lasso_final[c(1:22),] #del intrcept


ggplot(lasso_final, aes(x=reorder(V1, -vabs), y=vabs)) + geom_bar(stat = "identity") +
  theme(axis.text.x=element_text(angle = -90, hjust = 0)) + labs(title="Lasso Regression Feature Selection") + 
  xlab("Feature Name") + ylab("abs val change delta(log(odds))") + theme(plot.title = element_text(hjust = 0.5))


write.csv(lasso_final,"lassofinal.csv",row.names = FALSE)


#parsimony model tree based on market rules

names(vmdfinal)
vmdtree.pars = vmdfinal.normalize[,c(82,73,74,14,16,6,51,16)]

set.seed(1)
train = sample(1:nrow(vmdtree),.70*nrow(vmdtree.pars))
vmdtree.pars.train = vmdtree.pars[train,]
vmdtree.pars.test = vmdtree.pars[-train,]

rtree.web =  rpart(fac_loanstatus~., vmdtree.pars.train)
prp(rtree.web)
summary(rtree.web)

tree.pred = predict(rtree.web,vmdtree.pars.test, type="class")
confusionMatrix(tree.pred,vmdtree.pars.test$fac_loanstatus)






#create association rules to ascertain relevant predictors
colselect = c('X', 'loan_amnt', 'installment', 'annual_inc', 'loan_status', 'title', 'dti', 'out_prncp', 'last_pymnt_d', 'next_pymnt_d', 'chargeoff_within_12_mths', 'hardship_flag', 'int_rate_num', 'lastficoscore_mean', 'grade')

vmdgroceries = vmdfinal[,colselect]
summary(vmdgroceries$loan_amnt)

group_tags <- cut(vmdgroceries$loan_amnt, 
                  breaks=c(0,9000,15000,24000,40000), 
                  include.lowest=TRUE, 
                  right=FALSE, 
                  labels=c("1stq_loan","2ndq_loan","3rdq_loan","4thq_loan"))

vmdgroceries$facloan = group_tags

summary(vmdgroceries$installment)

group_tags <- cut(vmdgroceries$installment, 
                  breaks=c(0,265,400,645,40000), 
                  include.lowest=TRUE, 
                  right=FALSE, 
                  labels=c("1stq_install","2ndq_install","3rdq_install","4thq_install"))

vmdgroceries$facinstallment = group_tags
vmdgroceries$loan_amnt = NULL


summary(vmdgroceries$annual_inc)

xn = "annualinc"

group_tags <- cut(vmdgroceries$annual_inc, 
                  breaks=c(0,48000,70000,100000,180000), 
                  include.lowest=TRUE, 
                  right=FALSE, 
                  labels=c(paste("1q_",xn),paste("2q_",xn),paste("3q_",xn),paste("4q_",xn)))

vmdgroceries$annual_inc = group_tags

summary(vmdgroceries$dti)

xn = "dti"

group_tags <- cut(vmdgroceries$dti, 
                  breaks=c(0,12.3,18.61,25.93,180000), 
                  include.lowest=TRUE, 
                  right=FALSE, 
                  labels=c(paste("1q_",xn),paste("2q_",xn),paste("3q_",xn),paste("4q_",xn)))

vmdgroceries$dti = group_tags

summary(vmdgroceries$out_prncp)

xn = "outprincp"

group_tags <- cut(vmdgroceries$out_prncp, 
                  breaks=c(0,4745,9631,17200,33300),
                  include.lowest=TRUE, 
                  right=FALSE, 
                  labels=c(paste("1q_",xn),paste("2q_",xn),paste("3q_",xn),paste("4q_",xn)))

vmdgroceries$out_prncp = group_tags

vname = "int_rate_num"
vcol = match(vname,names(vmdgroceries))

summary(vmdgroceries[,vcol])

xn = vname

group_tags <- cut(vmdgroceries[,vcol], 
                  breaks=c(0,.0846,.1199,.1612,1),
                  include.lowest=TRUE, 
                  right=FALSE, 
                  labels=c(paste("1q_",xn),paste("2q_",xn),paste("3q_",xn),paste("4q_",xn)))

vmdgroceries[,vcol] = group_tags


vname = "lastficoscore_mean"
vcol = match(vname,names(vmdgroceries))

summary(vmdgroceries[,vcol])
xn = vname

group_tags <- cut(vmdgroceries[,vcol], 
                  breaks=c(0,672,702,737,1000),
                  include.lowest=TRUE, 
                  right=FALSE, 
                  labels=c(paste("1q_",xn),paste("2q_",xn),paste("3q_",xn),paste("4q_",xn)))

vmdgroceries[,vcol] = group_tags

vmdgroceries$chargeoff_within_12_mths = as.factor(vmdgroceries$chargeoff_within_12_mths)
vmdgroceries$X = NULL
vmdgroceries$loan_status = as.factor(sapply(vmdgroceries$loan_status,function(x){if(x == FALSE){"Current"}else{"Default"}}))

vmdgroceries$princpercent = vmdfinal$out_prncp / vmdfinal$loan_amnt
summary(vmdgroceries$princpercent)
vmdgroceries %>% group_by(loan_status) %>% summarize(vmean = mean(princpercent))

#RUN MODEL

grocules <- apriori(vmdgroceries[,-c(7,11,10,9,5,6)],parameter = list(minlen=2, supp=0.001, conf=0.0005), appearance = list(rhs=c("loan_status=Default"), lhs=c("grade=A","grade=B","grade=C","grade=D","grade=E","grade=F")))
names(vmdgroceries)

inspect(grocules)



