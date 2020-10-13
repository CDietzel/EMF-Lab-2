%Code by Charles Dietzel
%EGRE 309, Lab 2
clear variables globals;

%=========================================================================
% ALTER THE FOLLOWING VARIABLES TO DEFINE THE PARAMETERS OF THE SIMULATION
a = 5;%radius of the conducting rods
d = 10;%distance from the center of the conducting rods to the y axis
l = 50;%length of the simulation matrix
h = 50;%height of the simulation matrix
V = 1;%voltage of the conducting rods
numiter = 10000;%number of iterations of the finite difference method
%=========================================================================

zeromatrix = zeros(l, h);%create matrix of zeros of size lxh
fixednodesmask = zeromatrix;
fixednodesmask(1,:) = 1;
fixednodesmask(end,:) = 1;
fixednodesmask(:,1) = 1;
fixednodesmask(:,end) = 1;%define the border of the simulation as "fixed"
%so what the next few lines of code do is they pretty much check to see if
%any particular location in the matrix is inside one of the two conducting
%rods, and if it is, it sets that location to a value of 1.
[cols, rows] = meshgrid(1:l, 1:h);
circle1x = (l/2)-d;%defines the x position of the conducting rods
circle2x = (l/2)+d;
circle1y = h/2;%defines the y position of the conducting rods
circle2y = h/2;
circle1 = (rows - circle1y).^2 + (cols - circle1x).^2 <= a.^2;
circle2 = (rows - circle2y).^2 + (cols - circle2x).^2 <= a.^2;
%this line defines the two charged rods as "fixed"
fixednodesmask = fixednodesmask | circle1 | circle2;
%the next few lines apply the desired voltage to each conducting rod and
%then store those "fixed" voltage values in fixednodes
circle1 = circle1.*-V;
circle2 = circle2.*V;
fixednodes = circle1+circle2;
%defines equation 15.16 on the textbook
laplacefilter = [0 0.25 0; 0.25 0 0.25; 0 0.25 0];
%sets the initial state of the potentials field to the "fixed" voltage
%values we found earlier, with the conducting rods having voltge of
%positive/negative V, and the border of the simulation area having voltage
%of 0.
potentials = fixednodes;
oldpotentials = zeromatrix;
while max(max(abs(potentials-oldpotentials))) > 0.001
    oldpotentials = potentials;
    %continuously applies equation 15.16 to the matrix of potentials, and
    %then reapplies the "fixed" voltages afterwards to make sure that the
    %specified voltage conditions are maintained. Repeats this process
    %numiter times. 
    potentials = imfilter(potentials, laplacefilter);
    potentials(fixednodesmask) = 0;
    potentials = potentials + fixednodes;
end

[ex, ey] = gradient(-potentials);
[gradmag, graddir] = imgradient(-potentials);
potentialcutline = potentials(h/2, :);
electriccutline = gradmag(h/2, :);

figure;
contour(potentials);
%imagesc(potentials);
hold on;
quiver(ex, ey);
hold off;
c = colorbar;%adds color legend
c.Label.String = 'Potential (V)';
title('Simulated Potential/Electric Field')
xlabel('X Position');
ylabel('Y Position');
figure;
plot(potentialcutline);
hold on;
title('Cutline of Potential Field Along X-Axis');
ylabel('Potential Magnitude (V)');
xlabel('X Position');
figure;
plot(electriccutline);
hold on;
title('Cutline of Electric Field Magnitude Along X-Axis');
ylabel('Electric Field Magnitude (V)');
xlabel('X Position');