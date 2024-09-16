result.list <- list()

urlpartA <- "https://discodata.eea.europa.eu/sql?query=SELECT%20*%20FROM%20%5BCO2Emission%5D.%5Blatest%5D.%5Bco2cars%5D%0AWHERE%20MS%20%3D%20%27"
urlpartA2 <- "%27&p="
urlpartB <- "&nrOfHits=30000&mail=null&schema=null"

countries<-c("DK")
#("AT","DE","ES","FR","IE","NL","SI","PT","MT","BG","BE","SK","LU","PL","HU","GB","NO","FI","HR","IS","RO","LT","DK")

countries<-c("CY","CZ","EE","GR","IT","LV","SE","UK")

count <- 0
for(c in countries){
for(i in 1:900000000){
  url <- paste0(urlpartA,c,urlpartA2, i, urlpartB)
  df <- jsonlite::fromJSON(url)
  df <- df$results
  df <- subset(df, df$Status == "F")
  df$MMS <- as.character(df$MMS)
  result.list[[i]] <- df
  count <- count + nrow(df)
  message(count, " downloaded")
  if(nrow(df) == 0){
    message("All done.")
    break()
    }
  rm(df, url)
}
}



  result <- dplyr::bind_rows(result.list)

  result.names <- colnames(result)









#urlpartA <- "https://discodata.eea.europa.eu/sql?query=SELECT%20*%20FROM%20%5BCO2Emission%5D.%5Blatest%5D.%5Bco2cars%5D%0AWHERE%20MS%20%3D%20%27IE%27&p="
urlpartA <- "https://discodata.eea.europa.eu/sql?query=SELECT%20*%20FROM%20%5BCO2Emission%5D.%5Blatest%5D.%5Bco2cars%5D&p="

urlpartA <- "https://discodata.eea.europa.eu/sql?query=SELECT%20*%20FROM%20%5BCO2Emission%5D.%5Blatest%5D.%5Bco2cars%5D%0AWHERE%20MS%20%3D%20%27"
urlpartA2 <- "%27&p="


urlpartB <- "&nrOfHits=0000&mail=null&schema=null"

countries<-c("DK")
#("AT","DE","ES","FR","IE","NL","SI","PT","MT","BG","BE","SK","LU","PL","HU","GB","NO","FI","HR","IS","RO","LT","DK")

countries<-c("CY","CZ","EE","GR","IT","LV","SE","UK")


print(paste0(urlpartA,urlpartB))
count <- 0
for(c in countries){
  result.list <- list()
  for(i in 1:900000000){

    url <- paste0(urlpartA,c,urlpartA2, i, urlpartB)
    df <- jsonlite::fromJSON(url)
    df <- df$results
    df <- subset(df, df$Status == "F")
    df$MMS <- as.character(df$MMS)
    result.list[[i]] <- df
    count <- count + nrow(df)
    message(c ," Page  ",i, " and ",count, " records downloaded")
    # if(nrow(df) == 0){
    #  message("All done.")
    #  break()
    # }
    rm(df, url)
  }

  result <- dplyr::bind_rows(result.list)

  assign(paste0("result_",c),result)
}

result.names <- colnames(result)


#for(cnt in c("AT","DE","ES","FR","IE","NL","SI","PT","MT","BG","BE","SK","LU","PL","HU","GB","HR","IS","RO","LT")){
for(cnt in c("DK")){
  x<-get(paste0("result_",cnt))
  fwrite(x,paste0("co2cars/",cnt,".csv"))
  saveRDS(x,paste0("co2cars/",cnt,".RDS"))
  print(paste(cnt,"done"))
}

#Glue the files together


cnt<-"DE"
countries<-c("AT","DE","ES","FR","IE","NL","SI","PT","MT","BG","BE","SK","LU","PL","HU","GB","NO","FI","HR","IS","RO","LT","DK","CY","CZ","EE","GR","IT","LV","SE","UK")
for(cnt in countries){
  print(paste("Doing",cnt))
  file<-as.data.table(readRDS(paste0("co2cars/",cnt,".RDS")))
  #print(file[1:10,1:10])
  if(cnt=="AT"){all<-file}else{all<-rbind(all,file)}
  print(paste("Done",cnt))
  rm(file)
}

saveRDS(all,"co2cars/all_countries.RDS")
















labels <- googlesheets4::read_sheet("1G8afss87FjkwJH9MHciPDNk6nxv2dhOsFRBhcnHUE7I", sheet = "Naming")

years <- unique(df$Year)
for(i in 1:length(years)){
  year <- years[i]
  subset.df <- subset(df, df$Year == year)
  page.name <- paste0("Ireland ", year)
  googlesheets4::write_sheet(subset.df, "1G8afss87FjkwJH9MHciPDNk6nxv2dhOsFRBhcnHUE7I", sheet = page.name)
  print(i)
  rm(year, subset.df, page.name)
}
