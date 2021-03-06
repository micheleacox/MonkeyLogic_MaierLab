function AdaptorInfo = ioscan(adaptors)
%
% created by WA, July, 2006
% Modified 2/1/07 (bug in digitalio assignments fixed) --WA
% Modified 1/4/08 (improved error handling) --WA

if ~iscell(adaptors),
    adaptors = {adaptors};
end
totalboards = 0;
AdaptorInfo(1:length(adaptors)) = struct;
for adaptornum = 1:length(adaptors),
    clear adapinfo
    try
        adapinfo = daqhwinfo(adaptors{adaptornum});
    catch
        adapinfo.InstalledBoardIds = '';
    end
    if isempty(adapinfo.InstalledBoardIds),
        totalboards = totalboards + 1;
        AdaptorInfo(totalboards).Name = sprintf('%s (Not Connected)', adaptors{adaptornum});
        AdaptorInfo(totalboards).SubSystemsConstructors = {''};
        AdaptorInfo(totalboards).SubSystemsNames = {''};
        AdaptorInfo(totalboards).AvailableChannels = {[]};
        AdaptorInfo(totalboards).AvailablePorts = {[]};
        AdaptorInfo(totalboards).AvailableLines = {[]};
        AdaptorInfo(totalboards).SampleRate = 0;
        AdaptorInfo(totalboards).MaxSampleRate = 0;
        AdaptorInfo(totalboards).MinSampleRate = 0;
    else
        numboards = length(adapinfo.InstalledBoardIds);
        for bnum = 1:numboards,
            totalboards = totalboards + 1;
            AdaptorInfo(totalboards).Name = sprintf('%s: %s', adaptors{adaptornum}, adapinfo.BoardNames{bnum});
            allobconstructors = adapinfo.ObjectConstructorName(bnum, :);
            obconstructors = {};
            for csnum = 1:length(allobconstructors),
                if ~isempty(allobconstructors{csnum}),
                    obconstructors = cat(1, obconstructors, allobconstructors(csnum));
                end
            end
            cnt = 0;
            if ~isempty(obconstructors),
                for subsysnum = 1:length(obconstructors),
                    cname = obconstructors{subsysnum};
                    if ~isempty(cname),
                        cnt = cnt + 1;
                        AdaptorInfo(totalboards).SubSystemsConstructors{cnt} = cname;
                        sigch = eval(AdaptorInfo(totalboards).SubSystemsConstructors{cnt});
                        sigch_info = daqhwinfo(sigch);
                        AdaptorInfo(totalboards).SubSystemsNames{cnt} = sigch_info.SubsystemType;
                        if isfield(sigch_info, 'SingleEndedIDs'),
                            AdaptorInfo(totalboards).AvailableChannels{cnt} = sigch_info.SingleEndedIDs';
                            AdaptorInfo(totalboards).AvailablePorts{cnt} = [];
                        elseif isfield(sigch_info, 'ChannelIDs'),
                            AdaptorInfo(totalboards).AvailableChannels{cnt} = sigch_info.ChannelIDs';
                            AdaptorInfo(totalboards).AvailablePorts{cnt} = [];
                        elseif isfield(sigch_info, 'TotalChannels'),
                            AdaptorInfo(totalboards).AvailableChannels{cnt} = (1:sigch_info.TotalChannels)';
                            AdaptorInfo(totalboards).AvailablePorts{cnt} = [];
                        else %digital
                            AdaptorInfo(totalboards).AvailableChannels{cnt} = [];
                            port_info = sigch_info.Port;
                            AdaptorInfo(totalboards).AvailablePorts{cnt} = cat(2, port_info.ID);
                            AdaptorInfo(totalboards).AvailableLines{cnt} = {port_info.LineIDs};
                        end
                        try
                            AdaptorInfo(totalboards).MaxSampleRate(cnt) = sigch_info.MaxSampleRate;
                            AdaptorInfo(totalboards).MinSampleRate(cnt) = sigch_info.MinSampleRate;
                            AdaptorInfo(totalboards).SampleRate(cnt) = AdaptorInfo(bnum).MaxSampleRate(cnt);
                        catch
                            AdaptorInfo(totalboards).SampleRate(cnt) = NaN; %if digitalio
                            AdaptorInfo(totalboards).MaxSampleRate(cnt) = NaN;
                            AdaptorInfo(totalboards).MinSampleRate(cnt) = NaN;
                        end
                        delete(sigch);
                        clear sigch;
                    end
                end
            else
                AdaptorInfo(totalboards).Name = sprintf('%s (Not Supported)', adaptors{adaptornum});
                AdaptorInfo(totalboards).SubSystemsConstructors = {''};
                AdaptorInfo(totalboards).SubSystemsNames = {''};
                AdaptorInfo(totalboards).AvailableChannels = {[]};
                AdaptorInfo(totalboards).AvailablePorts = {[]};
                AdaptorInfo(totalboards).AvailableLines = {[]};
                AdaptorInfo(totalboards).SampleRate = 0;
                AdaptorInfo(totalboards).MaxSampleRate = 0;
                AdaptorInfo(totalboards).MinSampleRate = 0;
            end
        end
    end
end
AdaptorInfo = AdaptorInfo(1:totalboards);

