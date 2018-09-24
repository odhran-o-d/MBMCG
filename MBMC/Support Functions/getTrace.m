function [trace] = getTrace(postSynaptic_fr, postSynaptic_trace, eta)

trace = ((1-eta)*postSynaptic_fr) + eta*postSynaptic_trace;
end