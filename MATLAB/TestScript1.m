% DiaStats Test Script 1
clear;

% Load CSV and classify readings

%csvread only works if the file only has numbers in it...
%CSV = csvread('CareLink-Export-1424025644704.csv');

%Just read the file - 39 columns
csvID = fopen('CareLink-Export-1424025644704.csv');
%csvID = fopen('CareLink-Export-1424584563049.csv');
%format = '%s %s %s %s %s %f %s %f %s %s %s %f %f %s
%          A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  V

% Never used:
% E - New Device Time
% N - Bolus Duration

data = textscan(csvID, '%s', 'Delimiter', '\n');
fclose(csvID);

% Rename the CurrentInsulinSensitivityPattern...
for i=1:size(data{1,1},1)
    data{1,1}{i,1} = strrep(data{1,1}{i,1},'CurrentInsulinSensitivityPattern','CurSensPat');
    data{1,1}{i,1} = strrep(data{1,1}{i,1},'CurrentCarbRatioPattern','CurRatioPat');
end

% My data is in data{1,1}
% Count the number of lines that have BasalProfileStart, BolusNormal,
% BGCapturedOnPump, BGReceived, ChangeSuspendState, ...
% BasalCnt = CountWordsInData(data, 'BasalProfileStart');
% BolusNormalCnt = CountWordsInData(data, 'BolusNormal');
% BGCapturedOnPumpCnt = CountWordsInData(data, 'BGCapturedOnPump');
% BGReceivedCnt = CountWordsInData(data, 'BGReceived');
% ChangeSuspendStateCnt = CountWordsInData(data, 'ChangeSuspendState');

% For now, just pull out and plot the BGs
BGs = FeatureList(data, 'BGCapturedOnPump', {5}, {'(.*)'});
Basals = FeatureList(data, 'BasalProfileStart', {8}, {'RATE=(\d+\.?\d*)'});
CarbRatios = FeatureList(data, 'CurrentCarbRatio', {7,8,10}, {'\D*(\d+)','AMOUNT=(\d+)','\D*(\d+)'});
Sensitivities = FeatureList(data, 'CurrentInsulinSensitivity', {8}, {'AMOUNT=(\d+)'});
Sensitivities.values = Sensitivities.values./18; % Convert to mmol/L

%Fix carb ratios data 
%Fix order
orderingTab = [CarbRatios.date, CarbRatios.values];
[meh, map] = sortrows(orderingTab, [1;2]);
CarbRatios.date = CarbRatios.date(map,:);
CarbRatios.values = CarbRatios.values(map,:);
%Fix date issue (ratios not provided every day!)
if (BGs.date(1)~=CarbRatios.date(1))
    %Get count of ratios
    cnt=1;
    while(cnt<size(CarbRatios.date,1) && CarbRatios.date(cnt)==CarbRatios.date(1))
        cnt = cnt+1;
    end
    cnt = cnt-1;
    newTimes = CarbRatios.time(1:cnt,:);
    newDates = zeros(cnt,1)+BGs.date(1);
    newRatios= CarbRatios.values(1:cnt,:);
    CarbRatios.time = [newTimes; CarbRatios.time];
    CarbRatios.date = [newDates; CarbRatios.date];
    CarbRatios.values = [newRatios; CarbRatios.values];
end
%Fix time
CarbRatios.values(:,3) = CarbRatios.values(:,3)./(1000*60*60*24);

% PLOTS
figure();
hold on;
% PLOT BGs
PlotBG(BGs);
% PLOT BASALS
PlotBasal(Basals);

%TODO: PLOT RANGES
%PLOT LIMITS
x=[0,7,7,21,21,24];
y1=[7,7,6,6,7,7];
y2=[6,6,4.2,4.2,6,6];
avg = mean(BGs.values);
yavg=[avg,avg];
plot(x,y1,'-m');
plot(x,y2,'-m');
plot([0,24],yavg, '--k');

%TODO: Plot expected curve

%TODO: Focus on high blood sugars


% GET NEW FIGURE
figure();
hold on;
%PLOT LIMITS
x=[0,7,7,21,21,24];
y1=[7,7,6,6,7,7];
y2=[6,6,4.2,4.2,6,6];
plot(x,y1,'-m');
plot(x,y2,'-m');

%Classify BGs
hi_lim = [7,6,7];
lo_lim = [6,4.2,6];
ti_lim = [0,7,21];
%Row count = n(BGs)
%Col count = class + time + day of week + basal + ratio + sensitivity = 6
C = zeros(size(BGs.values,1),6);
%Fill out every entry
for i = 1:size(BGs.values,1)
    idx = 1;
    while(idx<size(hi_lim,2) && BGs.time(i)<ti_lim(idx+1))
        idx = idx+1;
    end
    if (BGs.values(i)>hi_lim(idx))
        C(i,1) = 1;
    else
        C(i,1) = -1;
    end
    % Get other interesting data
    
    %TIME
    C(i,2) = BGs.time(i);
    
    %DAY OF WEEK
    C(i,3) = weekday(BGs.date(i));
    
    %BASAL
    %Get basals for just that day
    basalT = [Basals.date, Basals.time, Basals.values];
    %Get rows with the same date
    first=1;
    while(Basals.date(first)~=BGs.date(i)) 
        first = first+1; end
    last = first;
    while(last < size(Basals.date,1) && Basals.date(last+1)==BGs.date(i))
        last = last+1; end
    idx = first;
    while(idx<last && BGs.time(i)>=Basals.time(idx+1))
        idx = idx+1;
    end
    C(i,4) = Basals.values(idx,1);
    
    %RATIO
    %Get first and last row with most recent ratios
    first = 1;
    while (CarbRatios.date(first)<BGs.date(i))
        first = first+1;
    end
    last = first;
    while (last <= size(CarbRatios.date,1) && CarbRatios.date(first)==(CarbRatios.date(last)))
        last = last+1;
    end
    last = last-1;
    idx = first;
    %DO NOT USE THE TIME ENTRY OF CARB RATIOS
    while (idx~=last && BGs.time(i)>=CarbRatios.values(idx+1,3))
        idx = idx+1;
    end
    C(i,5) = CarbRatios.values(idx,1);
    
    %SENSITIVITY
    %FIX THIS
    C(i,6) = Sensitivities.values(1);
end

[ features, thresholds, polarities, alphas ] = boost(C,15);
CONF = ApplyBoost(features, thresholds, polarities, alphas, C);
error = (CONF(1,2)+CONF(2,1))/sum(sum(CONF));
