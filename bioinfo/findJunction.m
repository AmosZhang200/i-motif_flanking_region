% function requires a fasta struct, a iM cell array (output from findiMs) 
% and a integer describing the number of flanking nucleotides, 
% we used 15 in our paper

% function returns a cell array called "junction" that contains 
% information of the following
% name of the sequence
% Smith-Waterman score
% sequence of the whole region
% sequence position relative to transcriptional start site
% i-motif forming sequence
% 5' aligned flanking region
% 3' aligend flanking region
% 5' locally aligned flanking region from SW algorithm
% SW algorithm alignment
% 3' locally aligned flanking region from SW algorithm
% sequence length

function junction = findJunction(fastafile, iMs, flanking)
junction = {};

for i = 1:length(fastafile)
    name = fastafile(i).Header;
    seq = fastafile(i).Sequence;
    seq_length = length(seq);

    start_index = iMs{i}{2};
    end_index = iMs{i}{3};

    each_seq = {};
    for j = 1:length(start_index)
        % get flanking nucleotides position surrounding the i-motif forming
        % sequence
        front_start = start_index(j)-flanking;
        front_end = start_index(j)-1;
        back_start = end_index(j)+1;
        back_end = end_index(j)+flanking;
        if front_start < 1
            % if there is less than 15 nucleotides in the 5' end of iM
            % forming sequence
            % start at 1
            front_start = 1;
            back_end = back_start + front_end - front_start;
        end
        if back_end > length(seq)
            % if there is less than 15 nucleotides in the 3' end of iM
            % forming sequence
            % end at 4000
            back_end = length(seq);
            front_start = front_end - back_end + back_start;
        end
        if (front_end <= flanking-5) || (back_start >= seq_length-flanking+5)
            % if there is less than 10 nucleotides in the 5' end and
            % 3' end of iM forming sequence, we exclude this search
            break
        end
        % in case of two sides have different length of flanking
        % nucleotides
        if ((front_end-front_start)>(back_end-back_start))
            front_start = start_index(j)-(back_end-back_start);
        elseif ((front_end-front_start)<(back_end-back_start))
            back_end = end_index(j)+(front_end-front_start);
        end

        % find flanking sequences
        fivePrime = seq(front_start:front_end);
        threePrime = seq(back_start:back_end);

        % find the reverse complement sequence of the 3' end
        threePrimerc = seqrcomplement(threePrime);
        % load the modified Smith-Waterman scoring matrix
        load('./ScoringMatrix.mat', 'ScoringMatrix')
        % align the sequences to find the maximum number of base pairs
        [SWscore, SWalignment] = swalign(fivePrime, threePrimerc, Alphabet='NT', ScoringMatrix=ScoringMatrix, GapOpen=10);
        [returnFivePrime, returnThreePrime] = complement(fivePrime, threePrime, SWalignment);
        each_seq{end+1} = {name, SWscore, strcat(returnFivePrime, ...
            seq(start_index(j):end_index(j)), returnThreePrime), ...
            front_start-2000, back_end-2000, ...
            seq(start_index(j):end_index(j)), returnFivePrime, ...
            returnThreePrime, SWalignment(1,:), ...
            SWalignment(2,:), SWalignment(3,:), ...
            back_start-1-(front_end+1)+1
            };
    end
    junction{end+1} = each_seq;
end
junction = junction';
end