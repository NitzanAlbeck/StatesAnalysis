classdef wakeAnalysis < sleepAnalysis
    properties
       
    end
    
    methods
        %% class constructor
        function obj=wakeAnalysis(xlsFile)
           
           obj=obj@sleepAnalysis(xlsFile);
        end
        
        %% Spectrogam - under construction
        % this method is made to show the spectrogrm for the waking time
        
        % what sould it do?
        %  - get the recorded signal
        %  - get the channel from the table
        %  - load the sleep time from the relevant analysis (i think it was D2BAC)
        %  - take the data in the specific timing and do the spectrogram. 
        %  - save the mat file
        %
        
        function obj = getSpectrogram(obj, varargin)
            
            % needs the out of the DBAC analysis
            
            %checking that there is a current rec:
            obj.checkFileRecording;
            
            % used in Mark's functions. create a parser for the inputs and
            % results.
            
            parseObj = inputParser;
            addParameter(parseObj,'ch',obj.recTable.defaulLFPCh(obj.currentPRec),@isnumeric);
            addParameter(parseObj,'win',1000,@isnumeric);
            addParameter(parseObj,'tStart',0,@isnumeric);
            %addParameter(parseObj,'overwrite',0,@isnumeric);       
            addParameter(parseObj,'inputParams',false,@isnumeric);
            parseObj.parse(varargin{:});
            
            if parseObj.Results.inputParams
                disp(parseObj.Results);
                return;
            end
            
            %evaluate all input parameters in workspace - don't know what
            %it does.
            
            for i=1:numel(parseObj.Parameters)
                eval([parseObj.Parameters{i} '=' 'parseObj.Results.(parseObj.Parameters{i});']);
            end
            
            %make parameter structure
            parSpectrogram=parseObj.Results;

            
            % get the wake time:
            % load the output of DB autocor, that holds the param for sleep
            % times
            DBAutocorFile=[obj.currentAnalysisFolder filesep 'dbAutocorr_ch' num2str(ch) '.mat'];
            load(DBAutocorFile)
            
            % get the signal
            signal = obj.currentDataObj.getData(ch, tStart,1000000);
            %get the spectro
            [s] = spectrogram (signal, win);
            figure;
            plot (s)
            
        end
    end
end