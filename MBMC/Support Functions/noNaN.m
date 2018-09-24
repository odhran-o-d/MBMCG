function synapses = noNaN(synapses)

    synapses(isnan(synapses)) = 0;

end