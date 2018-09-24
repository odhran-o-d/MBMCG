function display = makeOccupancyGrid(occupancy_cell, display_figure, fig_title)
if iscell(occupancy_cell{1})
    display = zeros(size(makeOccupancyGrid(occupancy_cell{1}, false)));
else
    display = zeros(size(occupancy_cell{1}));
end

for i = 1:length(occupancy_cell)
    if iscell(occupancy_cell{i})
        display = display + makeOccupancyGrid(occupancy_cell{i}, false);
    else
        display = display + occupancy_cell{i};
    end
end
display = display / length(occupancy_cell);
if display_figure == true
    figure(); imagesc(display,[0 1]); colormap('gray'); colorbar;
end
if exist('fig_title', 'var')
    title(fig_title)
end
end