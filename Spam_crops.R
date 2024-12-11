library(terra)
library(tidyterra)
library(data.table)
library(ggplot2)
library(dplyr)
library(plyr)

#set working directory
setwd("/Volumes/Macintosh HD - Data 2/Anna")

#import tif of all the outputs from cluster
output_rast<-rast("ALL_OUTPUT.tif")#climate distances
#import spam crop ranges as a tif stack
spam_stack<-rast("spam_ranges_physical_area.tif")

#mask climate distance raster to harvested area for one crop 
#these run slow, move to david's laptop
####DONE#####
WHEA_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_WHEA_A)
RICE_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_RICE_A)
MAIZ_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_MAIZ_A)
writeRaster(MAIZ_rast,"MAIZ_CD.tif")
BARL_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_BARL_A)
writeRaster(BARL_rast,"BARL_CD.tif")
MILL_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_MILL_A)
writeRaster(MILL_rast,"MILL_CD.tif")
PMIL_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_PMIL_A)
writeRaster(PMIL_rast,"PMIL_CD.tif")
SORG_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_SORG_A)
writeRaster(SORG_rast,"SORG_CD.tif")
OCER_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_OCER_A)
writeRaster(OCER_rast,"OCER_CD.tif")

POTA_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_POTA_A)
writeRaster(POTA_rast,"POTA_CD.tif")
SWPO_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_SWPO_A)
writeRaster(SWPO_rast,"SWPO_CD.tif")
YAMS_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_YAMS_A)
writeRaster(YAMS_rast,"YAMS_CD.tif")
CASS_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_CASS_A)
writeRaster(CASS_rast,"CASS_CD.tif")
ORTS_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_ORTS_A)
writeRaster(ORTS_rast,"ORTS_CD.tif")


BEAN_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_BEAN_A)
writeRaster(BEAN_rast,"BEAN_CD.tif")
CHIC_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_CHIC_A)
writeRaster(CHIC_rast,"CHIC_CD.tif")
COWP_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_COWP_A)
writeRaster(COWP_rast,"COWP_CD.tif")
PIGE_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_PIGE_A)
writeRaster(PIGE_rast,"PIGE_CD.tif")
LENT_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_LENT_A)
writeRaster(LENT_rast,"LENT_CD.tif")
OPUL_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_OPUL_A)
writeRaster(OPUL_rast,"OPUL_CD.tif")

SOYB_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_SOYB_A)
writeRaster(SOYB_rast,"SOYB_CD.tif")
GROU_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_GROU_A)
writeRaster(GROU_rast,"GROU_CD.tif")
CNUT_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_CNUT_A)
writeRaster(CNUT_rast,"CNUT_CD.tif")
OILP_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_OILP_A)
writeRaster(OILP_rast,"OILP_CD.tif")
SUNF_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_SUNF_A)
writeRaster(SUNF_rast,"SUNF_CD.tif")
RAPE_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_RAPE_A)
writeRaster(RAPE_rast,"RAPE_CD.tif")
SESA_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_SESA_A)
writeRaster(SESA_rast,"SESA_CD.tif")
OOIL_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_OOIL_A)
writeRaster(OOIL_rast,"OOIL_CD.tif")
SUGC_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_SUGC_A)
writeRaster(SUGC_rast,"SUGC_CD.tif")
SUGB_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_SUGB_A)
writeRaster(SUGB_rast,"SUGB_CD.tif")

COTT_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_COTT_A)
writeRaster(COTT_rast,"COTT_CD.tif")
OFIB_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_OFIB_A)
writeRaster(OFIB_rast,"OFIB_CD.tif")
COFF_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_COFF_A)
writeRaster(COFF_rast,"COFF_CD.tif")
RCOF_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_RCOF_A)
writeRaster(RCOF_rast,"RCOF_CD.tif")
COCO_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_COCO_A)
writeRaster(COCO_rast,"COCO_CD.tif")
TEAS_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_TEAS_A)
writeRaster(TEAS_rast,"TEAS_CD.tif")
TOBA_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_TOBA_A)
writeRaster(TOBA_rast,"TOBA_CD.tif")
BANA_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_BANA_A)
writeRaster(BANA_rast,"BANA_CD.tif")
PLNT_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_PLNT_A)
writeRaster(PLNT_rast,"PLNT_CD.tif")
CITR_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_CITR_A)
writeRaster(CITR_rast,"CITR_CD.tif")
TROF_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_TROF_A)
writeRaster(TROF_rast,"TROF_CD.tif")
TEMF_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_TEMF_A)
writeRaster(TEMF_rast,"TEMF_CD.tif")

