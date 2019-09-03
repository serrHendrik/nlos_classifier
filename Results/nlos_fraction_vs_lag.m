%Script to plot the effect of increased lag on label distribution
%Lag means that inputs to a learner now also provides historical data
%(e.g. pseudorange of last 5 seconds). This is useful in combination with CNNs.


%generate graph on fraction los/nlos of lag sets
tour = 'AMS_01';
GPS_flag = true;
GAL_flag = true; 
GLO_flag = false;
normalize_flag = false;
%base
dh_base = nlos_datahandler(tour,GPS_flag,GAL_flag,GLO_flag,normalize_flag);
%lag = 2
dh_lag2 = nlos_datahandler_cnn(tour,GPS_flag,GAL_flag,GLO_flag,2);
%lag = 3
dh_lag3 = nlos_datahandler_cnn(tour,GPS_flag,GAL_flag,GLO_flag,3);
%lag = 4
dh_lag4 = nlos_datahandler_cnn(tour,GPS_flag,GAL_flag,GLO_flag,4);
%lag = 5
dh_lag5 = nlos_datahandler_cnn(tour,GPS_flag,GAL_flag,GLO_flag,5);

nb_obs = [height(dh_base.data), height(dh_lag2.data), height(dh_lag3.data), ...
    height(dh_lag4.data), height(dh_lag5.data)];
nb_obs = nb_obs ./ height(dh_base.data) * 100;

nlos = [dh_base.fraction_nlos, dh_lag2.fraction_nlos, dh_lag3.fraction_nlos, ...
    dh_lag4.fraction_nlos, dh_lag5.fraction_nlos];
nlos = nlos .* 100;

%%
%plot number of observations
figure;
plot(1:5,nb_obs, '-o')
xlim([0 6])
ylim([88 102])
xlabel('Lag')
ylabel('number of observations [%]')
title('Reduction in available observations due to lag')
grid on;

%%
%plot fraction nlos

figure;
plot(1:5,nlos, '-o')
xlim([0 6])
%ylim([22 29])
xlabel('Lag')
ylabel('Percent NLOS observations [%]')
title('Reduction in NLOS observations due to lag')
grid on;

