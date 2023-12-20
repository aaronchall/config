{pkgs}: with pkgs.rPackages; [
      arules # mining association rules and frequent itemsets
      dbscan # Density Based Spatial Clustering of Applications with Noise
      mclust # Gaussian Mixture Modelling for Model-Based Clustering, Classification, and Density Estimation
      neuralnet
      reshape2
      caret # Classification And REgression Training, unified interface for predictive models
      caretEnsemble # extension of caret framework for ensembles of predictive models
      e1071 # for confusion matrix - (name of dept that created lib)
      rpart # Recursive Partitioning and Regression Trees
      rpart_plot
      rattle
      RColorBrewer
      klaR
      ROCR
      data_table # data.table see https://cran.r-project.org/web/packages/data.table/
      rmarkdown
      viridis
      shiny
      tidytext
      lme4 # linear mixed effects models
      forecast # time series forecasting
      devtools
      Rcpp # C++ integration
      Matrix # for arules, association rules lib.
      tidyverse #### includes (see all with tidyverse_update()):
      ggplot2 # data visualization
      dplyr #
      tidyr # complements dplyr
      readr #
      purrr # functional vector manipulation
      tibble #
      stringr # string manipulation
      forcats #
      lubridate # dates and times
      magrittr # pipe %>% operator for chaining
    ]
