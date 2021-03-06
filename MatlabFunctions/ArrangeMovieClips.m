
%======================== ArrangeMovieClips.m =============================
% This script transfers recently shot movie clips from an SD card to
% Nifstorage, and sorts them by camera position, time and duration in order
% to establish correspondence between clips from different cameras.
%
%==========================================================================
% 
% MovieFormat = '.mov';
% if ismac
%     Prefix = '/Volumes';
% else
%     Prefix = [];
% end
% SessionDir  = fullfile(Prefix, '/rawdata/murphya/Video/TEST/20180730');
% SessionFile = fullfile(SessionDir, 'AllData.mat');
% 
% %================ Identify corresponding clips from different cameras
% SDdir       = regexpdir(SessionDir, 'SX230_*', 0);
% SDdir       = SDdir(~cellfun(@isempty, SDdir));
% CamColor    = {[1,0,0],[0,1,0],[0,0,1],[0,1,1],[1,1,0]};
% fh1         = figure('position', get(0, 'screensize'));
% axh         = subplot(1,2,1);
% for cam = 1:numel(SDdir)
%     AllMovs   = wildcardsearch(SDdir{cam}, ['*',MovieFormat]);
%     AllMovs   = AllMovs(cellfun(@isempty, strfind(AllMovs, 'Trash')));
%     AllMovs   = AllMovs(cellfun(@isempty, strfind(AllMovs, '._')));
%     for m = 1:numel(AllMovs)
%         Mov(cam, m).Filename    = AllMovs{m};
%         Mov(cam, m).FileInfo    = dir(AllMovs{m});
%         ph(cam, m) = plot(Mov(cam, m).FileInfo.datenum, Mov(cam, m).FileInfo.bytes/10^6, '.k', 'markersize', 20, 'color', CamColor{cam}); 
%         hold on;
%     end
% end
% grid on;
% box off;
% xlabel('Time','fontsize', 16);
% ismac
% ylabel('File size (MB)','fontsize', 16);
% legend(ph(:,1), 'Cam 1', 'Cam 2', 'Cam 3', 'Cam 4', 'Cam 5');
% [~,SessionName] = fileparts(SessionDir);
% title(SessionName, 'fontsize', 18);
% 
% %================ Calculate pairwise euclidean distances
% SizeDiff = nan(numel(Mov), numel(Mov));
% TimeDiff = nan(numel(Mov), numel(Mov));
% 
% for clip1 = 1:numel(Mov)
%     for clip2 = 1:numel(Mov)
%         if ~isempty(Mov(clip1).Filename) && ~isempty(Mov(clip2).Filename)
%             SizeDiff(clip1, clip2) = abs(Mov(clip1).FileInfo.bytes - Mov(clip2).FileInfo.bytes)/10^6;
%             TimeDiff(clip1, clip2) = abs(Mov(clip1).FileInfo.datenum - Mov(clip2).FileInfo.datenum);
%         end
%     end
% end
% axh1(1)     = subplot(2,2,2);
% imh(1)      = imagesc(SizeDiff);
% Mask        = ~isnan(SizeDiff);
% Mask(1:(numel(Mov)+1):end) = 0;
% alpha(imh(1), double(Mask));
% axis equal tight;
% ylabel('Clip number','fontsize', 16);
% cbh(1)      = colorbar;
% %set(cbh(1), 'string', 'File size diff (MB)');
% set(axh1(1), 'clim', [0 20], 'color', [0,0,0]);
% colormap cool;
% 
% axh1(2)     = subplot(2,2,4);
% imh(2)      = imagesc(TimeDiff);
% Mask        = ~isnan(TimeDiff);
% Mask(1:(numel(Mov)+1):end) = 0;
% alpha(imh(2), double(Mask));
% axis equal tight;
% hold on;
% % for cam = 1:size(Mov,1)
% %     lh(cam, 1) = plot( );
% %     lh(cam, 2) = plot( );
% % end
% xlabel('Clip number','fontsize', 16);
% ylabel('Clip number','fontsize', 16);
% cbh(2)      = colorbar;
% %set(cbh(2), 'string', 'System time (s)');
% set(axh1(1), 'color', [0,0,0]);
% 
% 
% %================ Load and process corresponding clips
% wbh = waitbar(0);
% m = 1;
% for cam = 1:size(Mov,1)
%     waitbar(m/numel(AllMovs), wbh, sprintf('Loading clip %s from camera %d (of %d)...', Mov(cam, m).Filename, cam, size(Mov,1)));
% 
% 	%=========== Read video data
%     video = VideoReader(Mov(cam, m).Filename);
%     f = 1;
%     while f < 3 % hasFrame(video)
%         waitbar(m/numel(AllMovs), wbh, sprintf('Saving frames from %s (%d/%d)...', video.name, f, round(video.Duration*video.FrameRate)));
%         Mov(cam, m).Frame(f).cdata = readFrame(video);
%         f = f+1;
%     end
%     [y,Fs] = audioread(Mov(cam, m).Filename);
% 
%     %=========== Save data to structure
%     [~,Mov(cam, m).Camera]  = fileparts(Mov(cam, m).FileInfo.folder);
%     Mov(cam, m).Name        = video.Name;
%     Mov(cam, m).Audio       = y;
%     Mov(cam, m).Fs          = Fs;
%     Mov(cam, m).NoFrames    = f-1;
%     Mov(cam, m).Duration    = video.Duration;
%     Mov(cam, m).FrameRate   = video.FrameRate;
%     Mov(cam, m).Resolution  = [video.Width, video.Height];
% 
%     %save(SessionFile, 'Mov','-v7.3');
% end
% 
% 
% %=========== Caclulate lag between camera audio
% for cam = 1%:size(Mov,1)
%     [acor,lag] = xcorr(Mov(cam, 1).Audio(:,1), Mov(cam+1, 1).Audio(:,1));
%     [~,I]       = max(abs(acor));
%     LagSamp     = lag(I);
%     LagSec      = LagSamp/Mov(cam, 1).Fs;
%     LagFrames   = LagSec*Mov(cam, m).FrameRate;
%     
% end
%     


