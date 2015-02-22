function [  ] = PlotBasal( Basals )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    days = Basals.date(end) - Basals.date(1);
    for i=1:days
        date = i+Basals.date(1)-1;
            first = 1;
        while(Basals.date(first)~=date)
            first = first+1;
        end
        last = first;
        while(Basals.date(last+1)==date)
            last = last+1;
        end
        n = 2*(last-first); % Account for values that I need to double up
        times = zeros(n,1);
        rates = zeros(n,1);
        j = first;
        while (j~=(last+1))
            rates((j-first)*2+1) = Basals.values(j);
            times((j-first)*2+1) = Basals.time(j)*24;
            rates((j-first)*2+2) = Basals.values(j);
            if (j==last)
                times((j-first)*2+2)= 1*24;
            else
                times((j-first)*2+2) = Basals.time(j+1)*24;
            end
            j = j+1;
        end
        color = [0,1,0];
        color = color + [1,0,1]*((days-i)/days);
        plot(times,rates,'-', 'Color', color);
    end
end

