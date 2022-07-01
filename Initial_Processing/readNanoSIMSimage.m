function [image_data, header_data] = readNanoSIMSimage(inputfile)
% function [image_data,header_data]=readNanoSIMSimage(inputfile)
% For NanoSIMS 50

fid = fopen(inputfile);

s = dir(inputfile);
filesizebytes = s.bytes;

Def_analysis = def_analysis(fid);

Mask_im = maskim(fid);
for ii = 1:Mask_im.nb_mass
    Tab_mass_(ii) = tab_mass(fid);
end
Tab_mass_names = fieldnames(Tab_mass_(1));
Tab_mass = struct;
for ii = 1:numel(Tab_mass_names)
    Tab_mass.(Tab_mass_names{ii}) = {Tab_mass_(:).(Tab_mass_names{ii})};
end

%if Mask_im.auto_cal_in_anal~=0
for ii = 1:Mask_im.nb_mass
    Cal_cond_(ii) = cal_cond(fid);
end

Cal_cond_names = fieldnames(Cal_cond_(1));
Cal_cond = struct;
for ii = 1:numel(Cal_cond_names)
    Cal_cond.(Cal_cond_names{ii}) = {Cal_cond_(:).(Cal_cond_names{ii})};
end
%end
Polylist = poly_list(fid);
for ii = 1:Polylist.nb_poly
    Polyatomique(ii) = polyatomique(fid);
end

Mask_nano = mask_nano(fid); %This prints!!!

for ii = 1:Mask_nano.m_nNbBField
    Tab_Bfield_nano(ii) = tab_bfield_nano(fid);
end

Anal_param_nano = anal_param_nano(fid);

Def_analysis_bis = def_analysis_bis(fid);

%fread(fid,416,'uint8'); % Anal_param structure not used by NanoSIMS50
%fread(fid,376,'uint8'); % Setup_soft structure not used by NanoSIMS50
Anal_param_nano_bis = anal_param_nano_bis(fid);

fseek(fid, Def_analysis.header_size-84, 'bof');

Header_image = header_image(fid);


switch Header_image.pixelsize
    case 1
        pixeltype = 'uint8';
    case 2
        pixeltype = 'uint16';
    case 4
        pixeltype = 'uint32';
    case 8
        pixeltype = 'uint64';
end

% Read in the images:

mass_names = cell(Mask_im.nb_mass, 1);
mass_names{end} = 'SE';
for ii = 1:Mask_im.nb_mass - 1
    mass_names{ii} = Tab_mass.mass{ii}.charge(2:end);
end
massnames = struct('mass_names', {mass_names});

%data=fread(fid,Header_image.width.*Header_image.height.*Header_image.numberofimages.*Header_image.numberofplanes,pixeltype); %);
%image_data=reshape(double(data),Header_image.width,Header_image.height,Header_image.numberofimages,Header_image.numberofplanes);

%ncycles=(filesizebytes-Def_analysis.header_size)./(Header_image.width.*Header_image.height.*Header_image.numberofimages.*Header_image.numberofplanes.*Header_image.pixelsize);

data = fread(fid, Header_image.width.*Header_image.height.*Header_image.numberofimages.*Header_image.numberofplanes, [pixeltype, '=>double']); %);
image_data = reshape(data, Header_image.width, Header_image.height, Header_image.numberofimages, Header_image.numberofplanes);


data = [];
image_data = permute(image_data, [2, 1, 3, 4]);


if ~exist('Anal_param_nano', 'var')
    Anal_param_nano = [];
end

if ~exist('Anal_param_nano_bis', 'var')
    Anal_param_nano_bis = [];
end

if ~exist('Cal_cond', 'var')
    Cal_cond = [];
end

if ~exist('Def_analysis', 'var')
    Def_analysis = [];
end

if ~exist('Def_analysis_bis', 'var')
    Def_analysis_bis = [];
end

if ~exist('Header_image', 'var')
    Header_image = [];
end

if ~exist('Mask_im', 'var')
    Mask_im = [];
end

if ~exist('Mask_nano', 'var')
    Mask_nano = [];
end

if ~exist('Polylist', 'var')
    Polylist = [];
end

if ~exist('Tab_Bfield_nano', 'var')
    Tab_Bfield_nano = [];
end

if ~exist('Tab_mass', 'var')
    Tab_mass = [];
end

if ~exist('mass_names', 'var')
    mass_names = [];
end

header_data = struct('Anal_param_nano', Anal_param_nano, 'Anal_param_nano_bis', Anal_param_nano_bis, ...
    'Cal_cond', Cal_cond, 'Def_analysis', Def_analysis, 'Def_analysis_bis', Def_analysis_bis, ...
    'Header_image', Header_image, 'Mask_im', Mask_im, 'Mask_nano', Mask_nano, 'Polylist', Polylist, ...
    'Tab_Bfield_nano', Tab_Bfield_nano, 'Tab_mass', Tab_mass, 'mass_names', massnames);

fclose(fid);
end
%toc

function defanalysis_out = def_analysis(fid)

release = fread(fid, 1, 'int32=>double'); %);
analysis_type = fread(fid, 1, 'int32=>double'); %);
header_size = fread(fid, 1, 'int32=>double'); %);
fread(fid, 1, 'int32=>double'); %);
data_included = fread(fid, 1, 'int32=>double'); %);
sple_pos_x = fread(fid, 1, 'int32=>double'); %);
sple_pos_y = fread(fid, 1, 'int32=>double'); %);
analysis_name = fread(fid, 32, 'uint8=>char')';
username = fread(fid, 16, 'uint8=>char')';
sample_name = fread(fid, 16, 'uint8=>char')';
date = fread(fid, 16, 'uint8=>char')';
hour = fread(fid, 16, 'uint8=>char')';

