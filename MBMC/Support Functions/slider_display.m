function slider_display(array, ROI, scale)

%% Creates a figure with a set of matrix plots and a slider to move between them. Highights the ROI, if one exists.
% ROI must be an array with four values: [topleft, topright, x, y]

figure()

if scale == true
    hplot = imagesc(array{1}); colormap('gray');
else
    hplot = image(array{1}); colormap('gray');
end

if ~isempty(ROI)
    rectangle('Position',ROI, 'LineWidth',2,'EdgeColor','y')
end

h = uicontrol('style','slider', 'Value', 1, 'Min', 1, 'Max', size(array,2), 'units', 'pixels', 'SliderStep', [1/size(array,2), 1/size(array,2)], 'position',[20 20 300 20]);
addlistener(h,'ContinuousValueChange',@(hObject, event) makeplot(hObject, event, array,hplot));

function makeplot(hObject,event,cellfromarray, hplot)
n = get(hObject,'Value');
set(hplot,'CData',cellfromarray{round(n)});
drawnow;



% PRESERVED
%{
function world_display(world1,world2,world3,world4,world5)
worlds = {world1(:,:,1), world2(:,:,1), world3(:,:,1), world4(:,:,1), world5(:,:,1)};
hplot = imagesc(world1(:,:,1));
h = uicontrol('style','slider', 'Value', 1, 'Min', 1, 'Max', 5, 'units', 'pixels', 'SliderStep', [1/5, 1/5], 'position',[20 20 300 20]);
addlistener(h,'ContinuousValueChange',@(hObject, event) makeplot(hObject, event, worlds,hplot));

function makeplot(hObject,event,worlds, hplot)
n = get(hObject,'Value');
set(hplot,'CData',worlds{round(n)});
drawnow;

%}