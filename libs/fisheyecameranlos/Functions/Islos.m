function islos=Islos(az_cam,elev_cam,timestamp,probMap,Azimuth_map,Elevation_map)

% azimuth_map=load('az');
% Azimuth_map=azimuth_map.az;
% elevation_map=load('el');
% Elevation_map=elevation_map.el;

Eleve_ind=find(round(Elevation_map)==round(elev_cam));
Azimu_ind=find(mod(round(Azimuth_map),360)==mod(round(az_cam),360));
if length(Eleve_ind)<length(Azimu_ind)
    indice=[];
    test=[];
    for i=1:length(Eleve_ind)
       indice=[indice find( Azimu_ind==Eleve_ind(i))'];
       test=[test min(abs(Eleve_ind-Azimu_ind(i)))];
    end

    indice=Azimu_ind(indice);
else
    indice=[];
    test=[];
    for i=1:length(Azimu_ind)
       indice=[indice find( Eleve_ind==Azimu_ind(i))'];
       test=[test min(abs(Eleve_ind-Azimu_ind(i)))];
    end
    indice=Eleve_ind(indice);

end

if isempty(indice)
    islos=0;
else
    for k=1:length(indice)
        if(mod(indice(k),512)==0)
             j(k)=512;
             i(k)=(indice(k)-512)/512+1;
         else
             i(k)=floor(indice(k)/512)+1;
             j(k)=indice(k)-(i(k)-1)*512;

        end
    end
    azelev=[abs(Elevation_map(j(1),i(1))-elev_cam) ;abs( Azimuth_map(j(1),i(1))-az_cam)];
    mini=norm(azelev);
    indiceligne=j(1);
    indicecol=i(1);
    for k=1:length(i)
        azelev=[abs(Elevation_map(j(k),i(k))-elev_cam) ;abs( Azimuth_map(j(k),i(k))-az_cam)];
        if  norm(azelev)<mini
            indiceligne=j(k);
            indicecol=i(k);
            mini=norm(azelev);
        end
    end

    AZ=Azimuth_map(indiceligne,indicecol);
    EL=Elevation_map(indiceligne,indicecol);
    islos=probMap(indiceligne,indicecol);
end
end 