w = whos;
for ii = 1:length(w)
    if ~strcmp(w(ii).name, 'fid') && ~strcmp(w(ii).name, 'ii') && ~strcmp(w(ii).name, 'ans') && ~strcmp(w(ii).name, 'w')
        defanalysis_out.(w(ii).name) = eval(w(ii).name);
    end
end

end

function maskim_out = maskim(fid)
f1 = ftell(fid);
filename = fread(fid, 16, 'uint8=>char')';
analysis_duration_min = fread(fid, 1, 'int32=>double');
cycle_number = fread(fid, 1, 'int32=>double');
scantype = fread(fid, 1, 'int32=>double');
magnification = fread(fid, 1, 'int32=>double');
sizetype = fread(fid, 1, 'int32=>double');
size_detecteur = fread(fid, 1, 'int32=>double');
no_used = fread(fid, 1, 'int32=>double');
beam_blanking = fread(fid, 1, 'int16=>double');
pulverisation = fread(fid, 1, 'int16=>double');
pulve_duration = fread(fid, 1, 'int16=>double');
auto_cal_in_anal = fread(fid, 1, 'int16=>double');
AutoCal = autocal(fid);
sig_reference = fread(fid, 1, 'int32=>double');
SigRef = sigref(fid);
nb_mass = fread(fid, 1, 'int32=>double');
mass_table_pointer = fread(fid, 60, 'int32=>int32');
f2 = ftell(fid);
maskim_out = struct('filename', filename, 'analysis_duration_min', analysis_duration_min, 'cycle_number', cycle_number, ...
    'scantype', scantype, 'magnification', magnification, 'sizetype', sizetype, 'size_detecteur', size_detecteur, 'no_used', no_used, ...
    'beam_blanking', beam_blanking, 'pulverisation', pulverisation, 'pulve_duration', pulve_duration, ...
    'auto_cal_in_anal', auto_cal_in_anal, 'AutoCal', AutoCal, 'sig_reference', sig_reference, 'SigRef', SigRef, ...
    'nb_mass', nb_mass, 'mass_table_pointer', mass_table_pointer);
end

function autocal_out = autocal(fid)
mass = fread(fid, 64, 'uint8=>char')';
begin_cycle = fread(fid, 1, 'int32=>double');
end_cycle = fread(fid, 1, 'int32=>double');
autocal_out = struct('mass', mass, 'begin_cycle', begin_cycle, 'end_cycle', end_cycle);
end

function sigref_out = sigref(fid)
Polyatomique = polyatomique(fid);
detector = fread(fid, 1, 'int32=>double');
offset = fread(fid, 1, 'int32=>double');
cps = fread(fid, 1, 'int32=>double');
sigref_out = struct('Polyatomique', Polyatomique, 'detector', detector, 'offset', offset, 'cps', cps);
end

function tab_mass_out = tab_mass(fid)
f1 = ftell(fid);
type_mass = fread(fid, 1, 'int32=>double');
fread(fid, 1, 'int32=>double'); % ERROR IN DOCUMENTATION: Otherwise size of tab_mass struct = 188
mass_amu = fread(fid, 1, 'double=>double');
matrix_or_trace = fread(fid, 1, 'int32=>double');
detector = fread(fid, 1, 'int32=>double');
waitingtime = fread(fid, 1, 'double=>double');
countingtime = fread(fid, 1, 'double=>double');
offset = fread(fid, 1, 'int32=>double');
magfield = fread(fid, 1, 'int32=>double');
mass = polyatomique(fid);
f2 = ftell(fid);
tab_mass_out = struct('type_mass', type_mass, 'mass_amu', mass_amu, 'matrix_or_trace', matrix_or_trace, ...
    'detector', detector, 'waitingtime', waitingtime, 'countingtime', countingtime, 'offset', offset, ...
    'magfield', magfield, 'mass', mass);
end

function tabelts_out = tab_elts(fid)
eltnumn = fread(fid, 1, 'int32=>double');
isonum = fread(fid, 1, 'int32=>double');
num_of_elt = fread(fid, 1, 'int32=>double');
tabelts_out = struct('eltnumn', eltnumn, 'isonum', isonum, 'num_of_elt', num_of_elt);
end


function polyatomique_out = polyatomique(fid)
%fprintf('Polyatomique: %d\n',ftell(fid))
f1 = ftell(fid);
flag = fread(fid, 1, 'int32=>double');
number = fread(fid, 1, 'int32=>double');
numberelements = fread(fid, 1, 'int32=>double');
numberloading = fread(fid, 1, 'int32=>double');
charge = fread(fid, 4, 'uint8=>char')'; % ERROR: SIZW OF POLYATOMIQUE SHOULD BE 144 NOT 141, likely charge should be charge[4]
string = fread(fid, 64, 'uint8=>char')';


for ii = 1:5
    tabelts(ii) = tab_elts(fid);
end


f2 = ftell(fid);

%f2-f1
polyatomique_out = struct('flag', flag, 'number', number, 'numberelements', numberelements, ...
    'numberloading', numberloading, 'charge', charge, 'string', string, 'tab_elts', tabelts);
%fprintf('Polyatomique: %d\n',ftell(fid))
end

function calcond_out = cal_cond(fid)
f1 = ftell(fid);
n_delta = fread(fid, 1, 'int32=>double');
np_delta = fread(fid, 1, 'int32=>double');
counting_time_per_point = fread(fid, 1, 'int32=>double');
nb_cycles = fread(fid, 1, 'int32=>double');
no_used2 = fread(fid, 1, 'double=>double');
cal_ref_mass = fread(fid, 1, 'double=>double');
symbol = fread(fid, 64, 'uint8=>char')';
f2 = ftell(fid);
calcond_out = struct('n_delta', n_delta, 'np_delta', np_delta, 'counting_time_per_point', counting_time_per_point, ...
    'nb_cycles', nb_cycles, 'no_used2', no_used2, 'cal_ref_mass', cal_ref_mass, 'symbol', symbol);
