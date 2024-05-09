hyd1a = load('D:\SOCAL_E_63\tracking\experiments\inverseProblem\matfiles\SOCAL_E_63_EE_Hmatrix_fromHydLocInversion_210702.mat');
hyd1b = load('D:\MATLAB_addons\gitHub\wheresWhaledo\receiverPositionInversion\SOCAL_E_63_EE_Hmatrix_new.mat');
% hyd1.hydPos = hyd1.recPos;
hyd2a = load('D:\SOCAL_E_63\tracking\experiments\inverseProblem\matfiles\SOCAL_E_63_EW_Hmatrix_fromHydLocInversion_210702.mat');
hyd2b = load('D:\MATLAB_addons\gitHub\wheresWhaledo\receiverPositionInversion\SOCAL_E_63_EW_Hmatrix_new.mat');

% Reorder hydrophones to fit new TDOA order
H1{1} = [hyd1a.hydPos(2,:)-hyd1a.hydPos(1,:);
    hyd1a.hydPos(3,:)-hyd1a.hydPos(1,:);
    hyd1a.hydPos(4,:)-hyd1a.hydPos(1,:);
    hyd1a.hydPos(3,:)-hyd1a.hydPos(2,:);
    hyd1a.hydPos(4,:)-hyd1a.hydPos(2,:);
    hyd1a.hydPos(4,:)-hyd1a.hydPos(3,:)];

H2{1} = [hyd2a.hydPos(2,:)-hyd2a.hydPos(1,:);
    hyd2a.hydPos(3,:)-hyd2a.hydPos(1,:);
    hyd2a.hydPos(4,:)-hyd2a.hydPos(1,:);
    hyd2a.hydPos(3,:)-hyd2a.hydPos(2,:);
    hyd2a.hydPos(4,:)-hyd2a.hydPos(2,:);
    hyd2a.hydPos(4,:)-hyd2a.hydPos(3,:)];

% hyd1b.hydPos = hyd1b.recPos;
% H1{2} = [hyd1b.hydPos(2,:)-hyd1b.hydPos(1,:);
%     hyd1b.hydPos(3,:)-hyd1b.hydPos(1,:);
%     hyd1b.hydPos(4,:)-hyd1b.hydPos(1,:);
%     hyd1b.hydPos(3,:)-hyd1b.hydPos(2,:);
%     hyd1b.hydPos(4,:)-hyd1b.hydPos(2,:);
%     hyd1b.hydPos(4,:)-hyd1b.hydPos(3,:)];
% 
% H2{2} = [hyd2b.hydPos(2,:)-hyd2b.hydPos(1,:);
%     hyd2b.hydPos(3,:)-hyd2b.hydPos(1,:);
%     hyd2b.hydPos(4,:)-hyd2b.hydPos(1,:);
%     hyd2b.hydPos(3,:)-hyd2b.hydPos(2,:);
%     hyd2b.hydPos(4,:)-hyd2b.hydPos(2,:);
%     hyd2b.hydPos(4,:)-hyd2b.hydPos(3,:)];

% add error:
% stdev = 0.1;
% H1{2} = H1{1} + randn(size(H1{1})).*stdev;
% H2{2} = H2{1} + randn(size(H2{1})).*stdev;

DCM1=dcmfromeuler(0*pi/180,0*pi/180,3*pi/180,'rpy')
DCM2=dcmfromeuler(-0*pi/180,-0*pi/180,-3*pi/180,'rpy')

H1{2} = H1{1}*DCM1;
% H1{2}(1:3, 3) = H1{2}(1:3, 3) + 0.1;
H2{2} = H2{1}*DCM2;
% H2{2}(1:3, 3) = H2{2}(1:3, 3) + 0.1;

% load drift:
load('D:\SOCAL_E_63\tracking\experiments\clockSync\drift.mat');
dp{1} = coeffvalues(Dpoly{1}); % drift coefficients between inst 1 and 2
dp{2} = coeffvalues(Dpoly{2}); % drift coefficients between inst 1 and 3
dp{3} = coeffvalues(Dpoly{3}); % drift coefficients between inst 1 and 4
dp{4} = coeffvalues(Dpoly{4}); % drift coefficients between inst 2 and 3
dp{5} = coeffvalues(Dpoly{5}); % drift coefficients between inst 2 and 4
dp{6} = coeffvalues(Dpoly{6}); % drift coefficients between inst 3 and 4

