library(dplyr)
#install.packages("Kendall")
options(stringsAsFactors=FALSE)


df <- read.csv(file="C:/Users/Marcin/Desktop/Stosowana analiza regresji_gagolewski/Zadanie 3/Pobrane biblioteki/chess.stackexchange.com/chess_csv/Users.csv", header=TRUE, sep=",")
countries <- read.csv(file="C:/Users/Marcin/Desktop/Stosowana analiza regresji_gagolewski/Zadanie 3/Pobrane biblioteki/apple.stackexchange.com/apple_csv/countries.csv", header=TRUE, sep=",")
states <- read.csv(file="C:/Users/Marcin/Desktop/Stosowana analiza regresji_gagolewski/Zadanie 3/Pobrane biblioteki/apple.stackexchange.com/apple_csv/states.csv", header=TRUE, sep=",")


df$country <- NA
df$state <- NA

for(i in 1:length(df$Location)){
  location_split <- unlist(strsplit(df$Location[i], ", "))
  location_position <- location_split %in% countries$country
  if (any(location_split %in% states$code)) {
    df$country[i] <- "United States"
    df$state[i] <- location_split[location_split %in% states$code]
  } else {
    if (identical(character(0),location_split[location_position])){
      df$country[i] <- NA
    } else {
      df$country[i] <- location_split[location_position]
    }
    
  }
}

df2 <- df[-1,]
df2 <- df[!is.na(df$country),]



##### UpVote/(DownVote+1)
df2 <- df
df2$UDV <- NA
df2$UDV <- df2$UpVotes/(df2$DownVotes+1)
df2$UDV_mean <- NA
df2_srednia <- df2 %>% group_by(country) %>% summarise(UDV_mean = mean(UDV))


######### Spearman
Spearman_UDV <- function(a)
{
  ranking_krajow <- read.csv(file="C:/Users/Marcin/Desktop/Stosowana analiza regresji_gagolewski/Zadanie 3/Pobrane biblioteki/chess.stackexchange.com/chess_csv/best_countries.csv", header=TRUE, sep=",")
  countries_rating <- ranking_krajow[ranking_krajow$place<=a,]
  countries_rating <- data.frame(countries_rating)
  countries_rating$place <- as.numeric(countries_rating$place)
  
  df2_sre_wynik <- df2_srednia %>% arrange(desc(UDV_mean))
  AIWA <- cbind(df2_sre_wynik,1:nrow(df2_sre_wynik))
  colnames(AIWA) <- c("country","UDV_mean","rank")
  AIWA <- left_join(countries_rating,AIWA)
  ST <- AIWA %>% arrange(rank)
  ST <- cbind(ST,1:nrow(ST))
  ST <- ST[,-2]
  ST <- ST[,-2]
  ST <- ST[,-2]
  colnames(ST) <- c("place","rank")
  ST <- cbind(ST,(ST$place-ST$rank)^2)
  colnames(ST) <- c("place","rank","D_i")
  head(ST)
  m <- nrow(ST)
  T <- 1-(6*sum(ST$D_i)/(m*((m^2)-1)))
  c(T,m)
}

######### Kendall

Kendall_UDV <- function(a)
{
  ranking_krajow <- read.csv(file="C:/Users/Marcin/Desktop/Stosowana analiza regresji_gagolewski/Zadanie 3/Pobrane biblioteki/chess.stackexchange.com/chess_csv/best_countries.csv", header=TRUE, sep=",")
  countries_rating <- ranking_krajow[ranking_krajow$place<=a,]
  countries_rating <- data.frame(countries_rating)
  countries_rating$place <- as.numeric(countries_rating$place)
  
  df2_sre_wynik <- df2_srednia %>% arrange(desc(UDV_mean))
  AIWA <- cbind(df2_sre_wynik,1:nrow(df2_sre_wynik))
  colnames(AIWA) <- c("country","UDV_mean","rank")
  AIWA <- left_join(countries_rating,AIWA)
  ST <- AIWA %>% arrange(rank)
  ST <- cbind(ST,1:nrow(ST))
  ST <- ST[,-2]
  ST <- ST[,-2]
  ST <- ST[,-2]
  colnames(ST) <- c("place","rank")
  m <- nrow(ST)
  K <- Kendall::Kendall(ST$place,ST$rank)
  c(K$tau[1],m)
}

######### Wykresy

Spearman <- rep(0,40)
Kendall <- rep(0,40)
for(i in 3:40){
  Spearman[Spearman_UDV(i)[2]] <- Spearman_UDV(i)[1]
  Kendall[Kendall_UDV(i)[2]] <- Kendall_UDV(i)[1]
}
Spearman[1] <- -1
Spearman[2] <- -1
Kendall[1] <- -1
Kendall[2] <- -1
plot(1:40,Spearman,col="blue",type="l",ylim=c(-1.1,1.1)
     ,xlab="Liczba najlepszych kraj�w wzi�ta pod uwag�",
     ylab="Wsp. korelacji")
lines(1:40,Kendall,col="green",type="l")
######### linia, pod nia nad nia uznamy, ze zalezne. Pod nia, ze niezalezne
# do ilosci u�ytkownik�w na forum szachowym

z <- qnorm(0.95,mean=0,sd=1)
vector_odrz_S <- rep(0,40)
vector_odrz_K <- rep(0,40)
vector_odrz_S_2 <- rep(0,40)
vector_odrz_K_2 <- rep(0,40)
for (j in 3:40){
  vector_odrz_S[j] <- z/(sqrt(j-1))
  vector_odrz_K[j] <- z/(sqrt((9*j*(j-1))/(2*(2*j+5))))
}
vector_odrz_K[1] <- 10000
vector_odrz_K[2] <- 5000
vector_odrz_S[1] <- 10000
vector_odrz_S[2] <- 5000
vector_odrz_S_2 <- (-1)*vector_odrz_S
vector_odrz_K_2 <- (-1)*vector_odrz_K
lines(1:40,vector_odrz_S,col="red",type="l")
lines(1:40,vector_odrz_K,col="black",type="l")
lines(1:40,vector_odrz_S_2,col="red",type="l")
lines(1:40,vector_odrz_K_2,col="black",type="l")
legend("topright",col=c("blue","green","red","black"),
       legend=c("Spearman","Kendall","funkcja krytyczna Spearman","funkcja krytyczna Kendall"),
       pch=15,cex=0.9)