end

function polylist_out = poly_list(fid)
f1 = ftell(fid);
structname = fread(fid, 16, 'uint8=>char')';
nb_poly = fread(fid, 1, 'int32=>double');
polypointer = fread(fid, 1, 'int32=>double');
%Polyatomique=polyatomique(fid);
f2 = ftell(fid);
polylist_out = struct('structname', structname, 'nb_poly', nb_poly, 'polypointer', polypointer);
end

function masknano_out = mask_nano(fid)
f1 = ftell(fid);
m_nVersion = fread(fid, 1, 'int32=>double');
m_nRegulationMode = fread(fid, 1, 'int32=>double');
m_nMode = fread(fid, 1, 'int32=>double');
m_nGrain_mode = fread(fid, 1, 'int32=>double');
m_nSemi_graphic_mode = fread(fid, 1, 'int32=>double');
m_nDeltax = fread(fid, 1, 'int32=>double');
m_nDeltay = fread(fid, 1, 'int32=>double');

m_nNX_max = fread(fid, 1, 'int32=>double');
m_nNY_max = fread(fid, 1, 'int32=>double');

m_nNX_low = fread(fid, 1, 'int32=>double');
m_nNX_high = fread(fid, 1, 'int32=>double');

m_nNY_low = fread(fid, 1, 'int32=>double');
m_nNY_high = fread(fid, 1, 'int32=>double');

m_nNX_lowB = fread(fid, 1, 'int32=>double');
m_nNX_highB = fread(fid, 1, 'int32=>double');
m_nNY_lowB = fread(fid, 1, 'int32=>double');
m_nNY_highB = fread(fid, 1, 'int32=>double');

m_nType_detecteur = fread(fid, 1, 'int32=>double');
m_nElectron_scan = fread(fid, 1, 'int32=>double');
m_nScanning_mode = fread(fid, 1, 'int32=>double');
m_nBlanking_comptage = fread(fid, 1, 'int32=>double');
m_nCheckAvailaible = fread(fid, 1, 'int32=>double');
m_nCheckStart = fread(fid, 1, 'int32=>double');
m_nCheckFrequency = fread(fid, 1, 'int32=>double');
m_nNbBField = fread(fid, 1, 'int32=>double');

m_BFieldTab_pointer = fread(fid, 72, 'int32=>double');
m_nPrintRes = fread(fid, 1, 'int32=>double');
ftell(fid);
m_HorizontalSibcParam = sec_ion_beam_nano(fid);
ftell(fid);
m_VerticalSibcParam = sec_ion_beam_nano(fid);
m_nSibcBFieldInd = fread(fid, 1, 'int32=>double');
m_nSibcSelected = fread(fid, 1, 'int32=>double');
m_AecParam = energy_nano(fid);
m_nAecBFieldInd = fread(fid, 1, 'int32=>double');
m_nAecSelected = fread(fid, 1, 'int32=>double');
m_nAecFrequency = fread(fid, 1, 'int32=>double');
m_nE0SCenterBFieldInd = fread(fid, 1, 'int32=>double');
m_E0SCenterParam = eos_nano(fid);
m_nE0SCenterSelected = fread(fid, 1, 'int32=>double');
m_nAecWt = fread(fid, 1, 'int32=>double');
m_nPreSputRaster = fread(fid, 1, 'int32=>double');
m_nE0pOffsetForCent = fread(fid, 1, 'int32=>double');
m_nE0sCenterNbPoints = fread(fid, 1, 'int32=>double');
m_nBaselineNbMeas = fread(fid, 1, 'int32=>double');
m_dNotUsed = fread(fid, 1, 'double=>double');
m_nBaselineFrequency = fread(fid, 1, 'int32=>double');
m_nSibcDuringAcqSelected = fread(fid, 1, 'int32=>double');
m_nE0ScDuringAcqSelected = fread(fid, 1, 'int32=>double');
m_nCentenringDuringAcqFrequency = fread(fid, 1, 'int32=>double');
szDummy = fread(fid, 945-9, 'uint8=>char')';

f2 = ftell(fid);
%fprintf('mask_nano=%d\n',f2-f1);

w = whos;
for ii = 1:length(w)
    if ~strcmp(w(ii).name, 'fid') && ~strcmp(w(ii).name, 'ii') && ~strcmp(w(ii).name, 'ans') && ~strcmp(w(ii).name, 'w')
        masknano_out.(w(ii).name) = eval(w(ii).name);
    end
end

end

function tabbfieldnano_out = tab_bfield_nano(fid)
f1 = ftell(fid);
m_nFlagBFieldSelected = fread(fid, 1, 'int32=>double');
m_nBField = fread(fid, 1, 'int32=>double');
m_nWT = fread(fid, 1, 'int32=>double');
m_nCTperPixel = fread(fid, 1, 'int32=>double');
m_dCTperPoint = fread(fid, 1, 'double=>double');
m_nComputed = fread(fid, 1, 'int32=>double');
m_nE0wOffset = fread(fid, 1, 'int32=>double');
m_nQVal = fread(fid, 1, 'int32=>double');
m_nLF4Val = fread(fid, 1, 'int32=>double');
m_nHexVal = fread(fid, 1, 'int32=>double');
m_nNbFrame = fread(fid, 1, 'int32=>double');
no_used1 = fread(fid, 1, 'double=>double');
for ii = 1:12
    m_TrolleyTab(ii) = tab_trolley_nano(fid);
