function synapses = gaussian_synapses(cells, radius, synapse_weights)

% Connects each cell to its neighbours in an approximately gaussian fashion, with the
% radius of the connection determined by the appropriate variable. Does not
% wrap.

rows = size(cells,1);
col = size(cells,2);

initial_radius = radius;

synapses = nan(numel(cells));

for presynaptic_cell = 1:numel(cells)
    
    if presynaptic_cell == round(numel(cells)/4)
        disp('...')
    elseif presynaptic_cell == round(numel(cells)/2)
        disp('...')
    elseif presynaptic_cell == round(3*numel(cells)/4)
        disp('...')
    end
    
    radius = initial_radius;
    
    while radius >=1
        
        w = presynaptic_cell-(radius*rows); n = presynaptic_cell-radius; s = presynaptic_cell+radius; e = presynaptic_cell+(radius*rows);
        nw = w-radius; sw = w+radius; ne = e-radius; se = e+radius;
        
        %
        if any(mod(presynaptic_cell-1:-1:(presynaptic_cell - radius), rows) == 0)
            ring = [(ne+radius-mod(presynaptic_cell-1, rows)):se, sw:rows:se, (nw+radius-mod(presynaptic_cell-1, rows)):sw];
            nw = 0; n = 0; ne = 0;
        elseif any(mod(presynaptic_cell:(presynaptic_cell+radius-1), rows) == 0)
            ring = [nw:rows:ne, ne:(se-mod(presynaptic_cell+radius, rows)), nw:(sw-mod(presynaptic_cell+radius, rows))];
            se = 0; s = 0; sw = 0;
        else
            ring = [nw:rows:ne, ne:se, sw:rows:se, nw:sw];
        end
        
        
        ring = unique(ring);
        ring = ring(ring>=1);
        ring = ring(ring <= numel(cells));
        
        for count = 1:numel(ring)
        try
            synapses(presynaptic_cell,ring(count)) = synapse_weights/radius;
        end
        end
        
        radius = radius - 1;
        
    end
    
end

% Need to alter so doesn't wrap -- something along lines of

%{

if cell too close to top

    set nw, n, ne to 0

elseif cell too close to bottom

    set sw, s, se to 0

end

Could do something similar for walls?

%}