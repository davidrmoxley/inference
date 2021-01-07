############################################################
##                                                        ##
##         Create Historical Panel Dataset                ##
##                                                        ##
##  Convert the dataset with effective dating into a      ##
##  panel data set for modeling.                          ##
##                                                        ##
############################################################

file_path_data <- "C:/Users/dmoxley/OneDrive - Impact Makers/Pro Bono/RHFCU/Datasets"
file_path_scripts <- "C:/Users/dmoxley/OneDrive - Impact Makers/Pro Bono/RHFCU/Default_Model"


setwd(file_path_data)
df <- read.csv(paste0("loan_data_clean.csv"))


source(paste0(file_path_scripts,"/","RHFCU_HouseholdFunction.R"))


df_panel <- data.frame(Customer_ID=integer()
                       ,As_Of_Dt=as.Date(character())
                       ,Account_Number=character()
                       ,Default_Next_Year=integer()
                       ,Join_Date=as.Date(character())
                       ,Age=integer()
                       ,Gender=integer()
                       ,Marital_Status=character()
                       ,FICO=integer()
                       ,Tenure=numeric()
                       ,Has_Other_Acct=integer()
                       ,Open=integer()
                       ,Closed=integer()
                       ,Loan_Term=integer()
                       ,Amount=numeric()
                       ,Loan_Type=character()
                       ,Secured=integer()
                       ,Has_Cosigner=integer()
                       ,ACH=integer()
                       ,Has_Pressure=integer()
                       ,Pressure_Points=integer()
                       ,Pressure_Intensity=integer())
panel_range <- seq(as.Date("1997-12-31"), as.Date("2020-12-31"), by="years")