end
for ii = 1:12
    m_PhdTrolleyTab(ii) = phd_trolley_nano(fid);
end
f2 = ftell(fid);
%fprintf('tab_bfield_nano=%d\n',f2-f1);
w = whos;
for ii = 1:length(w)
    if ~strcmp(w(ii).name, 'fid') && ~strcmp(w(ii).name, 'ii') && ~strcmp(w(ii).name, 'ans') && ~strcmp(w(ii).name, 'w')
        tabbfieldnano_out.(w(ii).name) = eval(w(ii).name);
    end
end


% tabbfieldnano_out=struct('m_nFlagBFieldSelected',m_nFlagBFieldSelected,'m_nBField',m_nBField,'m_nWT',m_nWT,...
%     'm_nCTperPixel',m_nCTperPixel,'m_dCTperPoint',m_dCTperPoint,'m_nComputed',m_nComputed,'m_nE0wOffset',m_nE0wOffset,...
%     'm_nQVal',m_nQVal,'m_nLF4Val',m_nLF4Val,'m_nHexVal',m_nHexVal,'m_nNbFrame',m_nNbFrame,'no_used1',no_used1,...
%     'm_TrolleyTab',m_TrolleyTab,'m_PhdTrolleyTab',m_PhdTrolleyTab);
end


function tabtrolleynano_out = tab_trolley_nano(fid)
m_pszSymbol = fread(fid, 64, 'uint8=>char')';
m_dAMU = fread(fid, 1, 'double=>double');
m_dRadius = fread(fid, 1, 'double=>double');
m_nNegPlate = fread(fid, 1, 'int32=>double');
m_nPosPlate = fread(fid, 1, 'int32=>double');
m_nDetecteur = fread(fid, 1, 'int32=>double');
m_nOutSlit = fread(fid, 1, 'int32=>double');
m_nFlagTrolleyValided = fread(fid, 1, 'int32=>double');
m_nNum = fread(fid, 1, 'int32=>double');
m_nPicNum = fread(fid, 1, 'int32=>double');
m_nRefPicNum = fread(fid, 1, 'int32=>double');
m_dPolarizationVal = fread(fid, 1, 'double=>double');
m_dStartVoltage = fread(fid, 1, 'double=>double');
m_nStartDacPlate1 = fread(fid, 1, 'int32=>double');
m_nStartDacPlate2 = fread(fid, 1, 'int32=>double');
m_nDacStep = fread(fid, 1, 'int32=>double');
m_nPointNumber = fread(fid, 1, 'int32=>double');
m_nCountTime = fread(fid, 1, 'int32=>double');
m_nIsUsedForBaseline = fread(fid, 1, 'int32=>double');
m_d50PerCentWidth = fread(fid, 1, 'double=>double');
m_nEdgesMethod = fread(fid, 1, 'int32=>double');
m_nApcCountTime = fread(fid, 1, 'int32=>double');
m_nIsUsedForSecIonBeamCentering = fread(fid, 1, 'int32=>double');
m_nUnitCorrection = fread(fid, 1, 'int32=>double');
m_dDeflectionVal = fread(fid, 1, 'double=>double');
m_nIsUsedForEnergyCentering = fread(fid, 1, 'int32=>double');
m_nIsUsedForE0SCentering = fread(fid, 1, 'int32=>double');
m_dBaselinePdOffset = fread(fid, 1, 'double=>double');
m_nIsUsedForE0ScDuringAcq = fread(fid, 1, 'int32=>double');
m_nIsUsedForSibcDuringAcq = fread(fid, 1, 'int32=>double');
tabtrolleynano_out = struct('m_pszSymbol', m_pszSymbol, 'm_dAMU', m_dAMU, 'm_dRadius', m_dRadius, 'm_nNegPlate', m_nNegPlate, ...
    'm_nPosPlate', m_nPosPlate, 'm_nDetecteur', m_nDetecteur, 'm_nOutSlit', m_nOutSlit, 'm_nFlagTrolleyValided', m_nFlagTrolleyValided, ...
    'm_nNum', m_nNum, 'm_nPicNum', m_nPicNum, 'm_nRefPicNum', m_nRefPicNum, 'm_dPolarizationVal', m_dPolarizationVal, ...
    'm_dStartVoltage', m_dStartVoltage, 'm_nStartDacPlate1', m_nStartDacPlate1, 'm_nStartDacPlate2', m_nStartDacPlate2, 'm_nDacStep', m_nDacStep, ...
    'm_nPointNumber', m_nPointNumber, 'm_nCountTime', m_nCountTime, 'm_nIsUsedForBaseline', m_nIsUsedForBaseline, 'm_d50PerCentWidth', m_d50PerCentWidth, ...
    'm_nEdgesMethod', m_nEdgesMethod, 'm_nApcCountTime', m_nApcCountTime, 'm_nIsUsedForSecIonBeamCentering', m_nIsUsedForSecIonBeamCentering, ...
    'm_nUnitCorrection', m_nUnitCorrection, 'm_dDeflectionVal', m_dDeflectionVal, 'm_nIsUsedForEnergyCentering', m_nIsUsedForEnergyCentering, ...
    'm_nIsUsedForE0SCentering', m_nIsUsedForE0SCentering, 'm_dBaselinePdOffset', m_dBaselinePdOffset, 'm_nIsUsedForE0ScDuringAcq', m_nIsUsedForE0ScDuringAcq, ...
    'm_nIsUsedForSibcDuringAcq', m_nIsUsedForSibcDuringAcq);
end

function phdtrolleynano_out = phd_trolley_nano(fid)

