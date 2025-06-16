% function requires a fasta struct, and a cell array containing 
% random position (output from findRandPosition) 
% function returns the SW score, as well as other parameters of selected
% random sequences.

function randbps = findRandBps(fastaFile, randPosition)

randbps = {};
for i = 1:length(randPosition)
    
    randFrontStart = randPosition{i}{1};
    randFrontEnd = randPosition{i}{2};
    randBackStart = randPosition{i}{3};
    randBackEnd = randPosition{i}{4};
    
    each_chromosome = {};
    for j = 1:length(randFrontStart)
        seqName = fastaFile(i).Header;
        seqName = extractBefore(seqName, '_');
        fivePrime = fastaFile(i).Sequence(randFrontStart(j):randFrontEnd(j));
        middleSeq = fastaFile(i).Sequence(randFrontEnd(j)+1:randBackStart(j)-1);
        threePrime = fastaFile(i).Sequence(randBackStart(j):randBackEnd(j));
        threePrimerc = seqrcomplement(threePrime);

        load('./ScoringMatrix.mat', 'ScoringMatrix')
        [SWscore, SWalignment] = swalign(fivePrime, threePrimerc, Alphabet='NT', ScoringMatrix=ScoringMatrix, GapOpen=10);
        [returnFivePrime, returnThreePrime] = complement(fivePrime, threePrime, SWalignment);

        each_chromosome{end+1} = {SWscore, returnFivePrime, returnThreePrime, ...
            SWalignment(1,:), SWalignment(2,:), SWalignment(3,:), ...
            randBackStart(j)-1-(randFrontEnd(j)+1)+1, strcat(returnFivePrime, middleSeq, returnThreePrime), seqName};
    end
    each_chromosome = each_chromosome.';
    randbps{end+1} = each_chromosome;
end
randbps = randbps.';
end