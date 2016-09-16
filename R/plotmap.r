# last update: 18.sept.2013
plotmap <- function(region=v_area, lon, lat, center='E', add=F, 
                    grid=T, grid.res, resolution=0, 
                    main, axeslabels=T, ticklabels=T, cex.lab=0.8, cex.ticks=0.8, 
                    fill.land=T, col.land="grey", col.bg=NA, border='black', bwd=1, las=1, v_area){
  #   inst.pkg("maps") # needed to provide landmask
  #   #inst.pkg("mapdata") # needed to provide fine resolution landmask "worldHires"
  #   #inst.pkg("maptools") # needed to provide fine resolution landmask "worldHires"
  #   inst.pkg("grDevices") # needed for png file creation
  #   inst.pkg('raster')
  #   #inst.pkg("Cairo") # needed for png file creation on server
  #   data('worldHiresMapEnv',envir=environment())
  #   getAnywhere('worldHiresMapEnv')
  #   getAnywhere('worldHires')
  show.plot <- T
  if(is.na(col.land) & is.na(fill.land)){
    fill.land <- F
    show.plot <- F
    bwd <- 0
  }
  
  if(!missing(region)){ #' if region information is given
    if(class(region) == 'character') {
      r <- regions(region) # get regions defintions (extent and name)
      center <- r$center
      if(missing(grid.res)) grid.res <- r$grid.res[1]
    }else{
      if(grepl('Raster', class(region)) | grepl('Extent', class(region))){
        extent.vector <- as.vector(t(sp::bbox(extent(region))))
        r <- data.frame(xlim=extent.vector[1:2],ylim=extent.vector[3:4])
      }else{
        if(missing(lon) | missing(lat)) stop('error in plotmap: provide region information as name or lon, lat data')
      }
    }
  }else{
    if(missing(lat) | missing(lon)){
      lon <- par()$usr[1:2]
      lat <- par()$usr[3:4]
      add <- T
    }
  }
  if(!missing(lon) & !missing(lat))  r <- data.frame(xlim=range(lon),ylim=range(lat))
  if(missing(grid.res)) grid.res <- .get.grid.res(r)
  
  if(!fill.land) col.land <- NA
  
## old:
#   if(center == 'W'){
#     if(any(r$xlim < 0)){
#       r$xlim <- range(r$xlim)
#       r$xlim <- r$xlim[2:1]
#       r$xlim[2] <- 180+180+r$xlim[2]
#     }
#   }  

# old:
  if(center == 'W'){
#     r$xlim <- range(180+180+r$xlim)
#     r$xlim[r$xlim > 360] <- 360
    if(any(r$xlim < 0)){
      r$xlim <- range(r$xlim)
      r$xlim <- r$xlim[2:1]
      r$xlim[2] <- 180+180+r$xlim[2]
    }
  }  
  if(add == F) plot(10000,10000,type="p",cex=0,axes=F,xlim=r$xlim,ylim=r$ylim,xlab="",ylab="",asp=1) # l functions sets right axes limits, neccessary for maps
  par(cex.axis=cex.ticks)
  lims <- par()$usr
  rect(lims[1],lims[2],lims[3],lims[4],col=col.bg,border = NA)
  
  if(fill.land){
    if(any(r$xlim > 180)) {
#       data("worldmap", envir=environment())
      worldmap <- .get.worldmap(resolution)
      maps::map(worldmap, fill=fill.land, col=col.land,xlim=r$xlim,ylim=r$ylim,add=T,resolution=resolution,border=border)
    }else{
      maps::map(database='worldHires', fill=fill.land, col=col.land,xlim=r$xlim,ylim=r$ylim,add=T,resolution=resolution,border=border)
    }
    #### old code
    #   if(any(r$xlim > 180)) {
    #     #     data(world2HiresMapEnv, envir = environment())
    #     #     worlddb <- 'world2Hires'
    #     m1 <- maps::map('worldHires', xlim=c(100, 180),plot=F)
    #     m2 <- maps::map('worldHires', xlim=c(-180, -60),plot=F)
    #     m2$names <- m2$names[which(m2$names %in% c("USA:Alaska:Mitkof Island"))]
    #     maps::map('world2Hires', c(m1$names, m2$names), fill=fill.land, col=col.land,xlim=r$xlim,ylim=r$ylim,add=T,resolution=resolution,border=border)
    #   }else{
    # worlddb <- 'worldHires'
    #     maps::map(database=worlddb, fill=fill.land, col=col.land,xlim=r$xlim,ylim=r$ylim,add=T,resolution=resolution,border=border)
    #   }
  }
  
  #  # overplot landmask outside plotting region
  if(show.plot){
    rect(r$xlim[1],-400,-400,400,col="white",border="white",xpd=T) # xleft, ybottom, xright, ytop
    rect(r$xlim[2],-400,400,400,col="white",border="white",xpd=T)
    rect(-400,r$ylim[1],400,-400,col="white",border="white",xpd=T)
    rect(-400,r$ylim[2],400,+400,col="white",border="white",xpd=T)
    
    x <- c(ceiling(r$xlim[1]/grid.res)*grid.res, floor(r$xlim[2]/grid.res)*grid.res)
    y <- floor(r$ylim/grid.res)*grid.res
    xlabels <- seq(x[1],x[2],grid.res)
    xlabels <- xlabels[xlabels >= r$xlim[1] & xlabels <= r$xlim[2]]
    ylabels <- seq(y[1],y[2],grid.res)
    ylabels <- ylabels[ylabels >= r$ylim[1] & ylabels <= r$ylim[2]]
    EW <- rep(" E",length(xlabels))
    EW[xlabels < 0 | xlabels > 180] <- " W"
    at.xlabels <- xlabels
    xlabels[xlabels > 180] <- xlabels[xlabels > 180] - 360
    NS <- rep(" N",length(ylabels))
    NS[ylabels < 0] <- " S"
    
    if(length(ticklabels) == 1) ticklabels <- rep(ticklabels,2)
    XLabels <- switch(ticklabels[1]+1,rep('',length(xlabels)),parse(text = paste(abs(xlabels)," *degree ~",EW,sep="")))
    YLabels <- switch(ticklabels[2]+1,rep('',length(ylabels)),parse(text = paste(abs(ylabels)," *degree ~",NS,sep="")))
    axis(1,pos=r$ylim[1],at=at.xlabels,labels=XLabels)
    axis(2,pos=r$xlim[1],at=ylabels,labels=YLabels,las=las)
    axis(side=3,pos=r$ylim[2],at=at.xlabels,labels=F,tick=T)
    axis(side=4,pos=r$xlim[2],at=ylabels,labels=F,tick=T,las=las)
    
    par(cex.axis=cex.lab)
    if(length(axeslabels) == 1) axeslabels <- rep(axeslabels,2)
    if(axeslabels[1]) axis(1,pos=r$ylim[1],at=mean(r$xlim),labels="Longitude",tcl=0,mgp=c(0,2,0)) # parse(text = paste("longitude [ *degree ~ E]",sep=""))
    if(axeslabels[2]) axis(2,pos=r$xlim[1],at=mean(r$ylim),labels="Latitude",tcl=0,mgp=c(0,2.5+las*0.3,0),xpd=T) # parse(text = paste("longitude [ *degree ~ N]",sep=""))
    
    ..boundaries(r$xlim,r$ylim,grid.res,bwd=bwd) # plot ..boundaries
    if(grid == T) .grid2(r$xlim,r$ylim,grid.res,"black") # plot grid
    
    if(!missing(main)) title(main)
  }
}