m_nIsUsedForPhdScan = fread(fid, 1, 'int32=>double');
m_nStartDacThr = fread(fid, 1, 'int32=>double');
m_nDacStep = fread(fid, 1, 'int32=>double');
m_nPointNumber = fread(fid, 1, 'int32=>double');
m_nCountTime = fread(fid, 1, 'int32=>double');
m_nNbscan = fread(fid, 1, 'int32=>double');

phdtrolleynano_out = struct('m_nIsUsedForPhdScan', m_nIsUsedForPhdScan, 'm_nStartDacThr', m_nStartDacThr, ...
    'm_nDacStep', m_nDacStep, 'm_nPointNumber', m_nPointNumber, 'm_nCountTime', m_nCountTime, 'm_nNbscan', m_nNbscan);

end

function secionbeamnano_out = sec_ion_beam_nano(fid)
m_nDetId = fread(fid, 1, 'int32=>double');
m_nStartDac = fread(fid, 1, 'int32=>double');
m_nDacStep = fread(fid, 1, 'int32=>double');
m_nUnused1 = fread(fid, 1, 'int32=>double');
m_dStartValue = fread(fid, 1, 'double=>double');
m_d50PerCentWidth = fread(fid, 1, 'double=>double');
m_nAbcCountTime = fread(fid, 1, 'int32=>double');
m_nUnused2 = fread(fid, 1, 'int32=>double');
secionbeamnano_out = struct('m_nDetId', m_nDetId, 'm_nStartDac', m_nStartDac, 'm_nDacStep', m_nDacStep, ...
    'm_nUnused1', m_nUnused1, 'm_dStartValue', m_dStartValue, 'm_d50PerCentWidth', m_d50PerCentWidth, ...
    'm_nAbcCountTime', m_nAbcCountTime, 'm_nUnused2', m_nUnused2);
end

function energynano_out = energy_nano(fid)

m_nDetId = fread(fid, 1, 'int32=>double');
m_nStartDac = fread(fid, 1, 'int32=>double');
m_nDacStep = fread(fid, 1, 'int32=>double');
m_nUnused1 = fread(fid, 1, 'int32=>double');
m_dStartValue = fread(fid, 1, 'double=>double');
m_dDelta = fread(fid, 1, 'double=>double');
m_nAecCountTime = fread(fid, 1, 'int32=>double');
m_nUnused2 = fread(fid, 1, 'int32=>double');
energynano_out = struct('m_nDetId', m_nDetId, 'm_nStartDac', m_nStartDac, 'm_nDacStep', m_nDacStep, 'm_nUnused1', m_nUnused1, ...
    'm_dStartValue', m_dStartValue, 'm_dDelta', m_dDelta, 'm_nAecCountTime', m_nAecCountTime, ...
    'm_nUnused2', m_nUnused2);
end

function Analparamnano_out = anal_param_nano(fid)
f1 = ftell(fid);
fseek(fid, 288+f1, 'bof');
pszNomStruct = fread(fid, 16, 'uint8=>char')';
nRelease = fread(fid, 1, 'int32=>double');
nIsN50Large = fread(fid, 1, 'int32=>double');
nUnused2 = fread(fid, 1, 'int32=>double');
nUnused3 = fread(fid, 1, 'int32=>double');
pszComment = fread(fid, 256, 'uint8=>char')';
prim = ap_primary_nano(fid);
seco = ap_secondary_nano(fid);
f2 = ftell(fid);
%fprintf('anal_param_nano=%d\n',f2-f1);
Analparamnano_out = struct('pszNomStruct', pszNomStruct, 'nRelease', nRelease, 'nIsN50Large', nIsN50Large, ...
    'nUnused2', nUnused2, 'nUnused3', nUnused3, 'pszComment', pszComment, 'prim', prim, 'seco', seco);
end

function Apprimarynano_out = ap_primary_nano(fid)
f1 = ftell(fid);

pszIon = fread(fid, 8, 'uint8=>char')';
nPrimCurrentT0 = fread(fid, 1, 'int32=>double');
nPrimCurrentTEnd = fread(fid, 1, 'int32=>double');

nPrimLDuo = fread(fid, 1, 'single=>real*4');
nPrimL1 = fread(fid, 1, 'single=>real*4');

nDduoPos = fread(fid, 1, 'int32=>double');
nDduoTabValue = fread(fid, 10, 'int32=>double');

nD0Pos = fread(fid, 1, 'int32=>double');
nD0TabValue = fread(fid, 10, 'int32=>double');

nD1Pos = fread(fid, 1, 'int32=>double');
nD1TabValue = fread(fid, 10, 'int32=>double');

dRaster = fread(fid, 1, 'double=>real*4');
dOct45 = fread(fid, 1, 'double=>real*4');
dOct90 = fread(fid, 1, 'double=>real*4');
dPrimaryFoc = fread(fid, 1, 'double=>real*4');

pszAnalChamberPres = fread(fid, 40, 'char=>char')';

nPrimL0 = fread(fid, 1, 'int32=>double');
nCsHv = fread(fid, 1, 'int32=>double');
nDuoHv = fread(fid, 1, 'int32=>double');
nDCsPos = fread(fid, 1, 'int32=>double');

nDCsTabValue = fread(fid, 10, 'int32=>double');
nUnusedTab = fread(fid, 67, 'int32=>double');

f2 = ftell(fid);
%fprintf('ap_primary_nano=%d\n',f2-f1);
Apprimarynano_out = struct('pszIon', pszIon, 'nPrimCurrentT0', nPrimCurrentT0, 'nPrimCurrentTEnd', nPrimCurrentTEnd, ...
    'nPrimLDuo', nPrimLDuo, 'nPrimL1', nPrimL1, 'nDduoPos', nDduoPos, 'nDduoTabValue', nDduoTabValue, 'nD0Pos', nD0Pos, ...
    'nD0TabValue', nD0TabValue, 'nD1Pos', nD1Pos, 'nD1TabValue', nD1TabValue, 'dRaster', dRaster, 'dOct45', dOct45, 'dOct90', dOct90, ...
    'dPrimaryFoc', dPrimaryFoc, 'pszAnalChamberPres', pszAnalChamberPres, 'nPrimL0', nPrimL0, 'nCsHv', nCsHv, 'nDuoHv', nDuoHv, ...
    'nDCsPos', nDCsPos, 'nDCsTabValue', nDCsTabValue, 'nUnusedTab', nUnusedTab);
