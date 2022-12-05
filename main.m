% check excel file has students ordered by family name

clear all;
close all;
numClusters = 4; %%%% number of clusters of the k-means method
%%% In SCATTER figure, change first parameter in text function to min_mark+0.5, and in XLim to min_mark 

%filename = 'TCIS-IngSoft-1819';
filename = 'TALF-IngInfComp-1819';
%filename = 'SistInt-IngSalud-1819';

pathFolder = '';

fprintf('Starting analysis of course %s with %d clusters...\n', filename, numClusters);

fprintf('Loading data...\n');

[num,txt,raw] = xlsread(sprintf('%sdata/%s-CHAEA.xlsx',pathFolder,filename));
[numMarks,txtMarks,rawMarks] = xlsread(sprintf('%sdata/%s-Marks.xlsx',pathFolder,filename));

fprintf('Processing data...\n');

ndxStudentsMarksCHAEA = [];
answers = [];
finalMarkCHAEA = [];
finalMarkNoCHAEA = [];
noFinishedSurveys = [];
ndxCHAEAStudentsNoAttending = [];
ndxStudentsNoAttending = [];
for i=2:size(txt,1) % for each student     
    if strcmp(raw{i,10},'-')  || str2double(regexprep(txt{i,10}, ',', '.'))==0 % check if student has completed the chaea
        noFinishedSurveys = [noFinishedSurveys i-1];
    else % student has chaea
        cont_question_not_answered = 0;
        for j=11:size(txt,2) % for each answer
            if strcmp(txt{i,j},'Verdadero') || strcmp(txt{i,j},'True')
                answers(i-1,j-10) = 1;
            elseif strcmp(txt{i,j},'Falso') || strcmp(txt{i,j},'False')
                answers(i-1,j-10) = 0;
            else
                cont_question_not_answered = cont_question_not_answered + 1;
                %fprintf('Error in row %d %d\n',i,j);
                answers(i-1,j-10) = 0; %%% student has not answered that question, we consider as False
            end            
        end
        if cont_question_not_answered > 20 % if student has a lot of question without answer, the student is deleted
            noFinishedSurveys = [noFinishedSurveys i-1];
        else % looking student's final mark
            [iMarks,y]=find(strcmpi(rawMarks,txt{i,1})); % y has to be equal to 5
            if size(iMarks,1)>1
                ndxMark = 1;
                found = false;
                while ndxMark <= size(iMarks,1) && ~found
                    if ~strcmpi(rawMarks{iMarks(ndxMark),4},txt{i,2})
                        ndxMark = ndxMark + 1;
                    else
                        found = true;
                    end
                end
                iMarks = iMarks(ndxMark);
            end
            if ~strcmpi(rawMarks{iMarks,4},txt{i,2})
                fprintf('Error in row %d: possible duplicated student\n',i);
            end
            if strcmp(class(rawMarks{iMarks,9}),'char')
                rawMarks{iMarks,9} = str2double(rawMarks{iMarks,9});
            end
            if size(iMarks,1)==0 || isnan(rawMarks{iMarks,9}) || strcmp(rawMarks{iMarks,9},'-') 
                % fprintf('Error in row %d: final mark not found\n',i);
                ndxCHAEAStudentsNoAttending = [ndxCHAEAStudentsNoAttending i-1];
                ndxStudentsNoAttending = [ndxStudentsNoAttending iMarks];
            else
                finalMarkCHAEA(i-1) = rawMarks{iMarks,9};
                ndxStudentsMarksCHAEA = [ndxStudentsMarksCHAEA iMarks];
            end
        end
    end
end
noFinishedSurveys = noFinishedSurveys(find(noFinishedSurveys<=size(answers,1)));
answers([noFinishedSurveys ndxCHAEAStudentsNoAttending],:) = [];
finalMarkCHAEA([noFinishedSurveys ndxCHAEAStudentsNoAttending]) = [];

