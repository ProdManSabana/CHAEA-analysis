clear all;
close all;
% filename = 'prueba.xlsx';
% [num,txt,raw] = xlsread(filename);
filename = 'IS-IngSalud-1819';
filename = 'TCIS-IngSoft-1819';
filename = 'IngInfComp-TALF-1819';

DIR_DATA = './data/';
DIR_RES = './results/';

[num,txt,raw] = xlsread(sprintf('%s%s.xlsx',DIR_DATA,filename));

respuestas = [];
encuestasNoFinalizadas = [];
for i=2:size(txt,1)
    calificacion = raw{i,10};
    tiene_calificacion = true;
    if ~isnumeric(calificacion)
        if strcmp(calificacion,'-')
            tiene_calificacion = false;
        else
            calificacion = str2double(regexprep(calificacion, ',', '.'));
        end
    end
        
    if ~tiene_calificacion || calificacion==0 % miramos si no tiene calificacion
        encuestasNoFinalizadas = [encuestasNoFinalizadas i-1];
    else % tiene calificacion
        for j=11:size(txt,2)        
            if strcmp(txt{i,j},'Verdadero') || strcmp(txt{i,j},'True')
                respuestas(i-1,j-10) = 1;
            elseif strcmp(txt{i,j},'Falso') || strcmp(txt{i,j},'False')
                respuestas(i-1,j-10) = 0;
            else
                fprintf('Error en %d %d\n',i,j);
                respuestas(i-1,j-10) = 0; %%% no ha respondido a esa pregunta, la consideramos Falso
            end            
        end
    end
end
encuestasNoFinalizadas = encuestasNoFinalizadas(find(encuestasNoFinalizadas<=size(respuestas,1)));
respuestas(encuestasNoFinalizadas,:) = [];
preguntas_activo = [3, 5, 7, 9, 13, 20, 26, 27, 35, 37, 41, 43, 46, 48, 51, 61, 67, 74, 75, 77];
preguntas_reflexivo = [10, 16, 18, 19, 28, 31, 32, 34, 36, 39, 42, 44, 49, 55, 58, 63, 65, 69,70,79];
preguntas_teorico = [2, 4, 6, 11, 15, 17, 21, 23, 25, 29, 33, 45, 50, 54, 60, 64, 66, 71, 78, 80];
preguntas_pragmatico = [1, 8, 12, 14, 22, 24, 30, 38, 40, 47, 52, 53, 56, 57, 59, 62, 68, 72, 73, 76];

valoraciones = {'Muy Baja','Baja','Moderada','Alta','Muy Alta'};
vals_activo = [];
vals_reflexivo = [];
vals_teorico = [];
vals_pragmatico = [];

for ndxAlumno = 1:size(respuestas,1)
    
    respuestas_activo = respuestas(ndxAlumno,preguntas_activo);
    respuestas_reflexivo = respuestas(ndxAlumno,preguntas_reflexivo);
    respuestas_teorico = respuestas(ndxAlumno,preguntas_teorico);
    respuestas_pragmatico = respuestas(ndxAlumno,preguntas_pragmatico);
    
    num_respuestas_activo = sum(respuestas_activo);
    num_respuestas_reflexivo = sum(respuestas_reflexivo);
    num_respuestas_teorico = sum(respuestas_teorico);
    num_respuestas_pragmatico = sum(respuestas_pragmatico);
    
    if num_respuestas_activo >= 0 && num_respuestas_activo <= 6
        valoracion_activo = 1;
    elseif num_respuestas_activo >= 7 && num_respuestas_activo <= 8
        valoracion_activo = 2;
    elseif num_respuestas_activo >= 9 && num_respuestas_activo <= 10
        valoracion_activo = 3;
    elseif num_respuestas_activo >= 11 && num_respuestas_activo <= 13
        valoracion_activo = 4;
    elseif num_respuestas_activo >= 14 && num_respuestas_activo <= 20
        valoracion_activo = 5;
    else
        disp('Error');
    end
    
    if num_respuestas_reflexivo >= 0 && num_respuestas_reflexivo <= 11
        valoracion_reflexivo = 1;
    elseif num_respuestas_reflexivo >= 12 && num_respuestas_reflexivo <= 14
        valoracion_reflexivo = 2;
    elseif num_respuestas_reflexivo >= 15 && num_respuestas_reflexivo <= 17
        valoracion_reflexivo = 3;
    elseif num_respuestas_reflexivo >= 18 && num_respuestas_reflexivo <= 18
        valoracion_reflexivo = 4;
    elseif num_respuestas_reflexivo >= 19 && num_respuestas_reflexivo <= 20
        valoracion_reflexivo = 5;
    else
        disp('Error');
    end
    
    if num_respuestas_teorico >= 0 && num_respuestas_teorico <= 7
        valoracion_teorico = 1;
    elseif num_respuestas_teorico >= 8 && num_respuestas_teorico <= 10
        valoracion_teorico = 2;
    elseif num_respuestas_teorico >= 11 && num_respuestas_teorico <= 14
        valoracion_teorico = 3;
    elseif num_respuestas_teorico >= 15 && num_respuestas_teorico <= 15
        valoracion_teorico = 4;
    elseif num_respuestas_teorico >= 16 && num_respuestas_teorico <= 20
        valoracion_teorico = 5;
    else
        disp('Error');
    end
    
    if num_respuestas_pragmatico >= 0 && num_respuestas_pragmatico <= 8
        valoracion_pragmatico = 1;
    elseif num_respuestas_pragmatico >= 9 && num_respuestas_pragmatico <= 10
        valoracion_pragmatico = 2;
    elseif num_respuestas_pragmatico >= 11 && num_respuestas_pragmatico <= 14
        valoracion_pragmatico = 3;
    elseif num_respuestas_pragmatico >= 15 && num_respuestas_pragmatico <= 16
        valoracion_pragmatico = 4;
    elseif num_respuestas_pragmatico >= 17 && num_respuestas_pragmatico <= 20
        valoracion_pragmatico = 5;
    else
        disp('Error');
    end
    
    vals_activo(ndxAlumno) = valoracion_activo;
    vals_reflexivo(ndxAlumno) = valoracion_reflexivo;
    vals_teorico(ndxAlumno) = valoracion_teorico;
    vals_pragmatico(ndxAlumno) = valoracion_pragmatico;
    
