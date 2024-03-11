
% 
% for i=1:1:numel(DataB)
% 
%     Testx(i) = DataB(i);
%     Testx(i) =round(Testx,2); % rounds to 2 decimal places
% end
% 
% plot(Testx);

%Testx = round(DataB, 2); % Round DataB to 2 decimal places

% plot(linspace(1,1200,1200),Testx);
% ylim([-650,-550]);

%works 

Testx = rmoutliers(DataB);
plot(Testx);