ndxStudentsMarksNoCHAEA = 1:size(txtMarks,1);
ndxStudentsMarksNoCHAEA(ndxStudentsMarksCHAEA) = [];
ndxStudentsMarksNoCHAEA(1) = [];
for i=ndxStudentsMarksNoCHAEA
    if strcmp(class(rawMarks{i,9}),'char')
        rawMarks{i,9} = str2double(rawMarks{i,9});
    end
    if ~isfloat(rawMarks{i,9}) || isnan(rawMarks{i,9})       
        if isnan(rawMarks{i,9})
            rawMarks{i,9}=0;
        else
            if strcmp(rawMarks{i,9},'-')
                rawMarks{i,9} = str2double(regexprep(rawMarks{i,9},'-','0'));
            else
                rawMarks{i,9} = str2double(regexprep(rawMarks{i,9},'','0'));
            end
        end
        if rawMarks{i,9} == 0
            ndxStudentsNoAttending = [ndxStudentsNoAttending i];
            ndxStudentsMarksNoCHAEA(find(ndxStudentsMarksNoCHAEA==i))=[];
        else
            finalMarkNoCHAEA(i) = rawMarks{i,9};
        end
    else
        finalMarkNoCHAEA(i) = rawMarks{i,9};
    end
end
ndxStudentsNoAttending = unique(ndxStudentsNoAttending);
finalMarkNoCHAEA(end+1:size(txtMarks,1))=0;
finalMarkNoCHAEA([ndxStudentsMarksCHAEA ndxStudentsNoAttending]) = [];
finalMarkNoCHAEA(1) = [];

activist_questions = [3, 5, 7, 9, 13, 20, 26, 27, 35, 37, 41, 43, 46, 48, 51, 61, 67, 74, 75, 77];
reflector_questions = [10, 16, 18, 19, 28, 31, 32, 34, 36, 39, 42, 44, 49, 55, 58, 63, 65, 69,70,79];
theorist_questions = [2, 4, 6, 11, 15, 17, 21, 23, 25, 29, 33, 45, 50, 54, 60, 64, 66, 71, 78, 80];
pragmatist_questions = [1, 8, 12, 14, 22, 24, 30, 38, 40, 47, 52, 53, 56, 57, 59, 62, 68, 72, 73, 76];

% evaluation = {'Muy Baja','Baja','Moderada','Alta','Muy Alta'};
evaluations_activist = [];
evaluations_reflector = [];
evaluations_theorist = [];
evaluations_pragmatist = [];

num_answers_type_CHAEA = zeros(numel(answers),4);

