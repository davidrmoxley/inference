# loanrepayment_data_analysis
## Data dictionary of following values:

Account_Number - account number of a loan<br/>
Customer_ID	- borrower identifier<br/>
As_Of_Dt	- date of observation<br/>
Default	- dummy variable: 1 - loan defaulted in current year, 0 - otherwise; default is defined as a loan account that is 10 months delinquent<br/>
Join_Date	- date borrower joined the bank<br/>
Age	- age in years of borrower as of the observed date<br/>
Gender - dummy variable: 1 - male, 0 - female<br/>
FICO - observed and imputed (FICO_missing = 1) FICO score from 300 to 850 (most credit worthy)<br/>
Tenure - number of years borrower has been a member of the bank<br/>
Has_Other_Acct - dummy variable: 1 - borrower has another loan or deposit account with the bank, 0 - they do not<br/>
Open - number of other loans borrower has open<br/>
Closed - number of other loans borrower has closed<br/>
Paid - number of loans borrower has paid off satisfactorily<br/>
Paid_Early - number of loans borrower has paid off satisfactorily	early<br/>
Prev_Default - number of previous defaults with the bank<br/>
Time_Since_Prev_Default	- number of years since the borrower's last default<br/>
Loan_Term	- length in years of the loan term<br/>
Amount - original amount financed<br/>
Loan_Type	- type of loan<br/>
Secured	- dummy variable: 1 - loan is a secured loan, 0 - otherwise<br/>
Has_Cosigner - dummy variable: 1 - borrower has cosigner on the loan, 0 - otherwise<br/>
Has_Pressure - dummy variable: 1 - another member of the borrower's household banks with the lender; 0 - otherwise<br/>
Pressure_Points	- the number of other members of the borrower's household that bank with the lender<br/>
Pressure_Intensity - the total number of years other members of the borrower's household have banked with the lender<br/>
FICO_missing - dummy variable: 1 - FICO was a missing value (ie value reported is imputed), 0 - otherwise<br/>
Secured_missing - dummy variable: 1 - Secured was a missing value (ie value reported is imputed), 0 - otherwise<br/>
