function RGBmean = SingleMeasurement(number)
% single measure function
clc
% Delete a possible previous use of com port
port = importdata('PORT.txt');

delete(instrfind({'Port'},{port}));
    
%Fix the number of iterative measurements
    numero_muestras=number;
    
    %Inicialize number of characters received
    n=0;
    %Inicialize serial comm
    arduino=serial(port,'BaudRate',9600); % create serial communication object on port COM18
    fopen(arduino); % initiate arduino communication
    
    % Prepare serial comm protocol for measurement with arduino
    s1='R F 1 1 3 '; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%QUIQUE
    s2= int2str(numero_muestras);

    pause(2);
    fprintf(arduino,'%s',[s1 s2]); % send variable content to arduino
       
    contador_muestras=0;
     while contador_muestras<numero_muestras
         %Waiting for received data
         while n==0
         
             n=arduino.BytesAvailable;
        
         end
         % If data correspond with iterative measures..
         if (contador_muestras ~= numero_muestras)
             
         data = fscanf(arduino);
         
         datos(:,contador_muestras+1) = str2num(data(1:(length(data)-2)));
         
         else % if data correspond with teh last averaged data
         data = fscanf(arduino);
         end
         %Increment measures cont
         contador_muestras=contador_muestras+1;
         n=0;
     end
     
     
        RGB=datos'; %Transpose the matrix RGB
        %Mean measured RGB value
        RGBmean=round(mean(RGB));
     
    fclose(arduino); % end communication with arduino
end
    