function mapa=r_multi_v_cwt(c)

% estimating probability maps - free parameters:
%
% map calculation:
% MP, SP
% energy scale: log, sqrt, linear
% probability assesment:
% 1. pseudo-T distribution from reference period only
% 2. permutation test for each point
% Correction for multiple comparisons:
% FDR, BH - stepdown Benferoni, NONE_STATS, FULL_BONFERRONI, BY_COLUMN


if nargin==0
    disp('Set the config');
end

switch c.OUTPUT_TYPE
    case 'MEAN_MAP'% Display map of mean energy distribution
        switch c.MAX_RES
            case 0,
                mm=CalculateMapsOfEnargyDensity(c,0);
                mapa=mean_map(mm,c);
            case 1,
                mapa=CalculateMapsOfEnargyDensity(c,1);
        end
    case 'ERD_ERS' % Display raw map of ERD/ERS
        mapa=CalculateRawMapOf_ERD_ERS(c);
    case 'ACCEPTED'% Display map of accepted ERD/ERS
        mapa=CalculateMapOfAccepted_ERD_ERS(c);
end

