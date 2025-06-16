% NOTE: Function requires installing parallel toolbox application
% Function used parallel for loop (parfor) to speed up the random sampling
% This function is a void function - no input 

randomCellCoding = {};

% loads the coding strand gene names and the promoter sequences from a fasta file
% files developed in a previous project reference: 
% Hennecker, C., Yamout, L., Zhang, C., Zhao, C., Hiraki, D., Moitessier, N., & Mittermaier, A. (2022). Structural polymorphism of guanine quadruplex-containing regions in human promoters. International Journal of Molecular Sciences, 23(24), 16020.
coding = fastaread(fullfile('./promoter_sequence/', 'Coding.fa'));

% call findiMs function - find all iM forming sequences using regex pattern matching
iMCoding = findiMs(coding);

% Find 15 flanking nucleotides on each end surrounding the the iM forming sequences
junctionCoding = findJunction(coding, iMCoding, 15);

% remove the promoter regions that do not contain iM forming sequences
[junctionCleanedCoding, deleteIndexCoding] = cleanJunction(junctionCoding);

% this code block is used to find random sequences in the same promoter
% with identical length to the iM forming sequences
% this selection is done for 1000 times for data reproducibility

% if parfor is not installed, use regular for loop, but much slower
% one can reduce the number of iterations, but the average values are more
% variable
parfor times = 1:1000
    randPosition = findRandPosition(coding, junctionCoding, 15);
    randbps = findRandBps(coding, randPosition);
    randomCleanedCoding = cleanRandom(randbps, deleteIndexCoding);
    randomCellCoding{times} = randomCleanedCoding;
    disp(times)
end
randomCellCoding = randomCellCoding.';

randomCellNon = {};
% loads the non-coding strand gene names and the promoter sequences from a fasta file
nonCoding = fastaread(fullfile('./promoter_sequence/', 'nonCoding.fa'));

% call findiMs function - find all iM forming sequences using regex pattern matching
iMnonCoding = findiMs(nonCoding);

% Find 15 flanking nucleotides on each end surrounding the the iM forming sequences
junctionNonCoding = findJunction(nonCoding, iMnonCoding, 15);

% remove the promoter regions that do not contain iM forming sequences
[junctionCleanedNon, deleteIndexNon] = cleanJunction(junctionNonCoding);

% this code block is used to find random sequences in the same promoter
% with identical length to the iM forming sequences
% this selection is done for 1000 times for data reproducibility

% if parfor is not installed, use regular for loop, but much slower
% one can reduce the number of iterations, but the average values are more
% variable
parfor times = 1:1000
    randPosition = findRandPosition(nonCoding, junctionNonCoding, 15);
    randbps = findRandBps(nonCoding, randPosition);
    randomCleanedNon = cleanRandom(randbps, deleteIndexNon);
    randomCellNon{times} = randomCleanedNon;
    disp(times)
end
randomCellNon = randomCellNon.';

% prepare for plotting
if ~exist('plotI', 'var')
    plotI = 5;
end

% plot human promoter i-motif and random sequences together
plotI = plotTogether(junctionCleanedCoding, randomCellCoding, "Coding Strand", plotI);
plotI = plotTogether(junctionCleanedNon, randomCellNon, "Non-Coding Strand", plotI);