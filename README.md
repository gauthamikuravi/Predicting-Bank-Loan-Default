# Predicting-Bank-Loan-Default


### Content 
- [Problem Statement](#Problem-Statement)
- [Data-Overview](#Data-Overview)
- [Project Files](#Project-Files)
- [Data Directory](#Data-Directory)
- [Data Collection and Cleaning](#Data-Collection-and-Cleaning)
- [Data-Preprocessing-&-Preparation](#Data-Preprocessing-&-Preparation)
- [Market-Basket-Analysis](#Market-Basket-Analysis)
- [Principal-Component-Analysis](#Principal-Component-Analysis)
- [Enhanced-Feature-Engineering](#Enhanced-Feature-Engineering)
- [Modeling](#Modeling)
- [References](#References)


## Problem-Statement

The  goal in this analysis (the Analysis or the Project) is thus to predict if a loan remains current or if it will
default given that it has already been originated by a third party bank and purchased by Lending Club indirectly
through its investors. Mathematically, we present the problem statement as:

**Pr(Loan remains current | Loan has been funded)**

The probability that a loan remains current, or alternatively 1 less the probability that the loan defaults is relevant
to both the Company as well as the investors/holders of the notes that funded the purchase the loan. LC can
benefit from better understanding what loans will default once funded and further **improve their underwriting
models for future loans, and for investors, the ability to predict if a loan will default or remain current is essential
to understanding their expected return on investment of the loan.** 

The primary key for the data set is ID. The master data set file contains
1,012,366 tuples with **150 predictor**s including the response variable. We identified the response variable as
LOAN_STATUS with a cardinality of {Current, Charged Off, Default, Fully Paid, In Grace Period, Late (16-30
Days), Late (31-120 Days}. 

### Data Collection and Cleaning

**Response Variable**
For the data set as discussed above, the response variable has been defined as a loan being current or having
defaulted.**LOAN_STATUS** is the variable indicating loan status. The loan Status variable defines those who are
**fully Paid (16.83% ), Current status of the loan (75.8%) and Defaulted (less than 1% of the data) , charged
off(4.5%) of the data**. We could the conclude from the data that major portion consists of the Current status of
the loan

<img width="1000" src="./Images/loanstatus.PNG" alt="logo" />

**Numerical Predictors:**

One of the important input feature we have explored are LOAN_AMNT which is the loan amount. From the
below plot and Table , we can infer that the loan amount varies between as minimum of 1000$ up to maximum
of 40000. The mean of the loan amount is $16253 and as the box plot suggests, the majority of the loans are
somewhere between $10000 - $20000. 
The distributions of the numerical variables are to be considered for exploration while building the model􀀀􀀀





<img width="700" src="./Images/Loanamount.PNG" alt="logo" />
<img width="700" src="./Images/annualncomePNG.PNG" alt="logo" />
<img width="700" src="./Images/boxplot.PNG" alt="logo" />



- **Fico Score Vs Loan Status:**

From the box plot we observe that median FICO scores are much higher for current loans compared to defaulted
ones. These FICO scores provide the information on how likely loan status could go Default.
- **Installment Vs Loan Status:**
Installment amount varies largely between 261.4 to 693 with median of 450.Based on the plot, we can say that
loans defaulted have on average higher installment amount
<img width="1000" src="./Images/Installmentvsloanstatus.PNG" alt="logo" />

- **Term Length**
There are two categories in Term Length. One with 36 month term the loan was borrowed and other is 60
months. We could see there are higher proportions of those with 36 month term with 693412 and 60 months with

<img width="1000" src="./Images/loanstatus-term.PNG" alt="logo" />

### Data-Preprocessing-&-Preparation



- **Univariate Analysis**
performed univariate analysis on each of the features to check for its variance against the target variable
LOAN_STATUS. Zero-Variance features and the ones having higher percentage of unique values were removed.
- **Multicollinearity**
To understand the relationship between multiple variables and attributes in the dataset i ran correlation matrix
on all the numerical features with threshold as 80% and selected the co-related variable exhibiting maximum
variance to the response.
- **Outlier Analysis**
We performed outlier analysis on all the features that had skewed data distribution.
For identifying outliers Winsorization outlier technique was used. Winsorization replaces extreme values with
the quantiles, rather than removing. This gives an advantage over other techniques which result in loss of
information. Below is the density plot for ANNUAL INCOME feature, from the plot we can see that ANNUAL
INCOME is normally distributed after outlier treatment.

<img width="1000" src="./Images/denisity.PNG" alt="logo" />


### Market-Basket-Analysis

The purpose of Market Basket Association (MBA) was done as part of Exploratory Data Analysis to ascertain
what features demonstrated higher associations with the response variable in the spirit of parsimonious model
selection. 
The master dataset was prepared for MBA by including only complete data observations and then binning all
numericals into their respective quartile intervals subject to their respective distributions. MBA was then
performed 5x sequentially using the following control parameters:


| Sequence  	| Rule-Minimum 	| Rule-Max 	| Support 	| Confidence 	| Appearance 	| Runtime 	|
|-	|:-:	|-:	|-	|-	|-	|-	|
| 1 	| 2 	| 2 	| 0.01 	| 0.95 	| LOAN_STATUS=”Default” 	| Yes 	|
| 2 	| 2 	| 3 	| 0.01 	| 0.80 	| LOAN_STATUS=”Default” 	| Yes 	|
| 3 	| 2 	| 3 	| 0.01 	| 0.80 	| LOAN_STATUS=”Default” 	| Yes 	|
| 4 	| 2 	| 5 	| 0.01 	| 0.80 	| LOAN_STATUS=”Default” 	| No 	|
| 5 	| 2 	| 5 	| 0.05 	| 0.40 	| LOAN_STATUS=”Default” 	| Yes 	|




### Principal-Component-Analysis
The first 16 principal components are considered relevant with eigenvalues greater than 1.0, and cumulatively
serve to explain approximately 78.9% of the variance in the predictor data set. Examination of the first ф[1,5]
loading vectors indicates that the first 5 eigenvectors (principal components) describe the following features of a
loan:

• PC1: total # credit lines of borrower
• PC2: loan amount and installment of borrower
• PC3: length of time of open credit accounts
• PC4: borrower FICO scores
• PC5: total $ balance on all credit lines of borrower

<img width="1000" src="./Images/PCA.PNG" alt="logo" />

### Enhanced-Feature-Engineering

**Lasso Regression – Feature Selection**

Following initial model executions, to help gain intuition about which covariates account for most of the
variation in default, I estimated a LASSO regression using all of the available features from preprocessing.
To tune the penalty parameter, we performed 10-fold cross validation with binomial distribution.

<img width="700" src="./Images/Lasso.PNG" alt="logo" />


LASSO was primarily used for feature selection in conjunction with random forest bagging (variable importance)
to get final set of features. This helped in reducing the dimensionality from 57 to 23 features.

- The waterfall chart below summarizes the total feature selection completed as part of preprocessing and
enhanced feature engineering.
[1] RED denotes subtraction
[2] BLUE denotes addition


<img width="1000" src="./Images/Feature_Summary.PNG" alt="logo" />