end

%%%quantile(vals_activo,[0.25 0.50 0.75])
%%% no se pueden usar cuartiles (mediana) o medias de cada variable por
%%% independiente porque hay que tratarlas conjuntamente. para ello usar
%%% kmeans o similar

valoraciones = [vals_activo; vals_reflexivo; vals_teorico; vals_pragmatico]';
fileID = fopen(strcat(DIR_RES,filename,'.txt'),'w');
fprintf(fileID,'- Estudiante medio\r\n');
fprintf(fileID,'\tActivo: %0.1f\r\n',mean(vals_activo));
fprintf(fileID,'\tReflexivo: %0.1f\r\n',mean(vals_reflexivo));
fprintf(fileID,'\tTeórico: %0.1f\r\n',mean(vals_teorico));
fprintf(fileID,'\tPragmático: %0.1f\r\n',mean(vals_pragmatico));
fclose(fileID);


rng('default');
[idx,C] = kmeans(valoraciones,3);

%C = round(C);
%%%C =[5 1 2 2;4 1 2 1;5 1 1 2]; %%%% eliminar!!!!!!!!!!!!!!!!!!

% si hay varios elementos que se solapan, los unificamos
for i=1:size(C,1)-1
    for j=i+1:size(C,1)
        if isequal(C(i,:),C(j,:))
            idx(find(idx==j))=i;
        end
    end
end

% contamos el numero de elementos de cada grupo
vu=unique(idx,'stable');
C = C(vu,:);
for i=1:length(vu)
    m=vu(i);
    cont(i)=length( find(idx==vu(i)));
end

figure; 
p = pie(cont);
colormap([1 0 0; 0 1 0; 0 0 1]); 
colors = [1 0 0; 0 1 0; 0 0 1]; 
p(1).FaceColor = colors(1,:);
p(3).FaceColor = colors(2,:);

set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[20 10]);
set(gcf,'PaperPosition',[0 0 20 10]);
set(gca,'fontsize',16)
saveas(gcf,sprintf('%s%s_pie.pdf', DIR_RES,filename));



% https://es.mathworks.com/matlabcentral/fileexchange/59561-spider-radar-plot
% spider (radial) plot
etiquetas = {'Activo','Reflexivo','Teórico','Pragmático'};
axes_interval = 4; 
axes_precision = 1; 
figure;
spider_plot(C, etiquetas, axes_interval, axes_precision,... 
'Marker', 'o',... 
'LineStyle', '-',... 
'LineWidth', 2,... 
'MarkerSize', 5); 

set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[20 10]);
set(gcf,'PaperPosition',[0 0 20 10]);
set(gca,'fontsize',16)
saveas(gcf,sprintf('%s%s_radial.pdf', DIR_RES, filename));
