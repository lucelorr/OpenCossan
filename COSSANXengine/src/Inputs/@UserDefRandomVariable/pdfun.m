function Xobj = pdfun(Xobj)
%PDF compute missing parameters (if is possible) of the userdefined
%    distribution

%checks
if ~(isempty(Xobj.Xfunction) || isempty(Xobj.Cpar{1,2}))
    
%proceeds inputs
Xobj.Cpar{1,1}    = 'initial sample';
Xobj.Cpar{2,1}    = 'Mmarkovchains';
Xobj.Cpar{3,1}    = 'Vdeltaxi';

    if isempty(Xobj.Vtails)
        Xobj.Vtails = [.1 .9];
    end
    if isempty(Xobj.Cpar{2,2})
        Xobj.Cpar{1,2}=1000;
    end
    if isempty(Xobj.Cpar{3,2})
        Xobj.Cpar{3,2}=.5;
    end
    
    %% metropolis hastings
    RVvalue=zeros(floor(Xobj.Cpar{1,2})); %arrax containing the data generated by
    % metropolis hastings algorithm
    
    %the first element of arr is the value of the pdf at the point given as an
    %input
    Sname = Xobj.Xfunction.Ctoken{1}{1};
    x1=Xobj.Cpar{1,2}; %initial sample
    eval([Sname '=Parameter(''value'' ,x1);']);  %creates a parameter (that can be used as an input of the pdf function)
    eval(['Xin = Input(''Xparameter'',' Sname ');']); %the parameter is added to an input
    formerPDFvalue=evaluate(Xobj.Xfunction,Xin);
    
    
    for i=2:Xobj.Cpar{2,2}
        
        
        x2=unifrnd(x1-Xobj.Cpar{3,2},x1+Xobj.Cpar{3,2});
        
        %    Sname = Xfun.Ctoken{1}{1};
        %    eval([Sname '= Parameter(''value'',[' num2str(XStochasticProcess.time,'%e,') ']);']);
        
        
        eval([Sname '=Parameter(''value'' ,x2);']);  %creates a parameter (that can be used as an input of the pdf function)
        eval(['Xin = Input(''Xparameter'',' Sname ');']); %the parameter is added to an input
        
        candidatePDFvalue = evaluate(Xobj.Xfunction,Xin);
        
        a=min([candidatePDFvalue(1)/formerPDFvalue(1) 1]);
        b=unifrnd(0,1);
        if a>b
            RVvalue(i)=x2;
            x1=x2;
        else
            RVvalue(i)=x1;
        end
        
    end
    Xobj.Vdata=RVvalue;
    
    
    
    %% build the piecwisedistribution
    try
        Xobj.empirical_distribution = paretotails(Xobj.Vdata, min([Xobj.Vtails]),max([Xobj.Vtails]));
    catch ME
        error('openCOSSAN:UserDefRandomVariable:pdfun',ME.message);
    end
    
    
    
    %% approximate the mean and std
    Xobj.mean = mean(Xobj.Vdata);
    Xobj.std  = std(Xobj.Vdata);
    
    
    
    
elseif size(Xobj.Vdata,2) ==2        %the userdefrv is created with an array containing values of the cdf
    assert(logical(min(Xobj.Vdata(:,2))>=0),...
       'openCOSSAN:UserDefRandomVariable:pdfun',...
       'the value of the pdf must be greater than zero');
    
    fun = @(x)buildcdf2(x,Xobj.Vdata);
    Vcdf = fun(Xobj.Vdata(:,1));
    idxCensored=find(Vcdf==1,2);
    VdataCensored = Xobj.Vdata;
    if ~isempty(idxCensored) && length(idxCensored)>1
        VdataCensored(idxCensored(2):end,:) = [];
    end
    %build the distribution using the function and the points provided by the
    %user
    try
        Xobj.empirical_distribution =  paretotails(VdataCensored(:,1),0,1,fun);
    catch ME
        error('openCOSSAN:UserDefRandomVariable:pdfun',ME.message);
    end
    %generate sample to approximate the characteristics of the distribution
    Vu=random(Xobj.empirical_distribution,1000,1);
    Xobj.mean = mean(Vu);
    Xobj.std  = std(Vu);
    Xobj.lowerBound = min(Xobj.Vdata(:,1));
    Xobj.upperBound = max(Xobj.Vdata(:,1));
else
    error('openCOSSAN:UserDefRandomVariable:pdfun', ...
        'userdefined can be defined only via a pdf function and two parameters (parameter1: point with non-zero probability, parameter2: number of pdf estimations)');
end


end

function [p,xi]= buildcdf2(x1,Vdata)

xi=sort(x1);
s = cumsum(Vdata(:,2));
p=interp1(Vdata(:,1),s/s(end),xi);

end