end

function defanalysisbis_out = def_analysis_bis(fid)
magic = fread(fid, 1, 'int32=>double');
release = fread(fid, 1, 'int32=>double');
filename = fread(fid, 256, 'uint8=>char')';
matrice = fread(fid, 256, 'uint8=>char')';
sigref_mode = fread(fid, 1, 'int32=>double');
sigref_nbptsdm = fread(fid, 1, 'int32=>double');
sigref_nbdm = fread(fid, 1, 'int32=>double');
sigref_ct_scan = fread(fid, 1, 'int32=>double');
sigref_ct_meas = fread(fid, 1, 'int32=>double');
sigref_tps_pulve = fread(fid, 1, 'int32=>double');
eps_recentrage = fread(fid, 1, 'int32=>double');
eps_flag = fread(fid, 1, 'int32=>double');
eps = def_eps(fid);
sple_rot_flag = fread(fid, 1, 'int32=>double');
sple_rot_speed = fread(fid, 1, 'int32=>double');
sple_rot_acq_sync = fread(fid, 1, 'int32=>double');
sample_name = fread(fid, 80, 'uint8=>char')';
experience = fread(fid, 32, 'uint8=>char')';
method = fread(fid, 32, 'uint8=>char')';
noused = fread(fid, 1028, 'uint8=>char')';
defanalysisbis_out = struct('magic', magic, 'release', release, 'filename', filename, 'matrice', matrice, 'sigref_mode', sigref_mode, ...
    'sigref_nbptsdm', sigref_nbptsdm, 'sigref_nbdm', sigref_nbdm, 'sigref_ct_scan', sigref_ct_scan, ...
    'sigref_ct_meas', sigref_ct_meas, 'sigref_tps_pulve', sigref_tps_pulve, 'eps_recentrage', eps_recentrage, ...
    'eps_flag', eps_flag, 'eps', eps, 'sple_rot_flag', sple_rot_flag, 'sple_rot_speed', sple_rot_speed, 'sple_rot_acq_sync', sple_rot_acq_sync, ...
    'sample_name', sample_name, 'experience', experience, 'method', method, 'noused', noused);

end

function defeps_out = def_eps(fid)

central_energy = fread(fid, 1, 'int32=>double');
field = fread(fid, 1, 'int32=>double');
central_mass = polyatomique(fid);
reference_mass = polyatomique(fid);
tens_tube = fread(fid, 1, 'double=>double');
max_var_tens_tube = fread(fid, 1, 'double=>double');

defeps_out = struct('central_energy', central_energy, 'field', field, 'central_mass', central_mass, ...
    'reference_mass', reference_mass, 'tens_tube', tens_tube, 'max_var_tens_tube', max_var_tens_tube);

end

function apsecondarynano_out = ap_secondary_nano(fid)

dHVSample = fread(fid, 1, 'double=>double');
%dHVSample=fread(fid,1,'int64=>double');
nESPos = fread(fid, 1, 'int32=>double');
nESTabWidthValues = fread(fid, 10, 'int32=>double');
nESTabHeightValue = fread(fid, 10, 'int32=>double');
nASPos = fread(fid, 1, 'int32=>double');
nASTabWidthValue = fread(fid, 10, 'int32=>double');
nASTabHeightValue = fread(fid, 10, 'int32=>double');
dEnrjSPosValue = fread(fid, 1, 'double=>double');
dEnrjSWidthValue = fread(fid, 1, 'double=>double');

nExSFCPos = fread(fid, 1, 'int32=>double');
nExSFCType = fread(fid, 1, 'int32=>double');
nExSFCTabWidthValue = fread(fid, [2, 5], 'int32=>double');
nExSFCTabHeightValue = fread(fid, [2, 5], 'int32=>double');

nExSEM1Pos = fread(fid, 1, 'int32=>double');
nExSEM1Type = fread(fid, 1, 'int32=>double');
nExSEM1TabWidthValue = fread(fid, [2, 5], 'int32=>double');
nExSEM1TabHeightValue = fread(fid, [2, 5], 'int32=>double');

nExSEM2Pos = fread(fid, 1, 'int32=>double');
nExSEM2Type = fread(fid, 1, 'int32=>double');

nExSEM2TabWidthValue = fread(fid, [2, 5], 'int32=>double');
nExSEM2TabHeightValue = fread(fid, [2, 5], 'int32=>double');

nExSEM3Pos = fread(fid, 1, 'int32=>double');
nExSEM3Type = fread(fid, 1, 'int32=>double');

nExSEM3TabWidthValue = fread(fid, [2, 5], 'int32=>double');
nExSEM3TabHeightValue = fread(fid, [2, 5], 'int32=>double');

nExSEM4Pos = fread(fid, 1, 'int32=>double');
nExSEM4Type = fread(fid, 1, 'int32=>double');

nExSEM4TabWidthValue = fread(fid, [2, 5], 'int32=>double');
nExSEM4TabHeightValue = fread(fid, [2, 5], 'int32=>double');

nExSEM5Pos = fread(fid, 1, 'int32=>double');
nExSEM5Type = fread(fid, 1, 'int32=>double');

