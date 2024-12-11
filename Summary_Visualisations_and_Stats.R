library(terra)
library(ggplot2)
library(moranfast)
library(plyr)
library(dplyr)
library(forcats)


setwd("/Users/user/KEW/Cluster_Code")
#CROPLAND VS NON CROPLAND 
cropland_df<-read.csv("Agro_Stack_cropland.csv")
noncropland_df<-read.csv("Agro_Stack_noncropland.csv")
#to deal with spatial autocorrelation and sample size difference
noncropland_df<-noncropland_df[sample(nrow(noncropland_df),1000000),]

df<-rbind(cropland_df,noncropland_df)
ggplot(df, aes(x=Land_Type, y=(Climate_Distance))) + 
  geom_boxplot()
ggplot(df, aes(x=Land_Type, y=(Climate_Distance))) + 
  geom_violin()+coord_cartesian()
logdf<-df
logdf$Climate_Distance<-log(df$Climate_Distance)
mu <- ddply(df, "Land_Type", summarise, grp.mean=mean(Climate_Distance))
head(mu)
ggplot(df, aes(x=log(Climate_Distance), fill=Land_Type)) + 
  geom_density(alpha=0.4)+labs(x="Log[Climate Distance]", y="Density")+
  guides(fill=guide_legend(title="Land Type"))+coord_cartesian(xlim=c(0,7.5))

coord_cartesian(xlim=c(0.0001,500))
  geom_vline(data=mu, aes(xintercept=grp.mean, color=Land_Type),
                              linetype="dashed")

group_by(df,Land_Type) %>%
  summarise(
    count = n(),
    mean = mean(Climate_Distance, na.rm = TRUE),
    IQR = IQR(Climate_Distance, na.rm = TRUE))
df$logClimateDistance<-log(df$Climate_Distance)#log transform data into normal distribution
df<-subset(df,logClimateDistance!="-Inf")
t.test(Climate_Distance ~ Land_Type, data=df)
#STEEP VS NOT STEEP CROPLAND (12% CUT OFF)
steep_df<-read.csv("Agro_steep.csv")
nonsteep_df<-read.csv("Agro_notsteep.csv")
df<-rbind(steep_df,nonsteep_df)
mu <- ddply(df, "Cropland_Type", summarise, grp.mean=mean(Climate_Distance))
head(mu)
ggplot(df, aes(x=log(Climate_Distance), fill=Cropland_Type)) + 
  geom_density(alpha=0.4)+labs(x="Log[Climate Distance]", y="Density")+
  guides(fill=guide_legend(title="Cropland Type"))+coord_cartesian(xlim=c(0,7.5))
df$logClimateDistance<-log(df$Climate_Distance)#log transform data into normal distribution
df<-subset(df,logClimateDistance!="-Inf")
t.test(Climate_Distance ~ Cropland_Type, data=df)
#CROP EXPANSION/LOSS/CONSTANT
expan_df<-read.csv("crop_expansion.csv")
const_df<-read.csv("crop_constant.csv")
loss_df<-read.csv("crop_loss.csv")
df<-rbind(expan_df,const_df,loss_df)
mu <- ddply(df, "Type", summarise, grp.mean=mean(Climate_Distance))
head(mu)
df$Type<-as.factor(df$Type)
ggplot(df, aes(x=log(Climate_Distance), fill=Type)) + 
  geom_density(alpha=0.4)+labs(x="Log[Climate Distance]", y="Density")+
  guides(fill=guide_legend(title="Cropland Type"))+coord_cartesian(xlim=c(0,7.5))
df$logClimateDistance<-log(df$Climate_Distance)#log transform data into normal distribution
df<-subset(df,logClimateDistance!="-Inf")
field_aov<-aov(logClimateDistance~Type, data=df)
hist(field_aov$residuals)
summary(field_aov)
TukeyHSD(field_aov)
#CENTRES OF AGROBIODIVERSITY
agbio_df<-read.csv("centre_agrobio.csv")
non_agbio_df<-read.csv("noncentre_agrobio.csv")
df<-rbind(agbio_df,non_agbio_df)
mu <- ddply(df, "Type", summarise, grp.mean=mean(Climate_Distance))
head(mu)
ggplot(df, aes(x=log(Climate_Distance), fill=Type)) + 
  geom_density(alpha=0.4)+labs(x="Log[Climate Distance]", y="Density")+
  guides(fill=guide_legend(title="Type"))+coord_cartesian(xlim=c(0,7.5))
df$logClimateDistance<-log(df$Climate_Distance)#log transform data into normal distribution
df<-subset(df,logClimateDistance!="-Inf")
t.test(Climate_Distance ~ Type, data=df)

#field size
vsmall<-read.csv("field_vsmall.csv")
small<-read.csv("field_small.csv")
medium<-read.csv("field_medium.csv")
large<-read.csv("field_large.csv")
vlarge<-read.csv("field_vlarge.csv")
df<-rbind(vsmall,small,medium,large, vlarge)
colnames(df)<-c("X","Climate_Distance","Field_Size")
df$Field_Size<-as.factor(df$Field_Size)
df$Field_Size<-factor(df$Field_Size,levels=c("vsmall","small","medium","large","vlarge"))
mu <- ddply(df, "Field_Size", summarise, grp.mean=mean(Climate_Distance))
head(mu)
ggplot(df, aes(x=log(Climate_Distance), fill=Field_Size)) + 
  geom_density(alpha=0.4)+labs(x="Log[Climate Distance]", y="Density")+
  guides(fill=guide_legend(title="Field Size"))+coord_cartesian(xlim=c(0,7.5))
#STATS FOR FIELD SIZE 
df$logClimateDistance<-log(df$Climate_Distance)#log transform data into normal distribution
df<-subset(df,logClimateDistance!="-Inf")
field_aov<-aov(logClimateDistance~Field_Size, data=df)
hist(field_aov$residuals)
summary(field_aov)
tt<-TukeyHSD(field_aov)
print(tt, digits = 8)
#P adj is 0 for all pairings...