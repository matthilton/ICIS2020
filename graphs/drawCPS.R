library(tidyverse)
library(grid)
library(gridExtra)
pausePlot3<-
  readRDS("data/CPSdata.rds") %>% 
  filter(pauseLength=="short") %>% 
  mutate(location=fct_collapse(electrode, 
                               frontal=c("F3", "Fz", "F4"), 
                               central=c("C3", "Cz", "C4"), 
                               posterior=c("P3", "Pz", "P4")))
colG=c("NB"="#E69F00", "BC"="#56B4E9") 
lineG=c("BC"="solid", "NB" = "solid")

pp4<-pausePlot3 %>% 
  group_by(location, condition, timeCorrect) %>% 
  summarize(meanA=mean(meanAmp)) 

graph.cps.region.data<-
  ggplot()+
  geom_line(data=pp4,aes(x=timeCorrect, y=meanA, color=condition, linetype=condition), size=3)+
  scale_y_reverse()+
  facet_wrap(~location, ncol=1)+
  scale_color_manual(values=colG)+
  scale_linetype_manual(values=lineG)+
  jtools::theme_apa(  ) +
  theme(legend.position = "none", 
        plot.title = element_text(size=24),
        axis.title.x = element_text(size=28),
        axis.title.y = element_text(size=28),
        axis.text = element_text(size = 24), 
        strip.text.x=element_text(size=24)) +
  labs(x="time from midpoint of second action (ms)", y = expression(paste("amplitude ( ", mu*V, " )")))+
  theme(legend.position = "none", plot.margin=margin(10,50,10,50))+
  geom_vline(xintercept = 300, color="#E69F00", size=2.5, alpha=.4)+
  geom_vline(xintercept=540, color="#56B4E9", size=2.5, alpha=.4)+
  geom_vline(xintercept=890, color="#56B4E9", size=2.5, alpha=.4)

rect.props<-
  tribble(
    ~action, ~condition, ~xstart, ~xend, 
    "action 2",   "NB",  0, 300,
    "action 3",   "NB",  301, 750+300,
    "action 2",   "BC",  0, 540,
    "pause",      "BC",  541, 890,
    "action 3",   "BC",  891, 1640  
  ) %>% 
  mutate(ystart=ifelse(condition=="NB", 1, 0-.1), 
         yend=ifelse(condition=="NB", 0+.1, -1))

text.props <- 
  tribble(
    ~action, ~condition, ~xpos, 
    "action 2",   "NB",  150, 
    "action 3",   "NB",  300+375,
    "action 2",   "BC",  540/2, 
    "pause",      "BC",  540+(350/2),
    "action 3",   "BC",  540+350+(750/2)
  ) %>% 
  
  mutate(ypos=ifelse(condition=="NB", .5, -.5))

graph.cps.region.stimuli<-
  ggplot()+
  geom_line(data=filter(pausePlot3, electrode=="Fz"),aes(x=timeCorrect, y=meanAmp), color="white")+
  ylim(-1, 1)+
  scale_color_manual(values=colG)+
  scale_linetype_manual(values=lineG)+
  jtools::theme_apa(  ) +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(), 
        axis.text=element_text(colour="white", size=24), 
        axis.title.y=element_text(color="white", size=28), 
        axis.ticks.y=element_blank())+
  labs(x="t", y = "f")+
  theme(legend.position = "none", plot.margin=margin(10,50,10,50))+
  geom_rect(data=rect.props, aes(xmin=xstart, xmax=xend, ymin=ystart, ymax=yend, color=condition), size=2.5, fill="#ebebeb")+
  geom_text(data=text.props, aes(x=xpos, y=ypos, label=action), size=12)



grid.arrange(graph.cps.region.data, graph.cps.region.stimuli, ncol=1, heights=c(3, 1),
             top = textGrob(
               "Segment start: mid-point of second action.
    Segment end: offset of final action.",
               gp = gpar(fontface = 2, fontsize = 24)
             ), 
             bottom=textGrob(
               "baseline taken during the 200 ms interval prior to onset of first action", 
               gp=gpar(fontsize=20)
             )
)

tosave <- arrangeGrob(graph.cps.region.data, graph.cps.region.stimuli, ncol=1, heights=c(3, 1),
                      top = textGrob(
                        "Segment start: mid-point of second action.
    Segment end: offset of final action.",
                        gp = gpar(fontface = 2, fontsize = 24)
                      ), 
                      bottom=textGrob(
                        "baseline taken during the 200 ms interval prior to onset of first action", 
                        gp=gpar(fontsize=20)
                      )
)

#ggsave(tosave,file="graphs/CPS.eps", width=34.49, height=33.22, units="cm")
ggsave(tosave,file="graphs/CPS.png", width=34.49, height=33.22, units="cm")
ggsave(tosave,file="graphs/CPS.pdf", width=34.49, height=33.22, units="cm")