..boundaries <- function (xrange,yrange, grid.res = 10, col = "lightgray", lwd = par("lwd"),bwd) 
{
  f <- bwd*min(diff(xrange),diff(yrange))/125
  xrange <- c(xrange[1]-f,xrange[2]+f)
  yrange <- c(yrange[1]-f,yrange[2]+f)
  sf = grid.res/2
  xmin <- ceiling(xrange[1]/sf)*sf # round up
  xmax <- floor(xrange[2]/sf)*sf
  ymin <- ceiling(yrange[1]/sf)*sf
  ymax <- floor(yrange[2]/sf)*sf
  color <- c("white","black")
  x1 <- c(xrange[1],seq(xmin,xmax,sf))
  x2 <- c(seq(xmin,xmax,sf),xrange[2])
  
  for (x in 1:length(x1))
  {
    rect(x1[x],yrange[1],x2[x],yrange[1]+f,col=color[x%%2+1],xpd=T)
    rect(x1[x],yrange[2],x2[x],yrange[2]-f,col=color[x%%2+1],xpd=T)
  }
  y1 <- c(yrange[1],seq(ymin,ymax,sf))
  y2 <- c(seq(ymin,ymax,sf),yrange[2])
  for (y in 1:length(y1))
  {
    rect(xrange[1],y1[y],xrange[1]+f,y2[y],col=color[y%%2+1],xpd=T)
    rect(xrange[2]-f,y1[y],xrange[2],y2[y],col=color[y%%2+1],xpd=T)
  }
}

.grid2 <- function (xrange,yrange, grid.res = 10, col = "lightgray", lty = "dotted", lwd = par("lwd")) 
{
  xmin <- ceiling(xrange[1]/grid.res)*grid.res
  xmax <- floor(xrange[2]/grid.res)*grid.res
  ymin <- ceiling(yrange[1]/grid.res)*grid.res
  ymax <- floor(yrange[2]/grid.res)*grid.res
  
  for (x in seq(xmin,xmax,grid.res))
  {
    lines(c(x,x),yrange,col = col, lty = lty, lwd = lwd)
  }
  
  for (y in seq(ymin,ymax,grid.res))
  {
    lines(xrange,c(y,y),col = col, lty = lty, lwd = lwd)
  }
}

# l <- function(lim)
# {
#   lim2 <- lim
#   lim2[1] <- lim[1]+(diff(lim)-(diff(lim)/1.08))/2
#   lim2[2] <- lim[2]-(diff(lim)-(diff(lim)/1.08))/2
#   return(lim2)
# }