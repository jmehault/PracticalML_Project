PracticalML_Project
===================

PracticalML_Project

Here are the steps I follows to make the first version of the algo

1 / subsampling the traning set from "plm-training.csv" file to keep 20% in training and 70% as test set
2 / remove every columns with NA's and DIV/0 values and also non numeric variables since we want study measures from sensors
3 / compute PCA to check the more important variables in the 1st main plan and keep them to train the algo
4 / run Random Forest, Bootstrap or Bagging algo to get cross-checks in algo. I used trees because the problem is to separate data set into 5 cases. I could also try clustering directly on PCA results
5 / predict classes using test set to do not use training set
6 / rerun the 1-5 steps to cross-validate by resampling training and test sets
7 / Compute mean accuray and its error


Finally I obtained the following accuracy : 
0.9346 +/- 0.0052 for RandomForest
0.8932 +/- 0.0044 for GBM
0.8360 +/- 0.0150 for Bagging

This shows that the variables selected yield stables results and that in our case, RandomForest produce the best model


I used that one to predict the classe of the data from "plm-testing.csv" file
