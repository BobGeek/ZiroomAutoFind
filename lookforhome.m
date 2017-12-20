function lookforhome(keyword,searchurl,pricemax,pricemin,mailto,mailfrom,mailpass)
%% 刷房子主函数

if nargin < 7
	msg = '输入参数不足，请使用正确的调用方法';
    error(msg);
end

url = [searchurl,keyword];
try
    load('roomtable.mat');
catch
    roomtable = [{'网址'},{'名称'},{'价格'},{'入选图片状态'},{'入选房屋状态'},{'入选时间'},{'更新图片状态'},{'更新房屋状态'},{'更新时间'}];
end


urltext = urlread(url);
startexp = '<li class="clearfix">';
id = regexp(urltext,startexp);
for i = 1 : length(id)
    endexp = '</li>';
    thistext = urltext(id(i):end);
    thisend = regexp(thistext,endexp,'ONCE');
    thistext(thisend(1):end) = [];

    % 找url
    expstart = 'www.ziroom.com/z/vr/';
    roomurlstart = regexp(thistext,expstart);
    expend ='html"><img';
    roomurlend =regexp(thistext,expend,'ONCE');
    roomurl = thistext(roomurlstart(1):roomurlend(1)+3);

    % 找图片状态
    picstatestart = regexp(thistext,'defaultPZZ');
    picstateend = regexp(thistext,'.jpg');
    if isempty(picstatestart)
        roomstate = 'Realhomepicture';
    else
        roomstate = thistext(picstatestart(1)+11:picstateend(2)-1);
    end

    % 找名字 
    namestart = regexp(thistext,'html" class="t1">');
    nameend = regexp(thistext,'</a></h3>');
    roomname = thistext(namestart(1)+17:nameend(1)-1);

    % 找价格
    pricestart = regexp(thistext,'￥');
    roomprice = thistext(pricestart:pricestart+6);
    numprice = str2num(roomprice(2:end));
    if (numprice >pricemax) || (numprice < pricemin)
        continue
    end

    % 更新时间
    lastupdate = datestr(now,'yyyy-mm-dd HH:MM:SS');     

    % 找房屋状态
    webstate = currentwebstate(roomurl);

    % 表格序列
    roomid = ismember(roomtable(:,1),roomurl);

    if ~sum(roomid)
        tellme([{'新房源：'},{roomname},roomurl(21:end),{roomprice},{roomstate},{webstate},{lastupdate}],mailto,mailfrom,mailpass)
        roomtable(end+1,:) = [{roomurl},{roomname},{roomprice},{roomstate},{webstate},{lastupdate},{''},{''},{''}];
        save('roomtable.mat','roomtable');
    else
        if (~ismember(roomtable(roomid,5),webstate)) && (~ismember(roomtable(roomid,8),webstate))
            roomtable(roomid,7) = {roomstate};
            roomtable(roomid,8) = {webstate};
            roomtable(roomid,9) = {lastupdate};
            save('roomtable.mat','roomtable');
            tellme([{'状态改变：'},roomname,roomurl(21:end),{'从'},roomtable(roomid,5),'改变到',roomstate,roomstate,roomprice,webstate,lastupdate],mailto,mailfrom,mailpass)
        end
    end
end

save('roomtable.mat','roomtable');

end



function tellme(str,mailto,mailfrom,mailpass)

    if iscell(str)
        subject = [];
        for i = 1 : length(str)
            subject = [subject,'-',str{i}];
        end
        content = ['看附件！'];
    else
        subject = str;
        content = str;
    end
    disp(subject)
    if (isempty(mailto))||(isempty(mailfrom))||(isempty(mailpass))
        return
    end

    % 生成统计表
    load('roomtable.mat')
    filename = 'roomtable.csv';
    B = cell2table(roomtable,'VariableNames',[{'webaddress'},{'name'},{'price'},{'style'},{'webstate'},{'addtime'},{'updatestyle'},{'updatewebstate'},{'lastupdatetime'}]);
    writetable(B,filename,'WriteRowNames',true);




% 发邮件
ind = find( mailfrom == '@', 1);
SMTP_Server = ['smtp.',mailfrom(ind+1:end)];

try
    setpref('Internet','SMTP_Server',SMTP_Server);
    setpref('Internet','E_mail',mailfrom);
    setpref('Internet','SMTP_Username',mailfrom);
    setpref('Internet','SMTP_Password',mailpass);
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    sendmail(mailto, subject, content, filename)
catch
    error('邮件发送失败！');
end
end


function roomstate = currentwebstate(roomurl)
    
    webtext = urlread(['http://',roomurl]);
    Statestart = regexp(webtext,'room_btns clearfix','ONCE');
    Stateend = regexp(webtext(Statestart:end),'</div>','ONCE');
    scantext = webtext(Statestart:Statestart + Stateend);
    
    
    if regexp(scantext,'title="配置中"','ONCE')
        if regexp(scantext,'</span>预订','ONCE')
            roomstate = '配置中-可预订';
        else
            roomstate = '配置中';
        end
        return
    end
    
    if regexp(scantext,'已下定','ONCE')
        roomstate = '已下定';
        return
    end
    if regexp(scantext,'已出租','ONCE')
        roomstate = '已出租';
        return
    end
    if regexp(scantext,'id="zreserve" ><span class="icon"></span>我要看房</a>','ONCE')
        roomstate = '可签约';
        return
    end
    
    start1 = regexp(scantext,'>','ONCE');
    start2 = regexp(scantext,'<!--是否是配置中可预订-->','ONCE');
    roomstate = strtrim(scantext(start1+1:start2-1));
    start1 = regexp(roomstate,'可签约','ONCE');
    if ~isempty(start1)
        roomstate = roomstate(start1-5:start1+2);
    end 
end