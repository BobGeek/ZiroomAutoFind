%% ������������ȡ������ҳ�������������ݵ�״̬�仯
% 
% ���ߣ�Bob_Geek
% ʱ�䣺20171220


%% ���õĲ���
searchurl = 'http://www.ziroom.com/z/nl/z2-o1.html?qwd=';	%���ҵ� url
keyword = [{'�ѻ���'},{'����Ҥ'},{'�μ�ׯ'},{'��۹���'}];      %�ؼ���
pricemax = 2500;                                            %���۸�
pricemin = 1000;                                            %��С�۸�
mailto = [];                                                %��������  �����ʼ�����������
% mailto = 'wangpeng214@126.com';                             %��������  �����ʼ�����������
mailfrom = 'wangpeng214@126.com';                           %��������
mailpass = '123456789';                                   %������������
times = 1000;                                               %ѭ��ˢ�´���


%% ��ѭ��
while times > 0
    disp([datestr(now,'yyyy-mm-dd HH:MM:SS'),'--ѭ����ʣ',num2str(times),'��']);
    for keywordind = 1: length(keyword);
        lookforhome(keyword{keywordind},searchurl,pricemax,pricemin,mailto,mailfrom,mailpass); % �����Ĺؼ���
        pause(10)
    end
    times = times - 1;
end

