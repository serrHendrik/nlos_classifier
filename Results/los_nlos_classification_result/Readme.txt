Two models:

* Decision Tree
* Neural Network

Both have been trained on a small subset of the ROT_01 dataset, carefully selected based on the image segmentation footage of the fisheye camera project. Images were selected with minimal vegetation and minimal false labelling. 
Other important training info:
* training was only done on GPS and GAL satellites
* input features used: CNR, Elevation, KF Innovations 

After training, the models produced class predictions for all four datasets (AMS_01, AMS_02, ROT_01, ROT_02).

In the model directory, one will find:
* .csv files which contain all observation and navigation data, as well as the labelling from the camera and the machine learning algorithm.
* Confusion tables which compare the machine learning hard classification to the camera labelling, both from training, validation (also part of the small ROT_01 subset) and testing. As camera labelling is often wrong, the testing confusion tables do not show good results. It should therefore be interesting to evaluate the performance based on PVT estimations using the LOS/NLOS classification for satellite selection.

The .csv files can easily be read into matlab as a table with:
data = readtable('path/to/file.csv');

The .csv files contain the following 18 columns:
utc_time: UTC time at observation
rx_time: Receiver time at observation
common_time: Time used by PNT2 tool to sync camera with receiver
sv_sys: Space Vehicle System (G, E or R)
sv_id: Space Vehicle PNR
pseudorange:
carrierphase: (0 when no carrier phase measurement available!)
cnr: Carrier to noise ratio
doppler:
az/el: Azimuth and Elevation relative to position of receiver on the earth. Extracted from PNT2.
az_cm/el_cm: Azimuth and Elevation relative to camera. This will differ from az/el when the van is on a slope. These variables are never used however in this classification. Extracted from camera project.
third_ord_diff: Third Order Difference. Extracted from PNT2.
innovation: KF innovations. Extracted from PNT2. 
los_camera: LOS (=1) or NLOS (=0) labels based on image segmentation using the fisheye camera.
los_ml_hard: LOS (=1) or NLOS (=0) labels based on the given Machine Learning algorithm.
los_ml_soft: Probability of LOS provided by the given Machine Learning algorithm. 


How is the probaibliy of LOS obtained?
For Decision Trees, these are obtained as the fraction of training observations within the leaf of the tree which are LOS. In other words, if trees were trained to fully overfit on the training data, then all new observations would lead to a leaf with only one class present. In such a case, confidence of the tree would be high but overall results poor w.r.t. new data.
For neural networks, the network uses a softmax layer to transform unbounded numerical outputs to probabilities.


