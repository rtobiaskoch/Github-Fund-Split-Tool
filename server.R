#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/

library(shiny)
library(ggplot2)
library(dplyr)
library(tidyr)
library(DT)
library(scales)

setwd("S:/PCH/OICP/VaccineMgmt/Practice Profile - Fund Split Validation/Validation Production Environment/shiny demo")
cfs.data1 <- read.csv("demo data.csv")

#file upload tab outputs####
# creates the reactive variable that filters the data in the inputs----
shinyServer(function(input, output) {
  output$cfs.data <-  renderDataTable({
  req(input$cfs)
  cfs.data.df <- read.csv(input$cfs$datapath,
             header = input$header,
             sep = input$sep)
    assign('cfs.data1', cfs.data.df, envir=.GlobalEnv)
  })
  
  #creates output for file download for the vaccine breakdown----
  output$vb <-  renderDataTable({
    req(input$vb)
    cfs.data.df <- read.csv(input$vb$datapath,
                            header = input$header,
                            sep = input$sep)
    assign('vb1', vb.df, envir=.GlobalEnv)
  })
  
 #creates output for file download for the practice profile----
  output$pp <-  renderDataTable({
    req(input$pp)
    cfs.data.df <- read.csv(input$pp$datapath,
                            header = input$header,
                            sep = input$sep)
    assign('pp1', pp.df, envir=.GlobalEnv)
  })
  
  #creates output for file download for the vaccine ordering data----
  output$vo <-  renderDataTable({
    req(input$vo)
    cfs.data.df <- read.csv(input$vo$datapath,
                            header = input$header,
                            sep = input$sep)
    assign('vo1', vo.df, envir=.GlobalEnv)
  })

  #creates output for file download for the vaccine reference table----
  output$vac.rt <-  renderDataTable({
    req(input$vac.rt)
    cfs.data.df <- read.csv(input$vac.rt$datapath,
                            header = input$header,
                            sep = input$sep)
    assign('vac.rt1', vac.rt.df, envir=.GlobalEnv)
  })

  #creates output for file download for the insurance status reference table----
  output$status.rt <-  renderDataTable({
    req(input$status.rt)
    cfs.data.df <- read.csv(input$status.rt$datapath,
                            header = input$header,
                            sep = input$sep)
    assign('status.rt1', status.rt.df, envir=.GlobalEnv)
  })

#DASHBOARD TAB#### 
#SLIDER OUTPUT----  
#creates input values for filter the data on the sliders in the dashboard tab
  cfs <- eventReactive(input$go, {
    cfs.data1  %>%
      filter(Tl_Vac_Admin >= input$vac[1] & Tl_Vac_Admin <= input$vac[2],
             VB_2016_STATE >= input$vb[1] & VB_2016_STATE <= input$vb[2],
             PP_2017_STATE >= input$pp[1] & PP_2017_STATE <= input$pp[2],
             VB_2016_Unknown_Pct >=input$unknown[1] & VB_2016_Unknown_Pct <=input$unknown[2],
             Age_Group %in% input$age,
             PP_2017_Data_Source %in% input$source)
  })
  
#SUMMARY OUTPUT----
  #creates budget summary table based off of the filtered data from the cfs object  
  cfs.sum <- eventReactive(input$go, {
    cfs()%>% #reformats the cost data to be graphed by the bar chart
      mutate(CFS_STATE_Cost = CFS_STATE*Vac_Order_Cost_Tl) %>%
      mutate(CFS_VFC_Cost = CFS_VFC*Vac_Order_Cost_Tl) %>%
      transmute(STATE.PP = PP_2017_STATE_Cost_Delta + CFS_STATE_Cost,
                STATE.VB = VB_STATE_Cost_Delta + CFS_STATE_Cost,
                STATE.CFS = CFS_STATE_Cost,
                VFC.PP = PP_2017_VFC_Cost_Delta + CFS_VFC_Cost,
                VFC.VB = VB_VFC_Cost_Delta + CFS_VFC_Cost,
                VFC.CFS = CFS_VFC_Cost) %>%
      summarise_all(funs(sum(., na.rm = T))) %>%
      gather(data, cost) %>%
      separate(data, c("funding","data"), sep = "\\.")
  })
  
  #creates bar graph of the budget implications of the providers being filtered 
  output$bar <- renderPlot({ 
    ggplot(cfs.sum(), aes(x = funding, y = cost, fill = data)) +
      geom_bar(stat="identity", position = "dodge", colour = "black", width = 0.8) +
      geom_text(aes(label = dollar(cost)), vjust = 1.5, hjust = 0.5,  position = position_dodge(.9), size = 3) +
      scale_y_continuous(name="Cost", label = dollar) +
      scale_fill_manual(values = c("#d7191c", "#abdda4", "#2b83ba")) +
      ylim(0, 120000000) +
      #annotate("segment", x = 0.5, xend = 1.5, y = state_limit, yend= state_limit, colour = "red", size = 2) +
      #annotate("text", x = 0.6, y = (state_limit+2000000), label = "LIMIT", colour = "red") +
      #annotate("segment", x = 1.55, xend = 2.5, y = vfc_limit, yend = vfc_limit, colour = "red", size = 2)+
      #annotate("text", x = 1.65, y = (vfc_limit+2000000), label = "LIMIT", colour = "red") +
      theme(plot.title = element_text(face= "bold", size = 22))+
      theme(axis.title = element_text(face= "bold", size = 16))+
      theme(axis.text.x = element_text(face= "bold", size = 12))+
      theme(axis.text.y = element_text(face= "bold", size = 8, angle = 45))+
      theme(legend.text = element_text(size = 12))+
      theme(legend.title = element_text(size = 16))
  })

#SCATTERPLOT OUTPUT----  
  #creates scatterplot of delta from cfs by pp and vb data      
  output$hist <- renderPlot({  
    ggplot(cfs(), aes(x = VB_2016_STATE, y = PP_2017_STATE, size = Tl_Vac_Admin, fill = PP_2017_Data_Source)) +
      geom_point(shape = 21, alpha = 0.6)  +
      scale_fill_manual(values = c('#d7191c','#fdae61','#abdda4','#2b83ba')) +
      scale_size(breaks = c(2000,4000,6000,8000,10000),
                 range = c(1, 10)) +
      ylim(-1, 1) +
      xlim(-1, 1) +
      #adds formating and labels to graph
      labs(x = "VB Split Delta", y = "PP Split Delta") +
      guides(fill=guide_legend(title="Data Source", override.aes = list(size = 10)), guide_legend(title= "Total Vaccines Administered")) +
      annotate("rect", xmin=0, xmax= 1, ymin= 0, ymax = 1, colour = "orange", alpha = .05, fill= "orange")+
      annotate("rect", xmin=0, xmax= -1, ymin= 0, ymax = -1, colour = "blue", alpha =  .05, fill= "blue")+
      annotate("text", x=0.3, y=0.9, label="STATE")+
      annotate("text", x=-0.3, y=-0.9, label="VFC")
  })
  
  #Creates interactive outputs for scatterplot
  output$summary <- renderPrint({
    s <-  cfs()%>%
      select(VB_2016_STATE, PP_2017_STATE, 
             CFS_STATE, VB_2016_Unknown_Pct, Tl_Vac_Admin) %>%
      psych::describe(fast = T) 
    print(s)
    
  })
  
#TABLE OUTPUT----
  #creates table for download based off of cfs filtered reactive object  
  output$table <- renderDataTable({
    datatable(cfs(), options = list(scrollX = TRUE))
  })  
  
#DOWNLOAD OUTPUT----  
  output$downloadData <- downloadHandler(
    filename = paste("test", Sys.Date(), ".csv", sep = ""),
    contentType = "text/csv",
    content = function(file) {
      write.csv(cfs(), file, row.names = FALSE)
    })
})