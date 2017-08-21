require(lubridate)
require(ggplot2)
require(tidyverse)
require(reshape2)
require(geosphere)
require(cluster)

#     Sample Data In ZipCodes
### ZipCode	Lat	Lon
### 00501	40.8154	-73.0451
### 01001	42.0702	-72.6227
### 01002	42.3671	-72.4646
### 01003	42.3919	-72.5248
### 01004	42.3845	-72.5132
### 01005	42.4097	-72.1084
### 01007	42.2751	-72.411
### 01008	42.1829	-72.9361
### 01009	42.2061	-72.3405
### 01010	42.1165	-72.1885
### 01011	42.2794	-72.9888
### 01012	42.3923	-72.8256
### 01013	42.1487	-72.6079
### 01014	42.1707	-72.6048
### 01020	42.1764	-72.5761
### 01021	42.1707	-72.6048
### 01022	42.1934	-72.5544
### 01026	42.4633	-72.9202
### 01027	42.2668	-72.669

ZipCodes <- read.xlsx("C:\\Users\\kblv991\\Desktop\\ZipCodes.xlsx", 1)

GeoCluster <<- function(LatLon, Clusters){ # Any size data frame with two columns named Lat and Lon 
  
  if(!("Lat" %in% colnames(LatLon) & "Lon" %in% colnames(LatLon))){
    stop("Data frame must have columns named 'Lat' and 'Lon' for latitude and longitude")
  }
  if(missing(Clusters)){
    stop("Please enter the number of clusters")
  }
  
  Data <- LatLon %>% 
            mutate(RowCount = 1:nrow(.))
  
  Rows <- Data %>%
            dplyr::select(RowCount, Lat, Lon)
  
  Frame <- expand.grid(1:nrow(LatLon), 1:nrow(LatLon))
  
  DistMatrix <- Frame %>%
                  left_join(Rows, by = c("Var1" = "RowCount")) %>%
                  left_join(Rows, by = c("Var2" = "RowCount")) %>%
                  mutate(Distance = distHaversine(cbind(Lon.x, Lat.x), cbind(Lon.y, Lat.y))) %>%
                  dcast(Var1 ~ Var2, value.var = "Distance") %>%
                  dplyr::select(-Var1)
  
  #Partition around medoids (pam) approximates K-Means for dissimilarity (distance) matrices
  LatLon %>% 
    mutate(Cluster = pam(DistMatrix, Clusters, diss = TRUE)$clustering)
}

ClusterData <- GeoCluster(ZipCodes, 3)

# Plot Clustered Points
ggplot(data = ClusterData, aes(Lon, Lat, color = factor(Cluster))) + geom_point() 


