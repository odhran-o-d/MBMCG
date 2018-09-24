function indicator = displayperSteps(time, steps, num_figs)

if mod(time, steps/num_figs) < 0.99
    indicator = true;
else
    indicator = false;
end

end