for ndxStudent = 1:size(answers,1)
    
    answers_activist = answers(ndxStudent,activist_questions);
    answers_reflector = answers(ndxStudent,reflector_questions);
    answers_theorist = answers(ndxStudent,theorist_questions);
    answers_pragmatist = answers(ndxStudent,pragmatist_questions);
    
    num_answers_activist = sum(answers_activist);
    num_answers_reflector = sum(answers_reflector);
    num_answers_theorist = sum(answers_theorist);
    num_answers_pragmatist = sum(answers_pragmatist);
    
    if num_answers_activist >= 0 && num_answers_activist <= 6
        evaluation_activist = 1;
    elseif num_answers_activist >= 7 && num_answers_activist <= 8
        evaluation_activist = 2;
    elseif num_answers_activist >= 9 && num_answers_activist <= 10
        evaluation_activist = 3;
    elseif num_answers_activist >= 11 && num_answers_activist <= 13
        evaluation_activist = 4;
    elseif num_answers_activist >= 14 && num_answers_activist <= 20
        evaluation_activist = 5;
    else
        disp('Error');
    end
    
    if num_answers_reflector >= 0 && num_answers_reflector <= 11
        evaluation_reflector = 1;
    elseif num_answers_reflector >= 12 && num_answers_reflector <= 14
        evaluation_reflector = 2;
    elseif num_answers_reflector >= 15 && num_answers_reflector <= 17
        evaluation_reflector = 3;
    elseif num_answers_reflector >= 18 && num_answers_reflector <= 18
        evaluation_reflector = 4;
    elseif num_answers_reflector >= 19 && num_answers_reflector <= 20
        evaluation_reflector = 5;
    else
        disp('Error');
    end
    
    if num_answers_theorist >= 0 && num_answers_theorist <= 7
        evaluation_theorist = 1;
    elseif num_answers_theorist >= 8 && num_answers_theorist <= 10
        evaluation_theorist = 2;
    elseif num_answers_theorist >= 11 && num_answers_theorist <= 14
        evaluation_theorist = 3;
    elseif num_answers_theorist >= 15 && num_answers_theorist <= 15
        evaluation_theorist = 4;
    elseif num_answers_theorist >= 16 && num_answers_theorist <= 20
        evaluation_theorist = 5;
    else
        disp('Error');
    end
    
    if num_answers_pragmatist >= 0 && num_answers_pragmatist <= 8
        evaluation_pragmatist = 1;
    elseif num_answers_pragmatist >= 9 && num_answers_pragmatist <= 10
        evaluation_pragmatist = 2;
    elseif num_answers_pragmatist >= 11 && num_answers_pragmatist <= 14
        evaluation_pragmatist = 3;
    elseif num_answers_pragmatist >= 15 && num_answers_pragmatist <= 16
        evaluation_pragmatist = 4;
    elseif num_answers_pragmatist >= 17 && num_answers_pragmatist <= 20
        evaluation_pragmatist = 5;
    else
        disp('Error');
    end
    
    evaluations_activist(ndxStudent) = evaluation_activist;
    evaluations_reflector(ndxStudent) = evaluation_reflector;
    evaluations_theorist(ndxStudent) = evaluation_theorist;
    evaluations_pragmatist(ndxStudent) = evaluation_pragmatist;
    
    num_answers_type_CHAEA(ndxStudent,:) = [num_answers_activist num_answers_reflector num_answers_theorist num_answers_pragmatist];
        
    
end

evaluation = [evaluations_activist; evaluations_reflector; evaluations_theorist; evaluations_pragmatist]';

fprintf('Computing average CHAEA student profiles...\n');

rng('default');
[idx,C] = kmeans(evaluation,numClusters);

% if there are several overlapping elements, we merge them
for i=1:size(C,1)-1
    for j=i+1:size(C,1)
        if isequal(C(i,:),C(j,:))
            idx(find(idx==j))=i;
        end
    end
end

% count number of elements of each group
vu=sort(unique(idx,'stable'));
for i=1:length(vu)
    m=vu(i);
    cont(i)=length(find(idx==vu(i)));
end

% calculate the error
for i=1:length(idx)
    centroid = C(idx(i),:);
    datum = evaluation(i,:);
    error(i) = sqrt(sum((datum-centroid).^2)); % euclidean distance
end
error_mean = mean(error);
error_std = std(error);

fprintf('Creating results report...\n');

fileID = fopen(strcat('results/',filename,'_K',num2str(numClusters),'.txt'),'w');
fprintf(fileID,'Course: %s\r\n\r\n', filename);
fprintf(fileID,'Total students: %d\r\n', size(ndxStudentsMarksCHAEA,2)+size(ndxStudentsMarksNoCHAEA,2)+size(ndxStudentsNoAttending,2));
fprintf(fileID,'\tNumber attending students: %d\r\n', size(ndxStudentsMarksCHAEA,2)+size(ndxStudentsMarksNoCHAEA,2));
fprintf(fileID,'\t\tNumber of students who have done the survey CHAEA: %d\r\n', size(ndxStudentsMarksCHAEA,2));
fprintf(fileID,'\t\tNumber of students who have not done the survey CHAEA: %d\r\n', size(ndxStudentsMarksNoCHAEA,2));
fprintf(fileID,'\tNumber not attending students: %d\r\n\r\n', size(ndxStudentsNoAttending,2));

