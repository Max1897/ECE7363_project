# Topic: Traffic engineering with demand prediction


# Running
The workflow is   
1.Download raw data and process it.   
2. Prediction generation using .ipynb file   
3. Linear programming using AMPL 
## 1. Preparation
 
 We use *GEANT* traffic demand data throughout the project, download its native data first.   
http://sndlib.zib.de/home.action    

Then run [data_processing.py](https://github.com/Max1897/ECE7363_project/blob/main/src/data_processing.py) . Specify variable *demand_matrices_dir* as the directory of raw data and *output_dir* as the output directory.  

## 2. Generate prediction

### ARIMA  
Run[ECE7363_ARIMA_improved](https://github.com/Max1897/ECE7363_project/blob/main/src/ECE7363_ARIMA_improved.ipynb).

### LSTM
Run [ECE7363_LSTM.ipynb](https://github.com/Max1897/ECE7363_project/blob/main/src/ECE7363_LSTM.ipynb).    
  
In cell *Model loading*, make sure the directory is where [saved LSTM model](https://github.com/Max1897/ECE7363_project/tree/main/saved%20models/LSTM) are.  

### Temporal Convolutional Network(TCN)  
Run  [ECE7363_TCN_Improved.ipynb](https://github.com/Max1897/ECE7363_project/blob/main/src/ECE7363_TCN_Improved.ipynb).  
In cell _Model loading_, make sure the directory is where [saved TCN model](https://github.com/Max1897/ECE7363_project/tree/main/saved%20models/TCN) are.   

------------------
For all prediction model:  
In *prepare data* section, specify variable *work_dir*,*train_data* and *test_data* to load data processed.  

For ARIMA, in section *Model training* select the start and end index you like (0-5000).  
For LSTM and TCN, uncomment the cell in _Start training_ section if you want to train the model. The estimated training time on T4 GPU is 2 hours for both of them.     
After training is done, the sequences of demands that prediction based on are randomly chosen.   
In section *Output to AMPL form*, make sure you change *pred_dir*, *true_dir* to specify where the AMPL form demands  will be output.  

Predicted demand and their true demand are in the data folder.

## 3. Linear programming
We propose three linear programming models, ECMPTotalCost.mod, ECMPTotalDelay.mod, ECMPUtilization.mod, focusing on different objectives. And these three models all need data whose format is like following.
### Data format
The data that can be solved by ECMTotalCost.mod, ECMPTotalDelay.mod, ECMPUtilization.mod need the same format just like LSTMPred4.dat, LSTMPred5.dat, LSTMPred6.dat.
1. Number of demands;
2. Number of links;
3. Number of noeds;
4. Source node, destination node, capacity and cost of each link;
5. Weights of each link;
6. Source node, destination node, volume of each demand;
7. Big number M.

### LP model
Three models here can be used to solve different problems. For example, ECMPTotalCost.mod allocates flow aiming on minimizing the total cost, ECMPUtilization.mod focusing on minimizing the maximum utilizaiton of all links, and ECMPTotalDelay.mod handling with minizing the average delay among all links.

After reformat the data, the problem can be directly solved by using AMPL terminal, like following (all AMPL commands),
1. model ECMP-----.mod;
2. data ----.dat;
3. solve;
4. display ----.


