############################################################
##                                                        ##
##               Household Function                       ##
##                                                        ##
##  Deterministic match of bank customers into            ##
##  "households" based on name, address, and account info ##
##                                                        ##
############################################################


function_assign_household <- function(df,current_date){
####        df must have Last_Name, Address, Home_Phone_No, Email_Addr & Account_Number       ####
  
  
  ###     Match Households by Condition     ###
  
  ##    Condition 1: physical household match   ##
  df <- df %>% mutate(Condition_1 = as.integer(factor(Cond_1)))
  df$Condition_1 <- df$Condition_1 + 100000
  df = subset(df, select = -c(Cond_1))
  
  ##    Condition 2: Same phone number    ##
  df <- df %>% mutate(Condition_2 = as.integer(factor(Home_Phone_No)))
  df$Condition_2 <- df$Condition_2 + 200000
  df = subset(df, select = -c(Home_Phone_No))
  
  ##    Condition 3: Same email address   ##
  df$Email_Addr <- tolower(df$Email_Addr)
  df <- df %>% mutate(Condition_3 = as.integer(factor(Email_Addr)))
  df$Condition_3 <- df$Condition_3 + 300000
  df = subset(df, select = -c(Email_Addr))
  
  ##    Condition 4: Primary or Secondary Account Holder or Cosigner on the same account    ##
  temp <- df[which(df$Open_Date<=current_date),] %>% mutate(Condition_4 = as.integer(factor(Account_Number)))
  df[which(df$Open_Date<=current_date),"Condition_4"] <- temp$Condition_4
  df$Condition_4 <- df$Condition_4 + 400000

  
  ###     Assign Householdcode      ###
  
  ##    Check number of records per condition   ##
  df <- merge(df,data.frame(df %>% group_by(Condition_1) %>% summarize(Cond_1_Cnt = n_distinct(Customer_ID,na.rm=TRUE))))
  df <- merge(df,data.frame(df %>% group_by(Condition_2) %>% summarize(Cond_2_Cnt = n_distinct(Customer_ID,na.rm=TRUE))))
  df <- merge(df,data.frame(df %>% group_by(Condition_3) %>% summarize(Cond_3_Cnt = n_distinct(Customer_ID,na.rm=TRUE))))
  df <- merge(df,data.frame(df %>% group_by(Condition_4) %>% summarize(Cond_4_Cnt = n_distinct(Customer_ID,na.rm=TRUE))))
  
  df$Cond_1_Cnt[is.na(df$Condition_1)] <- NA
  df$Cond_2_Cnt[is.na(df$Condition_2)] <- NA
  df$Cond_3_Cnt[is.na(df$Condition_3)] <- NA
  df$Cond_4_Cnt[is.na(df$Condition_4)] <- NA
  
  
  ##    Default is Condition 1, same name and address   ##
  df$Household_Cd <- paste0("H",df$Condition_1)
  
  ##  Update to Condition 2 if more individuals are matched   ##
  df$Household_Cd[which(df$Cond_2_Cnt>df$Cond_1_Cnt & !is.na(df$Condition_2))] <- paste0("H",df$Condition_2[which(df$Cond_2_Cnt>df$Cond_1_Cnt & !is.na(df$Condition_2))])
  
  ##  Update to Condition 3 if more individuals are matched   ##
  df$Household_Cd[which(df$Cond_3_Cnt>df$Cond_2_Cnt & df$Cond_3_Cnt>df$Cond_1_Cnt & !is.na(df$Condition_3))] <- paste0("H",df$Condition_2[which(df$Cond_3_Cnt>df$Cond_2_Cnt & df$Cond_3_Cnt>df$Cond_1_Cnt & !is.na(df$Condition_3))])
  
  ##  Update to Condition 4 if more individuals are matched   ##
  df$Household_Cd[which(df$Cond_4_Cnt>df$Cond_3_Cnt & df$Cond_4_Cnt>df$Cond_2_Cnt & df$Cond_4_Cnt>df$Cond_1_Cnt & !is.na(df$Condition_4))] <- paste0("H",df$Condition_2[which(df$Cond_4_Cnt>df$Cond_3_Cnt & df$Cond_4_Cnt>df$Cond_2_Cnt & df$Cond_4_Cnt>df$Cond_1_Cnt & !is.na(df$Condition_4))])
  
  df = subset(df, select = -c(Condition_4, Condition_3, Condition_2, Condition_1, Cond_1_Cnt, Cond_2_Cnt, Cond_3_Cnt, Cond_4_Cnt))
  
  #Add count of unique members of household
  df <- merge(df,data.frame(df %>% group_by(Household_Cd) %>% summarize(Household_Cnt = n_distinct(Customer_ID,na.rm=TRUE))))
  
  #Calculate Tenure
  df$Household_Tenure_Yrs <- round(with(df, difftime(current_date, Join_Date, units = "days"))/365.25,2)
  customer_years <- unique(df[df$Household_Tenure_Yrs>0,c("Household_Cd","Customer_ID","Household_Tenure_Yrs")])
  df <- merge(df,data.frame(customer_years %>% group_by(Household_Cd) %>% summarize(Household_Tenure = sum(Household_Tenure_Yrs,na.rm=TRUE))))
  
  return(df)
}
  