%To detect that the user has keyed in appropriate inputs 
% initialising the value 
function [xECG,fsECG,hpECG,lpECG,fsRRI,ampthresh,timethresh,anomalyparam,ampthresh_autodetect,AAR] = init(varargin)

if nargin<2
    error('At least two inputs must be supplied: ''xECG'' and ''fsECG''.')
end

xECG = varargin{1};
fsECG = varargin{2};


if ~isvector(xECG)
  error('''xECG'' must be a vector.')
end

if size(xECG,1) > 1
  xECG = xECG.';
end

if ~isscalar(fsECG)
  error('''fsECG'' must be a scalar.')
end

if (fsECG)<32
  error('The ECG sampling frequency is insufficiently low for analysis (<32 Hz).')
end


if (fsECG)<120
  disp('Warning. The ECG sampling frequency is below the recommended value (<120 Hz).')
end


if ceil(length(xECG)/fsECG)<10
  error('At least 10 s of ECG are required to calculate RRI.')
end


if nargin>2
    inopts = struct(varargin{3:end});
end
parameter_fields = {'hpECG','lpECG','fsRRI','ampthresh','anomalyparam','timethresh','ampthresh_autodetect','AAR'};


% default parameter values
default_params.hpECG = 5;
default_params.lpECG = 20;
default_params.fsRRI = 4;
default_params.ampthresh = 0.5*10^(-3); 
default_params.timethresh = 0.4; 
default_params.anomalyparam = 0.3;
default_params.ampthresh_autodetect = 'Y';
default_params.AAR = 'N'; % areas at risk 
opts = default_params;

if nargin==2
    inopts = default_params;
end

parameters = fieldnames(inopts);

for parameter = parameters'
  if ~any(strcmpi(char(parameter), parameter_fields))
    error(['parameter not recognized: ',char(parameter)])
  end
  if ~isempty(eval(['inopts.',char(parameter)])) 
    eval(['opts.',(char(parameter)),' = inopts.',char(parameter),';'])
  end
end

hpECG = opts.hpECG;
lpECG = opts.lpECG;
fsRRI = opts.fsRRI;
ampthresh = opts.ampthresh;
timethresh = opts.timethresh;
anomalyparam = opts.anomalyparam;
AAR = opts.AAR;
if (any(strcmp(varargin,'ampthresh')))&&(any(strcmp(varargin,'ampthresh_autodetect')))
    %disp('Warning. Parameters ''ampthresh'' and ''ampthresh_autodetect'' have BOTH been selected. Auto-detection of the amplitude threshold has been turned OFF.')
    ampthresh_autodetect = 'N';
elseif (any(strcmp(varargin,'ampthresh')))
    ampthresh_autodetect = 'N';
    %disp('A parameter value for ''ampthresh'' has been selected. Auto-detection of the amplitude threshold has been turned OFF.')
else
    ampthresh_autodetect = opts.ampthresh_autodetect;
end


if ~ischar(ampthresh_autodetect)
  error('''ampthresh_autodetect'' must be a char.')
elseif (~strcmp(ampthresh_autodetect,'Y'))&&(~strcmp(ampthresh_autodetect,'N'))
    error('''ampthresh_autodetect'' must be ''Y'' or ''N'' ')
end

if ~ischar(AAR)
  error('''AAR'' must be a char.')
elseif (~strcmp(upper(AAR),'Y'))&&(~strcmp(upper(AAR),'N'))
    error('''AAR'' must be ''Y'' or ''N'' ')
end
AAR=upper(AAR);

if ~isscalar(lpECG)
  error('lpECG must be a scalar.')
end

if ~isscalar(hpECG)
  error('hpECG must be a scalar.')
end

if ~isscalar(fsRRI)
  error('fsRRI must be a scalar.')
end

if ~isscalar(ampthresh)
  error('ampthresh must be a scalar.')
end

if ~isscalar(timethresh)
  error('timethresh must be a scalar.')
end

if ~isscalar(anomalyparam)
  error('anomalyparam must be a scalar.')
end
end 
