

% NOTE: not for new design
% NOTE: replacement for Dahlia class for legacy code


classdef Ammeter2 < Dahlia

    methods
        function obj = Ammeter2(com_port)
            msgbox(["Legacy code:"; "use Dahlia class instead of Ammeter2"])
            warning('Legacy code: use Dahlia class instead of Ammeter2')
            obj@Dahlia(com_port);
        end
    end

end