for(y in 1:length(panel_range)){
  current_date <- as.Date(panel_range[y],format="%Y/%m/%d")
  
  #Get current records relative to effective date
  df_current <- df[df$Join_Date <= current_date,]#& (df$Closed_Date_1 >='2010-12-31' | df$Closed_Date >='2010-12-31'),]
  df_current <- df_current[!is.na(df_current$Customer_ID),]
  
  #Assign household code
  df_current <- assign_Household(df_current,current_date)
  
  #Limit to customers with an open account opened before the current_date
  df_current <- df_current[df_current$Open_Date <= current_date,]
  df_current <- unique(df_current)
  
  #Age  
  df_current$Age <- round(with(df_current, difftime(current_date, Birth_Date, units = "days"))/365.25,0)
  df_current = subset(df_current, select = -c(Birth_Date))
  
  #Gender
  
  #Marital Status
  
  #FICO
  df_current$Credit_Score[is.na(df_current$Credit_Score)] <-0
  df_current <- merge(df_current,data.frame(df_current %>% group_by(Customer_ID) %>% summarize(FICO = max(Credit_Score,na.rm=TRUE))))
  df_current = subset(df_current, select = -c(Credit_Score))
  df_current$FICO[df_current$FICO==0] <-NA
  
  
  #Tenure*
  df_current$Tenure <- round(with(df_current, difftime(current_date, Join_Date, units = "days"))/365.25,2)
  #df_current = subset(df_current, select = -c(Join_Date))
  
  #Has_Other_Acct*
  df_current <- merge(df_current,data.frame(df_current %>% group_by(Customer_ID) %>% summarize(Acct_Cnt = n_distinct(Account_Number))))
  df_current$Has_Other_Acct <- 0
  df_current$Has_Other_Acct[which(df_current$Acct_Cnt>1)] <- 1
  
  #df_current[df_current$Share_Acct_Flag==0,]
  ##Drop share account records
  df_current <- df_current[df_current$Share_Acct_Flag==0,]
  df_current = subset(df_current, select = -c(Share_Acct_Flag))
  
  #Open* - #of open loans
  df_current <- merge(df_current,data.frame(df_current[is.na(df_current$Acct_Clsd_Dt),] %>% group_by(Customer_ID) %>% summarize(Open = n_distinct(Account_Number))),all.x=TRUE)
  df_current$Open[is.na(df_current$Open)]<-0
  
  #Closed* - #of paid loans
  df_current <- merge(df_current,data.frame(df_current[!is.na(df_current$Acct_Clsd_Dt),] %>% group_by(Customer_ID) %>% summarize(Closed = n_distinct(Account_Number))),all.x=TRUE)
  df_current$Closed[is.na(df_current$Closed)]<-0
  
  #Time_Since_Default*
  df_current$Time_Since_Default <- round(with(df_current, difftime(current_date, Acct_Clsd_Dt, units = "days"))/365.25,2)
  #merge(df_current,data.frame(df_current %>% group_by(Customer_ID) %>% summarize(Time_Since_Most_Recent_Default = min(Time_Since_Default))),all.x=TRUE)
  df_current$Time_Since_Default[df_current$Time_Since_Default < 0] <- NA
  df_current <- merge(df_current,data.frame(df_current %>% group_by(Customer_ID) %>% summarize(Time_Since_Default = min(Time_Since_Default,na.rm=TRUE))),all.x=TRUE)
  
  
  df_current$Default_Next_Year<-0
  df_current$Default_Next_Year[df_current$Default==1 & df_current$Acct_Clsd_Dt>current_date & df_current$Acct_Clsd_Dt<=(current_date+365)] <- 1
  
  ##Limit df_current to loans that are currently open
  df_current <- df_current[which(df_current$Acct_Clsd_Dt >= current_date | is.na(df_current$Acct_Clsd_Dt)),]
  
  #Amount - original loan amount
  df_current$Amount <- df_current$Orig_Amt
  df_current = subset(df_current, select = -c(Orig_Amt))
  
  #Paid - balance paid YTD
  df_current$Paid <- NA
  df_current$Paid[df_current$Default==0] <- df_current$Ln_Bal[df_current$Default==0]
  df_current = subset(df_current, select = -c(Ln_Bal))
  
  #Loan_Type
  df_current$Loan_Type <- df_current$Loan_Type_Cat
  df_current = subset(df_current, select = -c(Loan_Type_Cat))
  
  #Has_Cosigner
  #ACH - auto payment
  
  #Has_Pressure
  df_current$Has_Pressure <- 0
  df_current$Has_Pressure[df_current$Household_Cnt>1] <- 1
  
  #Pressure_Points
  df_current$Pressure_Points <- 0
  df_current$Pressure_Points[df_current$Household_Cnt>1] <- df_current$Household_Cnt[df_current$Household_Cnt>1]-1
  
  #Pressure_Intensity
  df_current$Pressure_Intensity <- 0
  df_current$Pressure_Intensity[df_current$Household_Cnt>1] <- round(df_current$Household_Tenure[df_current$Household_Cnt>1],0)
  
  #Set Default
  df_current$Default[df_current$Acct_Clsd_Dt > current_date] <- 0
  
  #Combine
  df_current$As_Of_Dt <- current_date
  
  #Loan Term
  names(df_current)[names(df_current)=="No_of_Pmts"] <- "Loan_Term"
  
  df_panel <- rbind(df_panel, df_current[,c("Customer_ID","As_Of_Dt","Account_Number","Default_Next_Year","Join_Date","Age","Gender","Marital_Status","FICO","Tenure","Has_Other_Acct","Open","Closed","Loan_Term","Amount","Loan_Type","Secured","Has_Cosigner","ACH","Has_Pressure","Pressure_Points","Pressure_Intensity")])
  
}

df_panel$Age <- as.integer(df_panel$Age)
df_panel$Tenure <- as.numeric(df_panel$Tenure)
df_panel <- unique(df_panel) #Remove duplicates
names(df_panel)[names(df_panel) == "Default_Next_Year"] <- "Default"
df_panel$Customer_ID <- as.factor(df_panel$Customer_ID)
df_panel$Account_Number <- as.factor(df_panel$Account_Number)
df_panel = subset(df_panel, select = -c(Pressure_Points))


##Scale Data
df_panel$Loan_Term <- df_panel$Loan_Term/12 ##term in years
df_panel$Amount <- df_panel$Amount/1000 ##amount in hundres of dollars
df_panel$Pressure_Intensity <- df_panel$Pressure_Intensity/10 ##Intensity in decades



setwd(file_path_data)
write.csv(df_panel, "loan_data_panel.csv",row.names=FALSE)
rm(df_panel,df,df_current,current_date,panel_range,y,file_path_data,file_path_scripts,assign_Household)
