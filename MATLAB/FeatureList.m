function [ ret ] = FeatureList( data, word, cols, exprs )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    cnt = CountWordsInData(data, word);
    ret = struct('date', zeros(cnt,1), 'time', zeros(cnt,1), 'values', zeros(cnt,size(cols,2)));
    feat = 1;
    for i=12:(size(data{1,1},1)-1)
        if(~isempty(strfind(data{1,1}{i,1}, word)))
            % Split, and pull out cols
            row = strsplit(data{1,1}{i,1},','); %REMOVES EMPTY FIELDS
            ret.date(feat) = datenum(row(2),'dd/mm/yy');% Timestamp
            ret.time(feat) = datenum(row(3),'HH:MM:SS');% Timestamp
            ret.time(feat) = ret.time(feat)-floor(ret.time(feat));
            for j=1:size(cols,2)
                strcell = row(cols{j});
                val = regexp(strcell{1,1}, exprs{j}, 'tokens', 'once');
                ret.values(feat,j) = str2double(val{1,1});
            end
            feat = feat + 1;
        end
    end
end

