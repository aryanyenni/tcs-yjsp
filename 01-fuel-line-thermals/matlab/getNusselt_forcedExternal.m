% getNusselt_forcedExternal.m
%
% Owner: Aryan Yenni
% Org: Yellow Jacket Space Program
% Program: Elytra Vehicle Program
% DO NOT DISTRIBUTE



%% Nusselt Number Calculator

% =======================================================================
% Workflow
%     1) Know your film temperature. T_film = (T_s + T_inf)/2
% 
%     2) Fluid Properties
% 
%        Open the fluid properties lookup table provided for air, or
%        find one for your specific fluid.
%
%        Provide the following fluid properties upon function call (rho,
%        mu, k, cp, u, T_inf). Properties must be evaluated at film temp.
%
%     2) Material / Surface Properties
% 
%        Find material properties and surface values (k, L, T_s) (at film
%        temp. if a temperature function) to provide upon function call.
%
%     3) Provide a valid geometry (geo).
%
%     4) Attain Nu and h, please validate externally or with experiment.
%
% 
% Inputs
%    geo    : geometry type - e.g. 'flat_plate', 'cylinder_crossflow',
%                                  'sphere'
%    rho    : fluid density                             {kg/m^3}
%    mu     : fluid dynamic viscosity                   {Pa*s}
%    k      : fluid thermal conductivity                {W/(m*K)}
%    cp     : fluid specific heat (constant pressure)   {J/(kg*K)}
%    L      : characteristic length                     {m}
%    u      : bulk fluid velocity                       {m/s}
%    T_s    : surface temperature                       {K}
%    T_inf  : freestream temperature                    {K}
%    
% 
% Outputs
%    Nu     : Nusselt number                            {~}
%    h      : convective heat transfer coefficient      {W/(m^2*K)}
%
% 
% Assumptions:
% - Incompressible flow
% - Steady State
% - Properties evaluated at film temperature
% - Hydrodynamically and thermally fully developed
% - Properties provided by user from tables (Cengel appendix or equivalent)
%   in proper units
%   
% 
% Theory provided at the end.
% =======================================================================

function [Nu, h] = getNusselt_forcedExternal(geo, rho, mu, k, cp, L, u,...
                                             T_s, T_inf)


    % ===================================================================
    % Derived Values
    T_film = (T_s + T_inf)/2;   % {K} Film temperature
    Re = rho*u*L/mu;            % {~} Reynolds Number
    Pr = mu*cp/k;               % {~} Prandtl Number
        
    % ===================================================================
    
    
    switch geo
        
        case 'flat_plate'
            if Re < 5*(10^5) % Laminar
                Nu = 0.664 * Re^(1/2) * Pr^(1/3);
                % Average Nusselt number for laminar flow

            elseif Re > 5*(10^5) && Re < 10^7 % Mixed laminar-turbulent
                Nu = (0.037 * Re^(4/5) - 871) * Pr^(1/3);

            end
        
        case 'cylinder_crossflow' % Churchill-Bernstein Relation
            Nu = 0.3 + (0.62 * Re^0.5 * Pr^(1/3)) /...
                 (1 + (0.4/Pr)^(2/3))^(1/4) *...
                 (1 + (Re/28200)^(5/8))^(4/5);
            % Valid for all Re.
    
        case 'sphere'
            if Re < 1800 % Faeth Correlation
                Nu = 2 + (0.555*Re^(1/2)*Pr^(1/3))/...
                     (1 + 1.232/(Re*Pr^(4/3)))^(1/2);
            else % Whitaker Correlation
                Nu = 2 + (0.4*Re^0.5 + 0.6*Re^(2/3) * Pr^0.4);
                % mu_s (viscosity @ T_s) needed for correction
                % Placeholder: assumes mu_s = mu (use mu_s if needed)
            end

    
        otherwise
            
            error('Unknown geometry for forcedExternal(); %s', geo);
    
    end
    
    % ===================================================================

    
    h = Nu*k / L;
    
    fprintf('\n---- Results ----\n');
    fprintf('T_film : %.2f      K\n',       T_film);
    fprintf('Re     : %.2f\n',         Re);
    fprintf('Pr     : %.4f\n',         Pr);
    fprintf('Nu     : %.4f\n',         Nu);
    fprintf('h      : %.4f     W/m^2*K\n\n', h);

end



%% Theory / Documentation

% =======================================================================
% 
% 
% 
% 
% 
% 
% 
