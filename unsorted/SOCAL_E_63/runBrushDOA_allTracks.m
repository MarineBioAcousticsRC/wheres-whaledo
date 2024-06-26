d = dir('D:\SOCAL_E_63\tracking\interns2022\allTracks\*.mat');
saveDir = 'D:\SOCAL_E_63\tracking\interns2022\ericEdits_allTracks';
for nd = 64:numel(d)
    load(fullfile(d(nd).folder, d(nd).name));
    pstr = ['\n', d(nd).name, '\n'];
    fprintf(pstr, 'interpreter', 'none')

    [DET{1}, DET{2}] = brushDOA(DET{1}, DET{2}, 'D:\MATLAB_addons\gitHub\wheresWhaledo\brushing.params');
    
    % is track worth saving?
    str = input('Save track? y/n:', 's')
    if strcmp(str, 'n')||strcmp(str, 'N')
        continue % track isn't worth saving, continue to next iteration
    end

    % does DOA need to be reversed?
    str = input('Reverse DOA? y/n:', 's')

    %% DELETE IF YOUR DOA IS ALREADY OK:
    if strcmp(str, 'y')||strcmp(str, 'Y')
        DET{1}.DOA = -DET{1}.DOA;
        DET{2}.DOA = -DET{2}.DOA;

        DET{1}.Ang = [DET{1}.Ang(:, 1)-180, 180-DET{1}.Ang(:, 2)] ;
        DET{2}.Ang = [DET{2}.Ang(:, 1)-180, 180-DET{2}.Ang(:, 2)] ;
        
        DET{1}.Ang(DET{1}.Ang(:,1)<0) = DET{1}.Ang(DET{1}.Ang(:,1)<0) + 360;
        DET{2}.Ang(DET{2}.Ang(:,1)<0) = DET{2}.Ang(DET{2}.Ang(:,1)<0) + 360;
    end
    
    [DET{1}, DET{2}] = brushDOA(DET{1}, DET{2}, 'D:\MATLAB_addons\gitHub\wheresWhaledo\brushing_laptop.params');

    %%
    
    Itrack = strfind(d(nd).name, 'track');
    Imod = strfind(d(nd).name, 'mod');
    newFolderName = d(nd).name(Itrack:Imod-2);
    newDir = fullfile(saveDir, newFolderName);

    mkdir(newDir)
    
    fpn = fullfile(newDir, [d(nd).name(1:Imod-1), 'ericMod']);

    fig = findall(0, 'Type', 'figure', 'name', 'Brush DOA');

    saveas(fig, [fpn, '_brushDOA'], 'fig')
    saveas(fig, [fpn, '_brushDOA'], 'jpg')

    save(fpn, 'DET')


    
end