%% ================== Open GUI for editing of clips =======================
Fig.NoRows 	= 3;
Fig.fh      = figure('position', get(0,'Screensize'),'name','Process Clips');
% Fig.axh     = tight_subplot(Fig.NoRows, size(Mov,1), 0.04, 0.04, 0.04);

DefaultCropFrame    = [1, 1, 1000, 1000];

Fig.LabelWidths     = [0, 100, 200, 100];
Fig.LabelHeight     = 20;

for cam = 1:size(Mov,1)
    
    %=========== Set menu labels
    Fig.Labels{1}{cam}	= sprintf('Cam %d', cam);
    Fig.Labels{2}{cam}  = {Mov(cam,:).Name};
    Fig.Labels{3}{cam}  = 1;
    Cam(cam).CurrentFrame = 1;

    %=========== Plot original current frame
    Fig.axh(cam)    = subplot(3, size(Mov,1), cam);
    Fig.imh(cam,1) = image(Mov(cam, m).Frame(Cam(cam).CurrentFrame).cdata);
    axis tight equal;
    grid on;
    Fig.imr(cam) = imrect(Fig.axh(cam), DefaultCropFrame);
    Fig.imr(cam).setColor(CamColor{cam});
    fcn = makeConstrainToRectFcn('imrect',get(Fig.axh(cam),'XLim'),get(Fig.axh(cam),'YLim'));   % Limit crop rectange to within axes limits
    setPositionConstraintFcn(Fig.imr(cam), fcn);
    set(Fig.axh(cam), 'units', 'pixels');
%   	FrameAxPos  = get(Fig.axh(cam),'position');
%     set(Fig.axh(cam),'position', FrameAxPos - [0, 200, 0, 0]);

    %=========== Add GUI elements
    for l = 1:numel(Fig.Labels)
        set(Fig.axh(cam), 'units', 'pixels');
        FrameAxPos  = get(Fig.axh(cam),'position');
        UIpos       = [FrameAxPos(1)+sum(Fig.LabelWidths(1:l)), FrameAxPos(2)+FrameAxPos(4), Fig.LabelWidths(l+1), Fig.LabelHeight]; 
        Fig.Ui(cam,l) = uicontrol('style','popup','string', Fig.Labels{l}{cam},'value',1,'position',UIpos);
    end
    
    %=========== Plot audio timeline
    AxIndx = cam + size(Mov,1);
    Fig.axh(AxIndx) = subplot(3, size(Mov,1), AxIndx);
    AudioTs = linspace(0, size(Mov(cam, m).Audio, 1)/Mov(cam, m).Fs, size(Mov(cam, m).Audio, 1));
    Fig.audplh(cam)  = plot(AudioTs, Mov(cam, m).Audio(:,1), '-k');
    hold on;
    Fig.flh(cam)    = plot([0,0], ylim, '-r', 'linewidth',2, 'color', CamColor{cam});
    grid on;
    box off;
    axis tight
    xlabel('Time (s)', 'fontsize', 16);
    set(Fig.axh(AxIndx), 'XColor', 'b', 'position', get(Fig.axh(cam + 3),'Position').*[1,1,1,0.3]);
    Fig.Ax2(cam) = axes('Position', get(Fig.axh(AxIndx),'Position'), 'XAxisLocation', 'top', 'Ytick', [], 'Color', 'none');
    set(Fig.Ax2(cam), 'xlim', [0, Mov(cam, m).NoFrames]);
    xlabel('Time (frames', 'fontsize', 16);
    
  	%=========== Plot cropped region
    AxIndx = cam + size(Mov,1)*2;
    axes(Fig.axh(AxIndx));
    Fig.imh(cam,2) = image(Mov(cam, m).Frame(Cam(cam).CurrentFrame).cdata(DefaultCropFrame(2):DefaultCropFrame(4), DefaultCropFrame(1):DefaultCropFrame(3), :));
    axis equal tight;
    addNewPositionCallback(Fig.imr(cam), @(pos) set(Fig.imh(cam,2), 'cdata', Mov(cam, m).Frame(Frame).cdata(round(pos(2)+(1:pos(3))), round(pos(1)+(1:pos(4))), :)));
    set(Fig.axh(AxIndx), 'xticklabel',[], 'yticklabel',[]);
    grid on;
    
end


    