library(tidyverse)
#library(gganimate)
library(magick)

#written Matt Hilton 19 June 2020

# the purpose of this script is to create a animation that shows the progression
# of the ERP as time of the trial progresse, syncronised to the playing of an
# example stimulus. to do this, we need to create a sequence of images. Each
# image will contain the ERP with the corresponding frame of the stimulus video
# imposed onto it. These images are then all merged together into an animation.

dataIn <- readRDS("data/wholeTrialEEG.rds") %>% # read in eeg data
  ungroup() %>% 
  mutate(trialTimeCorrect=trialTime-1000) %>% 
  mutate(location=fct_relevel(location, "frontal", "central", "posterior"))

head(dataIn)



framesBC <- list.files("imgs/BCPD1Frames", full.names = TRUE) #import individual frames that were extracted in matlab
framesDF_bc <- 
  tibble(filename=framesBC) %>%  
  mutate(frameID=str_extract(filename, "(?<=imgs\\/BCPD1Frames\\/)(.*)(?=.jpg)") %>% as.numeric(), 
         frameOnset=frameID*16.7, 
         condition="BC") # determine time of onset of each frame and store in a dtaframe

toFill<-framesDF_bc %>% 
  select(frameID, frameOnset) %>% 
  mutate(condition="NB")


framesNB <- list.files("imgs/NBNB1Frames", full.names = TRUE) #import individual frames that were extracted in matlab

framesDF_nb <- 
  tibble(filename=framesNB) %>%  
    mutate(frameID=str_extract(filename, "(?<=imgs\\/NBNB1Frames\\/)(.*)(?=.jpg)") %>% as.numeric()) 

allFrames<-
  left_join(toFill, framesDF_nb) %>% 
  mutate(filename=ifelse(!is.na(filename), filename, framesNB[length(framesNB)])) %>% 
  bind_rows(framesDF_bc)




intly <- seq(min(dataIn$trialTime)+10, max(dataIn$trialTime), 50) # each number is a frame of the animation. the number is the ms (milisecond) of the experiment that the frame will show

#now loop through each "frame" as defined by the intly sequence
a <- lapply(intly, function(crit){
  fig <- image_graph(width = 400, height = 400, res = 96) # open new graphic 
  p <- ggplot(dataIn[dataIn$trialTime<=crit,], aes(x=trialTimeCorrect, y=meanAmp, color=condition))+
    geom_line()+
    scale_y_reverse(limits=rev(range(dataIn$meanAmp)))+
    facet_wrap(~location, ncol=1)+
    scale_x_continuous(limits=range(dataIn$trialTimeCorrect)) +# plot the graph to the point of the current frame
    jtools::theme_apa()+
    theme(legend.position = "none")+
    scale_colour_manual(values = c("NB"="#E69F00", "BC"="#56B4E9"))+
    ylab("amplitude (mV)")+
    xlab("time from onset of first action (ms)")

  print(p) # print this graph
  dev.off() # close graphics "editor"
  
  
  currentNB <- allFrames %>% 
    filter(condition=="NB") %>% 
    slice(which(abs(frameOnset-crit)==min(abs(frameOnset-crit)))) %>% 
    select(filename) %>% 
    pull()
    
  currentBC <- allFrames %>% 
    filter(condition=="BC") %>% 
    slice(which(abs(frameOnset-crit)==min(abs(frameOnset-crit)))) %>% 
    select(filename) %>% 
    pull()
  
  
  
  twoNB <- image_read(currentNB) %>% 
    image_scale("200") %>% # read the stimulus frame and scale it
    image_border("#E69F00", "5x5") %>% 
    image_annotate("no boundary", gravity="south", size=30)
  
  twoBC <- image_read(currentBC) %>% 
    image_scale("200") %>% # read the stimulus frame and scale it
    image_border("#56B4E9", "5x5") %>% 
    image_annotate("boundary", gravity="south", size=30)
 
  stim<-
  c(twoNB, twoBC) %>% 
    image_append()
    
  outfilename <- paste0("imgs/NBNB1/", crit, ".png")
  
  out<-c(fig, stim) %>% 
    image_append(stack = TRUE) %>% 
    image_write(outfilename)
  return(out)
  
})


#animate in R if you wanna
u <- image_join(a) # merge all individual images created in the lapply loop into one "image vector"



animation <- image_animate(u, fps = 2, optimize = TRUE) #animate this image vectore
print(animation) #show the resulting animation
image_write(animation, "test.gif") # this doesn't work for some reason
image_write(animation, "test.mpeg")
