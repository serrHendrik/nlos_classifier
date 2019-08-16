%{
%NOTE: Reading text data results in NaN (for column GNSS identifier (gnssId))

Number 	Name 	Information source
(Ground truth (GT) / Mass-Market Receiver (ublox) / Reference Receiver (NovAtel)) 	Unit
1 	GPSWeek 	ublox 	weeks
2 	GPSSecondsOfWeek 	ublox 	s
3 	Longitude (GT Lon) 	GT 	deg
4 	Longitude Cov (GT Lon Cov) 	GT 	deg
5 	Latitude (GT Lat) 	GT 	deg
6 	Latitude Cov (GT Lat Cov) 	GT 	deg
7 	Height above ellipsoid (GT Height) 	GT 	m
8 	Height above ellipsoid Cov (GT Height Cov) 	GT 	m
9 	Heading (0 = North) - (GT Heading) 	GT 	rad
10 	Heading Cov (0 = East, counterclockwise) - (GT Heading Cov) 	GT 	rad
11 	Acceleration (GT Acceleration) 	GT 	m/s^2
12 	Acceleration Cov (GT Acceleration Cov) 	GT 	m/s^2
13 	Velocity (GT Velocity) 	GT 	m/s
14 	Velocity Cov (GT Velocity Cov) 	GT 	m/s
15 	YawRate (GT Yawrate) 	GT 	rad/s
16 	Yaw-Rate Cov (GT Yaw-rate Cov) 	GT 	rad/s
17 	Measurement time of week (rcvTow) 	ublox 	s
18 	GPS week number (week) 	ublox 	weeks
19 	GPS leap seconds (leapS) 	ublox 	s
20 	Number of measurements to follow (numMeas) 	ublox 	-
21 	Receiver tracking status (recStat) 	ublox 	-
22 	Pseudorange measurement (prMes) 	ublox 	m
23 	Carrier phase measurement (cpMes) 	ublox 	cycles
24 	Doppler measurement (doMes) 	ublox 	Hz
25 	GNSS identifier (gnssId) 	ublox 	-
26 	Satellite identifier (svId) 	ublox 	-
27 	Frequency slot - only Glonass (freqId) 	ublox 	-
28 	Carrier phase locktime counter (locktime) 	ublox 	ms
29 	Carrier-to-noise density ratio (cno) 	ublox 	dBHz
30 	Estimated pseudorange measurement standard deviation (prStdev) 	ublox 	m
31 	Estimated carrier phase measurement standard deviation (cpStdev) 	ublox 	cycles
32 	Estimated Doppler measurement standard deviation (doStdev) 	ublox 	Hz
33 	Tracking status (trkStat) 	ublox 	-
34 	NLOS (0 == no, 1 == yes, # == No Information) 	NovAtel 	-

%}

%Load data
raw_data = readtable("data/berlin1_potsdamer_platz/RXM-RAWX.csv");
%raw_data_mat = readmatrix("data/berlin1_potsdamer_platz/RXM-RAWX.csv");

%{
%Add numerical version of the GNSS identifier
1: GPS
2: Glonass
3: Galileo

GNSS_id_num = zeros(size(raw_data,1),1);
for i = 1:size(raw_data,1)
    id = raw_data{i,25}{1};
    if  strcmp(id,'GPS')
       GNSS_id_num(i) = 1;
    elseif strcmp(id,'Glonass')
       GNSS_id_num(i) = 2;
    elseif strcmp(id,'Galileo')
       GNSS_id_num(i) = 3; 
    else
       GNSS_id_num(i) = -1;
    end
end
%}

% Alternative:
gnss_categ = categorical(raw_data.GNSSIdentifier_gnssId___);
factors = categories(gnss_categ);
factors_onehot = dummyvar(gnss_categ);

% One hot encoding for labels
nlos_categ = categorical(raw_data.NLOS_0__No_1__Yes____NoInformation_);
nlos_factors = categories(nlos_categ);
nlos_factors_onehot = dummyvar(nlos_categ);

%{
data description:
1   GPSSecondsOfWeek (s)
2   GNSS identifier (gnssId)
3   GNSS identifier (GPS)
3   GNSS identifier (Glonass)
3   GNSS identifier (SBAS)
4   Satellite identifier (svId)
5   Pseudorange measurement (m)
6   Estimated pseudorange measurement standard deviation (m)
7   carrier phase measurement (cycles)
8   Estimated carrier phase measurement standard deviation (cycles)
9   Doppler measurement measurement (dbHz)
10  Estimated Doppler measurement standard deviation (Hz)
11  Carrier-to-noise density ratio (CNO)
12 	NLOS (0 == no, 1 == yes, # == No Information)
%}
varNames = ["GPSSecondsOfWeek", "gnssId", "GPS", "Glonass", "SBAS", "svId", ...
    "C","C_std", "L","L_std", "D","D_std", "CNR","LOS","NLOS"];
data = table(raw_data{:,2}, ...
    raw_data{:,25}, factors_onehot(:,strcmp(factors,"GPS")), factors_onehot(:,strcmp(factors,"Glonass")), factors_onehot(:,strcmp(factors,"SBAS")), ...
    raw_data{:,26}, ...
    raw_data{:,22}, raw_data{:,30}, ...
    raw_data{:,23}, raw_data{:,31}, ...
    raw_data{:,24}, raw_data{:,32}, ...
    raw_data{:,29}, ...
    nlos_factors_onehot(:,strcmp(nlos_factors,'0')),nlos_factors_onehot(:,strcmp(nlos_factors,'1')), ...
    'VariableNames',varNames);


%Small dataset for testing
data_gps = data((data.GPS == 1),:);
data_gps_ = data_gps(1:5000,:);
ratio_NLOS_gps = sum(data_gps_.NLOS) / (sum(data_gps_.NLOS) + sum(data_gps_.LOS))


%%
%{
Change format to prepare data for training
%}

% Cross varidation (train: 70%, test: 30%)
cv = cvpartition(size(data,1),'HoldOut',0.3);
idx = cv.test;
% Separate to training and test data
dataTrain = data(~idx,:);
dataTest  = data(idx,:);

Xtrain = table2array(dataTrain(:,3:13))';
Ytrain = table2array(dataTrain(:,14:15))';
Xtest = table2array(dataTest(:,3:13))';
Ytest = table2array(dataTest(:,14:15))';

%Create and train network
net = feedforwardnet([10 10]);
net = configure(net,Xtrain,Ytrain);
net = train(net,Xtrain,Ytrain);
Ypred = net(Xtest);

%net = newpnn(Xtrain,Ytrain);
%Ypred = sim(net,Xtest);

ratio_NLOS = sum(data.NLOS) / (sum(data.NLOS) + sum(data.LOS))
MSE = perform(net,Ytest,Ypred,{1-ratio_NLOS;ratio_NLOS});
MSE


%Apply softmax + classify
%Fast implementation (find standard functions pls)
Ypred_hard = Ypred;
for i = 1:size(Ytest,2)
    if Ypred_hard(1,i) > Ypred_hard(2,i)
        Ypred_hard(1,i) = 1;
        Ypred_hard(2,i) = 0;
    else
        Ypred_hard(1,i) = 0;
        Ypred_hard(2,i) = 1;
    end
end


True_LOS = 0;
False_LOS = 0;
True_NLOS = 0;
False_NLOS = 0;
for i = 1:size(Ytest,2)
    if Ytest(1,i) == 1 %LOS
        if Ytest(1,i) == Ypred_hard(1,i)
           True_LOS = True_LOS + 1;
        else
           False_NLOS = False_NLOS + 1;
        end
        
    else  %NLOS
        if Ytest(1,i) == Ypred_hard(1,i)
           True_NLOS = True_NLOS + 1;
        else
           False_LOS = False_LOS + 1;
        end        
    end
end

%Accuracy
Accuracy = (True_LOS + True_NLOS) / (True_LOS + True_NLOS + False_LOS + False_NLOS)

%Precision and Recall

%F1
