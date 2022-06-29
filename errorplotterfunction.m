function errorplotterfunction(element, error, colour, label, ncycles, beadlabel)

%figure()

e = errorbar(1:ncycles, element, error, error,'-o',...
    'MarkerFaceColor',colour,...
    'DisplayName', 'Measured Points',...
    'CapSize',0,...
    'DisplayName', label);

e.Color = colour;

xlabel('Cycle Number')
ylabel('Counts')

title([label , ': ', beadlabel])

end