c = 1488.4;

load('D:\SOCAL_E_63\xwavTables\instrumentLocs.mat')
hydLoc{1} = hLatLonZ(1,:);
hydLoc{2} = hLatLonZ(2,:);
hydLoc{3} = hLatLonZ(3,:);
hydLoc{4} = hLatLonZ(4,:);

h0 = mean([hydLoc{1}; hydLoc{2}]);

% convert hydrophone locations to meters:
[h1(1), h1(2)] = latlon2xy_wgs84(hydLoc{1}(1), hydLoc{1}(2), h0(1), h0(2));
h1(3) = abs(h0(3))-abs(hydLoc{1}(3));

[h2(1), h2(2)] = latlon2xy_wgs84(hydLoc{2}(1), hydLoc{2}(2), h0(1), h0(2));
h2(3) = abs(h0(3))-abs(hydLoc{2}(3));

[h3(1), h3(2)] = latlon2xy_wgs84(hydLoc{3}(1), hydLoc{3}(2), h0(1), h0(2));
h3(3) = abs(h0(3))-abs(hydLoc{3}(3));

[h4(1), h4(2)] = latlon2xy_wgs84(hydLoc{4}(1), hydLoc{4}(2), h0(1), h0(2));
h4(3) = abs(h0(3))-abs(hydLoc{4}(3));

hloc = [h1;h2;h3;h4];
hloc(:,3) = hloc(:,3) + [6, 6, 10, 10].';

%%
xv = linspace(-400, 200, 61);
yv = linspace(-1500, 150, 83);
zv = linspace(0, 300, 61);
[MOD{1}.TDOA, MOD{1}.wloc] = makeModel(xv, yv, zv, hloc, H1{1}, H2{1}, c);
[MOD{2}.TDOA, MOD{2}.wloc] = makeModel(xv, yv, zv, hloc, H1{2}, H2{1}, 1470);
[MOD{3}.TDOA, MOD{3}.wloc] = makeModel(xv, yv, zv, hloc, H1{1}, H2{2}, 1480);
[MOD{4}.TDOA, MOD{4}.wloc] = makeModel(xv, yv, zv, hloc, H1{2}, H2{2}, 1500);

%%
load('D:\SOCAL_E_63\tracking\interns2022\ericEdits_allTracks\track600_180611_110414\SOCAL_E_63_track600_180611_110414_ericMod_localized.mat')
wn = 1;
Iuse = find(sum(~isnan(whale{wn}.TDOA), 2)>=12);

global LOC
loadParams('localize.params')

sig2sml = LOC.sig_sml^2; % variance of small ap
sig2lrg = LOC.sig_lrg^2; % variance of large ap
Asml = (2*pi*sig2sml)^(-length(12)/2); % coefficient of small ap

for i = 1:length(Iuse)
    TDOA = whale{wn}.TDOA(Iuse(i), :);
    for mi = 1:numel(MOD)
        Lsml = Asml*exp(-1./(2.*sig2sml).*sum((MOD{mi}.TDOA(:,1:12)-TDOA(1:12)).^2, 2));
        [Lmax, Imax] = max(Lsml);

        WLOC{mi}(i, :) = MOD{mi}.wloc(Imax, :);
        LBest{mi}(i) = Lmax;
    end

end

%%
tstr{1} = 'x (m)';
tstr{2} = 'y (m)';
tstr{3} = 'z (m)';
figure(1)
for sp = 1:3
    subplot(3,1,sp)
    for mi = 1:numel(WLOC)
        scatter(whale{wn}.TDet(Iuse), WLOC{mi}(:,sp), LBest{mi}/10)
        hold on
        
    end
    datetick
    hold off
    grid on
    ylabel(tstr{sp})
end
legend('T1-T2', 'T1-E2', 'E1-T2', 'E1-E2')
sgtitle(['Erroneous array rotation, \pm3^\circ'])