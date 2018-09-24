idx = find(chunk_cells == max(chunk_cells));
idx = find(b(2,:) > 0.0000003);
for count = idx
SAdecoded(find(SAdecoded(:,3) == count),:)
end

77
31
174
194
2
154
