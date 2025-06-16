% Function requires a struct as an input 
% outputs all the possible iM forming sequences found by pattern matching

function iMs = findiMs(fastaFile)

iMs = {};

% allowing 4-6 cytosines in each tract, 1-5 nucleotides in each loop, for 4
% or more C-tracts.
expression = '(C{4,6}[ATCG]{1,5}){3,}C{4,6}';

for i = 1:length(fastaFile)
    name = fastaFile(i).Header;
    seq = fastaFile(i).Sequence;
    [start_index, end_index] = regexp(seq, expression);
    iMs{end+1} = {name, start_index, end_index};
end
iMs = iMs.';
end