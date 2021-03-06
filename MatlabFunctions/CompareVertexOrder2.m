

MeshDir     = '/Volumes/Kastner/aidan/MacaqueExpressions/ExpressionTransfer/';
NeutralMesh = fullfile(MeshDir, 'BaseModelExpressions', 'M02_Neutral.obj');
ExpMesh     = fullfile(MeshDir, 'BaseModelExpressions', 'M02_Fear.obj');
TargetMesh  = fullfile(MeshDir, 'IdentityExamples', 'Average_Neutral.obj');
MeshFiles   = {NeutralMesh, ExpMesh, TargetMesh};

EdgeColor       = 'none';
Backface        = 'reverselit';
Ambient         = 0.3;                         	% Ambient light strength          
Diffuse         = 0.6;                      	% Diffuse light strength
Specular        = 0.1;                         	% Specular light strength 
SpecExp         = 2;                           	% Specular reflection exponent 
SpecCol         = 1;                          	% Specular light color

for m = 1:3
    OldObj              = LoadOBJFile(MeshFiles{m});
    [~,MeshName]        = fileparts(MeshFiles{m});
    fprintf('Loading mesh %s...\n', MeshName);
    NewObj(m).faces        = OldObj{1}.faces'+1;                          % Copy target object's face indices
    NewObj(m).vertices     = OldObj{1}.vertices';                        % Copy edited object's vertices, and reorder them
    NewObjN(m).texcoords    = OldObj{1}.texcoords;                   % Copy target objects' texture coords
    NewObjN(m).normals      = OldObj{1}.normals;
end

%========== Plot mesh to figure
fh = figure('position',get(0,'screensize'));
axh(1) = subplot(1,2,1);
m = 1;
ph(m)   = patch(NewObj(m), 'facecolor', [1,1,1]/2, 'edgecolor','none', 'facealpha', 0.5);
hold on;
sn  = quiver3(NewObj(m).vertices(:,1), NewObj(m).vertices(:,2),NewObj(m).vertices(:,3),NewObjN(m).normals(1,:)',NewObjN(m).normals(2,:)',NewObjN(m).normals(3,:)');
np  = plot3(NewObj(2).vertices(:,1), NewObj(2).vertices(:,2),NewObj(2).vertices(:,3), '.r');

axis vis3d tight;
daspect([1,1,1]);
material([Ambient Diffuse Specular SpecExp SpecCol]);                   	% Set material properties
%shading interp
lh(m,1) = camlight('headlight');                                          % Add headlight at camera position
lh(m,2) = light('Position',[-1 0 5],'Style','infinite');                  % Add 
grid on
xlabel('X')
ylabel('Y')
zlabel('Z')
    
title('Fear expression', 'fontsize', 18);
cbh                 = colorbar;
cbh.Label.String    = 'Dispalcement (mm)';
cbh.Label.FontSize  = 18;
cbh.Position        = cbh.Position + [0.05,0,0,0];


%====== Calculate dispalcement
Diff = NewObj(1).vertices - NewObj(2).vertices;
Disp = sqrt(Diff(:,1).^2+Diff(:,2).^2+Diff(:,3).^2);
set(ph(m), 'FaceVertexCData', Disp);
shading interp;

%=========== Plot selected vertex tranform
VertIndx    = 13210;
FaceIndices = find(any(NewObj(1).faces == VertIndx, 2));
for c = 1:3
    DispXYZ{c} =  [NewObj(1).vertices(VertIndx,c), NewObj(2).vertices(VertIndx,c)];
    NormXYZ{c} =  [NewObj(1).vertices(VertIndx,c), NewObjN(1).normals(c, VertIndx)];
end

for ax = 1:2
    if ax==2
        axh(2) =subplot(1,2,2);
    end
    plot3(DispXYZ{1}, DispXYZ{2}, DispXYZ{3}, '.-b', 'markersize', 30);         
    hold on;
    plot3(DispXYZ{1}(2), DispXYZ{2}(2), DispXYZ{3}(2), '.r', 'markersize', 30); % Plot expression vert position in RED
    quiver3(NewObj(m).vertices(VertIndx,1), NewObj(m).vertices(VertIndx,2),NewObj(m).vertices(VertIndx,3),NewObjN(m).normals(1,VertIndx),NewObjN(m).normals(2,VertIndx),NewObjN(m).normals(3,VertIndx));
    %plot3(NormXYZ{1}, NormXYZ{2}, NormXYZ{3}, '.-c', 'markersize', 30);         % Plot original vertex NORMAL in CYAN
end
grid on
xlabel('X')
ylabel('Y')
zlabel('Z')
for f = 1:numel(FaceIndices)
    VertIndices = NewObj(1).faces(FaceIndices(f),:);
    if f == 1
        plot3(NewObj(1).vertices(VertIndices(1), 1),NewObj(1).vertices(VertIndices(1), 2),NewObj(1).vertices(VertIndices(1), 3), '.c');
        plot3(NewObj(2).vertices(VertIndices(1), 1),NewObj(2).vertices(VertIndices(1), 2),NewObj(2).vertices(VertIndices(1), 3), '.r');
    end
    patch('faces',[1,2,3,4],'vertices', NewObj(1).vertices(VertIndices, :), 'facecolor', 'none', 'edgecolor', [0,1,1]);
    patch('faces',[1,2,3,4],'vertices', NewObj(2).vertices(VertIndices, :), 'facecolor', 'none', 'edgecolor', [1,0,0]);
end
axis equal tight

%linkprop(axh, {'CameraUpVector', 'CameraPosition', 'CameraTarget', 'XLim', 'YLim', 'ZLim'});

