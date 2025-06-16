% Since Smith-Waterman is a local alignment algorithm, the sequence output 
% is a subset of the flanking region.
% As a result, we need to map the local alignment to the global flanking region 
% (15 flanking nucleotides on either side)

function [returnFivePrime, returnThreePrime] = complement(fivePrime, threePrime, SWalignment)
% find reverse complement sequence at 3' end
threePrimerc = seqrcomplement(threePrime);

% making the aligned sequences in upper case
fiveAligned = upper(SWalignment(1, :));
alignment = SWalignment(2, :);
threercAligned = upper(SWalignment(3, :));

% remove all the gaps as the original flanking nucleotides doesn't have
% gaps
fiveAlignedNoGap = erase(fiveAligned, '-');
threercAlignedNoGap = erase(threercAligned,'-');

fiveLength = length(fiveAligned);
threercLength = length(threercAligned);

fivePrime = upper(fivePrime);
threePrimerc = upper(threePrimerc);

% find the location where this local alignment happens
fiveIndex = strfind(fivePrime, fiveAlignedNoGap);
threercIndex = strfind(threePrimerc, threercAlignedNoGap);

returnFivePrime = lower(fivePrime);
i = 1;
index = 1;
while i <= fiveLength
    alignInfo = alignment(i);
    if strcmp(alignInfo, '|')
        returnFivePrime(fiveIndex(end)+index-1) = fiveAligned(i);
    elseif strcmp(fiveAligned(i), '-')
        index = index - 1;
    end
    index = index + 1;
    i = i + 1;
end

returnThreePrimerc = lower(threePrimerc);
i = 1;
index = 1;
while i <= threercLength
    alignInfo = alignment(i);
    if strcmp(alignInfo, '|')
        returnThreePrimerc(threercIndex(1)+index-1) = threercAligned(i);
    elseif strcmp(threercAligned(i), '-')
        index = index - 1;
    end
    index = index + 1;
    i = i + 1;
end

returnThreePrime = seqrcomplement(returnThreePrimerc);

end
