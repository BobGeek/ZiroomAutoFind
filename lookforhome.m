function lookforhome(keyword,searchurl,pricemax,pricemin,mailto,mailfrom,mailpass)
%% ˢ����������

if nargin < 7
	msg = '����������㣬��ʹ����ȷ�ĵ��÷���';
    error(msg);
end

url = [searchurl,keyword];
try
    load('roomtable.mat');
catch
    roomtable = [{'��ַ'},{'����'},{'�۸�'},{'��ѡͼƬ״̬'},{'��ѡ����״̬'},{'��ѡʱ��'},{'����ͼƬ״̬'},{'���·���״̬'},{'����ʱ��'}];
end


urltext = urlread(url);
startexp = '<li class="clearfix">';
id = regexp(urltext,startexp);
for i = 1 : length(id)
    endexp = '</li>';
    thistext = urltext(id(i):end);
    thisend = regexp(thistext,endexp,'ONCE');
    thistext(thisend(1):end) = [];

    % ��url
    expstart = 'www.ziroom.com/z/vr/';
    roomurlstart = regexp(thistext,expstart);
    expend ='html"><img';
    roomurlend =regexp(thistext,expend,'ONCE');
    roomurl = thistext(roomurlstart(1):roomurlend(1)+3);

    % ��ͼƬ״̬
    picstatestart = regexp(thistext,'defaultPZZ');
    picstateend = regexp(thistext,'.jpg');
    if isempty(picstatestart)
        roomstate = 'Realhomepicture';
    else
        roomstate = thistext(picstatestart(1)+11:picstateend(2)-1);
    end

    % ������ 
    namestart = regexp(thistext,'html" class="t1">');
    nameend = regexp(thistext,'</a></h3>');
    roomname = thistext(namestart(1)+17:nameend(1)-1);

    % �Ҽ۸�
    pricestart = regexp(thistext,'��');
    roomprice = thistext(pricestart:pricestart+6);
    numprice = str2num(roomprice(2:end));
    if (numprice >pricemax) || (numprice < pricemin)
        continue
    end

    % ����ʱ��
    lastupdate = datestr(now,'yyyy-mm-dd HH:MM:SS');     

    % �ҷ���״̬
    webstate = currentwebstate(roomurl);

    % �������
    roomid = ismember(roomtable(:,1),roomurl);

    if ~sum(roomid)
        tellme([{'�·�Դ��'},{roomname},roomurl(21:end),{roomprice},{roomstate},{webstate},{lastupdate}],mailto,mailfrom,mailpass)
        roomtable(end+1,:) = [{roomurl},{roomname},{roomprice},{roomstate},{webstate},{lastupdate},{''},{''},{''}];
        save('roomtable.mat','roomtable');
    else
        if (~ismember(roomtable(roomid,5),webstate)) && (~ismember(roomtable(roomid,8),webstate))
            roomtable(roomid,7) = {roomstate};
            roomtable(roomid,8) = {webstate};
            roomtable(roomid,9) = {lastupdate};
            save('roomtable.mat','roomtable');
            tellme([{'״̬�ı䣺'},roomname,roomurl(21:end),{'��'},roomtable(roomid,5),'�ı䵽',roomstate,roomstate,roomprice,webstate,lastupdate],mailto,mailfrom,mailpass)
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
        content = ['��������'];
    else
        subject = str;
        content = str;
    end
    disp(subject)
    if (isempty(mailto))||(isempty(mailfrom))||(isempty(mailpass))
        return
    end

    % ����ͳ�Ʊ�
    load('roomtable.mat')
    filename = 'roomtable.csv';
    B = cell2table(roomtable,'VariableNames',[{'webaddress'},{'name'},{'price'},{'style'},{'webstate'},{'addtime'},{'updatestyle'},{'updatewebstate'},{'lastupdatetime'}]);
    writetable(B,filename,'WriteRowNames',true);




% ���ʼ�
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
    error('�ʼ�����ʧ�ܣ�');
end
end


function roomstate = currentwebstate(roomurl)
    
    webtext = urlread(['http://',roomurl]);
    Statestart = regexp(webtext,'room_btns clearfix','ONCE');
    Stateend = regexp(webtext(Statestart:end),'</div>','ONCE');
    scantext = webtext(Statestart:Statestart + Stateend);
    
    
    if regexp(scantext,'title="������"','ONCE')
        if regexp(scantext,'</span>Ԥ��','ONCE')
            roomstate = '������-��Ԥ��';
        else
            roomstate = '������';
        end
        return
    end
    
    if regexp(scantext,'���¶�','ONCE')
        roomstate = '���¶�';
        return
    end
    if regexp(scantext,'�ѳ���','ONCE')
        roomstate = '�ѳ���';
        return
    end
    if regexp(scantext,'id="zreserve" ><span class="icon"></span>��Ҫ����</a>','ONCE')
        roomstate = '��ǩԼ';
        return
    end
    
    start1 = regexp(scantext,'>','ONCE');
    start2 = regexp(scantext,'<!--�Ƿ��������п�Ԥ��-->','ONCE');
    roomstate = strtrim(scantext(start1+1:start2-1));
    start1 = regexp(roomstate,'��ǩԼ','ONCE');
    if ~isempty(start1)
        roomstate = roomstate(start1-5:start1+2);
    end 
end