nExSEM5TabWidthValue = fread(fid, [2, 5], 'int32=>double');
nExSEM5TabHeightValue = fread(fid, [2, 5], 'int32=>double');


dExSLDWidhtPos = fread(fid, 1, 'double=>double');
dExSLDWidhtValueA = fread(fid, 1, 'double=>double');
dExSLDWidhtValueB = fread(fid, 1, 'double=>double');

dSecondaryFoc = fread(fid, 1, 'double=>double');

pszMultiColChamberPres = fread(fid, 32, 'uint8=>char')';

nFCsPosBackground = fread(fid, 1, 'int32=>double');
nFCsNegBackground = fread(fid, 1, 'int32=>double');

dEM1Yield = fread(fid, 1, 'double=>double');
nEM1Background = fread(fid, 1, 'int32=>double');
nEM1DeadTime = fread(fid, 1, 'int32=>double');


dEM2Yield = fread(fid, 1, 'double=>double');
nEM2Background = fread(fid, 1, 'int32=>double');
nEM2DeadTime = fread(fid, 1, 'int32=>double');


dEM3Yield = fread(fid, 1, 'double=>double');
nEM3Background = fread(fid, 1, 'int32=>double');
nEM3DeadTime = fread(fid, 1, 'int32=>double');

dEM4Yield = fread(fid, 1, 'double=>double');
nEM4Background = fread(fid, 1, 'int32=>double');
nEM4DeadTime = fread(fid, 1, 'int32=>double');

dEM5Yield = fread(fid, 1, 'double=>double');
nEM5Background = fread(fid, 1, 'int32=>double');
nEM5DeadTime = fread(fid, 1, 'int32=>double');

dLDYield = fread(fid, 1, 'double=>double');
nLDBackground = fread(fid, 1, 'int32=>double');
nLDDeadTime = fread(fid, 1, 'int32=>double');

nExSEM4BPos = fread(fid, 1, 'int32=>double');
nExSEM4BType = fread(fid, 1, 'int32=>double');
nExSEM4BTabWidthValue = fread(fid, [2, 5], 'int32=>double');
nExSEM4BTabHeightValue = fread(fid, [2, 5], 'int32=>double');

dEM4BYield = fread(fid, 1, 'double=>double');

nEM4BBackground = fread(fid, 1, 'int32=>double');
nEM4BDeadTime = fread(fid, 1, 'int32=>double');

nUnusedTab = fread(fid, 2, 'int32=>double');

w = whos;
for ii = 1:length(w)
    if ~strcmp(w(ii).name, 'fid') && ~strcmp(w(ii).name, 'ii') && ~strcmp(w(ii).name, 'ans') && ~strcmp(w(ii).name, 'w')
        apsecondarynano_out.(w(ii).name) = eval(w(ii).name);
    end
end

