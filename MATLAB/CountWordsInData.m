function [ cnt ] = CountWordsInData( data, word )
%CountWordsInData - Counts the number of lines that contain the word
    cnt = 0;
    for i=12:(size(data{1,1},1)-1)
        if(~isempty(strfind(data{1,1}{i,1}, word)))
            cnt = cnt+1;
        end
    end
end

