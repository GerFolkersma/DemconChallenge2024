% Demcon Festival timetable generator.
% Ger Folkersma, 6-8-2024, Demcon
% Run this script (tested in Matalb 2023b), to generate a schedule from the
% data in a txt file or csv (see below). Saves the resulting schedule to
% timetable.png

clear variables
close all
%% Import data
% showData = importAsTable("input.txt"); %Matlab generated import function for data as presented in challenge
showData = importCSVasTable("input.csv"); %Matlab generated import function for CSV with three columns (show Name, start Hour, end Hour). Example contains randomly generated band names 
% showData = sortrows(showData, 'startHour'); %Sort by start time

%% get some key numbers
Nhours = max(showData.endHour);
Nshows = height(showData);
stage = nan(Nshows,1);
showData = addvars(showData,stage);

%% Generate a matrix of hours for each show as if every show has its own stage
showMatrix = false(Nshows, Nhours);

for i_show = 1:Nshows
    showMatrix(i_show, showData{i_show, "startHour"}:showData{i_show, "endHour"}) = true;
end

figure(1); 
clf
heatmap(double(showMatrix))
ylabel("Show ID")
xlabel("Hour")
colorbar("off")
%% The max of shows simulatainously at each hour tells us how many stages we need.
Nstages = max(sum(showMatrix, 1));
stageMatrix = nan(Nstages, Nhours); %Empty stage planning

%% Loop over each show. There should alsways be a stage for each.
for i_show = 1:Nshows
    show = showData(i_show,:);
    stageOccupation = ~isnan(stageMatrix(:, show.startHour:show.endHour)); %All stage availaibilty during this show
    firstEmptyStage = find(sum(stageOccupation ,2) == 0, 1, "first");
    if isempty(firstEmptyStage)
        error("No empty stage found for show " + show.showName + ", poor souls!")
    end
    showData{i_show,"stage"} = firstEmptyStage; % Add stage to showData
    stageMatrix(firstEmptyStage, show.startHour:show.endHour) = i_show; % Mark the stage as occupied for this slot
end

%% Heatmap figure. Unfortunately it does not support editing the labels
fig = figure(2);
clf
h = heatmap(stageMatrix, "Colormap", hsv);
xlabel("Hour")
ylabel("Stage")
clim([1 Nshows]);
colorbar("off")
h.Title = "Demcon Festival Timetable";
h.GridVisible = "off";
fig.Position=[200, 400, 1024,600];

%% Image approach (https://nl.mathworks.com/matlabcentral/answers/838348-how-to-change-heatmap-data-labels)
fig = figure(3);
clf
ax = axes(fig);
h = imagesc(ax, stageMatrix);
axis tight
set(h, 'AlphaData', ~isnan(stageMatrix))
colormap hsv
set(ax,'XTick',1:Nhours,'YTick',1:Nstages)
title('Demcon Festival Timetable', 'Color', 'b')
ax.TickLength(1) = 0;
hold on
% Set grid lines
xline(ax,ax.XTick+0.5,'w-','Alpha',0.1)
yline(ax,ax.YTick+0.5,'w-','Alpha',0.5)

labels = showData.showName;
xTxt = (showData.startHour + showData.endHour)/2;
yTxt = showData.stage;
th = text(xTxt(:), yTxt(:), labels(:), ...
    'VerticalAlignment', 'middle','HorizontalAlignment','Center', "Interpreter","none", 'FontWeight','bold');
xlabel("Hour")
ylabel("Stage")
fig.Position=[200, 400, 1760,750];

I = imread('30year.png'); 
h = image(xlim,ylim,I);
uistack(h, "bottom")
set(gca,'color',[0.1 0.1 0.1])
set(gcf,'color',[1 1 1])
saveas(fig, "timetable.png")