TOMA_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_TOMA_A)
writeRaster(TOMA_rast,"TOMA_CD.tif")
ONIO_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_ONIO_A)
writeRaster(ONIO_rast,"ONIO_CD.tif")
VEGE_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_VEGE_A)
writeRaster(VEGE_rast,"VEGE_CD.tif")

RUBB_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_RUBB_A)
writeRaster(RUBB_rast,"RUBB_CD.tif")
REST_rast<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_REST_A)
writeRaster(REST_rast,"REST_CD.tif")
####DONE#####

####### SKIP TO HERE #############
#stack
setwd("/Volumes/Macintosh HD - Data 2/Anna/")
files <- list.files(pattern = "*_CD.csv")
names<-substr(files, start = 1, stop = 4)
df<-do.call(rbind,lapply(files,read.csv))
write.csv(df,"/Volumes/Macintosh HD - Data 2/Anna/Spam_crops_CD.csv" )

data_summary<- function(data, varname, groupnames){
  require(plyr)
  summary_func<-function(x, col){
    c(mean=mean(x[[col]],na.rm=TRUE),
      sd=sd(x[[col]],na.rm=TRUE))
  }
  data_sum<-ddply(data, groupnames, .fun = summary_func,
                  varname)
  data_sum<-rename(data_sum, c ("mean"=varname))
  return(data_sum)
}

sum<-data_summary(df, varname = "Climate_Distance", groupnames = "Crop")
ggplot(sum, aes(x=Climate_Distance, y=reorder(Crop,Climate_Distance), fill=Climate_Distance))+
  geom_bar(stat = "identity",position = position_dodge())+
  labs(y="Crop",x="Mean Climate Distance of Phyical Range (km)", fill="Climate Distace (km)")+
  theme(axis.text.x = element_text(angle=45,vjust=1,hjust=1))+scale_fill_gradient(low="#FFC300",high="#900C3F")


#plot means
mu<-ddply(df,"Crop",summarise,grp.mean=mean((Climate_Distance)))
ggplot(mu, aes(x=Crop, y=grp.mean))+geom_bar(stat="identity")



rt_lst<-c("POTA","SWPO","YAMS","CASS","ORTS")
rt_df<-filter(df, Crop %in% rt_lst)
cer_lst<-c("WHEA","RICE","MAIZ","BARL","MILL","PMIL","SORG","OCER")
cer_df<-filter(df, Crop %in% cer_lst)
mu<-ddply(cer_df,"Crop",summarise,grp.mean=mean((Climate_Distance)))
ggplot(cer_df, aes(x=(log(Climate_Distance)),col=Crop))+geom_density()+
  coord_cartesian(xlim=c(0,10))+geom_vline(data=mu, aes(xintercept=grp.mean, color=Crop))
mu
mu<-ddply(rt_df,"Crop",summarise,grp.mean=mean((Climate_Distance)))
mu
ggplot(rt_df, aes(x=(log(Climate_Distance)),col=Crop))+geom_density()+
  coord_cartesian(xlim=c(0,10))+geom_vline(data=mu, aes(xintercept=grp.mean, color=Crop))




WHEA_rast_I<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_MAIZ_I)
writeRaster(WHEA_rast_I,"WHEA_I_CD.tif")
WHEA_rast_R<-mask(output_rast, spam_stack$spam2020_v1r0_global_A_MAIZ_R)
writeRaster(WHEA_rast_R,"WHEA_R_CD.tif")

df<-as.data.frame(WHEA_rast_I, cells=F, xy=F, na.rm=NA)
df$crop<-'WHEA'
df$water<-'Irrigated'
colnames(df)<-c("Climate_Distance","Crop")
write.csv(df,file="/Volumes/Macintosh HD - Data 2/Anna/WHEA_I_CD.csv")

df<-as.data.frame(WHEA_rast_R, cells=F, xy=F, na.rm=NA)
df$crop<-'WHEA'
df$water<-'Rainfed'
colnames(df)<-c("Climate_Distance","Crop")
write.csv(df,file="/Volumes/Macintosh HD - Data 2/Anna/WHEA_R_CD.csv")


