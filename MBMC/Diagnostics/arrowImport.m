function arrows = arrowImport()
arrows = repmat({uint8(zeros(16))}, [3 3]);
arrows{1} = imread('arrow_nw.png');
arrows{2} = imread('arrow_w.png');
arrows{3} = imread('arrow_sw.png');
arrows{4} = imread('arrow_n.png');
arrows{6} = imread('arrow_s.png');
arrows{7} = imread('arrow_ne.png');
arrows{8} = imread('arrow_e.png');
arrows{9} = imread('arrow_se.png');

for arrow = 1:numel(arrows)
    arrowNormalised = arrows{arrow};
    arrowNormalised(arrowNormalised > 0) = 255;
    arrows{arrow} = arrowNormalised;
end
end