fprintf(fileID,'Attending student marks\r\n');
fprintf(fileID,'\tMean: %0.2f\r\n', mean([finalMarkCHAEA finalMarkNoCHAEA]));
fprintf(fileID,'\tMedian: %0.2f\r\n', median([finalMarkCHAEA finalMarkNoCHAEA]));
fprintf(fileID,'\tStandard deviation: %0.2f\r\n\r\n', std([finalMarkCHAEA finalMarkNoCHAEA]));
fprintf(fileID,'\t- CHAEA student marks\r\n');
fprintf(fileID,'\t\tMean: %0.2f\r\n', mean(finalMarkCHAEA));
fprintf(fileID,'\t\tMedian: %0.2f\r\n', median(finalMarkCHAEA));
fprintf(fileID,'\t\tStandard deviation: %0.2f\r\n', std(finalMarkCHAEA));
fprintf(fileID,'\t- Not CHAEA student marks\r\n');
fprintf(fileID,'\t\tMean: %0.2f\r\n', mean(finalMarkNoCHAEA));
fprintf(fileID,'\t\tMedian: %0.2f\r\n', median(finalMarkNoCHAEA));
fprintf(fileID,'\t\tStandard deviation: %0.2f\r\n\r\n', std(finalMarkNoCHAEA));

fprintf(fileID,'CHAEA Results\r\n');
fprintf(fileID,'- Average student\r\n');
fprintf(fileID,'\tActivist: %0.2f\r\n',mean(evaluations_activist));
fprintf(fileID,'\tReflector: %0.2f\r\n',mean(evaluations_reflector));
fprintf(fileID,'\tTheorist: %0.2f\r\n',mean(evaluations_theorist));
fprintf(fileID,'\tPragmatist: %0.2f\r\n\r\n',mean(evaluations_pragmatist));
fprintf(fileID,'\tMark: %0.2f\r\n\r\n', mean(finalMarkCHAEA));
[contOut,idxSorted] = sort(cont,'descend');
j=1;
for i=idxSorted
    fprintf(fileID,'- Group %d (%d/%d -- %d%%) \r\n', j, cont(i), sum(cont),round(cont(i)*100/sum(cont)));
    fprintf(fileID,'\tActivist: %0.2f\r\n',C(i,1));
    fprintf(fileID,'\tReflector: %0.2f\r\n',C(i,2));
    fprintf(fileID,'\tTheorist: %0.2f\r\n',C(i,3));
    fprintf(fileID,'\tPragmatist: %0.2f\r\n\r\n',C(i,4));
    fprintf(fileID,'\tMark: %0.2f\r\n\r\n', mean(finalMarkCHAEA(find(idx==i))));
    j=j+1;
end
fprintf(fileID,'- Error in the assignment to group\r\n');
fprintf(fileID,'\tMean: %0.2f\r\n',error_mean);
fprintf(fileID,'\tStandard deviation: %0.2f\r\n\r\n',error_std);
fclose(fileID);

fprintf('Creating WHISKER figure...\n');
% WHISKER PLOT
% https://es.mathworks.com/help/stats/boxplot.html?lang=en
marks = [finalMarkCHAEA finalMarkNoCHAEA];
califs = [finalMarkCHAEA'; finalMarkNoCHAEA'; marks']; 
g1 = repmat({'Yes'},size(finalMarkCHAEA,2),1); 
g2 = repmat({'No'},size(finalMarkNoCHAEA,2),1); 
g3 = repmat({'Total'},size(marks,2),1);
g = [g1; g2; g3];
figure;
boxplot(califs, g, 'Whisker',0.75);
ylabel('Mark');
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[10 9]);
set(gcf,'PaperPosition',[0 0 10 9]);
set(gca,'fontsize',20)
saveas(gcf,sprintf(strcat('results/%s_whisker','_K',num2str(numClusters),'.pdf'), filename));
saveas(gcf,sprintf(strcat('results/%s_whisker','_K',num2str(numClusters),'.png'), filename));

