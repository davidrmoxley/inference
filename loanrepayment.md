Loan Default Probability Modeling
================
David R. Moxley

# Overview

This project follows the work done in a pro bono engagement with a
community credit union to reduce their overall loan portfolio risk.
Central to that effort was the development of a loan default probability
model which combined unique feature development based on economic theory
and evaluated traditional industry models with econometric solutions and
cutting edge models in the realm of explainable machine learning.

# The Business

The community credit union suffered fr

# The Theory

\[Insert from paper\]

\[Add charts of utility curves\]

# The Data

The dataset provided consisted over fewer than 9,000 observations and
had numerous data quality issues.

\[Insert from paper\]

## Data Cleansing

Data formatting issues were abundant, duplicates columns required
extensive analysis to determine business intent, and missingness of
values threatened to limit the sample size an already small
    dataset.

    ##   Credit_Score Orig_APR Int_Rate         Loan_Type Ln_Cur_Bal Paymts_Left
    ## 1            0    0.00%     9.00 CUDL Used Vehicle    9123.57          44
    ## 2            0    0.00%     4.75   Home Equity One       0.00           0
    ## 3            0    0.00%     4.99 CUDL Used Vehicle   18142.57          61
    ## 4          590    0.00%    14.00         Signature    4001.18          19
    ## 5            0    0.00%     9.00 CUDL Used Vehicle   12941.13          49
    ## 6            0    0.00%     2.49 CUDL Used Vehicle    8068.45          31
    ##   Begin_Date
    ## 1       /  /
    ## 2       /  /
    ## 3       /  /
    ## 4       /  /
    ## 5       /  /
    ## 6       /  /

First, date columns were addressed. In addition to removing unused date
fields and standardizing formats, logical checks needed to be applied.

For example, *Join\_Date*, the date on which a member joined the credit
union logically needed to precede their oldest account *Open\_Date*.
This was not always the case and needed to be corrected in the dataset.

``` r
# Ensure logical Join_Date of customer relative to account open_date
for(i in unique(df[df$Open_Date < df$Join_Date,"Customer_ID"])){
  df$Join_Date[df$Customer_ID==i] <- min(df$Open_Date[df$Customer_ID==i],na.rm=TRUE)
}
```

Of the remaining fields, basic data conforming was performed
(e.g. conversion of interest rates – *Int\_Rate* – to proportions),
duplicate fields were merged for completeness, and irrelevant fields
were dropped from the dataset. Binary categorical variables were
converted to dummy variables and loan types (*Loan\_Type*) were
converted into broader loan categories (*Loan\_Type\_Cat*) based on the
credit union’s practices and a secured loan flag (*secured*) was added
to the dataset.

``` r
###     Create New features     ###
# Loan Type Category
df$Loan_Type_Cat <- df$Loan_Type
df$Loan_Type_Cat[df$Loan_Type %in% c("Signature","Signature (25)","ALM")]<-"Unsecured"
df$Loan_Type_Cat[df$Loan_Type %in% c("Unsecured LOC","Unsecured LOC (76)","Promotional LOC")]<-"LOC"
df$Loan_Type_Cat[df$Loan_Type == "CUDL New Vehicle"]<-"New Auto Dealer"
df$Loan_Type_Cat[df$Loan_Type == "CUDL Used Vehicle"]<-"Used Auto Dealer"
df$Loan_Type_Cat[df$Loan_Type %in% c("Used Autos and Truck","Used Vehicle (28)","Rate Recapture Pgrm")]<-"Used Auto In House"
df$Loan_Type_Cat[df$Loan_Type %in% c("New Autos and Truck","New Autos and Trucks","New Vehicle (27)")]<-"New Auto In House"
df$Loan_Type_Cat[df$Loan_Type %in% c("Home Equity (98)","Home Equity One")]<-"HELOC"
df$Loan_Type_Cat[df$Loan_Type==""]<-NA
```

While most observations had logical remedies, one account had to be
removed due to an account opening date (*Open\_Date*) that was the same
as its charge-off date (*Chg\_Off\_Date*) with no information available
with which to logically impute a replacement value.

The last step of the data cleansing process was to derive a logical,
uniform account close date for share accounts, loan accounts, and
charged-off loan accounts.

Records which had been duplicated by the client’s joint compiling of
share and loan accounts were removed and a dataset of 4,221 accounts was
now usable for analysis.

## Constructing the target variable

Our ultimate objective was to quantify the risk of default in credit
union’s portfolio at any point in time. This require manipulation of our
dataset to reflect observations of the loans through time. Time variant
characteristics of the loan and the borrower needed to be simulated -
this included our key feature of the borrower’s personal relationship
with the credit union.

To do this, we created an algorithm to match credit union members with
members of their own household and reconstructed the 35 years of loan
and member history for the credit union.

### Householding

Known household matches within the loan portfolio (i.e. identified
marital relationships or parental relationships with non-minors) would
provide an incomplete picture of a borrower’s personal relationship with
the credit union, a proxy variable needed to be derived. This was
accomplished using a deterministic household matching process to link
account holders to other account holders by grouping them into
households based on the following criteria:

1)  Same last name and street address.
2)  Same phone number
3)  Same email address
4)  Primary or Secondary Account Holder or Cosigner on the same account

An additional criteria groups individuals into the same household
through a “chained” match. In this scenario, Person A would be matched
to the same household as Person B through criteria four (4), but both
Person A and Person B matched to the same household through a third
person, Person C.
