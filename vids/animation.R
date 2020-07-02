
library(magrittr)

testy<-data.frame(x=seq(1, 5, 1), 
                  y=rnorm(5, 30, 12))

ff <- c("imgs/1.png",
        "imgs/2.png",
        "imgs/3.png",
        "imgs/4.png",
        "imgs/5.png")



fig <- image_graph(width = 400, height = 400, res = 96)
ggplot(testy, aes(x, y)) + geom_line()
dev.off()

image_composite(fig, image_read(ff[[1]]))


frink <- image_read(ff[[1]])
out <- image_composite(fig, frink, offset = "+70+30")
print(out)

intly <- c(1:5)


a <- lapply(intly, function(crit){
  fig <- image_graph(width = 400, height = 400, res = 96)
  p <- ggplot(testy[testy$x<=crit,], aes(x, y)) + geom_line()
  print(p)
  dev.off()
  
  two <- image_read(ff[crit])
  out <- image_composite(fig, two)
  return(out)
  })


image_join(a)

image_read("vids/sample1.mp4")




