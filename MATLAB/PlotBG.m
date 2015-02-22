function [  ] = PlotBG( BGs )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    days = BGs.date(end) - BGs.date(1);
    for i = 1:days
        %Get first and last index for this day
        date = i+BGs.date(1)-1;
        first = 1;
        while(BGs.date(first)~=date)
            first = first+1;
        end
        last = first;
        while(BGs.date(last+1)==date)
            last = last+1;
        end
        ts = timeseries(BGs.values(first:last), BGs.time(first:last));
        ts.Time = ts.Time*24;
        ts.Name = 'BGs';
        ts.TimeInfo.Units = 'hours';
        ts.TimeInfo.Format = 'HH:MM';
    %     ts.TimeInfo.StartTime = '00:00';
    %TODO: Older lines are whiter
    %     color = [rand(), rand(), rand()];
        color = [1,1,1];
    %     color = color./1.5+0.25;
        %Normalize
    %     color = color./sqrt(sum(color.^2));
        color = color*((days-i)/days);
    %     color = color*(0.0016*(days-i)^2+3.9E-18*(days-1)+1);
        for k =1:3
            if color(k)>1
                color(k)=1;
            end
        end
        p = plot(ts, ':x', 'Color', color);
    end
    legend(datestr(unique(BGs.date)));
    axis([0,24,0,20]);
    set(gca, 'XTick', [0:3:24]);
    
end

