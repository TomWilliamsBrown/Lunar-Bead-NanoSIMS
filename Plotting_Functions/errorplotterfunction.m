function errorplotterfunction(element, error, colour, label, ncycles, beadlabel, marker)

if (~exist('marker', 'var'))
        marker = '-o';
end

e = errorbar(1:ncycles, element, error, error, marker,...
    'MarkerFaceColor',colour,...
    'DisplayName', 'Measured Points',...
    'CapSize',0,...
    'DisplayName', label);

e.Color = colour;

xlabel('Cycle Number')
ylabel('Counts')

title([label , ': ', beadlabel])

end

