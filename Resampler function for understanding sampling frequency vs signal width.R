## Resampling Many FWHM and identifying deviation

library(plyr) ###File manipulation
library(dplyr) ###File manipulation
library(ggplot2) ###plotting
library(gridExtra) ###Tabulating data
library(zoo)  ###not used in this, but mathematical functions
library(ggthemes) ###other ggplot2 graph themes
library(DescTools) ###Calculate Area under curve (AUC)
library(tidyr)
library(reshape2)
##Desired Output directory
mainDir <- "C:\\Users\\stbar\\Desktop\\Diffusion limited FEEM PeterTodd\\Figures"
subDir <- "Undersampling project 9.18.19"

##Setting the Working directory for the day's graphs

if (file.exists(subDir)){
  setwd(file.path(mainDir, subDir))
} else {
  dir.create(file.path(mainDir, subDir))
  setwd(file.path(mainDir, subDir))
  
}

#sigma.df<- 0.1/2.355 #Choosing FWHM = 0.1 ms (100 us) as our resampled peak
#grid.points=seq(-50, 50, length = 1e5*.1) ##length of dataset in s * 1e5 = 100 kHz SR
#amplitude.points = exp(-(grid.points)^2/(2*(sigma.df^2)))

FWHM.all<-c(0.05,0.1,0.5,1,2,5,10)
newRates<-c(10,20,30,40,50,100,200,300,400,500,1000,2000,3000,4000,5000,1e4,2e4,5e4,1e5)
variables<-list(newRate=newRates,FWHM.value=FWHM.all)
my.combos<-expand.grid(variables) ##expand.grid() creates a new data.frame with all possible permutations of our previous data.frame or in this case, list


Resampler<-function (newRate=df[,1],FWHM.value=df[,2]) {
  sigma.df<- FWHM.value/2.355 #Choosing FWHM = 0.1 ms (100 us) as our resampled peak
  grid.points=seq(-100, 100, length = 1e5*.2) ##length of dataset in s * 1e5 = 100 kHz SR
  amplitude.points = exp(-(grid.points)^2/(2*(sigma.df^2)))
  resampled<-data.frame(
    time.points = grid.points,
    amplitude.points=amplitude.points,
    resampled.points= rollmean(amplitude.points, k=(1e5/newRate), align = "center", na.pad = T),
    FWHM.ids=paste(FWHM.value,"ms"), #add an identifier variable
    newRate = paste(newRate,"Hz"),##add an identifier variable
    newRate.No= newRate
  )
}

All.resampled<-mdply(my.combos, Resampler) ##mdply applies multi-argument function to a dataframe
head(All.resampled)


##Have generated all permutations data.frame.  Pare down to find "plot deviation"
###Successfully plotted the differences between ET sampling and actual signals
###pipe out the NAs

Signal.differences <- All.resampled %>%
  na.omit() %>%
  group_by(FWHM.ids,newRate, newRate.No)%>%
  mutate(deviation=abs(resampled.points-amplitude.points))
head(Signal.differences)
#Signal.differences$newRate


Signal.differences.summary <- Signal.differences %>%
  group_by(FWHM.ids,newRate,newRate.No) %>%
  summarise(maxAmplitude=max(resampled.points))


###Visualize differences?

Differences.plot<-ggplot(Signal.differences.summary, aes(x=newRate.No, y=maxAmplitude, group=FWHM.ids, colour=FWHM.ids))
Differences.plot<- Differences.plot+
  geom_line(size=1)+
  geom_point(size=1)+
  labs(	x="Sampling Rate (Hz)",
        y="Max Amplitude of resampled peak (a.u.)",
        title="",
        subtitle="")+
  scale_colour_brewer(palette="Set1")+
  scale_y_continuous(expand=c(0,0))+
  scale_x_continuous(expand=c(0,0), trans="log10")#+
  #my.theme 
Differences.plot

ggsave(filename="maxPeakamplitude_vs_SR.plots3.tiff",plot=Differences.plot, device="tiff",dpi=600, units="in",width=5,height=5)

write.csv(Signal.differences.summary, "PlotPeakAmplitude_SR3.csv")