%apsecondarynano_out=struct('dHVSample',dHVSample

end

function analparamnanobis_out = anal_param_nano_bis(fid)
f1 = ftell(fid);
pszNomStruct = fread(fid, 24, 'uint8=>char')';
nExSEM6Pos = fread(fid, 1, 'int32=>double');
nExSEM6Type = fread(fid, 1, 'int32=>double');
nExSEM6TabWidthValue = fread(fid, [2, 5], 'int32=>double');
nExSEM6TabHeightValue = fread(fid, [2, 5], 'int32=>double');
dEM6Yield = fread(fid, 1, 'double=>real*4');
nEM6Background = fread(fid, 1, 'int32=>double');
nEM6DeadTime = fread(fid, 1, 'int32=>double');
nExSEM7Pos = fread(fid, 1, 'int32=>double');
nExSEM7Type = fread(fid, 1, 'int32=>double');
nExSEM7TabWidthValue = fread(fid, [2, 5], 'int32=>double');
nExSEM7TabHeightValue = fread(fid, [2, 5], 'int32=>double');
dEM7Yield = fread(fid, 1, 'double=>real*4');
nEM7Background = fread(fid, 1, 'int32=>double');
nEM7DeadTime = fread(fid, 1, 'int32=>double');
nXlExSEM1TabWidthValue = fread(fid, 5, 'int32=>double');
nXlExSEM1TabHeightValue = fread(fid, 5, 'int32=>double');
nXlExSEM2TabWidthValue = fread(fid, 5, 'int32=>double');
nXlExSEM2TabHeightValue = fread(fid, 5, 'int32=>double');
nXlExSEM3TabWidthValue = fread(fid, 5, 'int32=>double');
nXlExSEM3TabHeightValue = fread(fid, 5, 'int32=>double');
nXlExSEM4TabWidthValue = fread(fid, 5, 'int32=>double');
nXlExSEM4TabHeightValue = fread(fid, 5, 'int32=>double');
nXlExSEM5TabWidthValue = fread(fid, 5, 'int32=>double');
nXlExSEM5TabHeightValue = fread(fid, 5, 'int32=>double');
nXlExSEM6TabWidthValue = fread(fid, 5, 'int32=>double');
nXlExSEM6TabHeightValue = fread(fid, 5, 'int32=>double');
nXlExSEM7TabWidthValue = fread(fid, 5, 'int32=>double');
nXlExSEM7TabHeightValue = fread(fid, 5, 'int32=>double');
PreSputPresetSlit = appresetslit(fid);
PreSputPresetLens = appresetlens(fid);
AcqPresetSlit = appresetslit(fid);
AcqPresetLens = appresetlens(fid);
dEM7Yield = fread(fid, 1, 'double=>real*4');
nEMTICBackground = fread(fid, 1, 'int32=>double');
nEMTICDeadTime = fread(fid, 1, 'int32=>double');
nFC1PosBackground = fread(fid, 1, 'int32=>double');
nFC1NegBackground = fread(fid, 1, 'int32=>double');
nFC2PosBackground = fread(fid, 1, 'int32=>double');
nFC2NegBackground = fread(fid, 1, 'int32=>double');
nFC3PosBackground = fread(fid, 1, 'int32=>double');
nFC3NegBackground = fread(fid, 1, 'int32=>double');
nFC4PosBackground = fread(fid, 1, 'int32=>double');
nFC4NegBackground = fread(fid, 1, 'int32=>double');
nFC5PosBackground = fread(fid, 1, 'int32=>double');
nFC5NegBackground = fread(fid, 1, 'int32=>double');
nFC6PosBackground = fread(fid, 1, 'int32=>double');
nFC6NegBackground = fread(fid, 1, 'int32=>double');
nFC7PosBackground = fread(fid, 1, 'int32=>double');
nFC7NegBackground = fread(fid, 1, 'int32=>double');
nDet1Type = fread(fid, 1, 'int32=>double');
nDet2Type = fread(fid, 1, 'int32=>double');
nDet3Type = fread(fid, 1, 'int32=>double');
nDet4Type = fread(fid, 1, 'int32=>double');
nDet5Type = fread(fid, 1, 'int32=>double');
nDet6Type = fread(fid, 1, 'int32=>double');
nDet7Type = fread(fid, 1, 'int32=>double');
nUnusedTab = fread(fid, 763, 'int32=>double');
f2 = ftell(fid);
%fprintf('anal_param_nano_bis=%d\n',f2-f1);
w = whos;
for ii = 1:length(w)
    if ~strcmp(w(ii).name, 'fid') && ~strcmp(w(ii).name, 'ii') && ~strcmp(w(ii).name, 'ans') && ~strcmp(w(ii).name, 'w')
        analparamnanobis_out.(w(ii).name) = eval(w(ii).name);
    end
end
end

function headerimage_out = header_image(fid)

size_self = fread(fid, 1, 'int32=>double');
type = fread(fid, 1, 'int16=>double');
width = fread(fid, 1, 'int16=>double');
height = fread(fid, 1, 'int16=>double');
pixelsize = fread(fid, 1, 'int16=>double');
numberofimages = fread(fid, 1, 'int16=>double');
numberofplanes = fread(fid, 1, 'int16=>double');
raster = fread(fid, 1, 'int32=>double');
nickname = fread(fid, 64, 'uint8=>char')';

w = whos;
for ii = 1:length(w)
    if ~strcmp(w(ii).name, 'fid') && ~strcmp(w(ii).name, 'ii') && ~strcmp(w(ii).name, 'ans') && ~strcmp(w(ii).name, 'w')
        headerimage_out.(w(ii).name) = eval(w(ii).name);
    end
end

end

function appresetslit_out = appresetslit(fid)

PresetInfo = appresetdef(fid);
for ii = 1:20
    ParamTab(ii) = apparampreset(fid);
end

w = whos;
for ii = 1:length(w)
    if ~strcmp(w(ii).name, 'fid') && ~strcmp(w(ii).name, 'ii') && ~strcmp(w(ii).name, 'ans') && ~strcmp(w(ii).name, 'w')
        appresetslit_out.(w(ii).name) = eval(w(ii).name);
    end
end

end

function appresetdef_out = appresetdef(fid)

szFileName = fread(fid, 256, 'uint8=>char')';
szFilszNameeName = fread(fid, 224, 'uint8=>char')';
szDateCalib = fread(fid, 32, 'uint8=>char')';
nIsSelected = fread(fid, 1, 'int32=>double');
nNbParam = fread(fid, 1, 'int32=>double');

w = whos;
for ii = 1:length(w)
    if ~strcmp(w(ii).name, 'fid') && ~strcmp(w(ii).name, 'ii') && ~strcmp(w(ii).name, 'ans') && ~strcmp(w(ii).name, 'w')
        appresetdef_out.(w(ii).name) = eval(w(ii).name);
    end
end

end

function apparampreset_out = apparampreset(fid)

nId = fread(fid, 1, 'int32=>double');
nValue = fread(fid, 1, 'int32=>double');
szName = fread(fid, 20, 'uint8=>char')';


w = whos;
for ii = 1:length(w)
    if ~strcmp(w(ii).name, 'fid') && ~strcmp(w(ii).name, 'ii') && ~strcmp(w(ii).name, 'ans') && ~strcmp(w(ii).name, 'w')
        apparampreset_out.(w(ii).name) = eval(w(ii).name);
    end
end


end


function appresetlens_out = appresetlens(fid)

PresetInfo = appresetdef(fid);

for ii = 1:150
    ParamTab(ii) = apparampreset(fid);
end


w = whos;
for ii = 1:length(w)
    if ~strcmp(w(ii).name, 'fid') && ~strcmp(w(ii).name, 'ii') && ~strcmp(w(ii).name, 'ans') && ~strcmp(w(ii).name, 'w')
        appresetlens_out.(w(ii).name) = eval(w(ii).name);
    end
end

end

function eosnano_out = eos_nano(fid)

m_nDetId = fread(fid, 1, 'int32=>double');
m_nStartDac = fread(fid, 1, 'int32=>double');
m_nDacStep = fread(fid, 1, 'int32=>double');
m_nE0SCentCountTime = fread(fid, 1, 'int32=>double');
m_dStartValue = fread(fid, 1, 'double=>double');
m_d80PerCentWidth = fread(fid, 1, 'double=>double');


w = whos;
for ii = 1:length(w)
    if ~strcmp(w(ii).name, 'fid') && ~strcmp(w(ii).name, 'ii') && ~strcmp(w(ii).name, 'ans') && ~strcmp(w(ii).name, 'w')
        eosnano_out.(w(ii).name) = eval(w(ii).name);
    end
end

end
