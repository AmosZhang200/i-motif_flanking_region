Files under bioinfo directory finds putative human iM forming sequences 
and assign score for whether DNA duplex can form in the flanking regions. 
It also generates Figure 5.

Files under the uv directory is responsible for analyzing UVTH (UV thermal hysteresis) curves.
	2states3lowFitting method analyze samples with 5, 7, 10, 13, and 15 complementary flanking nucleotides, 
		and 0 - 5 spacer nucleotides at pH 7.0 and 295 nm
		(Refer to method: Thermal hysteresis analysis)
	3statesFitting method analyze samples with 5, 7, 10, 13, and 15 complementary flanking nucleotides, 
		and 0 - 5 spacer nucleotides at pH 7.0 and 260 nm, where samples have biphasic transitions.
		(Refer to SI method: Biphasic transition analysis)
	semiQuantitativeFitting method analyze samples with 10, 13, and 15 complementary flanking nucleotides, 
		and 0 - 5 spacer nucleotides at pH 5.5, 260 nm or 295 nm
		(Refer to SI method: Semi-quantitative analysis for samples slightly deviating from the two-state model)
	estimateLowBaselineFitting method analyze samples without low temperature baselines, according to samples with stabilized baselines
		(Refer to SI method: Estimation of the low temperature baseline)
	2statesFitting method analyze the rest of the samples
		(Refer to method: Thermal hysteresis analysis)

File under "shared" folder are used by the functions in uv folder, 
thus are required to "add to MATLAB path" before using.

The data from the UV-vis machine should be saved to rawdata file
Run "saveUV" function in the shared folder to save the data into structure.
The saved data is present in processed folder
To analyze the saved data, go to the desired method under uv folder and 
run "main" function in each of the desired method.
