# loanrepayment_data_analysis
Data dictionary of following values:

Account_Number - account number of a loan
Customer_ID	- borrower identifier
As_Of_Dt	- date of observation
Default	- dummy variable: 1 - loan defaulted in current year, 0 - otherwise; default is defined as a loan account that is 10 months delinquent
Join_Date	- date borrower joined the bank
Age	- age in years of borrower as of the observed date
Gender - dummy variable: 1 - male, 0 - female	
FICO - observed and imputed (FICO_missing = 1) FICO score from 300 to 850 (most credit worthy)
Tenure - number of years borrower has been a member of the bank
Has_Other_Acct - dummy variable: 1 - borrower has another loan or deposit account with the bank, 0 - they do not
Open - number of other loans borrower has open
Closed - number of other loans borrower has closed	
Paid - number of loans borrower has paid off satisfactorily	
Paid_Early - number of loans borrower has paid off satisfactorily	early
Prev_Default - number of previous defaults with the bank	
Time_Since_Prev_Default	- number of years since the borrower's last default
Loan_Term	- length in years of the loan term
Amount - original amount financed
Loan_Type	- type of loan 
Secured	- dummy variable: 1 - loan is a secured loan, 0 - otherwise
Has_Cosigner - dummy variable: 1 - borrower has cosigner on the loan, 0 - otherwise
Has_Pressure - dummy variable: 1 - another member of the borrower's household banks with the lender; 0 - otherwise
Pressure_Points	- the number of other members of the borrower's household that bank with the lender
Pressure_Intensity - the total number of years other members of the borrower's household have banked with the lender 
FICO_missing - dummy variable: 1 - FICO was a missing value (ie value reported is imputed), 0 - otherwise
Secured_missing - dummy variable: 1 - Secured was a missing value (ie value reported is imputed), 0 - otherwise