fprintf('Creating PIE figure...\n');
figure; 
p = pie(contOut);
colormap([1 0 0; 0 1 0; 0 0 1; 1 0.5 0]); 
colors = [1 0 0; 0 1 0; 0 0 1; 1 0.5 0]; 

for i=1:numClusters
    p(2*i-1).FaceColor = colors(i,:);    
    p(2*i).FontSize = 20;
end

set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[10 9]);
set(gcf,'PaperPosition',[0 0 10 9]);
set(gca,'fontsize',20)
% legend('Group 1','Group 2','Group 3')
saveas(gcf,sprintf(strcat('results/%s_pie','_K',num2str(numClusters),'.pdf'), filename));
saveas(gcf,sprintf(strcat('results/%s_pie','_K',num2str(numClusters),'.png'), filename));

fprintf('Creating RADIAL figure...\n');
% https://es.mathworks.com/matlabcentral/fileexchange/59561-spider-radar-plot
% spider (radial) plot
tags = {'Activo','Reflexivo','Teórico','Pragmático'};
tags = {'Activist','Reflector','Theorist','Pragmatist'};
axes_interval = 4; 
axes_precision = 1; 
figure;
spider_plot(C(idxSorted,:), tags, axes_interval, axes_precision,... 
'Marker', 'o',... 
'LineStyle', '-',... 
'LineWidth', 10,... 
'MarkerSize', 10); 

set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[29 23]);
set(gcf,'PaperPosition',[0 0 29 23]);
set(gca,'fontsize',30)
saveas(gcf,sprintf(strcat('results/%s_radial','_K',num2str(numClusters),'.pdf'), filename));
saveas(gcf,sprintf(strcat('results/%s_radial','_K',num2str(numClusters),'.png'), filename));

fprintf('Creating SCATTER figure...\n');
% Plot regression lines
[marks, orden_cal] = sort(finalMarkCHAEA);
for ndxType = 1:4
    
    figure
    hold on
    X = marks;
    
    Y = num_answers_type_CHAEA(orden_cal,ndxType)';
    mdl = fitlm(X,Y);
    h = plot(mdl);
    set(h,'LineWidth',2, 'MarkerSize',14);
    str = {['R^2 = ',num2str(mdl.Rsquared.Ordinary)],...
        ['MSE = ',num2str(mdl.MSE)]};
    text(6.5,4,str,'FontSize',16)   %%% Edit first parameter: TALF (0.5), IS (4.5) y TCIS (6.5)
%     set(get(gca,'Legend'),'orientation','horizontal')
%     set(get(gca,'Legend'),'location','southoutside')
    set(get(gca,'Legend'),'visible','off')
    set(gca,'XLim',[6 10])  %%% Edit interval: TALF (0 10), IS (4 10) y TCIS (6 10)
    set(gca,'YLim',[0 20]) 
    xlabel('Mark')
    ylabel('CHAEA mark')
    title([tags{ndxType}, ' learning style'])
    

    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperOrientation','portrait');
    set(gcf,'PaperPositionMode','manual');
    set(gcf,'PaperSize',[20 7]);    % If legend, use [20 10]
    set(gcf,'PaperPosition',[0 0 20 7]);    % If legend, use [20 10]
    set(gca,'fontsize',20)
    saveas(gcf,sprintf('results/%s_scatter-%s.pdf', filename,tags{ndxType}));
    saveas(gcf,sprintf('results/%s_scatter-%s.png', filename,tags{ndxType}));

end

save(sprintf('results/temp/%s-K%d.mat', filename,numClusters));

close all
clear all

fprintf('Finished!\n');