% Function requires a fasta struct, a junction cell array 
% (output from findJunction function), and number of flanking nucleotides
% (15 in our study) as inputs
% function return random position in the same promoter region as i-motif
% forming sequences.

function randPosition = findRandPosition(fastaFile, junction, bases)
randPosition = {};

for i = 1:length(fastaFile)
    num_seq_each_ch = length(junction{i});
    ch_seq = fastaFile(i).Sequence;
    ch_nt = length(ch_seq);
    randFrontEnd = round(rand(num_seq_each_ch, 1) * ch_nt);
    randFrontStart = [];
    randBackStart = [];
    randBackEnd = [];
    expression = '(C{4,6}[ATCG]{1,5}){3,}C{4,6}';
    for j = 1:length(randFrontEnd)
        length_of_iM_seq = length(junction{i}{j}{6});
        
        randFrontStart(j) = randFrontEnd(j) - bases;
        randBackStart(j) = randFrontEnd(j) + length_of_iM_seq;
        randBackEnd(j) = randBackStart(j) + bases-1;
        randFrontEnd(j) = randFrontEnd(j) - 1;
        
        start_index = [];
        if randFrontStart(j) >= 1 && randBackEnd(j) <= ch_nt
            midSeq = ch_seq(randFrontEnd(j)+1:randBackStart(j)-1);
            start_index = regexp(midSeq, expression, 'once');
        end
        
        % do not allow "N" as a nucleotide and do not allow i-motif forming
        % sequence in the randomly selected sequence containing iM
        while randFrontStart(j) < 1 || randBackEnd(j) > ch_nt || ~isempty(start_index)
            randFrontEnd(j) = round(rand(1)*ch_nt);
            randFrontStart(j) = randFrontEnd(j) - bases;
            randBackStart(j) = randFrontEnd(j) + length_of_iM_seq;
            randBackEnd(j) = randBackStart(j) + bases-1;
            randFrontEnd(j) = randFrontEnd(j) - 1;
            start_index = [];
            if randFrontStart(j) >= 1 && randBackEnd(j) <= ch_nt
                midSeq = ch_seq(randFrontEnd(j)+1:randBackStart(j)-1);
                start_index = regexp(midSeq, expression, 'once');
            end
        end
    end

    randFrontStart = randFrontStart.';
    randBackStart = randBackStart.';
    randBackEnd = randBackEnd.';

    randPosition{end+1} = {randFrontStart, randFrontEnd, ...
        randBackStart, randBackEnd};
end

randPosition = randPosition.';
end