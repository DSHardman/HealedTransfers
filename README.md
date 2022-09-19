# Healed Transfers
This is the code used in the paper *Learning-Based Damage Recovery for Healable Soft Electronic Skins*.

This repository contains the data for all figures and tests, and the code used to train the neural networks. Written using MATLAB 2021b (Deep Learning Toolbox). Data was collected using Python 3, though this code is not presented here.

The parent repository can be found [here](https://github.com/DSHardman/SensorProbing).

## Data Availability
(See releases for data).

Time-series responses of the 8 sensor channels to the 3 damages (Figure 3) are given in *CuttingResponses/CuttingResponses.mat*.

Characterisations of the 7 sensor states (Original, after each of the 3 damages and after each of the 3 heals) are stored in *SensorStates/* as
**SensorState** objects. These contain **SingleTest** objects for random probing tests, repeated probing tests, and probes along the channel of interest.

The transfer data from Figures 5 & 6 is contained in the*Transfers/* directory. 
**Transfer** objects contain **SingleCase** (for fully trained and untrained data) and **Approach** (for transfer methods) objects, as described in the comments. **Approach** objects contain **Attempt** objects to store the data in each line of a plot in the 2 Figures.


## Functions

**TrainNetwork.m** contains the function used to train networks with no prior knowledge. Before ending, this function calls **heatscat.m** to calculate and plot errors.

**TransferNetwork.m** contains the function used for transfer learning, given a number of frozen layers, number of inputs, and method of sampling.

**AdaptNetwork.m** performs the transfer learning one point at a time, enabling a thorough analysis of the dynamics over time.

**pwc_tvdrobust.m** performs the square wave fitting seen in Figure 2d.
